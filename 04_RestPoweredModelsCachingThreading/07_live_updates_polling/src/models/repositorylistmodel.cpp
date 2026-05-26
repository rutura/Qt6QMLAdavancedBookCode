#include "repositorylistmodel.h"
#include "githubservice.h"
#include "repository.h"
#include <QUrl>
#include "cachemanager.h"
#include <QQmlEngine>
#include <QDateTime>
#include <QDebug>
#include <QTimer>
#include <QUrl>


RepositoryListModel::RepositoryListModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_service(new GitHubService(this))
    , m_refreshTimer(new QTimer(this))       // NEW
    , m_clearNewTimer(new QTimer(this))      // NEW
{
    connect(m_service, &GitHubService::searchResultsPageReady,
            this, &RepositoryListModel::onSearchResultsPageReady);

    connect(m_service, &GitHubService::searchResultsCursorReady,
            this, &RepositoryListModel::onSearchResultsCursorReady);

    m_service->setCache(CacheManager::create(nullptr, nullptr));

    connect(m_service, &GitHubService::cachedPageReady,
            this, &RepositoryListModel::onSearchResultsPageReady);
    connect(m_service, &GitHubService::cachedCursorReady,
            this, &RepositoryListModel::onSearchResultsCursorReady);

    // NEW: wire the refresh timer (repeating) and the clearance timer (single-shot)
    m_refreshTimer->setSingleShot(false);
    connect(m_refreshTimer, &QTimer::timeout,
            this, &RepositoryListModel::onRefreshTick);

    m_clearNewTimer->setSingleShot(true);
    connect(m_clearNewTimer, &QTimer::timeout,
            this, &RepositoryListModel::onClearNewFlags);
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

void RepositoryListModel::setAutoRefresh(bool autoRefresh)
{
    if (m_autoRefresh == autoRefresh)
        return;
    m_autoRefresh = autoRefresh;
    emit autoRefreshChanged();

    if (m_autoRefresh && !m_useCursor && !m_currentQuery.isEmpty()) {
        m_refreshTimer->start(m_refreshIntervalMs);
    } else {
        m_refreshTimer->stop();
    }
}



void RepositoryListModel::setRefreshIntervalMs(int intervalMs)
{
    const int clamped = qMax(intervalMs, 10000);  // hard floor: 10s
    if (m_refreshIntervalMs == clamped)
        return;
    m_refreshIntervalMs = clamped;
    emit refreshIntervalMsChanged();
    if (m_refreshTimer->isActive())
        m_refreshTimer->setInterval(m_refreshIntervalMs);
}

void RepositoryListModel::setSortField(const QString &field)
{
    const QString normalized = (field == QLatin1String("updated"))
    ? field : QLatin1String("stars");
    if (m_sortField == normalized)
        return;
    m_sortField = normalized;
    emit sortFieldChanged();
}

void RepositoryListModel::onRefreshTick()
{
    if (m_currentQuery.isEmpty())
        return;
    if (m_isLoadingPage)
        return;
    if (m_useCursor)
        return;
    if (m_isRefreshing)
        return;

    m_isRefreshing = true;
    m_lastRefreshAt = QDateTime::currentDateTime();
    emit lastRefreshAtChanged();

    // Fetch page 1 silently: no setIsLoadingPage, no spinner blink
    m_service->searchRepositoriesPage(m_currentQuery, 1, m_perPage, m_sortField, "desc");
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

    // Stop any in-flight background refresh so the fresh search owns the next result.
    m_refreshTimer->stop();
    m_isRefreshing = false;

    m_currentQuery = query;
    m_currentPage = 1;
    setNextUrl({});
    emit currentPageChanged();

    setIsLoadingPage(true);
    if (m_useCursor) {
        m_service->searchRepositoriesCursor(query, m_perPage, m_sortField, "desc");
    } else {
        m_service->searchRepositoriesPage(query, m_currentPage, m_perPage, m_sortField, "desc");
    }

}

void RepositoryListModel::loadMore()
{
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
    // Background refresh tick: apply diff instead of full reset.
    if (m_isRefreshing && page == 1) {
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

    // Start the refresh timer after data lands, not when the search button was clicked
    if (m_autoRefresh && !m_useCursor && !m_currentQuery.isEmpty()) {
        m_refreshTimer->start(m_refreshIntervalMs);
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

void RepositoryListModel::applyDiff(const QList<Repository *> &incoming)
{
    // Build current row index (repo id -> row number)
    QHash<int, int> rowById;
    rowById.reserve(m_repos.size());
    for (int i = 0; i < m_repos.size(); ++i)
        rowById.insert(m_repos.at(i)->id(), i);

    // Build incoming lookup (repo id -> object) and membership set
    QHash<int, Repository *> incomingById;
    QSet<int> incomingIds;
    incomingById.reserve(incoming.size());
    incomingIds.reserve(incoming.size());
    for (Repository *r : incoming) {
        incomingById.insert(r->id(), r);
        incomingIds.insert(r->id());
    }

    // Pass 1: remove rows absent from incoming (backwards keeps indices valid)
    for (int i = m_repos.size() - 1; i >= 0; --i) {
        if (!incomingIds.contains(m_repos.at(i)->id())) {
            beginRemoveRows({}, i, i);
            delete m_repos.at(i);
            m_repos.removeAt(i);
            endRemoveRows();
        }
    }

    // Rebuild the row index after removals
    rowById.clear();
    for (int i = 0; i < m_repos.size(); ++i)
        rowById.insert(m_repos.at(i)->id(), i);


    // Pass 2: update mutable fields for surviving rows
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
        if (!changedRoles.isEmpty())
            emit dataChanged(index(i), index(i), changedRoles);

        // This incoming object served its purpose; delete it.
        delete updated;
        incomingById.remove(existing->id());
    }

    // Pass 3: collect new items and prepend them in one batch
    QList<Repository *> toPrepend;
    for (Repository *r : incoming) {
        if (incomingById.contains(r->id()))
            toPrepend.append(r);
    }

    if (!toPrepend.isEmpty()) {
        beginInsertRows({}, 0, toPrepend.size() - 1);
        for (int i = toPrepend.size() - 1; i >= 0; --i) {
            Repository *r = toPrepend.at(i);
            r->setParent(this);
            m_repos.prepend(r);
            m_newIds.insert(r->id());
        }
        endInsertRows();

        // Light up IsNewRole so QML shows the green badge immediately
        emit dataChanged(index(0), index(toPrepend.size() - 1), {IsNewRole});

        // Schedule the 3s badge clearance
        m_clearNewTimer->start(3000);
    }

    if (m_repos.size() != rowById.size())
        emit countChanged();


}

void RepositoryListModel::onClearNewFlags()
{
    if (m_newIds.isEmpty())
        return;

    const QSet<int> snapshot = m_newIds;
    m_newIds.clear();

    // Linear scan is fine; the "new" set is always small.
    for (int i = 0; i < m_repos.size(); ++i) {
        if (snapshot.contains(m_repos.at(i)->id()))
            emit dataChanged(index(i), index(i), {IsNewRole});
    }
}