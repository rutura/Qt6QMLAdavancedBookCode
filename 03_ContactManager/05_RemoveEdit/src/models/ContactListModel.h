#ifndef CONTACTLISTMODEL_H
#define CONTACTLISTMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include "Contact.h"

/**
 * @brief The ContactListModel class is a QAbstractListModel implementation for managing contacts.
 *
 * This model provides full CRUD (Create, Read, Update, Delete) operations for contacts
 * and properly implements all required virtual methods from QAbstractListModel.
 * It emits appropriate signals when data changes to keep the UI synchronized.
 *
 * Key features:
 * - Add, update, remove contacts with proper model signals
 * - Custom role names for QML binding
 * - Editable items support via setData()
 * - Safe data access methods
 * - Bulk operations support
 */
class ContactListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    // Custom roles for QML access
    enum ContactRoles {
        IdRole = Qt::UserRole + 1,
        FirstNameRole,
        LastNameRole,
        FullNameRole,
        EmailRole,
        PhoneRole,
        CompanyRole,
        JobTitleRole,
        AddressRole,
        NotesRole,
        AvatarUrlRole,
        TagsRole,
        IsFavoriteRole,
        DateAddedRole,
        DateModifiedRole,
        ContactFrequencyRole,
        InitialsRole,
        AvatarColorIndexRole
    };

    explicit ContactListModel(QObject *parent = nullptr);
    ~ContactListModel() override = default;

    // Required QAbstractListModel overrides
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    // Public methods for contact management (Q_INVOKABLE for QML access)
    Q_INVOKABLE void addContact(const QString &firstName, const QString &lastName,
                                const QString &email = QString(),
                                const QString &phone = QString());
    Q_INVOKABLE void removeContact(int index);
    Q_INVOKABLE void clear();
    Q_INVOKABLE void toggleFavorite(int index);
    Q_INVOKABLE Contact getContact(int index) const;

    // C++ methods for advanced operations
    void addContact(const Contact &contact);
    void addContacts(const QVector<Contact> &contacts);
    void updateContact(int index, const Contact &contact);
    QVector<Contact> getAllContacts() const;
    int count() const { return m_contacts.size(); }

    // Sorting support
    void sortByName(Qt::SortOrder order = Qt::AscendingOrder);
    void sortByDateAdded(Qt::SortOrder order = Qt::DescendingOrder);
    void sortByDateModified(Qt::SortOrder order = Qt::DescendingOrder);
    void sortByFrequency(Qt::SortOrder order = Qt::DescendingOrder);

signals:
    void countChanged();
    void contactAdded(int index);
    void contactRemoved(int index);
    void contactUpdated(int index);

private:
    QVector<Contact> m_contacts;

    // Helper methods
    bool isValidIndex(int index) const;
    void emitDataChanged(int index);
};

#endif // CONTACTLISTMODEL_H
