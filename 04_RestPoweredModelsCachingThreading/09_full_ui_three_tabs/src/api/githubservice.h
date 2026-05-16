#ifndef GITHUBSERVICE_H
#define GITHUBSERVICE_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QVariantList>
#include <QList>
#include <QHash>
#include <QString>
#include <QDateTime>
#include <qqml.h>

#include <functional>

class Repository;
class CacheManager;

class GitHubService : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString authToken READ authToken WRITE setAuthToken NOTIFY authTokenChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(bool isParsing READ isParsing NOTIFY isParsingChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(QVariantList repositories READ repositories NOTIFY repositoriesChanged)
    Q_PROPERTY(int rateLimitRemaining READ rateLimitRemaining NOTIFY rateLimitChanged)
    Q_PROPERTY(int rateLimitTotal READ rateLimitTotal NOTIFY rateLimitChanged)
    Q_PROPERTY(QDateTime rateLimitReset READ rateLimitReset NOTIFY rateLimitChanged)

public:
    explicit GitHubService(QObject *parent = nullptr);

    QString authToken() const { return m_authToken; }
    bool isLoading() const { return m_isLoading; }
    bool isParsing() const { return m_inflightParses > 0; }
    QString errorMessage() const { return m_errorMessage; }
    QVariantList repositories() const { return m_repositories; }
    int rateLimitRemaining() const { return m_rateLimitRemaining; }
    int rateLimitTotal() const { return m_rateLimitTotal; }
    QDateTime rateLimitReset() const { return m_rateLimitReset; }

    void setAuthToken(const QString &token);

    Q_INVOKABLE void fetchUserRepositories(const QString &username = QString());
    Q_INVOKABLE void fetchRepository(const QString &owner, const QString &repo);
    Q_INVOKABLE void clearRepositories();
    Q_INVOKABLE void searchRepositories(const QString &query, const QString &sort = "stars", const QString &order = "desc");
    Q_INVOKABLE void fetchAuthenticatedUserRepositories();

    // Page-aware search used by the model's offset-pagination path.
    void searchRepositoriesPage(const QString &query, int page, int perPage,
                                const QString &sort = "stars", const QString &order = "desc");

    // Cursor-pagination entry: first call uses searchRepositoriesCursor() (the same URL
    // pattern as the offset path but parses the `Link` header on response); follow-ups
    // call fetchByUrl() with the URL extracted from `Link: <…>; rel="next"`.
    void searchRepositoriesCursor(const QString &query, int perPage,
                                  const QString &sort = "stars", const QString &order = "desc");
    void fetchByUrl(const QUrl &url);

    static QString parseNextLink(const QByteArray &linkHeader);

    // Wire the service to a shared on-disk cache. When set, every paged/cursor request
    // first looks up the cache (stale-while-revalidate) before issuing the network call.
    void setCache(CacheManager *cache);

signals:
    void authTokenChanged();
    void isLoadingChanged();
    void isParsingChanged();
    void errorMessageChanged();
    void repositoriesChanged();
    void repositoryFetched(const QVariant &repository);

    // Raw-typed signal consumed by the new RepositoryListModel.
    // The QVariantList-based path above is kept intact for chapter-2 callers.
    // The Repository* objects emitted have no parent — the receiver must take ownership.
    void searchResultsReady(const QList<Repository*> &repositories);

    // Page-aware variant. Carries the page number requested and the API-reported total.
    void searchResultsPageReady(const QList<Repository*> &repositories, int page, int totalCount);

    // Cursor variant. `nextUrl` is empty when there is no next page.
    // `isFirstPage` distinguishes a fresh cursor search (model should reset)
    // from a follow-up fetchByUrl() result (model should append).
    void searchResultsCursorReady(const QList<Repository*> &repositories,
                                  const QString &nextUrl, bool isFirstPage);

    // Cache hit fired ahead of any network response so the model can render stale
    // data instantly. The network results (above signals) follow when they arrive.
    void cachedPageReady(const QList<Repository*> &repositories, int page, int totalCount);
    void cachedCursorReady(const QList<Repository*> &repositories,
                           const QString &nextUrl, bool isFirstPage);

    void rateLimitChanged();

private slots:
    void onUserRepositoriesReceived();
    void onRepositoryReceived();
    void onSearchResultsReceived();
    void onSearchResultsPageReceived();
    void onSearchResultsCursorReceived();
    void onRequestFailed(QNetworkReply::NetworkError error);
    void onCacheLoaded(const QString &key, const QByteArray &body, const QByteArray &etag, bool found);

private:
    enum class RequestKind { Page, Cursor };

    struct PendingRequest {
        RequestKind kind;
        int page = 0;          // Page kind only.
        bool isFirstPage = false; // Cursor kind only.
    };

    void setIsLoading(bool loading);
    void setErrorMessage(const QString &message);
    QVariant parseRepositoryJson(const QJsonObject &json);
    QList<Repository*> parseSearchItems(const QByteArray &body, int *totalCountOut = nullptr) const;

    // Parses `body` on a worker thread via QtConcurrent. When parsing finishes,
    // `onParsed(repos, totalCount)` is invoked on the GUI thread. isParsing stays
    // true for the duration so QML can show a "parsing…" state distinct from "fetching…".
    void parseBytesAsync(const QByteArray &body,
                         std::function<void(const QList<Repository*> &, int)> onParsed);
    void beginParse();
    void endParse();

    // Reads X-RateLimit-* response headers and updates the rate-limit properties.
    void updateRateLimit(QNetworkReply *reply);

    QNetworkAccessManager *m_networkManager;
    QString m_authToken;
    bool m_isLoading = false;
    int m_inflightParses = 0;
    QString m_errorMessage;
    QVariantList m_repositories;
    CacheManager *m_cache = nullptr;
    QHash<QString, PendingRequest> m_pendingByKey;

    // ETag store keyed by request URL. Populated from cache loads; consumed when
    // building outgoing requests to send a conditional If-None-Match header.
    QHash<QString, QByteArray> m_etagByUrl;

    int m_rateLimitRemaining = -1;
    int m_rateLimitTotal = -1;
    QDateTime m_rateLimitReset;
};

#endif // GITHUBSERVICE_H
