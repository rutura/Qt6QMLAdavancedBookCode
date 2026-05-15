#include "abstractgithublistmodel.h"
#include "cachemanager.h"

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QCryptographicHash>
#include <QUrl>
#include <QUrlQuery>

static QString cacheKey(const QUrl &url)
{
    return QString::fromLatin1(
        QCryptographicHash::hash(url.toString().toUtf8(), QCryptographicHash::Sha1).toHex());
}

AbstractGitHubListModel::AbstractGitHubListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_cache = CacheManager::create(nullptr, nullptr);

    connect(m_cache, &CacheManager::loaded,
            this, &AbstractGitHubListModel::onCacheLoaded);

    connect(&m_nam, &QNetworkAccessManager::finished,
            this, &AbstractGitHubListModel::onReplyFinished);
}

AbstractGitHubListModel::~AbstractGitHubListModel()
{
    qDeleteAll(m_items);
}

void AbstractGitHubListModel::setAuthToken(const QString &token)
{
    if (m_authToken != token) {
        m_authToken = token;
        emit authTokenChanged();
    }
}

bool AbstractGitHubListModel::hasMore() const
{
    if (usesCursorPagination())
        return !m_nextUrl.isEmpty();
    return m_items.size() < m_totalCount;
}

void AbstractGitHubListModel::search(const QString &query)
{
    if (query.isEmpty() || m_isLoadingPage)
        return;

    m_currentQuery = query;
    m_currentPage = 1;
    m_nextUrl.clear();

    setIsLoadingPage(true);
    setStatus(Status::Loading);

    const QString endpoint = endpointForQuery(query, 1, m_perPage);
    const QUrl url(endpoint);
    const QString key = cacheKey(url);

    m_cacheKeyPending[key] = { 1, true };
    m_cache->requestLoad(key);
}

void AbstractGitHubListModel::loadMore()
{
    if (m_isLoadingPage || m_currentQuery.isEmpty() || !hasMore())
        return;

    setIsLoadingPage(true);

    if (usesCursorPagination()) {
        if (m_nextUrl.isEmpty())
            return;
        fetchUrl(QUrl(m_nextUrl), m_currentPage + 1, false);
    } else {
        const int nextPage = m_currentPage + 1;
        const QString endpoint = endpointForQuery(m_currentQuery, nextPage, m_perPage);
        fetchUrl(QUrl(endpoint), nextPage, false);
    }
}

void AbstractGitHubListModel::onCacheLoaded(const QString &key, const QByteArray &body,
                                             const QByteArray &etag, bool found)
{
    if (!m_cacheKeyPending.contains(key))
        return;

    const PendingRequest req = m_cacheKeyPending.take(key);

    if (found && !body.isEmpty()) {
        if (!etag.isEmpty())
            m_etagByKey.insert(key, etag);
        processResponse(body, req.page, req.isFirstPage, key, etag);
    }

    // Always fire a network request for freshness validation (ETag 304 shortcut if unchanged).
    const QString endpoint = endpointForQuery(m_currentQuery, req.page, m_perPage);
    fetchUrl(QUrl(endpoint), req.page, req.isFirstPage);
}

void AbstractGitHubListModel::fetchUrl(const QUrl &url, int page, bool isFirstPage)
{
    QNetworkRequest req = buildRequest(url);

    const QString key = cacheKey(url);
    if (m_etagByKey.contains(key)) {
        req.setRawHeader("If-None-Match", m_etagByKey.value(key));
    }

    QNetworkReply *reply = m_nam.get(req);
    m_pendingReplies.insert(reply, { page, isFirstPage });
}

QNetworkRequest AbstractGitHubListModel::buildRequest(const QUrl &url) const
{
    QNetworkRequest req(url);
    req.setHeader(QNetworkRequest::UserAgentHeader, "RepoExplorerPro/1.0");
    req.setRawHeader("Accept", "application/vnd.github+json");
    req.setRawHeader("X-GitHub-Api-Version", "2022-11-28");
    if (!m_authToken.isEmpty())
        req.setRawHeader("Authorization", ("Bearer " + m_authToken).toUtf8());
    return req;
}

