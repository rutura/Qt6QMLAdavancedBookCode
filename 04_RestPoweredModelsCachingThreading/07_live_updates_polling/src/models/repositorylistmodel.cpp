#include "repositorylistmodel.h"
#include "githubservice.h"
#include "repository.h"

#include <QDateTime>     // NEW
#include <QDebug>        // NEW
#include <QTimer>        // NEW
#include <QUrl>          // NEW
#include "cachemanager.h"     // NEW
#include <QQmlEngine>          // NEW


RepositoryListModel::RepositoryListModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_service(new GitHubService(this))
    , m_refreshTimer(new QTimer(this))           // NEW
    , m_clearNewTimer(new QTimer(this))          // NEW
    , m_debugCountdownTimer(new QTimer(this))    // NEW
{
    connect(m_service, &GitHubService::searchResultsPageReady,
            this, &RepositoryListModel::onSearchResultsPageReady);

    connect(m_service, &GitHubService::searchResultsCursorReady,
            this, &RepositoryListModel::onSearchResultsCursorReady);

    // NEW: hand the QML-singleton cache to the service so requests go
    // disk-first, then network. Both responses arrive here as separate signals.
    m_service->setCache(CacheManager::create(nullptr, nullptr));

    connect(m_service, &GitHubService::cachedPageReady,
            this, &RepositoryListModel::onSearchResultsPageReady);
    connect(m_service, &GitHubService::cachedCursorReady,
            this, &RepositoryListModel::onSearchResultsCursorReady);

    // NEW: wire polling timers
    m_refreshTimer->setSingleShot(false);
    connect(m_refreshTimer, &QTimer::timeout, this, &RepositoryListModel::onRefreshTick);

    m_clearNewTimer->setSingleShot(true);
    connect(m_clearNewTimer, &QTimer::timeout, this, &RepositoryListModel::onClearNewFlags);

    // NEW: countdown debug timer — fires every 2s while auto-refresh is on
    m_debugCountdownTimer->setInterval(2000);
    connect(m_debugCountdownTimer, &QTimer::timeout, this, [this]() {
        const int remaining = m_refreshTimer->remainingTime();
        if (remaining < 0) {
            qDebug() << "[poll] auto-refresh ON, waiting for first search to complete";
        } else {
            qDebug() << "[poll] next refresh in" << (remaining / 1000) << "s"
                     << "(interval" << m_refreshIntervalMs / 1000 << "s)"
                     << "| query:" << m_currentQuery;
        }
    });
}

bool RepositoryListModel::hasMore() const
{
    if (m_useCursor)
        return !m_nextUrl.isEmpty();
    return m_repos.size() < m_totalCount;
}

void RepositoryListModel::setUseCursor(bool useCursor)
{
    if (m_useCursor != useCursor) {
        m_useCursor = useCursor;

        // Clear all results and reset every mode-specific counter so offset
        // variables (totalCount, currentPage) and cursor variables (nextUrl)
        // never bleed across modes.
        resetWith({});
        m_currentQuery.clear();
        m_currentPage = 0;
        emit currentPageChanged();
        setTotalCount(0);
        setNextUrl({});

        emit useCursorChanged();
        emit hasMoreChanged();
    }
}

void RepositoryListModel::setPerPage(int perPage)
{
    if (m_perPage != perPage && perPage > 0) {
        m_perPage = perPage;
        emit perPageChanged();
    }
}

void RepositoryListModel::setIsLoadingPage(bool loading)
{
    if (m_isLoadingPage != loading) {
        m_isLoadingPage = loading;
        emit isLoadingPageChanged();
    }
}

void RepositoryListModel::setTotalCount(int total)
{
    if (m_totalCount != total) {
        m_totalCount = total;
        emit totalCountChanged();
    }
}

void RepositoryListModel::setNextUrl(const QString &url)
{
    if (m_nextUrl != url) {
        m_nextUrl = url;
        emit nextUrlChanged();
    }
}

int RepositoryListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_repos.size();
}

QVariant RepositoryListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_repos.size())
        return {};

    const Repository *repo = m_repos.at(index.row());
    switch (role) {
    case IdRole:          return repo->id();
    case NameRole:        return repo->name();
    case FullNameRole:    return repo->fullName();
    case DescriptionRole: return repo->description();
    case StarsRole:       return repo->stargazersCount();
    case ForksRole:       return repo->forksCount();
    case LanguageRole:    return repo->language();
    case UrlRole:         return repo->htmlUrl();
    case IsNewRole:       return m_newIds.contains(repo->id());  // NEW
    default:              return {};
    }
}

