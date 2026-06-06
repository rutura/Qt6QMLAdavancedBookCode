#include "issue.h"
#include <QJsonArray>
#include <QJsonDocument>

Issue::Issue(QObject *parent)
    : QObject(parent)
{}

void Issue::setId(int id)
{
    if (m_id != id) {
        m_id = id;
        emit idChanged();
    }
}

void Issue::setNumber(int number)
{
    if (m_number != number) {
        m_number = number;
        emit numberChanged();
    }
}

void Issue::setTitle(const QString &title)
{
    if (m_title != title) {
        m_title = title;
        emit titleChanged();
    }
}

void Issue::setState(const QString &state)
{
    if (m_state != state) {
        m_state = state;
        emit stateChanged();
    }
}

void Issue::setBody(const QString &body)
{
    if (m_body != body) {
        m_body = body;
        emit bodyChanged();
    }
}

void Issue::setHtmlUrl(const QString &htmlUrl)
{
    if (m_htmlUrl != htmlUrl) {
        m_htmlUrl = htmlUrl;
        emit htmlUrlChanged();
    }
}

void Issue::setRepoFullName(const QString &repoFullName)
{
    if (m_repoFullName != repoFullName) {
        m_repoFullName = repoFullName;
        emit repoFullNameChanged();
    }
}

void Issue::setCommentsCount(int count)
{
    if (m_commentsCount != count) {
        m_commentsCount = count;
        emit commentsCountChanged();
    }
}

void Issue::setUserLogin(const QString &login)
{
    if (m_userLogin != login) {
        m_userLogin = login;
        emit userLoginChanged();
    }
}

void Issue::setCreatedAt(const QDateTime &dt)
{
    if (m_createdAt != dt) {
        m_createdAt = dt;
        emit createdAtChanged();
    }
}

Issue* Issue::fromJson(const QJsonObject &json, QObject *parent)
{
    auto *issue = new Issue(parent);
    issue->setId(json.value("id").toInt());
    issue->setNumber(json.value("number").toInt());
    issue->setTitle(json.value("title").toString());
    issue->setState(json.value("state").toString());
    issue->setBody(json.value("body").toString());
    issue->setHtmlUrl(json.value("html_url").toString());
    issue->setCommentsCount(json.value("comments").toInt());
    issue->setCreatedAt(
        QDateTime::fromString(json.value("created_at").toString(), Qt::ISODate));

    // Derive repo full name from html_url: https://github.com/owner/repo/issues/N
    const QString url = json.value("html_url").toString();
    const QStringList parts = url.split('/');
    if (parts.size() >= 5)
        issue->setRepoFullName(parts.at(3) + "/" + parts.at(4));

    const QJsonObject user = json.value("user").toObject();
    issue->setUserLogin(user.value("login").toString());

    return issue;
}