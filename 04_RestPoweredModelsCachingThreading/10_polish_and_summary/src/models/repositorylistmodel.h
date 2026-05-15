#ifndef REPOSITORYLISTMODEL_H
#define REPOSITORYLISTMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QString>
#include <QTimer>
#include <QSet>
#include <qqml.h>

class GitHubService;
class Repository;

class RepositoryListModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    // The model owns its GitHubService internally. We picked internal ownership
    // (over injection via a writable property) because it gives the model a
    // single, predictable place to wire signals and clean up replies on reset.
    Q_PROPERTY(GitHubService* service READ service CONSTANT)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int currentPage READ currentPage NOTIFY currentPageChanged)
    Q_PROPERTY(int perPage READ perPage WRITE setPerPage NOTIFY perPageChanged)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)
    Q_PROPERTY(bool hasMore READ hasMore NOTIFY hasMoreChanged)
    Q_PROPERTY(bool isLoadingPage READ isLoadingPage NOTIFY isLoadingPageChanged)
    Q_PROPERTY(bool useCursor READ useCursor WRITE setUseCursor NOTIFY useCursorChanged)
    Q_PROPERTY(QString nextUrl READ nextUrl NOTIFY nextUrlChanged)
    Q_PROPERTY(int refreshIntervalMs READ refreshIntervalMs WRITE setRefreshIntervalMs NOTIFY refreshIntervalMsChanged)
    Q_PROPERTY(bool autoRefresh READ autoRefresh WRITE setAutoRefresh NOTIFY autoRefreshChanged)

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
        IsNewRole
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
    bool hasMore() const;
    bool isLoadingPage() const { return m_isLoadingPage; }
    bool useCursor() const { return m_useCursor; }
    QString nextUrl() const { return m_nextUrl; }
    int refreshIntervalMs() const { return m_refreshIntervalMs; }
    bool autoRefresh() const { return m_autoRefresh; }

    void setPerPage(int perPage);
    void setUseCursor(bool useCursor);
    void setRefreshIntervalMs(int ms);
    void setAutoRefresh(bool enabled);

    Q_INVOKABLE void search(const QString &query);
    Q_INVOKABLE void loadMore();
    Q_INVOKABLE void fetchNextPage();

signals:
    void countChanged();
    void currentPageChanged();
    void perPageChanged();
    void totalCountChanged();
    void hasMoreChanged();
    void isLoadingPageChanged();
    void useCursorChanged();
    void nextUrlChanged();
    void refreshIntervalMsChanged();
    void autoRefreshChanged();

private slots:
    void onSearchResultsPageReady(const QList<Repository*> &repositories, int page, int totalCount);
    void onSearchResultsCursorReady(const QList<Repository*> &repositories,
                                    const QString &nextUrl, bool isFirstPage);
    void onRefreshTimer();
    void onIsNewClearTimer();

private:
    void setIsLoadingPage(bool loading);
    void setTotalCount(int total);
    void setNextUrl(const QString &url);
    void appendBatch(const QList<Repository*> &batch);
    void resetWith(const QList<Repository*> &batch);
    void applyDiff(const QList<Repository*> &incoming);

    GitHubService *m_service;
    QList<Repository*> m_repos;
    QString m_currentQuery;
    int m_currentPage = 0;
    int m_perPage = 30;
    int m_totalCount = 0;
    bool m_isLoadingPage = false;
    bool m_useCursor = false;
    QString m_nextUrl;
    QTimer m_refreshTimer;
    QTimer m_isNewClearTimer;
    int m_refreshIntervalMs = 60000;
    bool m_autoRefresh = false;
    bool m_isRefreshing = false;
    QSet<int> m_newIds;
};

#endif // REPOSITORYLISTMODEL_H
