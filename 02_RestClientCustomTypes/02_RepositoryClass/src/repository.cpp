#include "repository.h"

Repository::Repository(QObject *parent)
    : QObject(parent)
{
}

void Repository::setId(int id)
{
    if (m_id != id) {
        m_id = id;
        emit idChanged();
    }
}

void Repository::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

void Repository::setFullName(const QString &fullName)
{
    if (m_fullName != fullName) {
        m_fullName = fullName;
        emit fullNameChanged();
    }
}

void Repository::setDescription(const QString &description)
{
    if (m_description != description) {
        m_description = description;
        emit descriptionChanged();
    }
}

void Repository::setHtmlUrl(const QString &htmlUrl)
{
    if (m_htmlUrl != htmlUrl) {
        m_htmlUrl = htmlUrl;
        emit htmlUrlChanged();
    }
}

void Repository::setLanguage(const QString &language)
{
    if (m_language != language) {
        m_language = language;
        emit languageChanged();
    }
}

void Repository::setStargazersCount(int count)
{
    if (m_stargazersCount != count) {
        m_stargazersCount = count;
        emit stargazersCountChanged();
    }
}

void Repository::setForksCount(int count)
{
    if (m_forksCount != count) {
        m_forksCount = count;
        emit forksCountChanged();
    }
}

void Repository::setUpdatedAt(const QDateTime &dateTime)
{
    if (m_updatedAt != dateTime) {
        m_updatedAt = dateTime;
        emit updatedAtChanged();
    }
}

void Repository::setIsPrivate(bool isPrivate)
{
    if (m_isPrivate != isPrivate) {
        m_isPrivate = isPrivate;
        emit isPrivateChanged();
    }
}

void Repository::setOwner(QObject *owner)
{
    if (m_owner != owner) {
        m_owner = owner;
        emit ownerChanged();
    }
}

/*
Repository* Repository::fromJson(const QJsonObject &json, QObject *parent)
{
    Repository *repo = new Repository(parent);

    repo->setId(json["id"].toInt());
    repo->setName(json["name"].toString());
    repo->setFullName(json["full_name"].toString());
    repo->setDescription(json["description"].toString());
    repo->setHtmlUrl(json["html_url"].toString());
    repo->setLanguage(json["language"].toString());
    repo->setStargazersCount(json["stargazers_count"].toInt());
    repo->setForksCount(json["forks_count"].toInt());
    repo->setIsPrivate(json["private"].toBool());

    QString updatedAtStr = json["updated_at"].toString();
    if (!updatedAtStr.isEmpty()) {
        QDateTime updatedAt = QDateTime::fromString(updatedAtStr, Qt::ISODate);
        repo->setUpdatedAt(updatedAt);
    }

    QJsonObject ownerJson = json["owner"].toObject();
    if (!ownerJson.isEmpty()) {
        User *owner = User::fromJson(ownerJson, repo);
        repo->setOwner(owner);
    }

    return repo;
}
*/