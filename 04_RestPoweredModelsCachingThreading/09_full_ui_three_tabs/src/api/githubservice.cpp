#include "githubservice.h"
#include "repository.h"
#include "cachemanager.h"
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QNetworkRequest>
#include <QDebug>
#include <QElapsedTimer>
#include <QtConcurrent>
#include <QFutureWatcher>

GitHubService::GitHubService(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
{
}

void GitHubService::beginParse()
{
    if (m_inflightParses++ == 0)
        emit isParsingChanged();
}

void GitHubService::endParse()
{
    if (--m_inflightParses == 0)
        emit isParsingChanged();
}

void GitHubService::updateRateLimit(QNetworkReply *reply)
{
    bool changed = false;

    const QByteArray remaining = reply->rawHeader("X-RateLimit-Remaining");
    if (!remaining.isEmpty()) {
        m_rateLimitRemaining = remaining.toInt();
        changed = true;
    }
    const QByteArray total = reply->rawHeader("X-RateLimit-Limit");
    if (!total.isEmpty()) {
        m_rateLimitTotal = total.toInt();
        changed = true;
    }
    const QByteArray reset = reply->rawHeader("X-RateLimit-Reset");
    if (!reset.isEmpty()) {
        m_rateLimitReset = QDateTime::fromSecsSinceEpoch(reset.toLongLong());
        changed = true;
    }

    if (changed)
        emit rateLimitChanged();
}

void GitHubService::parseBytesAsync(const QByteArray &body,
                                    std::function<void(const QList<Repository*> &, int)> onParsed)
{
    beginParse();

    auto *watcher = new QFutureWatcher<QList<Repository*>>(this);

    // The shared total-count needs to survive past the lambda that produces the list,
    // so it is captured into a heap cell the watcher owns for its lifetime.
    auto *total = new int(0);

    connect(watcher, &QFutureWatcher<QList<Repository*>>::finished, this,
            [this, watcher, total, onParsed]() {
        const QList<Repository*> repos = watcher->result();
        const int totalCount = *total;
        delete total;
        watcher->deleteLater();
        endParse();
        onParsed(repos, totalCount);
    });

    QFuture<QList<Repository*>> future = QtConcurrent::run([body, total]() {
        QElapsedTimer timer;
        timer.start();
        QList<Repository*> repos = Repository::listFromJsonBytes(body, total);
        qDebug() << "[parse] off-GUI-thread parse of" << body.size()
                 << "bytes ->" << repos.size() << "repos in" << timer.elapsed() << "ms";
        return repos;
    });
    watcher->setFuture(future);
}

void GitHubService::setCache(CacheManager *cache)
{
    if (m_cache == cache) return;
    if (m_cache) m_cache->disconnect(this);
    m_cache = cache;
    if (m_cache) {
        connect(m_cache, &CacheManager::loaded, this, &GitHubService::onCacheLoaded);
    }
}

QList<Repository*> GitHubService::parseSearchItems(const QByteArray &body, int *totalCountOut) const
{
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(body, &parseError);
    QList<Repository*> items;
    if (parseError.error != QJsonParseError::NoError || !doc.isObject())
        return items;

    const QJsonObject root = doc.object();
    if (totalCountOut)
        *totalCountOut = root.value("total_count").toInt();

    const QJsonArray arr = root.value("items").toArray();
    items.reserve(arr.size());
    for (const QJsonValue &v : arr) {
        if (v.isObject())
            items.append(Repository::fromJson(v.toObject(), nullptr));
    }
    return items;
}

void GitHubService::onCacheLoaded(const QString &key, const QByteArray &body, const QByteArray &etag, bool found)
{
    // Remember the ETag so the in-flight request for this URL can attach
    // If-None-Match. The network request was issued before the cache replied,
    // so the conditional header is set there from this same store on the next call.
    if (found && !etag.isEmpty())
        m_etagByUrl.insert(key, etag);

    auto it = m_pendingByKey.find(key);
    if (it == m_pendingByKey.end())
        return;

    const PendingRequest req = it.value();
    m_pendingByKey.erase(it);

    if (!found || body.isEmpty())
        return;

    if (req.kind == RequestKind::Page) {
        int total = 0;
        QList<Repository*> items = parseSearchItems(body, &total);
        if (!items.isEmpty() || total > 0)
            emit cachedPageReady(items, req.page, total);
        else
            qDeleteAll(items);
    } else {
        QList<Repository*> items = parseSearchItems(body);
        if (!items.isEmpty())
            emit cachedCursorReady(items, QString(), req.isFirstPage);
        else
            qDeleteAll(items);
    }
}


void GitHubService::setAuthToken(const QString &token)
{
    if (m_authToken != token) {
        m_authToken = token;
        emit authTokenChanged();
    }
}

void GitHubService::setIsLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged();
    }
}

