#include "githubservice.h"
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

void GitHubService::fetchUserRepositories(const QString &username)
{
    if (m_isLoading || username.isEmpty()) {
        return;
    }

    setIsLoading(true);
    setErrorMessage(QString());
    clearRepositories();

    QString endpoint = QString("users/%1/repos").arg(username);
    QUrl url(QString("https://api.github.com/%1?sort=updated&per_page=50").arg(endpoint));

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "GitHubClient-Qt-Modern");
    request.setRawHeader("Accept", "application/vnd.github.v3+json");

    if (!m_authToken.isEmpty()) {
        request.setRawHeader("Authorization", QString("Bearer %1").arg(m_authToken).toUtf8());
    }

    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("requestType", "userRepositories");

    connect(reply, &QNetworkReply::finished, this, &GitHubService::onUserRepositoriesReceived);
    connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::errorOccurred),
            this, &GitHubService::onRequestFailed);
}



void GitHubService::fetchAuthenticatedUserRepositories()
{
    if (m_isLoading) {
        return;
    }

    setIsLoading(true);
    setErrorMessage(QString());
    clearRepositories();

    QUrl url(QString("https://api.github.com/user/repos?sort=updated&per_page=50&visibility=all"));

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "GitHubClient-Qt-Modern");
    request.setRawHeader("Accept", "application/vnd.github.v3+json");

    if (!m_authToken.isEmpty()) {
        request.setRawHeader("Authorization", QString("Bearer %1").arg(m_authToken).toUtf8());
    }

    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("requestType", "userRepositories");

    connect(reply, &QNetworkReply::finished, this, &GitHubService::onUserRepositoriesReceived);
    connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::errorOccurred),
            this, &GitHubService::onRequestFailed);
}

void GitHubService::fetchRepository(const QString &owner, const QString &repo)
{
    if (m_isLoading || owner.isEmpty() || repo.isEmpty()) {
        return;
    }

    setIsLoading(true);
    setErrorMessage(QString());

    QUrl url(QString("https://api.github.com/repos/%1/%2").arg(owner, repo));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "GitHubClient-Qt-Modern");
    request.setRawHeader("Accept", "application/vnd.github.v3+json");

    if (!m_authToken.isEmpty()) {
        request.setRawHeader("Authorization", QString("Bearer %1").arg(m_authToken).toUtf8());
    }

    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("requestType", "singleRepository");

    connect(reply, &QNetworkReply::finished, this, &GitHubService::onRepositoryReceived);
    connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::errorOccurred),
            this, &GitHubService::onRequestFailed);
}


void GitHubService::searchRepositories(const QString &query, const QString &sort, const QString &order)
{
    if (m_isLoading || query.isEmpty()) {
        return;
    }

    setIsLoading(true);
    setErrorMessage(QString());
    clearRepositories();

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

void GitHubService::clearRepositories()
{
    if (!m_repositories.isEmpty()) {
        m_repositories.clear();
        emit repositoriesChanged();
    }
}

QVariant GitHubService::parseRepositoryJson(const QJsonObject &json)
{
    QVariantMap repo;

    repo["id"] = json["id"].toInt();
    repo["name"] = json["name"].toString();
    repo["fullName"] = json["full_name"].toString();
    repo["description"] = json["description"].toString();
    repo["htmlUrl"] = json["html_url"].toString();
    repo["language"] = json["language"].toString();
    repo["stargazersCount"] = json["stargazers_count"].toInt();
    repo["forksCount"] = json["forks_count"].toInt();
    repo["isPrivate"] = json["private"].toBool();
    repo["updatedAt"] = QDateTime::fromString(json["updated_at"].toString(), Qt::ISODate);

    // Owner information
    QJsonObject owner = json["owner"].toObject();
    QVariantMap ownerMap;
    ownerMap["id"] = owner["id"].toInt();
    ownerMap["login"] = owner["login"].toString();
    ownerMap["avatarUrl"] = owner["avatar_url"].toString();
    ownerMap["htmlUrl"] = owner["html_url"].toString();
    ownerMap["type"] = owner["type"].toString();
    repo["owner"] = ownerMap;

    return repo;
}

void GitHubService::onUserRepositoriesReceived()
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

    if (!doc.isArray()) {
        setErrorMessage("Expected JSON array for repository list");
        reply->deleteLater();
        return;
    }

    QJsonArray repositories = doc.array();
    QVariantList repoList;

    for (const QJsonValue &value : repositories) {
        if (value.isObject()) {
            repoList.append(parseRepositoryJson(value.toObject()));
        }
    }

    m_repositories = repoList;
    emit repositoriesChanged();
    reply->deleteLater();
}

void GitHubService::onRepositoryReceived()
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
        setErrorMessage("Expected JSON object for repository");
        reply->deleteLater();
        return;
    }

    QVariant repository = parseRepositoryJson(doc.object());
    emit repositoryFetched(repository);
    reply->deleteLater();
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
    QVariantList repoList;

    for (const QJsonValue &value : items) {
        if (value.isObject()) {
            repoList.append(parseRepositoryJson(value.toObject()));
        }
    }

    m_repositories = repoList;
    emit repositoriesChanged();
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
