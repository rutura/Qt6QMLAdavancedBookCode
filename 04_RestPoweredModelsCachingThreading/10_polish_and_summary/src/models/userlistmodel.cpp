#include "userlistmodel.h"
#include "../user.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrlQuery>
#include <QUrl>

UserListModel::UserListModel(QObject *parent)
    : AbstractGitHubListModel(parent)
{
}

int UserListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return items().size();
}

QVariant UserListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= items().size())
        return {};

    const User *user = qobject_cast<User*>(items().at(index.row()));
    if (!user)
        return {};

    switch (role) {
    case IdRole:       return user->id();
    case LoginRole:    return user->login();
    case AvatarUrlRole: return user->avatarUrl();
    case HtmlUrlRole:  return user->htmlUrl();
    case TypeRole:     return user->type();
    default:           return {};
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

QString UserListModel::endpointForQuery(const QString &query, int page, int perPage) const
{
    QUrl url("https://api.github.com/search/users");
    QUrlQuery q;
    q.addQueryItem("q", query);
    q.addQueryItem("page", QString::number(page));
    q.addQueryItem("per_page", QString::number(perPage));
    url.setQuery(q);
    return url.toString();
}

QList<QObject*> UserListModel::parseItems(const QByteArray &body, int *totalCountOut)
{
    const QJsonDocument doc = QJsonDocument::fromJson(body);
    if (doc.isNull()) {
        if (totalCountOut) *totalCountOut = 0;
        return {};
    }
    const QJsonObject root = doc.object();
    if (totalCountOut)
        *totalCountOut = root["total_count"].toInt();

    QList<QObject*> result;
    const QJsonArray items = root["items"].toArray();
    result.reserve(items.size());
    for (const QJsonValue &val : items)
        result.append(User::fromJson(val.toObject(), nullptr));
    return result;
}
