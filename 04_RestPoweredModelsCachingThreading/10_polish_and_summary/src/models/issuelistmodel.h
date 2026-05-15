#ifndef ISSUELISTMODEL_H
#define ISSUELISTMODEL_H

#include "abstractgithublistmodel.h"
#include <qqml.h>

class Issue;

class IssueListModel : public AbstractGitHubListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NumberRole,
        TitleRole,
        StateRole,
        UserLoginRole,
        CommentsCountRole,
        HtmlUrlRole
    };

    explicit IssueListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

protected:
    QString endpointForQuery(const QString &query, int page, int perPage) const override;
    QList<QObject*> parseItems(const QByteArray &body, int *totalCountOut) override;
    bool usesCursorPagination() const override { return false; }
};

#endif // ISSUELISTMODEL_H
