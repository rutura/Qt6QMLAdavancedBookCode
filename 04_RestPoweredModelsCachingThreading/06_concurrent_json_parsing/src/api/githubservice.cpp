#include "githubservice.h"
#include "repository.h"     // NEW
#include "cachemanager.h"     // NEW
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QNetworkRequest>
#include <QDebug>

GitHubService::GitHubService(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
{
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
    Q_UNUSED(etag);
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

    // NEW: fire a cache lookup in parallel with the network request.
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

    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("requestType", "searchRepositoriesPage");
    reply->setProperty("page", page);

    connect(reply, &QNetworkReply::finished, this, &GitHubService::onSearchResultsPageReceived);
    connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::errorOccurred),
            this, &GitHubService::onRequestFailed);
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

void GitHubService::onSearchResultsPageReceived()
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

    /*
    const int page = reply->property("page").toInt();
    const QByteArray data = reply->readAll();
    reply->deleteLater();
    */
    const int page = reply->property("page").toInt();
    const QString cacheKey = reply->url().toString();
    const QByteArray etag = reply->rawHeader("ETag");
    const QByteArray data = reply->readAll();
    reply->deleteLater();

    // NEW: persist this fresh response for next time.
    if (m_cache && !data.isEmpty()) {
        m_cache->requestSave(cacheKey, data, etag);
    }


    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);
    if (parseError.error != QJsonParseError::NoError || !doc.isObject()) {
        setErrorMessage("JSON parse error on paged search response");
        return;
    }

    const QJsonObject results = doc.object();
    const int totalCount = results.value("total_count").toInt();
    const QJsonArray items = results.value("items").toArray();

    QList<Repository*> typedList;
    typedList.reserve(items.size());
    for (const QJsonValue &value : items) {
        if (value.isObject()) {
            typedList.append(Repository::fromJson(value.toObject(), nullptr));
        }
    }

    emit searchResultsPageReady(typedList, page, totalCount);
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

    if (reply->error() != QNetworkReply::NoError) {
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
    }

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);
    if (parseError.error != QJsonParseError::NoError || !doc.isObject()) {
        setErrorMessage("JSON parse error on cursor search response");
        return;
    }

    const QJsonArray items = doc.object().value("items").toArray();
    QList<Repository*> typedList;
    typedList.reserve(items.size());
    for (const QJsonValue &value : items) {
        if (value.isObject()) {
            typedList.append(Repository::fromJson(value.toObject(), nullptr));
        }
    }

    emit searchResultsCursorReady(typedList, nextUrl, isFirstPage);
}

void GitHubService::onRequestFailed(QNetworkReply::NetworkError error)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    setIsLoading(false);

    QString errorMsg;
    switch (error) {
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
