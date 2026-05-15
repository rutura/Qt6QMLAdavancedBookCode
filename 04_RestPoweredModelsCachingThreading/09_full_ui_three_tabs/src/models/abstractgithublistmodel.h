#ifndef ABSTRACTGITHUBLISTMODEL_H
#define ABSTRACTGITHUBLISTMODEL_H

#include <QAbstractListModel>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QList>
#include <QString>
#include <QByteArray>
#include <qqml.h>

class CacheManager;

// Base class for GitHub search list models. Owns the QNAM + cache + pagination
// state, so each concrete model only needs to supply its endpoint URL and
// a parser that turns raw JSON into typed QObject*.
class AbstractGitHubListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum class Status { Idle, Loading, Error };
    Q_ENUM(Status)

    Q_PROPERTY(Status status READ status NOTIFY statusChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)
    Q_PROPERTY(bool hasMore READ hasMore NOTIFY hasMoreChanged)
    Q_PROPERTY(bool isLoadingPage READ isLoadingPage NOTIFY isLoadingPageChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QString authToken READ authToken WRITE setAuthToken NOTIFY authTokenChanged)

    explicit AbstractGitHubListModel(QObject *parent = nullptr);
    ~AbstractGitHubListModel() override;

    Status status() const { return m_status; }
    QString errorMessage() const { return m_errorMessage; }
    int totalCount() const { return m_totalCount; }
    bool hasMore() const;
    bool isLoadingPage() const { return m_isLoadingPage; }
    int count() const { return m_items.size(); }
    QString authToken() const { return m_authToken; }

    void setAuthToken(const QString &token);

    Q_INVOKABLE virtual void search(const QString &query);
    Q_INVOKABLE virtual void loadMore();

signals:
    void statusChanged();
    void errorMessageChanged();
    void totalCountChanged();
    void hasMoreChanged();
    void isLoadingPageChanged();
    void countChanged();
    void authTokenChanged();

protected:
    // Subclasses implement these two methods to provide endpoint and item parsing.
    // endpointForQuery must return a full URL string.
    virtual QString endpointForQuery(const QString &query, int page, int perPage) const = 0;
    // parseItems parses the search JSON body. Returns items parented to nullptr.
    // Sets *totalCountOut to the "total_count" field.
    virtual QList<QObject*> parseItems(const QByteArray &body, int *totalCountOut) = 0;

    // Subclasses may override to indicate cursor vs offset pagination.
    virtual bool usesCursorPagination() const { return false; }
    virtual QString parseNextLink(const QByteArray &linkHeader) const;

    // Access to the internal item list for data() implementations.
    const QList<QObject*> &items() const { return m_items; }

private slots:
    void onCacheLoaded(const QString &key, const QByteArray &body, const QByteArray &etag, bool found);
    void onReplyFinished(QNetworkReply *reply);

private:
    struct PendingRequest {
        int page;
        bool isFirstPage;
    };

    QNetworkRequest buildRequest(const QUrl &url) const;
    void fetchUrl(const QUrl &url, int page, bool isFirstPage);
    void processResponse(const QByteArray &body, int page, bool isFirstPage,
                         const QString &cacheKey, const QByteArray &etag);
    void setStatus(Status s);
    void setIsLoadingPage(bool loading);
    void setTotalCount(int total);
    void resetWith(QList<QObject*> items);
    void appendBatch(QList<QObject*> batch);

    QNetworkAccessManager m_nam;
    CacheManager *m_cache = nullptr;
    QString m_authToken;
    QString m_currentQuery;
    int m_currentPage = 0;
    int m_perPage = 30;
    int m_totalCount = 0;
    bool m_isLoadingPage = false;
    Status m_status = Status::Idle;
    QString m_errorMessage;
    QString m_nextUrl;
    QList<QObject*> m_items;
    QHash<QString, QByteArray> m_etagByKey;
    // Map from pending network reply to request metadata.
    QHash<QNetworkReply*, PendingRequest> m_pendingReplies;
    // Tracks in-flight cache lookups so onCacheLoaded knows which page they belong to.
    QHash<QString, PendingRequest> m_cacheKeyPending;
};

#endif // ABSTRACTGITHUBLISTMODEL_H
