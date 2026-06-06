#include "userlistmodel.h"
#include "githubservice.h"
#include "user.h"
#include "cachemanager.h"

UserListModel::UserListModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_service(new GitHubService(this))
{
    connect(m_service, &GitHubService::userSearchResultsReady,
            this, &UserListModel::onSearchResultsReady);

    m_service->setCache(CacheManager::create(nullptr, nullptr));
}

int UserListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_users.size();
}

QVariant UserListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_users.size())
        return {};

    const User *user = m_users.at(index.row());
    switch (role) {
    case IdRole:        return user->id();
    case LoginRole:     return user->login();
    case AvatarUrlRole: return user->avatarUrl();
    case HtmlUrlRole:   return user->htmlUrl();
    case TypeRole:      return user->type();
    default:            return {};
    }
}

QHash<int, QByteArray> UserListModel::roleNames() const
{
    return {
        { IdRole,        "userId" },
        { LoginRole,     "login" },
        { AvatarUrlRole, "avatarUrl" },
        { HtmlUrlRole,   "htmlUrl" },
        { TypeRole,      "userType" }
    };
}


void UserListModel::search(const QString &query)
{
    if (query.isEmpty() || m_isLoadingPage)
        return;

    m_currentQuery = query;
    m_currentPage = 1;
    emit currentPageChanged();
    setIsLoadingPage(true);
    m_service->searchUsers(query, m_currentPage, m_perPage);
}

void UserListModel::loadMore()
{
    if (m_isLoadingPage || m_currentQuery.isEmpty() || !hasMore())
        return;

    setIsLoadingPage(true);
    const int nextPage = m_currentPage + 1;
    m_service->searchUsers(m_currentQuery, nextPage, m_perPage);
}


void UserListModel::onSearchResultsReady(const QList<User*> &users,
                                         int page, int totalCount)
{
    setIsLoadingPage(false);
    setTotalCount(totalCount);

    if (page == 1)
        resetWith(users);
    else
        appendBatch(users);

    m_currentPage = page;
    emit currentPageChanged();
    emit hasMoreChanged();
}

void UserListModel::setIsLoadingPage(bool loading)
{
    if (m_isLoadingPage != loading) {
        m_isLoadingPage = loading;
        emit isLoadingPageChanged();
    }
}

void UserListModel::setTotalCount(int total)
{
    if (m_totalCount != total) {
        m_totalCount = total;
        emit totalCountChanged();
    }
}

void UserListModel::resetWith(const QList<User*> &batch)
{
    beginResetModel();
    qDeleteAll(m_users);
    m_users.clear();
    m_users = batch;
    for (User *u : m_users)
        u->setParent(this);
    endResetModel();
    emit countChanged();
}

void UserListModel::appendBatch(const QList<User*> &batch)
{
    if (batch.isEmpty())
        return;

    const int first = m_users.size();
    const int last = first + batch.size() - 1;
    beginInsertRows({}, first, last);
    for (User *u : batch) {
        u->setParent(this);
        m_users.append(u);
    }
    endInsertRows();
    emit countChanged();
}