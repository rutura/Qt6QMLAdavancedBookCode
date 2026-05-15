#include "repositorylistmodel.h"
#include "githubservice.h"
#include "repository.h"
#include "cachemanager.h"

#include <QQmlEngine>
#include <QUrl>

RepositoryListModel::RepositoryListModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_service(new GitHubService(this))
{
    // Hand the QML-singleton cache to the service so requests go disk-first,
    // then network. Both cached and network responses end up here as separate signals.
    m_service->setCache(CacheManager::create(nullptr, nullptr));

    connect(m_service, &GitHubService::cachedPageReady,
            this, &RepositoryListModel::onSearchResultsPageReady);
    connect(m_service, &GitHubService::cachedCursorReady,
            this, &RepositoryListModel::onSearchResultsCursorReady);
    connect(m_service, &GitHubService::searchResultsPageReady,
            this, &RepositoryListModel::onSearchResultsPageReady);
    connect(m_service, &GitHubService::searchResultsCursorReady,
            this, &RepositoryListModel::onSearchResultsCursorReady);

    connect(&m_refreshTimer, &QTimer::timeout, this, &RepositoryListModel::onRefreshTimer);

    m_isNewClearTimer.setSingleShot(true);
    connect(&m_isNewClearTimer, &QTimer::timeout, this, &RepositoryListModel::onIsNewClearTimer);
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
    case IsNewRole:       return m_newIds.contains(repo->id());
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
        { IsNewRole,       "isNew" }
    };
}

bool RepositoryListModel::hasMore() const
{
    if (m_useCursor)
        return !m_nextUrl.isEmpty();
    return m_repos.size() < m_totalCount;
}

void RepositoryListModel::setPerPage(int perPage)
{
    if (m_perPage != perPage && perPage > 0) {
        m_perPage = perPage;
        emit perPageChanged();
    }
}

void RepositoryListModel::setUseCursor(bool useCursor)
{
    if (m_useCursor != useCursor) {
        m_useCursor = useCursor;
        emit useCursorChanged();
        emit hasMoreChanged();
    }
}

void RepositoryListModel::setRefreshIntervalMs(int ms)
{
    if (m_refreshIntervalMs != ms && ms > 0) {
        m_refreshIntervalMs = ms;
        emit refreshIntervalMsChanged();
        if (m_autoRefresh) {
            m_refreshTimer.stop();
            m_refreshTimer.start(m_refreshIntervalMs);
        }
    }
}

void RepositoryListModel::setAutoRefresh(bool enabled)
{
    if (m_autoRefresh != enabled) {
        m_autoRefresh = enabled;
        emit autoRefreshChanged();
        if (enabled && !m_currentQuery.isEmpty())
            m_refreshTimer.start(m_refreshIntervalMs);
        else
            m_refreshTimer.stop();
    }
}

void RepositoryListModel::onRefreshTimer()
{
    if (m_isLoadingPage || m_currentQuery.isEmpty())
        return;
    m_isRefreshing = true;
    setIsLoadingPage(true);
    if (m_useCursor)
        m_service->searchRepositoriesCursor(m_currentQuery, m_perPage);
    else
        m_service->searchRepositoriesPage(m_currentQuery, 1, m_perPage);
}

void RepositoryListModel::onIsNewClearTimer()
{
    if (m_newIds.isEmpty())
        return;
    // Collect rows that need dataChanged before clearing the set.
    QVector<int> rowsToUpdate;
    for (int row = 0; row < m_repos.size(); ++row) {
        if (m_newIds.contains(m_repos.at(row)->id()))
            rowsToUpdate.append(row);
    }
    m_newIds.clear();
    for (int row : rowsToUpdate) {
        const QModelIndex idx = index(row);
        emit dataChanged(idx, idx, {IsNewRole});
    }
}

