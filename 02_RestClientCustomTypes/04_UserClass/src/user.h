#ifndef USER_H
#define USER_H

#include <QObject>
#include <QString>
#include <QJsonObject>
#include <qqml.h>

class User : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString login READ login WRITE setLogin NOTIFY loginChanged)
    Q_PROPERTY(QString avatarUrl READ avatarUrl WRITE setAvatarUrl NOTIFY avatarUrlChanged)
    Q_PROPERTY(QString htmlUrl READ htmlUrl WRITE setHtmlUrl NOTIFY htmlUrlChanged)
    Q_PROPERTY(QString type READ type WRITE setType NOTIFY typeChanged)

public:
    explicit User(QObject *parent = nullptr);

    int id() const { return m_id; }
    QString login() const { return m_login; }
    QString avatarUrl() const { return m_avatarUrl; }
    QString htmlUrl() const { return m_htmlUrl; }
    QString type() const { return m_type; }

    void setId(int id);
    void setLogin(const QString &login);
    void setAvatarUrl(const QString &avatarUrl);
    void setHtmlUrl(const QString &htmlUrl);
    void setType(const QString &type);

    static User* fromJson(const QJsonObject &json, QObject *parent = nullptr);

signals:
    void idChanged();
    void loginChanged();
    void avatarUrlChanged();
    void htmlUrlChanged();
    void typeChanged();

private:
    int m_id = 0;
    QString m_login;
    QString m_avatarUrl;
    QString m_htmlUrl;
    QString m_type;
};

#endif // USER_H
