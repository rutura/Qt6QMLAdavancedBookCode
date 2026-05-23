#include "githubservice.h"
#include "repository.h"     // NEW
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QNetworkRequest>
#include <QDebug>

GitHubService::GitHubService(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
{
}


void GitHubService::setAuthToken(const QString &token)
{
    if (m_authToken != token) {
        m_authToken = token;
        emit authTokenChanged();
    }
}

void GitHubService::setIsLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged();
    }
}

void GitHubService::setErrorMessage(const QString &message)
{
    if (m_errorMessage != message) {
        m_errorMessage = message;
        emit errorMessageChanged();
    }
}

void GitHubService::searchRepositories(const QString &query, const QString &sort, const QString &order)
{
    if (m_isLoading || query.isEmpty()) {
        return;
    }

    setIsLoading(true);
    setErrorMessage(QString());

    QUrl url(QString("https://api.github.com/search/repositories?q=%1&sort=%2&order=%3&per_page=50")
                 .arg(query, sort, order));

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "GitHubClient-Qt-Modern");
    request.setRawHeader("Accept", "application/vnd.github.v3+json");

    if (!m_authToken.isEmpty()) {
        request.setRawHeader("Authorization", QString("Bearer %1").arg(m_authToken).toUtf8());
    }

    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("requestType", "searchRepositories");

    connect(reply, &QNetworkReply::finished, this, &GitHubService::onSearchResultsReceived);
    connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::errorOccurred),
            this, &GitHubService::onRequestFailed);
}

void GitHubService::onSearchResultsReceived()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) {
        setIsLoading(false);
        setErrorMessage("Invalid response received");
        return;
    }

    setIsLoading(false);

    if (reply->error() != QNetworkReply::NoError) {
        reply->deleteLater();
        return;
    }

    QByteArray data = reply->readAll();
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        setErrorMessage(QString("JSON parsing error: %1").arg(parseError.errorString()));
        reply->deleteLater();
        return;
    }

    if (!doc.isObject()) {
        setErrorMessage("Expected JSON object for search results");
        reply->deleteLater();
        return;
    }

    QJsonObject searchResults = doc.object();
    QJsonArray items = searchResults["items"].toArray();
    QList<Repository*> typedList;

    for (const QJsonValue &value : items) {
        if (value.isObject()) {
            const QJsonObject obj = value.toObject();
            typedList.append(Repository::fromJson(obj, nullptr));
        }
    }
    emit searchResultsReady(typedList);
    reply->deleteLater();
}

void GitHubService::onRequestFailed(QNetworkReply::NetworkError error)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    setIsLoading(false);

    QString errorMsg;
    switch (error) {
    case QNetworkReply::AuthenticationRequiredError:
        errorMsg = "Authentication required. Please check your token.";
        break;
    case QNetworkReply::ContentNotFoundError:
        errorMsg = "Repository or user not found.";
        break;
    case QNetworkReply::TimeoutError:
        errorMsg = "Request timed out. Please try again.";
        break;
    case QNetworkReply::HostNotFoundError:
        errorMsg = "Unable to connect to GitHub API.";
        break;
    default:
        errorMsg = QString("Network error occurred: %1").arg(static_cast<int>(error));
        break;
    }

    setErrorMessage(errorMsg);
    qWarning() << "GitHub API request failed:" << errorMsg;

    if (reply) {
        reply->deleteLater();
    }
}
