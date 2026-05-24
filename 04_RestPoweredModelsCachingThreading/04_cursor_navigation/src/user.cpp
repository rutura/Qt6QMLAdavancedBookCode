#include "user.h"
#include <QJsonObject>

User::User(QObject *parent)
    : QObject(parent)
{
}

void User::setId(int id)
{
    if (m_id != id) {
        m_id = id;
        emit idChanged();
    }
}

void User::setLogin(const QString &login)
{
    if (m_login != login) {
        m_login = login;
        emit loginChanged();
    }
}

void User::setAvatarUrl(const QString &avatarUrl)
{
    if (m_avatarUrl != avatarUrl) {
        m_avatarUrl = avatarUrl;
        emit avatarUrlChanged();
    }
}

void User::setHtmlUrl(const QString &htmlUrl)
{
    if (m_htmlUrl != htmlUrl) {
        m_htmlUrl = htmlUrl;
        emit htmlUrlChanged();
    }
}

void User::setType(const QString &type)
{
    if (m_type != type) {
        m_type = type;
        emit typeChanged();
    }
}

User* User::fromJson(const QJsonObject &json, QObject *parent)
{
    User *user = new User(parent);

    user->setId(json["id"].toInt());
    user->setLogin(json["login"].toString());
    user->setAvatarUrl(json["avatar_url"].toString());
    user->setHtmlUrl(json["html_url"].toString());
    user->setType(json["type"].toString());

    return user;
}
