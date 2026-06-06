#ifndef ISSUELISTMODEL_H
#define ISSUELISTMODEL_H

#include <QObject>

class IssueListModel : public QObject
{
    Q_OBJECT
public:
    explicit IssueListModel(QObject *parent = nullptr);

signals:
};

#endif // ISSUELISTMODEL_H
