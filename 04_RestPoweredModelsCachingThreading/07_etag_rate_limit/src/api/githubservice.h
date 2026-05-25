#ifndef GITHUBSERVICE_H
#define GITHUBSERVICE_H

#include <QHash>          // NEW
#include <QString>        // NEW
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QList>
#include <QDateTime>     // NEW
#include <functional>     // NEW
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
    Q_PROPERTY(bool isParsing READ isParsing NOTIFY isParsingChanged)

    Q_PROPERTY(int rateLimitRemaining READ rateLimitRemaining NOTIFY rateLimitChanged)   // NEW
    Q_PROPERTY(int rateLimitTotal READ rateLimitTotal NOTIFY rateLimitChanged)           // NEW
    Q_PROPERTY(QDateTime rateLimitReset READ rateLimitReset NOTIFY rateLimitChanged)     // NEW


public:
    explicit GitHubService(QObject *parent = nullptr);

    QString authToken() const { return m_authToken; }
    bool isLoading() const { return m_isLoading; }
    QString errorMessage() const { return m_errorMessage; }
    bool isParsing() const { return m_inflightParses > 0; }

    int rateLimitRemaining() const { return m_rateLimitRemaining; }     // NEW
    int rateLimitTotal() const { return m_rateLimitTotal; }             // NEW
    QDateTime rateLimitReset() const { return m_rateLimitReset; }       // NEW


    void setAuthToken(const QString &token);
    // request first looks up the cache (stale-while-revalidate) before the network call.
    void setCache(CacheManager *cache);

    void searchRepositoriesPage(const QString &query, int page, int perPage,
                                const QString &sort = "stars", const QString &order = "desc");

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
    void isParsingChanged();
    void rateLimitChanged();     // NEW



    // API-reported total so the model can track pagination state.
    void searchResultsPageReady(const QList<Repository*> &repositories, int page, int totalCount);

    // `isFirstPage` distinguishes a fresh cursor search (model should reset)
    // from a follow-up fetchByUrl() result (model should append).
    void searchResultsCursorReady(const QList<Repository*> &repositories,
                                  const QString &nextUrl, bool isFirstPage);

    // stale data instantly. The network results follow when they arrive.
    void cachedPageReady(const QList<Repository*> &repositories, int page, int totalCount);
    void cachedCursorReady(const QList<Repository*> &repositories,
                           const QString &nextUrl, bool isFirstPage);

private slots:
    void onSearchResultsPageReceived();
    void onSearchResultsCursorReceived();

    void onCacheLoaded(const QString &key, const QByteArray &body,
                       const QByteArray &etag, bool found);

    void onRequestFailed(QNetworkReply::NetworkError error);

private:
    // so when the cache answers we know how to interpret the bytes.
    enum class RequestKind { Page, Cursor };

    struct PendingRequest {
        RequestKind kind;
        int page = 0;             // Page kind only.
        bool isFirstPage = false; // Cursor kind only.
    };

    QList<Repository*> parseSearchItems(const QByteArray &body,
                         int *totalCountOut = nullptr) const;

    // `onParsed(repos, totalCount)` is invoked on the GUI thread. isParsing stays
    // true for the duration so QML can show a "parsing…" state distinct from "fetching…".
    void parseBytesAsync(const QByteArray &body,
                         std::function<void(const QList<Repository*> &, int)> onParsed);
    void beginParse();
    void endParse();

    // NEW: Reads X-RateLimit-* response headers and updates the rate-limit properties.
    void updateRateLimit(QNetworkReply *reply);

    void setIsLoading(bool loading);
    void setErrorMessage(const QString &message);

    QNetworkAccessManager *m_networkManager;
    QString m_authToken;
    bool m_isLoading = false;
    QString m_errorMessage;
    CacheManager *m_cache = nullptr;
    QHash<QString, PendingRequest> m_pendingByKey;
    int m_inflightParses = 0;     // NEW

    // NEW: ETag store keyed by request URL. Populated from cache loads; consumed
    // when building outgoing requests to send a conditional If-None-Match header.
    QHash<QString, QByteArray> m_etagByUrl;
    int m_rateLimitRemaining = -1;     // NEW
    int m_rateLimitTotal = -1;          // NEW
    QDateTime m_rateLimitReset;         // NEW
};

#endif // GITHUBSERVICE_H
