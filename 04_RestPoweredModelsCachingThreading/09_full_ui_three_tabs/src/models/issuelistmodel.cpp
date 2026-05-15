#include "issuelistmodel.h"
#include "issue.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrlQuery>
#include <QUrl>

IssueListModel::IssueListModel(QObject *parent)
    : AbstractGitHubListModel(parent)
{
}

int IssueListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return items().size();
}

QVariant IssueListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= items().size())
        return {};

    const Issue *issue = qobject_cast<Issue*>(items().at(index.row()));
    if (!issue)
        return {};

    switch (role) {
    case IdRole:           return issue->id();
    case NumberRole:       return issue->number();
    case TitleRole:        return issue->title();
    case StateRole:        return issue->state();
    case UserLoginRole:    return issue->userLogin();
    case CommentsCountRole: return issue->commentsCount();
    case HtmlUrlRole:      return issue->htmlUrl();
    default:               return {};
    }
}

QHash<int, QByteArray> IssueListModel::roleNames() const
{
    return {
        { IdRole,            "issueId" },
        { NumberRole,        "number" },
        { TitleRole,         "title" },
        { StateRole,         "state" },
        { UserLoginRole,     "userLogin" },
        { CommentsCountRole, "commentsCount" },
        { HtmlUrlRole,       "htmlUrl" }
    };
}

QString IssueListModel::endpointForQuery(const QString &query, int page, int perPage) const
{
    QUrl url("https://api.github.com/search/issues");
    QUrlQuery q;
    q.addQueryItem("q", query);
    q.addQueryItem("page", QString::number(page));
    q.addQueryItem("per_page", QString::number(perPage));
    url.setQuery(q);
    return url.toString();
}

QList<QObject*> IssueListModel::parseItems(const QByteArray &body, int *totalCountOut)
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
        result.append(Issue::fromJson(val.toObject(), nullptr));
    return result;
}