void GitHubService::setErrorMessage(const QString &message)
{
    if (m_errorMessage != message) {
        m_errorMessage = message;
        emit errorMessageChanged();
    }
}

void GitHubService::fetchUserRepositories(const QString &username)
{
    if (m_isLoading || username.isEmpty()) {
        return;
    }

    setIsLoading(true);
    setErrorMessage(QString());
    clearRepositories();

    QString endpoint = QString("users/%1/repos").arg(username);
    QUrl url(QString("https://api.github.com/%1?sort=updated&per_page=50").arg(endpoint));

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "RepoExplorerPro-Qt");
    request.setRawHeader("Accept", "application/vnd.github+json");

    if (!m_authToken.isEmpty()) {
        request.setRawHeader("Authorization", QString("Bearer %1").arg(m_authToken).toUtf8());
    }

    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("requestType", "userRepositories");

    connect(reply, &QNetworkReply::finished, this, &GitHubService::onUserRepositoriesReceived);
    connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::errorOccurred),
            this, &GitHubService::onRequestFailed);
}



void GitHubService::fetchAuthenticatedUserRepositories()
{
    if (m_isLoading) {
        return;
    }

    setIsLoading(true);
    setErrorMessage(QString());
    clearRepositories();

    QUrl url(QString("https://api.github.com/user/repos?sort=updated&per_page=50&visibility=all"));

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "RepoExplorerPro-Qt");
    request.setRawHeader("Accept", "application/vnd.github+json");

    if (!m_authToken.isEmpty()) {
        request.setRawHeader("Authorization", QString("Bearer %1").arg(m_authToken).toUtf8());
    }

    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("requestType", "userRepositories");

    connect(reply, &QNetworkReply::finished, this, &GitHubService::onUserRepositoriesReceived);
    connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::errorOccurred),
            this, &GitHubService::onRequestFailed);
}

void GitHubService::fetchRepository(const QString &owner, const QString &repo)
{
    if (m_isLoading || owner.isEmpty() || repo.isEmpty()) {
        return;
    }

    setIsLoading(true);
    setErrorMessage(QString());

    QUrl url(QString("https://api.github.com/repos/%1/%2").arg(owner, repo));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "RepoExplorerPro-Qt");
    request.setRawHeader("Accept", "application/vnd.github+json");

    if (!m_authToken.isEmpty()) {
        request.setRawHeader("Authorization", QString("Bearer %1").arg(m_authToken).toUtf8());
    }

    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("requestType", "singleRepository");

    connect(reply, &QNetworkReply::finished, this, &GitHubService::onRepositoryReceived);
    connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::errorOccurred),
            this, &GitHubService::onRequestFailed);
}


void GitHubService::searchRepositories(const QString &query, const QString &sort, const QString &order)
{
    if (m_isLoading || query.isEmpty()) {
        return;
    }

    setIsLoading(true);
    setErrorMessage(QString());
    clearRepositories();

    QUrl url(QString("https://api.github.com/search/repositories?q=%1&sort=%2&order=%3&per_page=50")
                 .arg(query, sort, order));

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "RepoExplorerPro-Qt");
    request.setRawHeader("Accept", "application/vnd.github+json");

    if (!m_authToken.isEmpty()) {
        request.setRawHeader("Authorization", QString("Bearer %1").arg(m_authToken).toUtf8());
    }

    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("requestType", "searchRepositories");

    connect(reply, &QNetworkReply::finished, this, &GitHubService::onSearchResultsReceived);
    connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::errorOccurred),
            this, &GitHubService::onRequestFailed);
}

