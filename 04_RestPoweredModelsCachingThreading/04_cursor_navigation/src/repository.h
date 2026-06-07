#ifndef REPOSITORY_H
#define REPOSITORY_H

#include <QObject>
#include <QString>
#include <QDateTime>
#include <QJsonObject>
#include <qqml.h>

class Repository : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString fullName READ fullName WRITE setFullName NOTIFY fullNameChanged)
    Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QString htmlUrl READ htmlUrl WRITE setHtmlUrl NOTIFY htmlUrlChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(int stargazersCount READ stargazersCount WRITE setStargazersCount NOTIFY stargazersCountChanged)
    Q_PROPERTY(int forksCount READ forksCount WRITE setForksCount NOTIFY forksCountChanged)
    Q_PROPERTY(QDateTime updatedAt READ updatedAt WRITE setUpdatedAt NOTIFY updatedAtChanged)
    Q_PROPERTY(bool isPrivate READ isPrivate WRITE setIsPrivate NOTIFY isPrivateChanged)
    Q_PROPERTY(QObject* owner READ owner WRITE setOwner NOTIFY ownerChanged)

public:
    explicit Repository(QObject *parent = nullptr);

    int id() const { return m_id; }
    QString name() const { return m_name; }
    QString fullName() const { return m_fullName; }
    QString description() const { return m_description; }
    QString htmlUrl() const { return m_htmlUrl; }
    QString language() const { return m_language; }
    int stargazersCount() const { return m_stargazersCount; }
    int forksCount() const { return m_forksCount; }
    QDateTime updatedAt() const { return m_updatedAt; }
    bool isPrivate() const { return m_isPrivate; }
    QObject* owner() const { return m_owner; }

    void setId(int id);
    void setName(const QString &name);
    void setFullName(const QString &fullName);
    void setDescription(const QString &description);
    void setHtmlUrl(const QString &htmlUrl);
    void setLanguage(const QString &language);
    void setStargazersCount(int count);
    void setForksCount(int count);
    void setUpdatedAt(const QDateTime &dateTime);
    void setIsPrivate(bool isPrivate);
    void setOwner(QObject *owner);

    static Repository* fromJson(const QJsonObject &json, QObject *parent = nullptr);

signals:
    void idChanged();
    void nameChanged();
    void fullNameChanged();
    void descriptionChanged();
    void htmlUrlChanged();
    void languageChanged();
    void stargazersCountChanged();
    void forksCountChanged();
    void updatedAtChanged();
    void isPrivateChanged();
    void ownerChanged();

private:
    int m_id = 0;
    QString m_name;
    QString m_fullName;
    QString m_description;
    QString m_htmlUrl;
    QString m_language;
    int m_stargazersCount = 0;
    int m_forksCount = 0;
    QDateTime m_updatedAt;
    bool m_isPrivate = false;
    QObject *m_owner = nullptr;
};

#endif // REPOSITORY_H
