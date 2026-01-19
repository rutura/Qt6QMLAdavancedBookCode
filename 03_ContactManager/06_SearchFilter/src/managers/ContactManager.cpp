#include "ContactManager.h"
#include <QDebug>
#include <QRandomGenerator>

ContactManager::ContactManager(QObject *parent)
    : QObject(parent)
    , m_contactModel(new ContactListModel(this))
{
    // Setup signal connections
    setupConnections();

    // Generate sample contacts for demonstration
    generateSampleContacts(45);
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
 * Updates an existing contact at the specified index with all available fields.
 */
void ContactManager::updateContactFull(int index, const QString &firstName, const QString &lastName,
                                       const QString &email, const QString &phone,
                                       const QString &company, const QString &jobTitle,
                                       const QString &address, const QString &notes,
                                       bool isFavorite, const QStringList &tags)
{
    Contact contact(firstName, lastName);

    // Set all fields (including empty ones to allow clearing)
    contact.setEmail(email);
    contact.setPhone(phone);
    contact.setCompany(company);
    contact.setJobTitle(jobTitle);
    contact.setAddress(address);
    contact.setNotes(notes);
    contact.setIsFavorite(isFavorite);
    contact.setTags(tags);

    m_contactModel->updateContact(index, contact);
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
void ContactManager::generateSampleContacts(int count)
{
    // Sample data arrays
    QStringList firstNames = {
        "Emma", "Liam", "Olivia", "Noah", "Ava", "Ethan", "Sophia", "Mason",
        "Isabella", "William", "Mia", "James", "Charlotte", "Benjamin", "Amelia",
        "Lucas", "Harper", "Henry", "Evelyn", "Alexander", "Abigail", "Michael",
        "Emily", "Daniel", "Elizabeth", "Matthew", "Sofia", "Jackson", "Avery",
        "Sebastian", "Ella", "David", "Scarlett", "Joseph", "Grace", "Carter",
        "Chloe", "Owen", "Victoria", "Wyatt", "Riley", "John", "Aria", "Jack",
        "Lily", "Luke", "Aubrey", "Jayden", "Zoey", "Dylan", "Penelope", "Grayson",
        "Layla", "Levi", "Nora", "Isaac", "Hannah", "Gabriel", "Lillian", "Julian"
    };

    QStringList lastNames = {
        "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller",
        "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez",
        "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin",
        "Lee", "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark",
        "Ramirez", "Lewis", "Robinson", "Walker", "Young", "Allen", "King",
        "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores", "Green",
        "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell",
        "Carter", "Roberts", "Gomez", "Phillips", "Evans", "Turner", "Diaz",
        "Parker", "Cruz", "Edwards", "Collins", "Reyes"
    };

    QStringList companies = {
        "Tech Innovations Inc", "Global Solutions Ltd", "Creative Designs Co",
        "Data Systems Corp", "Smart Technologies", "Digital Ventures",
        "Cloud Services Inc", "Future Analytics", "Quantum Computing Ltd",
        "AI Research Group", "Cyber Security Solutions", "Web Development Pro",
        "Mobile Apps Studio", "Software Consulting", "IT Services Group",
        "Network Solutions", "Database Systems", "Enterprise Software",
        "Startup Accelerator", "Innovation Labs", "Product Design Studio",
        "Marketing Agency", "Finance Corporation", "Healthcare Systems",
        "Education Technology", "E-commerce Platform", "Social Media Inc",
        "Gaming Studios", "Robotics Engineering", "Green Energy Solutions"
    };

    QStringList jobTitles = {
        "Software Engineer", "Product Manager", "UX Designer", "Data Scientist",
        "DevOps Engineer", "Marketing Manager", "Sales Director", "CEO",
        "CTO", "Project Manager", "Business Analyst", "QA Engineer",
        "System Administrator", "Network Engineer", "Security Analyst",
        "Frontend Developer", "Backend Developer", "Full Stack Developer",
        "Mobile Developer", "UI Designer", "Graphic Designer", "Content Writer",
        "Account Manager", "HR Manager", "Financial Analyst", "Consultant",
        "Team Lead", "Senior Engineer", "Junior Developer", "Intern"
    };

    QStringList tags = {
        "work", "family", "friends", "client", "colleague", "vendor",
        "partner", "lead", "prospect", "alumni"
    };

    // Generate contacts
    for (int i = 0; i < count; ++i) {
        QString firstName = firstNames[QRandomGenerator::global()->bounded(firstNames.size())];
        QString lastName = lastNames[QRandomGenerator::global()->bounded(lastNames.size())];
        QString email = QString("%1.%2@example.com")
                           .arg(firstName.toLower())
                           .arg(lastName.toLower());
        QString phone = QString("+1-%1-%2-%3")
                           .arg(100 + QRandomGenerator::global()->bounded(900))
                           .arg(100 + QRandomGenerator::global()->bounded(900))
                           .arg(1000 + QRandomGenerator::global()->bounded(9000));

        Contact contact(firstName, lastName);
        contact.setEmail(email);
        contact.setPhone(phone);

        // Add company and job title for some contacts
        if (QRandomGenerator::global()->bounded(100) < 80) { // 80% have company
            contact.setCompany(companies[QRandomGenerator::global()->bounded(companies.size())]);
            contact.setJobTitle(jobTitles[QRandomGenerator::global()->bounded(jobTitles.size())]);
        }

        // Add tags (1-3 tags per contact)
        QStringList contactTags;
        int tagCount = 1 + QRandomGenerator::global()->bounded(3);
        for (int j = 0; j < tagCount; ++j) {
            QString tag = tags[QRandomGenerator::global()->bounded(tags.size())];
            if (!contactTags.contains(tag)) {
                contactTags.append(tag);
            }
        }
        contact.setTags(contactTags);

        // Mark some as favorites (first 6 contacts are favorites for demo)
        contact.setIsFavorite(i < 6);

        m_contactModel->addContact(contact);
    }

    qDebug() << "Generated" << count << "sample contacts";
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
