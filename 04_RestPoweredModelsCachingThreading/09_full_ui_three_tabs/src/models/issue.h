#ifndef ISSUE_H
#define ISSUE_H

#include <QObject>
#include <QString>
#include <QJsonObject>
#include <qqml.h>

class Issue : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(int number READ number WRITE setNumber NOTIFY numberChanged)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QString state READ state WRITE setState NOTIFY stateChanged)
    Q_PROPERTY(QString userLogin READ userLogin WRITE setUserLogin NOTIFY userLoginChanged)
    Q_PROPERTY(int commentsCount READ commentsCount WRITE setCommentsCount NOTIFY commentsCountChanged)
    Q_PROPERTY(QString htmlUrl READ htmlUrl WRITE setHtmlUrl NOTIFY htmlUrlChanged)

public:
    explicit Issue(QObject *parent = nullptr);

    int id() const { return m_id; }
    int number() const { return m_number; }
    QString title() const { return m_title; }
    QString state() const { return m_state; }
    QString userLogin() const { return m_userLogin; }
    int commentsCount() const { return m_commentsCount; }
    QString htmlUrl() const { return m_htmlUrl; }

    void setId(int id);
    void setNumber(int number);
    void setTitle(const QString &title);
    void setState(const QString &state);
    void setUserLogin(const QString &login);
    void setCommentsCount(int count);
    void setHtmlUrl(const QString &url);

    static Issue* fromJson(const QJsonObject &json, QObject *parent = nullptr);

signals:
    void idChanged();
    void numberChanged();
    void titleChanged();
    void stateChanged();
    void userLoginChanged();
    void commentsCountChanged();
    void htmlUrlChanged();

private:
    int m_id = 0;
    int m_number = 0;
    QString m_title;
    QString m_state;
    QString m_userLogin;
    int m_commentsCount = 0;
    QString m_htmlUrl;
};

#endif // ISSUE_H
