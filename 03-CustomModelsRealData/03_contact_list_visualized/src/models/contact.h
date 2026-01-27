#ifndef CONTACT_H
#define CONTACT_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QDateTime>
#include <QUrl>
#include <QUuid>
#include <QJsonObject>


class Contact
{
public:
    //Constructors
    Contact();
    Contact(const QString &firstName, const QString &lastName);
    Contact(const Contact &other);
    Contact(Contact &&other) noexcept;

    // Assignment operators
    Contact& operator=(const Contact &other);
    Contact& operator=(Contact &&other) noexcept;


    // Getters
    QString id() const { return m_id; }
    QString firstName() const { return m_firstName; }
    QString lastName() const { return m_lastName; }
    QString fullName() const { return m_firstName + " " + m_lastName; }
    QString email() const { return m_email; }
    QString phone() const { return m_phone; }
    QString company() const { return m_company; }
    QString jobTitle() const { return m_jobTitle; }
    QString address() const { return m_address; }
    QString notes() const { return m_notes; }
    QUrl avatarUrl() const { return m_avatarUrl; }
    QStringList tags() const { return m_tags; }
    bool isFavorite() const { return m_isFavorite; }
    QDateTime dateAdded() const { return m_dateAdded; }
    QDateTime dateModified() const { return m_dateModified; }

    // Setters
    void setId(const QString &id) { m_id = id; }
    void setFirstName(const QString &firstName);
    void setLastName(const QString &lastName);
    void setEmail(const QString &email);
    void setPhone(const QString &phone);
    void setCompany(const QString &company);
    void setJobTitle(const QString &jobTitle);
    void setAddress(const QString &address);
    void setNotes(const QString &notes);
    void setAvatarUrl(const QUrl &avatarUrl);
    void setTags(const QStringList &tags);
    void setIsFavorite(bool isFavorite);
    void setDateAdded(const QDateTime &dateAdded);
    void setDateModified(const QDateTime &dateModified);

    //Utility methods
    void touch();
    void addTag(const QString &tag);
    void removeTag(const QString &tag);
    bool hasTag(const QString &tag) const;

    // JSON serialization
    QJsonObject toJson() const;
    static Contact fromJson(const QJsonObject &json);

    // Comparison operators
    bool operator==(const Contact &other) const;
    bool operator!=(const Contact &other) const { return !(*this == other); }

    // Get initials for avatar display
    QString initials() const;

    // Get avatar color index (for consistent color selection based on name)
    int avatarColorIndex() const;

private:
    QString m_id;
    QString m_firstName;
    QString m_lastName;
    QString m_email;
    QString m_phone;
    QString m_company;
    QString m_jobTitle;
    QString m_address;
    QString m_notes;
    QUrl m_avatarUrl;
    QStringList m_tags;
    bool m_isFavorite;
    QDateTime m_dateAdded;
    QDateTime m_dateModified;

};

#endif // CONTACT_H
