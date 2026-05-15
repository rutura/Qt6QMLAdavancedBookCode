#include "repositorylistmodel.h"
#include "githubservice.h"
#include "repository.h"

RepositoryListModel::RepositoryListModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_service(new GitHubService(this))
{
    connect(m_service, &GitHubService::searchResultsReady,
            this, &RepositoryListModel::onSearchResultsReady);
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

void RepositoryListModel::search(const QString &query)
{
    m_service->searchRepositories(query);
}

void RepositoryListModel::onSearchResultsReady(const QList<Repository*> &repositories)
{
    resetWith(repositories);
}

void RepositoryListModel::resetWith(const QList<Repository*> &repositories)
{
    beginResetModel();
    qDeleteAll(m_repos);
    m_repos.clear();
    m_repos = repositories;
    for (Repository *r : m_repos)
        r->setParent(this);
    endResetModel();
    emit countChanged();
}