void GitHubService::searchRepositoriesPage(const QString &query, int page, int perPage,
                                           const QString &sort, const QString &order)
{
    if (m_isLoading || query.isEmpty()) {
        return;
    }

    setIsLoading(true);
    setErrorMessage(QString());

    QUrl url(QString("https://api.github.com/search/repositories?q=%1&sort=%2&order=%3&per_page=%4&page=%5")
                 .arg(query, sort, order)
                 .arg(perPage)
                 .arg(page));

    if (m_cache) {
        const QString key = url.toString();
        m_pendingByKey.insert(key, PendingRequest{ RequestKind::Page, page, false });
        m_cache->requestLoad(key);
    }

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "RepoExplorerPro-Qt");
    request.setRawHeader("Accept", "application/vnd.github+json");

    if (!m_authToken.isEmpty()) {
        request.setRawHeader("Authorization", QString("Bearer %1").arg(m_authToken).toUtf8());
    }

    // m_etagByUrl is seeded by onCacheLoaded from a prior network save (this session
    // or a previous run — cache files are persisted on disk). When present, the
    // conditional request lets GitHub answer 304 and not spend our rate budget on a body.
    const auto etagIt = m_etagByUrl.constFind(url.toString());
    if (etagIt != m_etagByUrl.constEnd() && !etagIt.value().isEmpty()) {
        request.setRawHeader("If-None-Match", etagIt.value());
    }

    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("requestType", "searchRepositoriesPage");
    reply->setProperty("page", page);

    connect(reply, &QNetworkReply::finished, this, &GitHubService::onSearchResultsPageReceived);
    connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::errorOccurred),
            this, &GitHubService::onRequestFailed);
}

void GitHubService::onSearchResultsPageReceived()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) {
        setIsLoading(false);
        setErrorMessage("Invalid response received");
        return;
    }

    setIsLoading(false);
    updateRateLimit(reply);

    if (reply->error() != QNetworkReply::NoError) {
        reply->deleteLater();
        return;
    }

    const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    if (status == 304) {
        // Not Modified: the cached body the model already rendered is still current.
        // No parse, no signal — deliberately no row churn.
        reply->deleteLater();
        return;
    }

    const int page = reply->property("page").toInt();
    const QString cacheKey = reply->url().toString();
    const QByteArray etag = reply->rawHeader("ETag");
    const QByteArray data = reply->readAll();
    reply->deleteLater();

    if (m_cache && !data.isEmpty()) {
        m_cache->requestSave(cacheKey, data, etag);
        if (!etag.isEmpty())
            m_etagByUrl.insert(cacheKey, etag);
    }

    parseBytesAsync(data, [this, page](const QList<Repository*> &repos, int totalCount) {
        if (repos.isEmpty() && totalCount == 0) {
            setErrorMessage("JSON parse error on paged search response");
            return;
        }
        emit searchResultsPageReady(repos, page, totalCount);
    });
}

void GitHubService::searchRepositoriesCursor(const QString &query, int perPage,
                                             const QString &sort, const QString &order)
{
    if (m_isLoading || query.isEmpty()) {
        return;
    }

    setIsLoading(true);
    setErrorMessage(QString());

    QUrl url(QString("https://api.github.com/search/repositories?q=%1&sort=%2&order=%3&per_page=%4&page=1")
                 .arg(query, sort, order)
                 .arg(perPage));

    if (m_cache) {
        const QString key = url.toString();
        m_pendingByKey.insert(key, PendingRequest{ RequestKind::Cursor, 0, true });
        m_cache->requestLoad(key);
    }

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "RepoExplorerPro-Qt");
    request.setRawHeader("Accept", "application/vnd.github+json");

    if (!m_authToken.isEmpty()) {
        request.setRawHeader("Authorization", QString("Bearer %1").arg(m_authToken).toUtf8());
    }

    const auto etagIt = m_etagByUrl.constFind(url.toString());
    if (etagIt != m_etagByUrl.constEnd() && !etagIt.value().isEmpty()) {
        request.setRawHeader("If-None-Match", etagIt.value());
    }

    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("requestType", "searchRepositoriesCursor");
    reply->setProperty("isFirstPage", true);

    connect(reply, &QNetworkReply::finished, this, &GitHubService::onSearchResultsCursorReceived);
    connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::errorOccurred),
            this, &GitHubService::onRequestFailed);
}

