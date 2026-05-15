#ifndef GITHUBSERVICE_H
#define GITHUBSERVICE_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QVariantList>
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
    Q_PROPERTY(QVariantList repositories READ repositories NOTIFY repositoriesChanged)

public:
    explicit GitHubService(QObject *parent = nullptr);

    QString authToken() const { return m_authToken; }
    bool isLoading() const { return m_isLoading; }
    QString errorMessage() const { return m_errorMessage; }
    QVariantList repositories() const { return m_repositories; }

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

signals:
    void authTokenChanged();
    void isLoadingChanged();
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

private slots:
    void onUserRepositoriesReceived();
    void onRepositoryReceived();
    void onSearchResultsReceived();
    void onSearchResultsPageReceived();
    void onSearchResultsCursorReceived();
    void onRequestFailed(QNetworkReply::NetworkError error);

private:
    void setIsLoading(bool loading);
    void setErrorMessage(const QString &message);
    QVariant parseRepositoryJson(const QJsonObject &json);

    QNetworkAccessManager *m_networkManager;
    QString m_authToken;
    bool m_isLoading = false;
    QString m_errorMessage;
    QVariantList m_repositories;
};

#endif // GITHUBSERVICE_H
