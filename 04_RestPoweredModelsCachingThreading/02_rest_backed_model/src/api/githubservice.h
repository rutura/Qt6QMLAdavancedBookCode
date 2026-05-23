#ifndef GITHUBSERVICE_H
#define GITHUBSERVICE_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QVariantList>
#include <QList>          // NEW
#include <qqml.h>

class Repository;          // NEW: forward declaration

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

    Q_INVOKABLE void searchRepositories(const QString &query, const QString &sort = "stars", const QString &order = "desc");

signals:
    void authTokenChanged();
    void isLoadingChanged();
    void errorMessageChanged();

    // NEW: Raw-typed signal consumed by the new RepositoryListModel.
    // The Repository* objects emitted have no parent. The receiver takes ownership.
    void searchResultsReady(const QList<Repository*> &repositories);

private slots:
    void onSearchResultsReceived();
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