void GitHubService::fetchByUrl(const QUrl &url)
{
    if (m_isLoading || !url.isValid()) {
        return;
    }

    setIsLoading(true);
    setErrorMessage(QString());

    if (m_cache) {
        const QString key = url.toString();
        m_pendingByKey.insert(key, PendingRequest{ RequestKind::Cursor, 0, false });
        m_cache->requestLoad(key);
    }

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "RepoExplorerPro-Qt");
    request.setRawHeader("Accept", "application/vnd.github+json");

    if (!m_authToken.isEmpty()) {
        request.setRawHeader("Authorization", QString("Bearer %1").arg(m_authToken).toUtf8());
    }

    const auto etagIt = m_etagByUrl.constFind(url.toString());
    if (etagIt != m_etagByUrl.constEnd() && !etagIt.value().isEmpty()) {
        request.setRawHeader("If-None-Match", etagIt.value());
    }

    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("requestType", "searchRepositoriesCursor");
    reply->setProperty("isFirstPage", false);

    connect(reply, &QNetworkReply::finished, this, &GitHubService::onSearchResultsCursorReceived);
    connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::errorOccurred),
            this, &GitHubService::onRequestFailed);
}

QString GitHubService::parseNextLink(const QByteArray &linkHeader)
{
    // Format: <url>; rel="next", <url>; rel="last", ...
    const QString header = QString::fromUtf8(linkHeader);
    const QStringList parts = header.split(',', Qt::SkipEmptyParts);
    for (const QString &part : parts) {
        const int relIdx = part.indexOf(QStringLiteral("rel=\"next\""));
        if (relIdx < 0) continue;
        const int lt = part.indexOf('<');
        const int gt = part.indexOf('>');
        if (lt >= 0 && gt > lt) {
            return part.mid(lt + 1, gt - lt - 1);
        }
    }
    return {};
}

void GitHubService::onSearchResultsCursorReceived()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) {
        setIsLoading(false);
        setErrorMessage("Invalid response received");
        return;
    }

    setIsLoading(false);
    updateRateLimit(reply);

    if (reply->error() != QNetworkReply::NoError) {
        reply->deleteLater();
        return;
    }

    const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    if (status == 304) {
        reply->deleteLater();
        return;
    }

    const bool isFirstPage = reply->property("isFirstPage").toBool();
    const QByteArray linkHeader = reply->rawHeader("Link");
    const QString nextUrl = parseNextLink(linkHeader);
    const QString cacheKey = reply->url().toString();
    const QByteArray etag = reply->rawHeader("ETag");
    const QByteArray data = reply->readAll();
    reply->deleteLater();

    if (m_cache && !data.isEmpty()) {
        m_cache->requestSave(cacheKey, data, etag);
        if (!etag.isEmpty())
            m_etagByUrl.insert(cacheKey, etag);
    }

    parseBytesAsync(data, [this, nextUrl, isFirstPage](const QList<Repository*> &repos, int totalCount) {
        Q_UNUSED(totalCount);
        emit searchResultsCursorReady(repos, nextUrl, isFirstPage);
    });
}

void GitHubService::clearRepositories()
{
    if (!m_repositories.isEmpty()) {
        m_repositories.clear();
        emit repositoriesChanged();
    }
}

QVariant GitHubService::parseRepositoryJson(const QJsonObject &json)
{
    QVariantMap repo;

    repo["id"] = json["id"].toInt();
    repo["name"] = json["name"].toString();
    repo["fullName"] = json["full_name"].toString();
    repo["description"] = json["description"].toString();
    repo["htmlUrl"] = json["html_url"].toString();
    repo["language"] = json["language"].toString();
    repo["stargazersCount"] = json["stargazers_count"].toInt();
    repo["forksCount"] = json["forks_count"].toInt();
    repo["isPrivate"] = json["private"].toBool();
    repo["updatedAt"] = QDateTime::fromString(json["updated_at"].toString(), Qt::ISODate);

    QJsonObject owner = json["owner"].toObject();
    QVariantMap ownerMap;
    ownerMap["id"] = owner["id"].toInt();
    ownerMap["login"] = owner["login"].toString();
    ownerMap["avatarUrl"] = owner["avatar_url"].toString();
    ownerMap["htmlUrl"] = owner["html_url"].toString();
    ownerMap["type"] = owner["type"].toString();
    repo["owner"] = ownerMap;

    return repo;
}