QHash<int, QByteArray> RepositoryListModel::roleNames() const
{
    return {
        { IdRole,          "repoId" },
        { NameRole,        "name" },
        { FullNameRole,    "fullName" },
        { DescriptionRole, "description" },
        { StarsRole,       "stargazersCount" },
        { ForksRole,       "forksCount" },
        { LanguageRole,    "language" },
        { UrlRole,         "htmlUrl" },
        { IsNewRole,       "isNew" }   // NEW
    };
}

void RepositoryListModel::search(const QString &query)
{
    if (query.isEmpty() || m_isLoadingPage)
        return;

    // NEW: cancel any in-flight background refresh so the fresh search owns the next result
    m_refreshTimer->stop();
    m_debugCountdownTimer->stop();
    m_isRefreshing = false;
    qDebug() << "[poll] new search started, query:" << query << "| sort:" << m_sortField;

    m_currentQuery = query;
    m_currentPage = 1;
    setNextUrl({});                  // NEW: clear any stale cursor
    emit currentPageChanged();

    setIsLoadingPage(true);
    if (m_useCursor) {
        m_service->searchRepositoriesCursor(query, m_perPage, m_sortField, "desc");  // NEW: pass sortField
    } else {
        m_service->searchRepositoriesPage(query, m_currentPage, m_perPage, m_sortField, "desc");  // NEW: pass sortField
    }

}

void RepositoryListModel::loadMore()
{
    /*
    if (m_isLoadingPage || m_currentQuery.isEmpty() || !hasMore())
        return;
    */
    if (m_isLoadingPage || m_currentQuery.isEmpty() || !hasMore() || m_useCursor)  // CHANGED: + m_useCursor
        return;

    setIsLoadingPage(true);
    const int nextPage = m_currentPage + 1;
    m_service->searchRepositoriesPage(m_currentQuery, nextPage, m_perPage, m_sortField, "desc");  // NEW: pass sortField
}

void RepositoryListModel::fetchNextPage()
{
    if (m_isLoadingPage || !m_useCursor || m_nextUrl.isEmpty())
        return;

    setIsLoadingPage(true);
    m_service->fetchByUrl(QUrl(m_nextUrl));
}

void RepositoryListModel::onSearchResultsPageReady(const QList<Repository*> &repositories, int page, int totalCount)
{
    // NEW: background refresh tick - apply diff instead of full reset
    if (m_isRefreshing && page == 1) {
        qDebug() << "[poll] tick response arrived," << repositories.size()
                 << "repos in page 1, totalCount" << totalCount
                 << "| running applyDiff against" << m_repos.size() << "current rows";
        applyDiff(repositories);
        setTotalCount(totalCount);
        m_isRefreshing = false;
        return;
    }

    setIsLoadingPage(false);
    setTotalCount(totalCount);

    if (page == 1) {
        resetWith(repositories);
        m_currentPage = 1;
    } else {
        appendBatch(repositories);
        m_currentPage = page;
    }
    emit currentPageChanged();
    emit hasMoreChanged();

    // NEW: start the refresh timer after a fresh search lands (not when the search button was clicked)
    if (m_autoRefresh && !m_useCursor && !m_currentQuery.isEmpty()) {
        m_refreshTimer->start(m_refreshIntervalMs);
        m_debugCountdownTimer->start();
        qDebug() << "[poll] refresh timer started, interval" << m_refreshIntervalMs / 1000
                 << "s, first tick in" << m_refreshIntervalMs / 1000 << "s";
    }
}

void RepositoryListModel::onSearchResultsCursorReady(const QList<Repository*> &repositories,
                                                     const QString &nextUrl, bool isFirstPage)
{
    setIsLoadingPage(false);
    setNextUrl(nextUrl);

    if (isFirstPage)
        resetWith(repositories);
    else
        appendBatch(repositories);

    emit hasMoreChanged();
}



void RepositoryListModel::resetWith(const QList<Repository*> &batch)
{
    beginResetModel();
    qDeleteAll(m_repos);
    m_repos.clear();
    m_repos = batch;
    for (Repository *r : m_repos)
        r->setParent(this);
    endResetModel();
    emit countChanged();
}

