#include "Contact.h"
#include <QJsonArray>
#include <QDebug>

// Default constructor
Contact::Contact()
    : m_id(QUuid::createUuid().toString(QUuid::WithoutBraces))
    , m_isFavorite(false)
    , m_dateAdded(QDateTime::currentDateTime())
    , m_dateModified(QDateTime::currentDateTime())
    , m_contactFrequency(0)
{
}

// Constructor with name
Contact::Contact(const QString &firstName, const QString &lastName)
    : m_id(QUuid::createUuid().toString(QUuid::WithoutBraces))
    , m_firstName(firstName)
    , m_lastName(lastName)
    , m_isFavorite(false)
    , m_dateAdded(QDateTime::currentDateTime())
    , m_dateModified(QDateTime::currentDateTime())
    , m_contactFrequency(0)
{
}

// Copy constructor
Contact::Contact(const Contact &other)
    : m_id(other.m_id)
    , m_firstName(other.m_firstName)
    , m_lastName(other.m_lastName)
    , m_email(other.m_email)
    , m_phone(other.m_phone)
    , m_company(other.m_company)
    , m_jobTitle(other.m_jobTitle)
    , m_address(other.m_address)
    , m_notes(other.m_notes)
    , m_avatarUrl(other.m_avatarUrl)
    , m_tags(other.m_tags)
    , m_isFavorite(other.m_isFavorite)
    , m_dateAdded(other.m_dateAdded)
    , m_dateModified(other.m_dateModified)
    , m_contactFrequency(other.m_contactFrequency)
{
}

// Move constructor
Contact::Contact(Contact &&other) noexcept
    : m_id(std::move(other.m_id))
    , m_firstName(std::move(other.m_firstName))
    , m_lastName(std::move(other.m_lastName))
    , m_email(std::move(other.m_email))
    , m_phone(std::move(other.m_phone))
    , m_company(std::move(other.m_company))
    , m_jobTitle(std::move(other.m_jobTitle))
    , m_address(std::move(other.m_address))
    , m_notes(std::move(other.m_notes))
    , m_avatarUrl(std::move(other.m_avatarUrl))
    , m_tags(std::move(other.m_tags))
    , m_isFavorite(other.m_isFavorite)
    , m_dateAdded(std::move(other.m_dateAdded))
    , m_dateModified(std::move(other.m_dateModified))
    , m_contactFrequency(other.m_contactFrequency)
{
}

// Copy assignment
Contact& Contact::operator=(const Contact &other)
{
    if (this != &other) {
        m_id = other.m_id;
        m_firstName = other.m_firstName;
        m_lastName = other.m_lastName;
        m_email = other.m_email;
        m_phone = other.m_phone;
        m_company = other.m_company;
        m_jobTitle = other.m_jobTitle;
        m_address = other.m_address;
        m_notes = other.m_notes;
        m_avatarUrl = other.m_avatarUrl;
        m_tags = other.m_tags;
        m_isFavorite = other.m_isFavorite;
        m_dateAdded = other.m_dateAdded;
        m_dateModified = other.m_dateModified;
        m_contactFrequency = other.m_contactFrequency;
    }
    return *this;
}

// Move assignment
Contact& Contact::operator=(Contact &&other) noexcept
{
    if (this != &other) {
        m_id = std::move(other.m_id);
        m_firstName = std::move(other.m_firstName);
        m_lastName = std::move(other.m_lastName);
        m_email = std::move(other.m_email);
        m_phone = std::move(other.m_phone);
        m_company = std::move(other.m_company);
        m_jobTitle = std::move(other.m_jobTitle);
        m_address = std::move(other.m_address);
        m_notes = std::move(other.m_notes);
        m_avatarUrl = std::move(other.m_avatarUrl);
        m_tags = std::move(other.m_tags);
        m_isFavorite = other.m_isFavorite;
        m_dateAdded = std::move(other.m_dateAdded);
        m_dateModified = std::move(other.m_dateModified);
        m_contactFrequency = other.m_contactFrequency;
    }
    return *this;
}

// Setters with automatic dateModified update
void Contact::setFirstName(const QString &firstName)
{
    m_firstName = firstName;
    touch();
}

void Contact::setLastName(const QString &lastName)
{
    m_lastName = lastName;
    touch();
}

void Contact::setEmail(const QString &email)
{
    m_email = email;
    touch();
}

void Contact::setPhone(const QString &phone)
{
    m_phone = phone;
    touch();
}

