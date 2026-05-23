#ifndef REPOSITORYLISTMODEL_H
#define REPOSITORYLISTMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QString>          // NEW
#include <qqml.h>

class GitHubService;
class Repository;

class RepositoryListModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(GitHubService* service READ service CONSTANT)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

    Q_PROPERTY(int currentPage READ currentPage NOTIFY currentPageChanged)        // NEW
    Q_PROPERTY(int perPage READ perPage WRITE setPerPage NOTIFY perPageChanged)    // NEW
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)            // NEW
    Q_PROPERTY(bool hasMore READ hasMore NOTIFY hasMoreChanged)                    // NEW
    Q_PROPERTY(bool isLoadingPage READ isLoadingPage NOTIFY isLoadingPageChanged)  // NEW

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        FullNameRole,
        DescriptionRole,
        StarsRole,
        ForksRole,
        LanguageRole,
        UrlRole
    };


    explicit RepositoryListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    GitHubService* service() const { return m_service; }
    int count() const { return m_repos.size(); }

    int currentPage() const { return m_currentPage; }                       // NEW
    int perPage() const { return m_perPage; }                               // NEW
    int totalCount() const { return m_totalCount; }                         // NEW
    bool hasMore() const { return m_repos.size() < m_totalCount; }           // NEW
    bool isLoadingPage() const { return m_isLoadingPage; }                  // NEW

    void setPerPage(int perPage);                                            // NEW

    Q_INVOKABLE void search(const QString &query);
    Q_INVOKABLE void loadMore();                                             // NEW


signals:
    void countChanged();
    void currentPageChanged();      // NEW
    void perPageChanged();          // NEW
    void totalCountChanged();       // NEW
    void hasMoreChanged();          // NEW
    void isLoadingPageChanged();    // NEW

private slots:
    void onSearchResultsPageReady(const QList<Repository*> &repositories,
                                  int page, int totalCount);  // CHANGED


private:
    void setIsLoadingPage(bool loading);                       // NEW
    void setTotalCount(int total);                             // NEW
    void appendBatch(const QList<Repository*> &batch);          // NEW
    void resetWith(const QList<Repository*> &batch);		// (renamed param)

    GitHubService *m_service;
    QList<Repository*> m_repos;
    QString m_currentQuery;       // NEW: remembered so loadMore() can re-query
    int m_currentPage = 0;        // NEW
    int m_perPage = 30;           // NEW
    int m_totalCount = 0;         // NEW
    bool m_isLoadingPage = false; // NEW
};

#endif // REPOSITORYLISTMODEL_H