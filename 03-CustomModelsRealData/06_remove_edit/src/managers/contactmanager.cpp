#include "contactManager.h"
#include <QDebug>

ContactManager::ContactManager(QObject *parent)
    : QObject(parent)
    , m_contactModel(new ContactListModel(this))
{
    // Setup signal connections
    setupConnections();

    // Generate sample contacts for demonstration
    generateSampleContacts();
}

/**
 * Returns the total number of contacts.
 */
int ContactManager::totalContacts() const
{
    return m_contactModel->count();
}

/**
 * Returns the number of favorite contacts.
 */
int ContactManager::favoritesCount() const
{
    int count = 0;
    for (int i = 0; i < m_contactModel->count(); ++i) {
        Contact contact = m_contactModel->getContact(i);
        if (contact.isFavorite()) {
            count++;
        }
    }
    return count;
}

/**
 * Adds a new contact with basic information.
 */
void ContactManager::addContact(const QString &firstName, const QString &lastName,
                                const QString &email, const QString &phone)
{
    m_contactModel->addContact(firstName, lastName, email, phone);
}

/**
 * Adds a new contact with all available fields.
 */
void ContactManager::addContactFull(const QString &firstName, const QString &lastName,
                                    const QString &email, const QString &phone,
                                    const QString &company, const QString &jobTitle,
                                    const QString &address, const QString &notes,
                                    bool isFavorite, const QStringList &tags)
{
    Contact contact(firstName, lastName);

    if (!email.isEmpty())
        contact.setEmail(email);
    if (!phone.isEmpty())
        contact.setPhone(phone);
    if (!company.isEmpty())
        contact.setCompany(company);
    if (!jobTitle.isEmpty())
        contact.setJobTitle(jobTitle);
    if (!address.isEmpty())
        contact.setAddress(address);
    if (!notes.isEmpty())
        contact.setNotes(notes);

    contact.setIsFavorite(isFavorite);
    contact.setTags(tags);

    m_contactModel->addContact(contact);
}

/**
 * Updates an existing contact with all available fields.
 */
void ContactManager::updateContactFull(int index, const QString &firstName, const QString &lastName,
                                       const QString &email, const QString &phone,
                                       const QString &company, const QString &jobTitle,
                                       const QString &address, const QString &notes,
                                       bool isFavorite, const QStringList &tags)
{
    if (index < 0 || index >= m_contactModel->count()) {
        qWarning() << "Invalid index for updateContactFull:" << index;
        return;
    }

    Contact contact = m_contactModel->getContact(index);

    contact.setFirstName(firstName);
    contact.setLastName(lastName);
    contact.setEmail(email);
    contact.setPhone(phone);
    contact.setCompany(company);
    contact.setJobTitle(jobTitle);
    contact.setAddress(address);
    contact.setNotes(notes);
    contact.setIsFavorite(isFavorite);
    contact.setTags(tags);
    contact.touch();

    m_contactModel->updateContact(index, contact);
}

/**
 * Returns contact data as a QVariantMap for QML consumption.
 */
QVariantMap ContactManager::getContactData(int index) const
{
    QVariantMap data;
    if (index < 0 || index >= m_contactModel->count()) {
        return data;
    }

    Contact contact = m_contactModel->getContact(index);
    data["firstName"] = contact.firstName();
    data["lastName"] = contact.lastName();
    data["email"] = contact.email();
    data["phone"] = contact.phone();
    data["company"] = contact.company();
    data["jobTitle"] = contact.jobTitle();
    data["address"] = contact.address();
    data["notes"] = contact.notes();
    data["isFavorite"] = contact.isFavorite();
    data["tags"] = contact.tags();
    data["avatarColor"] = m_contactModel->data(m_contactModel->index(index), ContactListModel::AvatarColorRole).toString();

    return data;
}

/**
 * Removes a contact at the specified index.
 */
void ContactManager::removeContact(int index)
{
    m_contactModel->removeContact(index);
}

/**
 * Toggles the favorite status of a contact.
 */
void ContactManager::toggleFavorite(int index)
{
    m_contactModel->toggleFavorite(index);
}

/**
 * Removes all contacts.
 */
void ContactManager::clearAllContacts()
{
    m_contactModel->clear();
}

/**
 * Generates sample contacts for testing/demonstration.
 */
void ContactManager::generateSampleContacts()
{
    Contact c1("Emma", "Johnson");
    c1.setEmail("emma.johnson@example.com");
    c1.setPhone("+1-555-123-4567");
    c1.setCompany("Tech Innovations Inc");
    c1.setJobTitle("Software Engineer");
    c1.setTags({"work", "colleague"});
    c1.setAddress("123 Maple Street");
    c1.setNotes("The phoenix king");
    c1.setIsFavorite(true);
    m_contactModel->addContact(c1);

    Contact c2("Liam", "Williams");
    c2.setEmail("liam.williams@example.com");
    c2.setPhone("+1-555-234-5678");
    c2.setCompany("Global Solutions Ltd");
    c2.setJobTitle("Product Manager");
    c2.setTags({"work", "client"});
    c2.setIsFavorite(true);
    m_contactModel->addContact(c2);

    Contact c3("Olivia", "Brown");
    c3.setEmail("olivia.brown@example.com");
    c3.setPhone("+1-555-345-6789");
    c3.setCompany("Creative Designs Co");
    c3.setJobTitle("UX Designer");
    c3.setTags({"friends"});
    c3.setIsFavorite(false);
    m_contactModel->addContact(c3);

    Contact c4("Noah", "Davis");
    c4.setEmail("noah.davis@example.com");
    c4.setPhone("+1-555-456-7890");
    c4.setCompany("Data Systems Corp");
    c4.setJobTitle("Data Scientist");
    c4.setTags({"work", "lead"});
    c4.setIsFavorite(false);
    m_contactModel->addContact(c4);

    Contact c5("Sophia", "Martinez");
    c5.setEmail("sophia.martinez@example.com");
    c5.setPhone("+1-555-567-8901");
    c5.setCompany("Smart Technologies");
    c5.setJobTitle("CTO");
    c5.setTags({"family", "friends"});
    c5.setIsFavorite(true);
    m_contactModel->addContact(c5);
}

/**
 * Sets up signal connections for statistics updates.
 */
void ContactManager::setupConnections()
{
    connect(m_contactModel, &ContactListModel::contactAdded,
            this, &ContactManager::onContactAdded);
    connect(m_contactModel, &ContactListModel::contactRemoved,
            this, &ContactManager::onContactRemoved);
    connect(m_contactModel, &ContactListModel::contactUpdated,
            this, &ContactManager::onContactUpdated);
}

/**
 * Called when a contact is added.
 */
void ContactManager::onContactAdded()
{
    updateStatistics();
}

/**
 * Called when a contact is removed.
 */
void ContactManager::onContactRemoved()
{
    updateStatistics();
}

/**
 * Called when a contact is updated.
 */
void ContactManager::onContactUpdated()
{
    updateStatistics();
}

/**
 * Updates statistics signals.
 */
void ContactManager::updateStatistics()
{
    emit totalContactsChanged();
    emit favoritesCountChanged();
}