void GitHubService::onUserRepositoriesReceived()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) {
        setIsLoading(false);
        setErrorMessage("Invalid response received");
        return;
    }

    setIsLoading(false);

    if (reply->error() != QNetworkReply::NoError) {
        reply->deleteLater();
        return;
    }

    QByteArray data = reply->readAll();
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        setErrorMessage(QString("JSON parsing error: %1").arg(parseError.errorString()));
        reply->deleteLater();
        return;
    }

    if (!doc.isArray()) {
        setErrorMessage("Expected JSON array for repository list");
        reply->deleteLater();
        return;
    }

    QJsonArray repositories = doc.array();
    QVariantList repoList;

    for (const QJsonValue &value : repositories) {
        if (value.isObject()) {
            repoList.append(parseRepositoryJson(value.toObject()));
        }
    }

    m_repositories = repoList;
    emit repositoriesChanged();
    reply->deleteLater();
}

void GitHubService::onRepositoryReceived()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) {
        setIsLoading(false);
        setErrorMessage("Invalid response received");
        return;
    }

    setIsLoading(false);

    if (reply->error() != QNetworkReply::NoError) {
        reply->deleteLater();
        return;
    }

    QByteArray data = reply->readAll();
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        setErrorMessage(QString("JSON parsing error: %1").arg(parseError.errorString()));
        reply->deleteLater();
        return;
    }

    if (!doc.isObject()) {
        setErrorMessage("Expected JSON object for repository");
        reply->deleteLater();
        return;
    }

    QVariant repository = parseRepositoryJson(doc.object());
    emit repositoryFetched(repository);
    reply->deleteLater();
}

void GitHubService::onSearchResultsReceived()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) {
        setIsLoading(false);
        setErrorMessage("Invalid response received");
        return;
    }

    setIsLoading(false);

    if (reply->error() != QNetworkReply::NoError) {
        reply->deleteLater();
        return;
    }

    QByteArray data = reply->readAll();
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        setErrorMessage(QString("JSON parsing error: %1").arg(parseError.errorString()));
        reply->deleteLater();
        return;
    }

    if (!doc.isObject()) {
        setErrorMessage("Expected JSON object for search results");
        reply->deleteLater();
        return;
    }

    QJsonObject searchResults = doc.object();
    QJsonArray items = searchResults["items"].toArray();
    QVariantList repoList;
    QList<Repository*> typedList;

    for (const QJsonValue &value : items) {
        if (value.isObject()) {
            const QJsonObject obj = value.toObject();
            repoList.append(parseRepositoryJson(obj));
            typedList.append(Repository::fromJson(obj, nullptr));
        }
    }

    m_repositories = repoList;
    emit repositoriesChanged();
    emit searchResultsReady(typedList);
    reply->deleteLater();
}

void GitHubService::onRequestFailed(QNetworkReply::NetworkError error)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    setIsLoading(false);

    // GitHub returns {"message": "...", "documentation_url": "..."} in the response
    // body even for error status codes (403, 429, etc.), so prefer that over generic Qt descriptions.
    QString githubMessage;
    if (reply) {
        const QByteArray body = reply->readAll();
        const QJsonDocument doc = QJsonDocument::fromJson(body);
        if (doc.isObject())
            githubMessage = doc.object()["message"].toString();
    }

    QString errorMsg;
    if (!githubMessage.isEmpty()) {
        errorMsg = githubMessage;
    } else switch (error) {
    case QNetworkReply::AuthenticationRequiredError:
        errorMsg = "Authentication required. Please check your token.";
        break;
    case QNetworkReply::ContentNotFoundError:
        errorMsg = "Repository or user not found.";
        break;
    case QNetworkReply::TimeoutError:
        errorMsg = "Request timed out. Please try again.";
        break;
    case QNetworkReply::HostNotFoundError:
        errorMsg = "Unable to connect to GitHub API.";
        break;
    default:
        errorMsg = QString("Network error occurred: %1").arg(static_cast<int>(error));
        break;
    }

    setErrorMessage(errorMsg);
    qWarning() << "GitHub API request failed:" << errorMsg;

    if (reply) {
        reply->deleteLater();
    }
}
