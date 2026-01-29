#ifndef CONTACTMANAGER_H
#define CONTACTMANAGER_H

#include <QObject>
#include <QQmlEngine>
#include "models/contactListModel.h"

/**
 * @brief The ContactManager class orchestrates contact management operations.
 *
 * This is the main business logic layer that:
 * - Owns the ContactListModel
 * - Exposes the model to QML
 * - Manages contact statistics
 * - Generates sample contacts for demonstration
 *
 * This class serves as the single point of contact (no pun intended)
 * between QML and the C++ backend.
 */
class ContactManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(ContactListModel* contactModel READ contactModel CONSTANT)
    Q_PROPERTY(int totalContacts READ totalContacts NOTIFY totalContactsChanged)
    Q_PROPERTY(int favoritesCount READ favoritesCount NOTIFY favoritesCountChanged)

public:
    explicit ContactManager(QObject *parent = nullptr);

    // Property getters
    ContactListModel* contactModel() const { return m_contactModel; }
    int totalContacts() const;
    int favoritesCount() const;

    // Contact management (delegates to model)
    Q_INVOKABLE void addContact(const QString &firstName, const QString &lastName,
                                const QString &email = QString(),
                                const QString &phone = QString());
    Q_INVOKABLE void addContactFull(const QString &firstName, const QString &lastName,
                                    const QString &email, const QString &phone,
                                    const QString &company, const QString &jobTitle,
                                    const QString &address, const QString &notes,
                                    bool isFavorite, const QStringList &tags);
    Q_INVOKABLE void removeContact(int index);
    Q_INVOKABLE void toggleFavorite(int index);
    Q_INVOKABLE void clearAllContacts();

    // Bulk operations
    Q_INVOKABLE void generateSampleContacts(int count = 50);

signals:
    void totalContactsChanged();
    void favoritesCountChanged();

private slots:
    void onContactAdded();
    void onContactRemoved();
    void onContactUpdated();

private:
    ContactListModel *m_contactModel;

    void setupConnections();
    void updateStatistics();
};

#endif // CONTACTMANAGER_H
