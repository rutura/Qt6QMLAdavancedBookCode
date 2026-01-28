#include "contactlistmodel.h"
#include <QDebug>

ContactListModel::ContactListModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

/**
 * Returns the number of rows (contacts) in the model.
 * Required override from QAbstractListModel.
 */
int ContactListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_contacts.size();
}

/**
 * Returns data for a given model index and role.
 * This is the primary data access method called by QML views.
 * Required override from QAbstractListModel.
 */
QVariant ContactListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_contacts.size())
        return QVariant();

    const Contact &contact = m_contacts.at(index.row());

    switch (role) {
    case IdRole:
        return contact.id();
    case FirstNameRole:
        return contact.firstName();
    case LastNameRole:
        return contact.lastName();
    case FullNameRole:
        return contact.fullName();
    case EmailRole:
        return contact.email();
    case PhoneRole:
        return contact.phone();
    case CompanyRole:
        return contact.company();
    case JobTitleRole:
        return contact.jobTitle();
    case AddressRole:
        return contact.address();
    case NotesRole:
        return contact.notes();
    case AvatarUrlRole:
        return contact.avatarUrl();
    case TagsRole:
        return contact.tags();
    case IsFavoriteRole:
        return contact.isFavorite();
    case DateAddedRole:
        return contact.dateAdded();
    case DateModifiedRole:
        return contact.dateModified();
    case InitialsRole:
        return contact.initials();
    case AvatarColorIndexRole:
        return contact.avatarColorIndex();
    default:
        return QVariant();
    }
}

/**
 * Returns the role names for QML property binding.
 * This maps role enums to QML-accessible property names.
 * Required override from QAbstractListModel.
 */
QHash<int, QByteArray> ContactListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "contactId";
    roles[FirstNameRole] = "firstName";
    roles[LastNameRole] = "lastName";
    roles[FullNameRole] = "fullName";
    roles[EmailRole] = "email";
    roles[PhoneRole] = "phone";
    roles[CompanyRole] = "company";
    roles[JobTitleRole] = "jobTitle";
    roles[AddressRole] = "address";
    roles[NotesRole] = "notes";
    roles[AvatarUrlRole] = "avatarUrl";
    roles[TagsRole] = "tags";
    roles[IsFavoriteRole] = "isFavorite";
    roles[DateAddedRole] = "dateAdded";
    roles[DateModifiedRole] = "dateModified";
    roles[ContactFrequencyRole] = "contactFrequency";
    roles[InitialsRole] = "initials";
    roles[AvatarColorIndexRole] = "avatarColorIndex";
    return roles;
}