void RepositoryListModel::appendBatch(const QList<Repository*> &batch)
{
    if (batch.isEmpty())
        return;

    const int first = m_repos.size();
    const int last = first + batch.size() - 1;
    beginInsertRows({}, first, last);
    for (Repository *r : batch) {
        r->setParent(this);
        m_repos.append(r);
    }
    endInsertRows();
    emit countChanged();
}

// NEW: turn background polling on or off
void RepositoryListModel::setAutoRefresh(bool autoRefresh)
{
    if (m_autoRefresh == autoRefresh)
        return;
    m_autoRefresh = autoRefresh;
    emit autoRefreshChanged();

    if (m_autoRefresh && !m_useCursor && !m_currentQuery.isEmpty()) {
        m_refreshTimer->start(m_refreshIntervalMs);
        m_debugCountdownTimer->start();
        qDebug() << "[poll] auto-refresh ON, interval" << m_refreshIntervalMs / 1000
                 << "s, query:" << m_currentQuery
                 << "| sort:" << m_sortField;
    } else {
        m_refreshTimer->stop();
        m_debugCountdownTimer->stop();
        if (m_autoRefresh)
            qDebug() << "[poll] auto-refresh ON but no active query yet; timer starts after first search";
        else
            qDebug() << "[poll] auto-refresh OFF";
    }
}

// NEW: set poll interval with a hard floor of 10s
void RepositoryListModel::setRefreshIntervalMs(int intervalMs)
{
    const int clamped = qMax(intervalMs, 10000);
    if (m_refreshIntervalMs == clamped)
        return;
    m_refreshIntervalMs = clamped;
    emit refreshIntervalMsChanged();
    if (m_refreshTimer->isActive())
        m_refreshTimer->setInterval(m_refreshIntervalMs);
    qDebug() << "[poll] interval changed to" << m_refreshIntervalMs / 1000 << "s"
             << (intervalMs < 10000 ? "(clamped from" + QString::number(intervalMs / 1000) + "s to 10s floor)" : QString());
}

// NEW: switch sort axis ("updated" or "stars"; anything else falls back to "stars")
void RepositoryListModel::setSortField(const QString &field)
{
    const QString normalized = (field == QLatin1String("updated") || field == QLatin1String("stars"))
                               ? field : QLatin1String("stars");
    if (m_sortField == normalized)
        return;
    m_sortField = normalized;
    emit sortFieldChanged();
}

// NEW: called by m_refreshTimer on each tick
void RepositoryListModel::onRefreshTick()
{
    if (m_currentQuery.isEmpty()) {
        qDebug() << "[poll] tick skipped: no active query";
        return;
    }
    if (m_isLoadingPage) {
        qDebug() << "[poll] tick skipped: user-initiated load already in flight";
        return;
    }
    if (m_useCursor) {
        qDebug() << "[poll] tick skipped: cursor mode does not support background refresh";
        return;
    }
    if (m_isRefreshing) {
        qDebug() << "[poll] tick skipped: previous tick's response has not arrived yet";
        return;
    }

    m_isRefreshing = true;
    m_lastRefreshAt = QDateTime::currentDateTime();
    emit lastRefreshAtChanged();

    qDebug() << "[poll] tick fired at" << m_lastRefreshAt.toString(Qt::ISODate)
             << "| fetching page 1 for query '" + m_currentQuery + "'"
             << "sort:" << m_sortField;

    // Fetch page 1 silently - no spinner (setIsLoadingPage stays false)
    m_service->searchRepositoriesPage(m_currentQuery, 1, m_perPage, m_sortField, "desc");
}

