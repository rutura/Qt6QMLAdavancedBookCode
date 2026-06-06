#ifndef USERLISTMODEL_H
#define USERLISTMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QString>
#include <qqml.h>

class GitHubService;
class User;

class UserListModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(GitHubService* service READ service CONSTANT)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool isLoadingPage READ isLoadingPage NOTIFY isLoadingPageChanged)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)
    Q_PROPERTY(bool hasMore READ hasMore NOTIFY hasMoreChanged)
    Q_PROPERTY(int currentPage READ currentPage NOTIFY currentPageChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        LoginRole,
        AvatarUrlRole,
        HtmlUrlRole,
        TypeRole
    };

    explicit UserListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    GitHubService* service() const { return m_service; }
    int count() const { return m_users.size(); }
    bool isLoadingPage() const { return m_isLoadingPage; }
    int totalCount() const { return m_totalCount; }
    bool hasMore() const { return m_users.size() < m_totalCount; }
    int currentPage() const { return m_currentPage; }

    Q_INVOKABLE void search(const QString &query);
    Q_INVOKABLE void loadMore();

signals:
    void countChanged();
    void isLoadingPageChanged();
    void totalCountChanged();
    void hasMoreChanged();
    void currentPageChanged();

private slots:
    void onSearchResultsReady(const QList<User*> &users, int page, int totalCount);

private:
    void setIsLoadingPage(bool loading);
    void setTotalCount(int total);
    void appendBatch(const QList<User*> &batch);
    void resetWith(const QList<User*> &batch);

    GitHubService *m_service;
    QList<User*> m_users;
    QString m_currentQuery;
    int m_currentPage = 0;
    int m_perPage = 30;
    int m_totalCount = 0;
    bool m_isLoadingPage = false;
};

#endif // USERLISTMODEL_H