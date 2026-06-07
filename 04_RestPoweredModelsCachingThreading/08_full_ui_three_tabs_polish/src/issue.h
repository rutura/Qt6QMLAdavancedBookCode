#ifndef ISSUE_H
#define ISSUE_H

#include <QObject>
#include <QString>
#include <QDateTime>
#include <QJsonObject>
#include <QByteArray>
#include <QList>
#include <qqml.h>

class Issue : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(int number READ number WRITE setNumber NOTIFY numberChanged)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QString state READ state WRITE setState NOTIFY stateChanged)
    Q_PROPERTY(QString body READ body WRITE setBody NOTIFY bodyChanged)
    Q_PROPERTY(QString htmlUrl READ htmlUrl WRITE setHtmlUrl NOTIFY htmlUrlChanged)
    Q_PROPERTY(QString repoFullName READ repoFullName
                   WRITE setRepoFullName NOTIFY repoFullNameChanged)
    Q_PROPERTY(int commentsCount READ commentsCount
                   WRITE setCommentsCount NOTIFY commentsCountChanged)
    Q_PROPERTY(QString userLogin READ userLogin WRITE setUserLogin NOTIFY userLoginChanged)
    Q_PROPERTY(QDateTime createdAt READ createdAt WRITE setCreatedAt NOTIFY createdAtChanged)

public:
    explicit Issue(QObject *parent = nullptr);

    int id() const { return m_id; }
    int number() const { return m_number; }
    QString title() const { return m_title; }
    QString state() const { return m_state; }
    QString body() const { return m_body; }
    QString htmlUrl() const { return m_htmlUrl; }
    QString repoFullName() const { return m_repoFullName; }
    int commentsCount() const { return m_commentsCount; }
    QString userLogin() const { return m_userLogin; }
    QDateTime createdAt() const { return m_createdAt; }

    void setId(int id);
    void setNumber(int number);
    void setTitle(const QString &title);
    void setState(const QString &state);
    void setBody(const QString &body);
    void setHtmlUrl(const QString &htmlUrl);
    void setRepoFullName(const QString &repoFullName);
    void setCommentsCount(int count);
    void setUserLogin(const QString &login);
    void setCreatedAt(const QDateTime &dt);

    static Issue* fromJson(const QJsonObject &json, QObject *parent = nullptr);
    static QList<Issue*> listFromJsonBytes(const QByteArray &bytes,
                                            int *totalCountOut = nullptr);

signals:
    void idChanged();
    void numberChanged();
    void titleChanged();
    void stateChanged();
    void bodyChanged();
    void htmlUrlChanged();
    void repoFullNameChanged();
    void commentsCountChanged();
    void userLoginChanged();
    void createdAtChanged();

private:
    int m_id = 0;
    int m_number = 0;
    QString m_title;
    QString m_state;
    QString m_body;
    QString m_htmlUrl;
    QString m_repoFullName;
    int m_commentsCount = 0;
    QString m_userLogin;
    QDateTime m_createdAt;

};
#endif // ISSUE_H