void Contact::setCompany(const QString &company)
{
    m_company = company;
    touch();
}

void Contact::setJobTitle(const QString &jobTitle)
{
    m_jobTitle = jobTitle;
    touch();
}

void Contact::setAddress(const QString &address)
{
    m_address = address;
    touch();
}

void Contact::setNotes(const QString &notes)
{
    m_notes = notes;
    touch();
}

void Contact::setAvatarUrl(const QUrl &avatarUrl)
{
    m_avatarUrl = avatarUrl;
    touch();
}

void Contact::setTags(const QStringList &tags)
{
    m_tags = tags;
    touch();
}

void Contact::setIsFavorite(bool isFavorite)
{
    m_isFavorite = isFavorite;
    touch();
}

void Contact::setDateAdded(const QDateTime &dateAdded)
{
    m_dateAdded = dateAdded;
}

void Contact::setDateModified(const QDateTime &dateModified)
{
    m_dateModified = dateModified;
}

void Contact::setContactFrequency(int frequency)
{
    m_contactFrequency = frequency;
}

// Utility methods
void Contact::addTag(const QString &tag)
{
    if (!m_tags.contains(tag)) {
        m_tags.append(tag);
        touch();
    }
}

void Contact::removeTag(const QString &tag)
{
    if (m_tags.removeOne(tag)) {
        touch();
    }
}

bool Contact::hasTag(const QString &tag) const
{
    return m_tags.contains(tag);
}

void Contact::incrementContactFrequency()
{
    m_contactFrequency++;
    touch();
}

void Contact::touch()
{
    m_dateModified = QDateTime::currentDateTime();
}

// JSON serialization
QJsonObject Contact::toJson() const
{
    QJsonObject json;
    json["id"] = m_id;
    json["firstName"] = m_firstName;
    json["lastName"] = m_lastName;
    json["email"] = m_email;
    json["phone"] = m_phone;
    json["company"] = m_company;
    json["jobTitle"] = m_jobTitle;
    json["address"] = m_address;
    json["notes"] = m_notes;
    json["avatarUrl"] = m_avatarUrl.toString();

    QJsonArray tagsArray;
    for (const QString &tag : m_tags) {
        tagsArray.append(tag);
    }
    json["tags"] = tagsArray;

    json["isFavorite"] = m_isFavorite;
    json["dateAdded"] = m_dateAdded.toString(Qt::ISODate);
    json["dateModified"] = m_dateModified.toString(Qt::ISODate);
    json["contactFrequency"] = m_contactFrequency;

    return json;
}

Contact Contact::fromJson(const QJsonObject &json)
{
    Contact contact;

    contact.setId(json["id"].toString());
    contact.m_firstName = json["firstName"].toString();
    contact.m_lastName = json["lastName"].toString();
    contact.m_email = json["email"].toString();
    contact.m_phone = json["phone"].toString();
    contact.m_company = json["company"].toString();
    contact.m_jobTitle = json["jobTitle"].toString();
    contact.m_address = json["address"].toString();
    contact.m_notes = json["notes"].toString();
    contact.m_avatarUrl = QUrl(json["avatarUrl"].toString());

    QJsonArray tagsArray = json["tags"].toArray();
    QStringList tags;
    for (const QJsonValue &value : tagsArray) {
        tags.append(value.toString());
    }
    contact.m_tags = tags;

    contact.m_isFavorite = json["isFavorite"].toBool();
    contact.m_dateAdded = QDateTime::fromString(json["dateAdded"].toString(), Qt::ISODate);
    contact.m_dateModified = QDateTime::fromString(json["dateModified"].toString(), Qt::ISODate);
    contact.m_contactFrequency = json["contactFrequency"].toInt();

    return contact;
}

// Comparison operator
bool Contact::operator==(const Contact &other) const
{
    return m_id == other.m_id;
}

// Get initials for avatar display
QString Contact::initials() const
{
    QString result;
    if (!m_firstName.isEmpty()) {
        result += m_firstName[0].toUpper();
    }
    if (!m_lastName.isEmpty()) {
        result += m_lastName[0].toUpper();
    }
    return result.isEmpty() ? "?" : result;
}

// Get avatar color index (for consistent color selection)
int Contact::avatarColorIndex() const
{
    // Generate consistent color index based on name hash
    QString name = fullName();
    if (name.isEmpty()) name = m_id;

    uint hash = qHash(name);
    return static_cast<int>(hash % 8); // 8 different colors
}
