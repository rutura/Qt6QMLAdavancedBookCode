#ifndef GITHUBSERVICE_H
#define GITHUBSERVICE_H

#include <QHash>          // NEW
#include <QString>        // NEW
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QList>
#include <qqml.h>

class Repository;
class CacheManager;        // NEW

class GitHubService : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString authToken READ authToken WRITE setAuthToken NOTIFY authTokenChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

public:
    explicit GitHubService(QObject *parent = nullptr);

    QString authToken() const { return m_authToken; }
    bool isLoading() const { return m_isLoading; }
    QString errorMessage() const { return m_errorMessage; }

    void setAuthToken(const QString &token);
    // NEW: Wire the service to a shared on-disk cache. When set, every paged/cursor
    // request first looks up the cache (stale-while-revalidate) before the network call.
    void setCache(CacheManager *cache);

    void searchRepositoriesPage(const QString &query, int page, int perPage,
                                const QString &sort = "stars", const QString &order = "desc");

    // NEW: Cursor-pagination entry. The first call uses searchRepositoriesCursor()
    // (same URL pattern as the offset path but parses the `Link` header on response);
    // follow-ups call fetchByUrl() with the URL extracted from `Link: <…>; rel="next"`.
    void searchRepositoriesCursor(const QString &query, int perPage,
                                  const QString &sort = "stars", const QString &order = "desc");
    void fetchByUrl(const QUrl &url);

    static QString parseNextLink(const QByteArray &linkHeader);

signals:
    void authTokenChanged();
    void isLoadingChanged();
    void errorMessageChanged();

    // API-reported total so the model can track pagination state.
    void searchResultsPageReady(const QList<Repository*> &repositories, int page, int totalCount);

    // NEW: Cursor variant. `nextUrl` is empty when there is no next page.
    // `isFirstPage` distinguishes a fresh cursor search (model should reset)
    // from a follow-up fetchByUrl() result (model should append).
    void searchResultsCursorReady(const QList<Repository*> &repositories,
                                  const QString &nextUrl, bool isFirstPage);

    // NEW: Cache hit fired ahead of any network response so the model can render
    // stale data instantly. The network results follow when they arrive.
    void cachedPageReady(const QList<Repository*> &repositories, int page, int totalCount);
    void cachedCursorReady(const QList<Repository*> &repositories,
                           const QString &nextUrl, bool isFirstPage);

private slots:
    void onSearchResultsPageReceived();
    void onSearchResultsCursorReceived();

    void onCacheLoaded(const QString &key, const QByteArray &body,
                       const QByteArray &etag, bool found);  // NEW

    void onRequestFailed(QNetworkReply::NetworkError error);

private:
    // NEW: a pending request remembers what kind of request a cache key belongs to,
    // so when the cache answers we know how to interpret the bytes.
    enum class RequestKind { Page, Cursor };

    struct PendingRequest {
        RequestKind kind;
        int page = 0;             // Page kind only.
        bool isFirstPage = false; // Cursor kind only.
    };

    QList<Repository*> parseSearchItems(const QByteArray &body,
                         int *totalCountOut = nullptr) const;  // NEW

    void setIsLoading(bool loading);
    void setErrorMessage(const QString &message);

    QNetworkAccessManager *m_networkManager;
    QString m_authToken;
    bool m_isLoading = false;
    QString m_errorMessage;
    CacheManager *m_cache = nullptr;                       // NEW
    QHash<QString, PendingRequest> m_pendingByKey;          // NEW
};

#endif // GITHUBSERVICE_H
