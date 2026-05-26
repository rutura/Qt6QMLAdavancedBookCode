#ifndef REPOSITORYLISTMODEL_H
#define REPOSITORYLISTMODEL_H

#include <QAbstractListModel>
#include <QDateTime>     // NEW
#include <QList>
#include <QSet>          // NEW
#include <QString>
#include <QTimer>        // NEW
#include <qqml.h>

class GitHubService;
class Repository;

class RepositoryListModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(GitHubService* service READ service CONSTANT)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

    Q_PROPERTY(int currentPage READ currentPage NOTIFY currentPageChanged)
    Q_PROPERTY(int perPage READ perPage WRITE setPerPage NOTIFY perPageChanged)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)
    Q_PROPERTY(bool hasMore READ hasMore NOTIFY hasMoreChanged)
    Q_PROPERTY(bool isLoadingPage READ isLoadingPage NOTIFY isLoadingPageChanged)

    Q_PROPERTY(bool useCursor READ useCursor WRITE setUseCursor NOTIFY useCursorChanged)  // NEW
    Q_PROPERTY(QString nextUrl READ nextUrl NOTIFY nextUrlChanged)

    // NEW: live-update surface
    Q_PROPERTY(bool autoRefresh READ autoRefresh WRITE setAutoRefresh NOTIFY autoRefreshChanged)
    Q_PROPERTY(int refreshIntervalMs READ refreshIntervalMs
                   WRITE setRefreshIntervalMs NOTIFY refreshIntervalMsChanged)
    Q_PROPERTY(QDateTime lastRefreshAt READ lastRefreshAt NOTIFY lastRefreshAtChanged)
    Q_PROPERTY(QString sortField READ sortField WRITE setSortField NOTIFY sortFieldChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        FullNameRole,
        DescriptionRole,
        StarsRole,
        ForksRole,
        LanguageRole,
        UrlRole,
        IsNewRole // NEW: true for ~3s after a diff-merge insert
    };


    explicit RepositoryListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    GitHubService* service() const { return m_service; }
    int count() const { return m_repos.size(); }

    int currentPage() const { return m_currentPage; }
    int perPage() const { return m_perPage; }
    int totalCount() const { return m_totalCount; }


    /*
    bool hasMore() const { return m_repos.size() < m_totalCount; }
    */
    bool hasMore() const;                                    // CHANGED: was inline

    bool isLoadingPage() const { return m_isLoadingPage; }

    bool useCursor() const { return m_useCursor; }
    QString nextUrl() const { return m_nextUrl; }

    bool autoRefresh() const { return m_autoRefresh; }
    int refreshIntervalMs() const { return m_refreshIntervalMs; }
    QDateTime lastRefreshAt() const { return m_lastRefreshAt; }
    QString sortField() const { return m_sortField; }

    void setPerPage(int perPage);
    void setUseCursor(bool useCursor);
    // NEW
    void setAutoRefresh(bool autoRefresh);
    void setRefreshIntervalMs(int intervalMs);
    void setSortField(const QString &field);


    Q_INVOKABLE void search(const QString &query);
    Q_INVOKABLE void loadMore();
    Q_INVOKABLE void fetchNextPage();                        // NEW: cursor-mode "load next"



signals:
    void countChanged();
    void currentPageChanged();
    void perPageChanged();
    void totalCountChanged();
    void hasMoreChanged();
    void isLoadingPageChanged();
    void useCursorChanged();
    void nextUrlChanged();

    void autoRefreshChanged();
    void refreshIntervalMsChanged();
    void lastRefreshAtChanged();
    void sortFieldChanged();

private slots:
    void onSearchResultsPageReady(const QList<Repository*> &repositories,
                                  int page, int totalCount);

    void onSearchResultsCursorReady(const QList<Repository*> &repositories,    // NEW
                                    const QString &nextUrl, bool isFirstPage);

    void onRefreshTick();    // background poll
    void onClearNewFlags();  // expire the "new" highlight after 3s


private:
    void setIsLoadingPage(bool loading);
    void setTotalCount(int total);
    void setNextUrl(const QString &url);          // NEW

    void appendBatch(const QList<Repository*> &batch);
    void resetWith(const QList<Repository*> &batch);

    void applyDiff(const QList<Repository*> &incoming);  // three-pass diff-merge


    GitHubService *m_service;
    QList<Repository*> m_repos;
    QString m_currentQuery;
    int m_currentPage = 0;
    int m_perPage = 30;
    int m_totalCount = 0;
    bool m_isLoadingPage = false;
    bool m_useCursor = false;     // NEW: default to offset mode
    QString m_nextUrl;            // NEW: the stored cursor

    // live-update state
    QTimer *m_refreshTimer = nullptr;
    QTimer *m_clearNewTimer = nullptr;
    bool m_autoRefresh = false;
    int m_refreshIntervalMs = 15000;
    QDateTime m_lastRefreshAt;
    QString m_sortField = QStringLiteral("updated");
    bool m_isRefreshing = false;
    QSet<int> m_newIds;
};

#endif // REPOSITORYLISTMODEL_H