void AbstractGitHubListModel::onReplyFinished(QNetworkReply *reply)
{
    reply->deleteLater();

    if (!m_pendingReplies.contains(reply))
        return;

    const PendingRequest meta = m_pendingReplies.take(reply);
    const int httpStatus = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    if (reply->error() != QNetworkReply::NoError && httpStatus != 304) {
        setStatus(Status::Error);
        m_errorMessage = reply->errorString();
        emit errorMessageChanged();
        setIsLoadingPage(false);
        return;
    }

    if (httpStatus == 304) {
        // ETag matched — cached data still valid, already served from cache.
        setIsLoadingPage(false);
        setStatus(Status::Idle);
        return;
    }

    const QString key = cacheKey(reply->url());
    const QByteArray etag = reply->rawHeader("ETag");
    if (!etag.isEmpty())
        m_etagByKey.insert(key, etag);

    const QByteArray body = reply->readAll();
    m_cache->requestSave(key, body, etag);

    // Parse cursor/next URL from Link header for cursor-paginated subclasses.
    if (usesCursorPagination()) {
        const QByteArray linkHeader = reply->rawHeader("Link");
        m_nextUrl = parseNextLink(linkHeader);
    }

    processResponse(body, meta.page, meta.isFirstPage, key, etag);
}

void AbstractGitHubListModel::processResponse(const QByteArray &body, int page, bool isFirstPage,
                                               const QString &cacheKey, const QByteArray &etag)
{
    Q_UNUSED(cacheKey)
    Q_UNUSED(etag)

    int totalCount = 0;
    QList<QObject*> parsed = parseItems(body, &totalCount);

    setTotalCount(totalCount);
    setIsLoadingPage(false);
    setStatus(Status::Idle);

    if (isFirstPage || page == 1)
        resetWith(std::move(parsed));
    else
        appendBatch(std::move(parsed));

    emit hasMoreChanged();
}

QString AbstractGitHubListModel::parseNextLink(const QByteArray &linkHeader) const
{
    // Parse Link: <url>; rel="next", <url>; rel="last"
    const QString header = QString::fromUtf8(linkHeader);
    const QStringList parts = header.split(',');
    for (const QString &part : parts) {
        const QStringList segments = part.trimmed().split(';');
        if (segments.size() < 2)
            continue;
        if (segments.at(1).trimmed() == QLatin1String("rel=\"next\"")) {
            QString url = segments.at(0).trimmed();
            if (url.startsWith('<'))
                url = url.mid(1);
            if (url.endsWith('>'))
                url.chop(1);
            return url;
        }
    }
    return {};
}

void AbstractGitHubListModel::setStatus(Status s)
{
    if (m_status != s) {
        m_status = s;
        emit statusChanged();
    }
}

void AbstractGitHubListModel::setIsLoadingPage(bool loading)
{
    if (m_isLoadingPage != loading) {
        m_isLoadingPage = loading;
        emit isLoadingPageChanged();
    }
}

void AbstractGitHubListModel::setTotalCount(int total)
{
    if (m_totalCount != total) {
        m_totalCount = total;
        emit totalCountChanged();
    }
}

void AbstractGitHubListModel::resetWith(QList<QObject*> items)
{
    beginResetModel();
    qDeleteAll(m_items);
    m_items = std::move(items);
    for (QObject *item : m_items)
        item->setParent(this);
    endResetModel();
    emit countChanged();
}

void AbstractGitHubListModel::appendBatch(QList<QObject*> batch)
{
    if (batch.isEmpty())
        return;
    const int first = m_items.size();
    const int last = first + batch.size() - 1;
    beginInsertRows({}, first, last);
    for (QObject *item : batch) {
        item->setParent(this);
        m_items.append(item);
    }
    endInsertRows();
    emit countChanged();
}
