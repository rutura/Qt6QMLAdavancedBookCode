
#ifndef CONTACTLISTMODEL_H
#define CONTACTLISTMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include "Contact.h"

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
        AvatarColorIndexRole,
        AvatarColorRole
    };
    explicit ContactListModel(QObject *parent = nullptr);
    ~ContactListModel() override = default;


    // Required QAbstractListModel overrides
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    // C++ methods for advanced operations
    int count() const { return m_contacts.size(); }
    void addContact(const Contact &contact);
    void addContacts(const QVector<Contact> &contacts);
    void updateContact(int index, const Contact &contact);
    QVector<Contact> getAllContacts() const;

    // QML-accessible methods
    Q_INVOKABLE void toggleFavorite(int row);
    Q_INVOKABLE void addContact(const QString &firstName, const QString &lastName,
                                const QString &email = QString(),
                                const QString &phone = QString());
    Q_INVOKABLE void removeContact(int index);
    Q_INVOKABLE void clear();
    Q_INVOKABLE Contact getContact(int index) const;


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
