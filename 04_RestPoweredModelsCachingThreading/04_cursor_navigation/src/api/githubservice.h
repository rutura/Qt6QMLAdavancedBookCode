#ifndef GITHUBSERVICE_H
#define GITHUBSERVICE_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QList>
#include <qqml.h>

class Repository;

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

    /*
    Q_INVOKABLE void searchRepositories(const QString &query, const QString &sort = "stars",
                                                                const QString &order = "desc");
    */

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

    // The Repository* objects emitted have no parent. The receiver takes ownership.
    /*
    void searchResultsReady(const QList<Repository*> &repositories);
    */


    // API-reported total so the model can track pagination state.
    void searchResultsPageReady(const QList<Repository*> &repositories, int page, int totalCount);

    // NEW: Cursor variant. `nextUrl` is empty when there is no next page.
    // `isFirstPage` distinguishes a fresh cursor search (model should reset)
    // from a follow-up fetchByUrl() result (model should append).
    void searchResultsCursorReady(const QList<Repository*> &repositories,
                                  const QString &nextUrl, bool isFirstPage);

private slots:
    //void onSearchResultsReceived();
    void onSearchResultsPageReceived();
    void onSearchResultsCursorReceived();      // NEW
    void onRequestFailed(QNetworkReply::NetworkError error);

private:
    void setIsLoading(bool loading);
    void setErrorMessage(const QString &message);

    QNetworkAccessManager *m_networkManager;
    QString m_authToken;
    bool m_isLoading = false;
    QString m_errorMessage;
};

#endif // GITHUBSERVICE_H