void RepositoryListModel::applyDiff(const QList<Repository*> &incoming)
{
    // Build lookup structures.
    QHash<int, Repository*> incomingById;
    incomingById.reserve(incoming.size());
    for (Repository *r : incoming)
        incomingById.insert(r->id(), r);

    QHash<int, int> currentIdxById;
    currentIdxById.reserve(m_repos.size());
    for (int i = 0; i < m_repos.size(); ++i)
        currentIdxById.insert(m_repos.at(i)->id(), i);

    // Remove rows absent from incoming (iterate backwards to preserve indices).
    for (int row = m_repos.size() - 1; row >= 0; --row) {
        if (!incomingById.contains(m_repos.at(row)->id())) {
            beginRemoveRows({}, row, row);
            Repository *dead = m_repos.takeAt(row);
            dead->deleteLater();
            endRemoveRows();
        }
    }

    // Rebuild currentIdxById after removals.
    currentIdxById.clear();
    for (int i = 0; i < m_repos.size(); ++i)
        currentIdxById.insert(m_repos.at(i)->id(), i);

    // Update overlapping rows; collect new ids.
    QList<int> newIds;
    for (Repository *incoming_r : incoming) {
        const int id = incoming_r->id();
        if (currentIdxById.contains(id)) {
            Repository *existing = m_repos.at(currentIdxById.value(id));
            QVector<int> changedRoles;
            if (existing->stargazersCount() != incoming_r->stargazersCount()) {
                existing->setStargazersCount(incoming_r->stargazersCount());
                changedRoles.append(StarsRole);
            }
            if (existing->forksCount() != incoming_r->forksCount()) {
                existing->setForksCount(incoming_r->forksCount());
                changedRoles.append(ForksRole);
            }
            if (existing->description() != incoming_r->description()) {
                existing->setDescription(incoming_r->description());
                changedRoles.append(DescriptionRole);
            }
            if (!changedRoles.isEmpty()) {
                const QModelIndex idx = index(currentIdxById.value(id));
                emit dataChanged(idx, idx, changedRoles);
            }
            incoming_r->deleteLater(); // We updated in-place; discard the incoming copy.
        } else {
            newIds.append(id);
        }
    }

    // Prepend genuinely new items at row 0.
    QList<Repository*> toInsert;
    for (Repository *incoming_r : incoming) {
        if (newIds.contains(incoming_r->id()))
            toInsert.append(incoming_r);
    }
    if (!toInsert.isEmpty()) {
        beginInsertRows({}, 0, toInsert.size() - 1);
        for (int i = toInsert.size() - 1; i >= 0; --i) {
            toInsert.at(i)->setParent(this);
            m_repos.prepend(toInsert.at(i));
        }
        endInsertRows();
        for (int id : newIds)
            m_newIds.insert(id);
        // Restart/start the clear timer: new items stay highlighted for 3 s.
        m_isNewClearTimer.start(3000);
    }

    emit countChanged();
    emit hasMoreChanged();
}

void RepositoryListModel::search(const QString &query)
{
    if (query.isEmpty() || m_isLoadingPage)
        return;

    m_currentQuery = query;
    m_currentPage = 1;
    setNextUrl({});
    emit currentPageChanged();

    setIsLoadingPage(true);
    if (m_useCursor) {
        m_service->searchRepositoriesCursor(query, m_perPage);
    } else {
        m_service->searchRepositoriesPage(query, m_currentPage, m_perPage);
    }
}

void RepositoryListModel::loadMore()
{
    if (m_isLoadingPage || m_currentQuery.isEmpty() || !hasMore() || m_useCursor)
        return;

    setIsLoadingPage(true);
    const int nextPage = m_currentPage + 1;
    m_service->searchRepositoriesPage(m_currentQuery, nextPage, m_perPage);
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
    setIsLoadingPage(false);
    setTotalCount(totalCount);

    if (m_isRefreshing && page == 1) {
        m_isRefreshing = false;
        applyDiff(repositories);
    } else if (page == 1) {
        resetWith(repositories);
        m_currentPage = 1;
    } else {
        appendBatch(repositories);
        m_currentPage = page;
    }
    emit currentPageChanged();
    emit hasMoreChanged();
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
