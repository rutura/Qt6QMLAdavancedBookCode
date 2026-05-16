#include "repositorylistmodel.h"
#include "githubservice.h"
#include "repository.h"
#include "cachemanager.h"

#include <QQmlEngine>
#include <QUrl>
#include <QHash>

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

    m_refreshTimer.setInterval(m_refreshIntervalMs);
    connect(&m_refreshTimer, &QTimer::timeout, this, &RepositoryListModel::onRefreshTick);

    // Clears the transient "is new" highlight a few seconds after rows are inserted.
    m_clearNewTimer.setSingleShot(true);
    m_clearNewTimer.setInterval(3000);
    connect(&m_clearNewTimer, &QTimer::timeout, this, [this]() {
        if (m_newRows.isEmpty())
            return;
        const QList<int> rows = m_newRows.values();
        m_newRows.clear();
        for (int row : rows) {
            if (row >= 0 && row < m_repos.size()) {
                const QModelIndex idx = index(row);
                emit dataChanged(idx, idx, { IsNewRole });
            }
        }
    });
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
    case IsNewRole:       return m_newRows.contains(index.row());
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

    if (page == 1 && m_refreshing) {
        // Timer-driven refresh: merge in place so scroll position survives.
        m_refreshing = false;
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

void RepositoryListModel::setAutoRefresh(bool autoRefresh)
{
    if (m_autoRefresh == autoRefresh)
        return;
    m_autoRefresh = autoRefresh;
    if (m_autoRefresh)
        m_refreshTimer.start();
    else
        m_refreshTimer.stop();
    emit autoRefreshChanged();
}

void RepositoryListModel::setRefreshIntervalMs(int ms)
{
    if (m_refreshIntervalMs == ms || ms < 1000)
        return;
    m_refreshIntervalMs = ms;
    m_refreshTimer.setInterval(ms);
    emit refreshIntervalMsChanged();
}

void RepositoryListModel::onRefreshTick()
{
    // Cursor mode has no stable "page 1" to diff against; only offset mode polls.
    if (m_currentQuery.isEmpty() || m_isLoadingPage || m_useCursor)
        return;

    m_refreshing = true;
    setIsLoadingPage(true);
    m_service->searchRepositoriesPage(m_currentQuery, 1, m_perPage);
}

void RepositoryListModel::applyDiff(const QList<Repository*> &incoming)
{
    // Index current rows by stable GitHub id.
    QHash<int, int> currentRowById;
    currentRowById.reserve(m_repos.size());
    for (int i = 0; i < m_repos.size(); ++i)
        currentRowById.insert(m_repos.at(i)->id(), i);

    QSet<int> incomingIds;
    incomingIds.reserve(incoming.size());
    for (Repository *r : incoming)
        incomingIds.insert(r->id());

    // 1) Remove rows whose id vanished from the incoming page.
    for (int row = m_repos.size() - 1; row >= 0; --row) {
        if (!incomingIds.contains(m_repos.at(row)->id())) {
            beginRemoveRows({}, row, row);
            delete m_repos.takeAt(row);
            endRemoveRows();
        }
    }

    // 2) Update changed fields on rows whose id is still present.
    currentRowById.clear();
    for (int i = 0; i < m_repos.size(); ++i)
        currentRowById.insert(m_repos.at(i)->id(), i);

    for (Repository *in : incoming) {
        auto it = currentRowById.constFind(in->id());
        if (it == currentRowById.constEnd())
            continue;
        Repository *cur = m_repos.at(it.value());
        QList<int> changedRoles;
        if (cur->stargazersCount() != in->stargazersCount()) {
            cur->setStargazersCount(in->stargazersCount());
            changedRoles << StarsRole;
        }
        if (cur->forksCount() != in->forksCount()) {
            cur->setForksCount(in->forksCount());
            changedRoles << ForksRole;
        }
        if (cur->description() != in->description()) {
            cur->setDescription(in->description());
            changedRoles << DescriptionRole;
        }
        if (!changedRoles.isEmpty()) {
            const QModelIndex idx = index(it.value());
            emit dataChanged(idx, idx, changedRoles);
        }
    }

    // 3) Insert genuinely new ids at the top, flagged "new" for the highlight cue.
    QList<Repository*> freshlyNew;
    for (Repository *in : incoming) {
        if (!currentRowById.contains(in->id()))
            freshlyNew.append(in);
    }
    if (!freshlyNew.isEmpty()) {
        beginInsertRows({}, 0, freshlyNew.size() - 1);
        for (int i = freshlyNew.size() - 1; i >= 0; --i) {
            Repository *r = freshlyNew.at(i);
            r->setParent(this);
            m_repos.prepend(r);
        }
        endInsertRows();
        emit countChanged();

        // Newly-inserted rows occupy [0, freshlyNew.size()-1].
        m_newRows.clear();
        for (int row = 0; row < freshlyNew.size(); ++row)
            markNew(row);
        m_clearNewTimer.start();
    }

    // incoming objects not adopted above are duplicates of existing rows — free them.
    for (Repository *in : incoming) {
        if (!freshlyNew.contains(in) && in->parent() != this)
            delete in;
    }
}

void RepositoryListModel::markNew(int row)
{
    m_newRows.insert(row);
    const QModelIndex idx = index(row);
    emit dataChanged(idx, idx, { IsNewRole });
}