// NEW: three-pass diff-merge; called when a background tick result arrives
void RepositoryListModel::applyDiff(const QList<Repository *> &incoming)
{
    qDebug() << "[diff] pass 0: model has" << m_repos.size() << "rows, incoming has" << incoming.size() << "repos";
    const int countBefore = m_repos.size();

    // Build current row index (repo id -> row number)
    QHash<int, int> rowById;
    rowById.reserve(m_repos.size());
    for (int i = 0; i < m_repos.size(); ++i)
        rowById.insert(m_repos.at(i)->id(), i);

    // Build incoming lookup (repo id -> object) and id set
    QHash<int, Repository *> incomingById;
    QSet<int> incomingIds;
    incomingById.reserve(incoming.size());
    incomingIds.reserve(incoming.size());
    for (Repository *r : incoming) {
        incomingById.insert(r->id(), r);
        incomingIds.insert(r->id());
    }

    // Pass 1: remove rows absent from the incoming set (backwards, so indices stay valid)
    int removedCount = 0;
    for (int i = m_repos.size() - 1; i >= 0; --i) {
        if (!incomingIds.contains(m_repos.at(i)->id())) {
            qDebug() << "[diff] pass 1: removing row" << i
                     << "id" << m_repos.at(i)->id() << m_repos.at(i)->fullName();
            beginRemoveRows({}, i, i);
            delete m_repos.at(i);
            m_repos.removeAt(i);
            endRemoveRows();
            ++removedCount;
        }
    }
    qDebug() << "[diff] pass 1 done:" << removedCount << "row(s) removed";

    // Rebuild row index after removals
    rowById.clear();
    for (int i = 0; i < m_repos.size(); ++i)
        rowById.insert(m_repos.at(i)->id(), i);

    // Pass 2: update mutable fields for surviving rows (narrow dataChanged signals)
    int updatedCount = 0;
    for (int i = 0; i < m_repos.size(); ++i) {
        Repository *existing = m_repos.at(i);
        Repository *updated = incomingById.value(existing->id(), nullptr);
        if (!updated)
            continue;

        QVector<int> changedRoles;
        if (existing->stargazersCount() != updated->stargazersCount()) {
            existing->setStargazersCount(updated->stargazersCount());
            changedRoles.append(StarsRole);
        }
        if (existing->forksCount() != updated->forksCount()) {
            existing->setForksCount(updated->forksCount());
            changedRoles.append(ForksRole);
        }
        if (existing->description() != updated->description()) {
            existing->setDescription(updated->description());
            changedRoles.append(DescriptionRole);
        }
        if (existing->language() != updated->language()) {
            existing->setLanguage(updated->language());
            changedRoles.append(LanguageRole);
        }
        if (!changedRoles.isEmpty()) {
            qDebug() << "[diff] pass 2: updated row" << i << m_repos.at(i)->fullName()
                     << "| roles changed:" << changedRoles.size();
            emit dataChanged(index(i), index(i), changedRoles);
            ++updatedCount;
        }

        // This incoming object was only used for its data; delete it now.
        delete updated;
        incomingById.remove(existing->id());
    }
    qDebug() << "[diff] pass 2 done:" << updatedCount << "row(s) had field changes";

    // Pass 3: prepend new items (those whose ids still remain in incomingById)
    QList<Repository *> toPrepend;
    for (Repository *r : incoming) {
        if (incomingById.contains(r->id()))
            toPrepend.append(r);
    }

    if (!toPrepend.isEmpty()) {
        qDebug() << "[diff] pass 3: prepending" << toPrepend.size() << "new repo(s):";
        for (const Repository *r : std::as_const(toPrepend))
            qDebug() << "[diff]   +" << r->fullName() << "id" << r->id();

        beginInsertRows({}, 0, toPrepend.size() - 1);
        // Prepend in reverse so toPrepend[0] lands at row 0
        for (int i = toPrepend.size() - 1; i >= 0; --i) {
            Repository *r = toPrepend.at(i);
            r->setParent(this);
            m_repos.prepend(r);
            m_newIds.insert(r->id());
        }
        endInsertRows();

        // Notify QML of the IsNewRole so the highlight lights up immediately
        emit dataChanged(index(0), index(toPrepend.size() - 1), {IsNewRole});

        // Schedule the flag clearance 3s from now (restart if already running)
        m_clearNewTimer->start(3000);
    } else {
        qDebug() << "[diff] pass 3: no new repos to prepend";
    }

    qDebug() << "[diff] done: removed" << (countBefore - m_repos.size() + toPrepend.size())
             << "updated" << updatedCount << "inserted" << toPrepend.size()
             << "| model now has" << m_repos.size() << "rows";

    if (m_repos.size() != countBefore)
        emit countChanged();
}

// NEW: expire the "new" highlight; called by m_clearNewTimer
void RepositoryListModel::onClearNewFlags()
{
    if (m_newIds.isEmpty())
        return;

    qDebug() << "[diff] clearing isNew flag for" << m_newIds.size() << "repo(s)";
    const QSet<int> snapshot = m_newIds;
    m_newIds.clear();

    // Linear scan is fine; the new set is at most a handful of rows.
    for (int i = 0; i < m_repos.size(); ++i) {
        if (snapshot.contains(m_repos.at(i)->id()))
            emit dataChanged(index(i), index(i), {IsNewRole});
    }
}