#include "issue.h"

Issue::Issue(QObject *parent) : QObject(parent) {}

void Issue::setId(int id) { if (m_id == id) return; m_id = id; emit idChanged(); }
void Issue::setNumber(int number) { if (m_number == number) return; m_number = number; emit numberChanged(); }
void Issue::setTitle(const QString &title) { if (m_title == title) return; m_title = title; emit titleChanged(); }
void Issue::setState(const QString &state) { if (m_state == state) return; m_state = state; emit stateChanged(); }
void Issue::setUserLogin(const QString &login) { if (m_userLogin == login) return; m_userLogin = login; emit userLoginChanged(); }
void Issue::setCommentsCount(int count) { if (m_commentsCount == count) return; m_commentsCount = count; emit commentsCountChanged(); }
void Issue::setHtmlUrl(const QString &url) { if (m_htmlUrl == url) return; m_htmlUrl = url; emit htmlUrlChanged(); }

Issue* Issue::fromJson(const QJsonObject &json, QObject *parent)
{
    auto *issue = new Issue(parent);
    issue->setId(json["id"].toInt());
    issue->setNumber(json["number"].toInt());
    issue->setTitle(json["title"].toString());
    issue->setState(json["state"].toString());
    issue->setCommentsCount(json["comments"].toInt());
    issue->setHtmlUrl(json["html_url"].toString());
    const QJsonObject userObj = json["user"].toObject();
    issue->setUserLogin(userObj["login"].toString());
    return issue;
}
