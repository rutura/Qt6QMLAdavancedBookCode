#include "repositorylistmodel.h"
#include "githubservice.h"
#include "repository.h"

#include <QUrl>

RepositoryListModel::RepositoryListModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_service(new GitHubService(this))
{
    connect(m_service, &GitHubService::searchResultsPageReady,
            this, &RepositoryListModel::onSearchResultsPageReady);
    connect(m_service, &GitHubService::searchResultsCursorReady,
            this, &RepositoryListModel::onSearchResultsCursorReady);
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
        { UrlRole,         "htmlUrl" }
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

    if (page == 1) {
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
