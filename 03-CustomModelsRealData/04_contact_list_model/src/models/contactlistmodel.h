
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
        AvatarColorIndexRole
    };
    explicit ContactListModel(QObject *parent = nullptr);
    ~ContactListModel() override = default;


    // Required QAbstractListModel overrides
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const { return m_contacts.size(); }

signals:
    void countChanged();

private:
    QVector<Contact> m_contacts;
};

#endif // CONTACTLISTMODEL_H
