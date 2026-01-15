#include "ContactListModel.h"
#include <QDebug>
#include <algorithm>

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
    case ContactFrequencyRole:
        return contact.contactFrequency();
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

/**
 * Allows editing of contact data from QML.
 * Emits dataChanged() signal when successful.
 */
bool ContactListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || index.row() >= m_contacts.size())
        return false;

    Contact &contact = m_contacts[index.row()];
    bool changed = false;

    switch (role) {
    case FirstNameRole:
        if (contact.firstName() != value.toString()) {
            contact.setFirstName(value.toString());
            changed = true;
        }
        break;
    case LastNameRole:
        if (contact.lastName() != value.toString()) {
            contact.setLastName(value.toString());
            changed = true;
        }
        break;
    case EmailRole:
        if (contact.email() != value.toString()) {
            contact.setEmail(value.toString());
            changed = true;
        }
        break;
    case PhoneRole:
        if (contact.phone() != value.toString()) {
            contact.setPhone(value.toString());
            changed = true;
        }
        break;
    case CompanyRole:
        if (contact.company() != value.toString()) {
            contact.setCompany(value.toString());
            changed = true;
        }
        break;
    case JobTitleRole:
        if (contact.jobTitle() != value.toString()) {
            contact.setJobTitle(value.toString());
            changed = true;
        }
        break;
    case AddressRole:
        if (contact.address() != value.toString()) {
            contact.setAddress(value.toString());
            changed = true;
        }
        break;
    case NotesRole:
        if (contact.notes() != value.toString()) {
            contact.setNotes(value.toString());
            changed = true;
        }
        break;
    case IsFavoriteRole:
        if (contact.isFavorite() != value.toBool()) {
            contact.setIsFavorite(value.toBool());
            changed = true;
        }
        break;
    case TagsRole:
        if (contact.tags() != value.toStringList()) {
            contact.setTags(value.toStringList());
            changed = true;
        }
        break;
    default:
        return false;
    }

    if (changed) {
        emitDataChanged(index.row());
        emit contactUpdated(index.row());
    }

    return changed;
}

/**
 * Returns flags indicating the item is enabled and editable.
 */
Qt::ItemFlags ContactListModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsEditable;
}

/**
 * Adds a new contact with basic information.
 * This is the QML-friendly version.
 */
void ContactListModel::addContact(const QString &firstName, const QString &lastName,
                                  const QString &email, const QString &phone)
{
    Contact contact(firstName, lastName);
    if (!email.isEmpty())
        contact.setEmail(email);
    if (!phone.isEmpty())
        contact.setPhone(phone);

    addContact(contact);
}

/**
 * Adds a new contact to the model.
 * Properly uses beginInsertRows/endInsertRows for view synchronization.
 */
void ContactListModel::addContact(const Contact &contact)
{
    int newRow = m_contacts.size();

    // Signal to views that we're about to insert a row
    beginInsertRows(QModelIndex(), newRow, newRow);
    m_contacts.append(contact);
    endInsertRows();

    emit countChanged();
    emit contactAdded(newRow);
}

/**
 * Adds multiple contacts efficiently (bulk operation).
 */
void ContactListModel::addContacts(const QVector<Contact> &contacts)
{
    if (contacts.isEmpty())
        return;

    int firstRow = m_contacts.size();
    int lastRow = firstRow + contacts.size() - 1;

    beginInsertRows(QModelIndex(), firstRow, lastRow);
    m_contacts.append(contacts);
    endInsertRows();

    emit countChanged();
}

/**
 * Removes a contact at the specified index.
 * Properly uses beginRemoveRows/endRemoveRows for view synchronization.
 */
void ContactListModel::removeContact(int index)
{
    if (!isValidIndex(index))
        return;

    beginRemoveRows(QModelIndex(), index, index);
    m_contacts.remove(index);
    endRemoveRows();

    emit countChanged();
    emit contactRemoved(index);
}

/**
 * Updates an existing contact with new data.
 * Emits dataChanged signal to refresh views.
 */
void ContactListModel::updateContact(int index, const Contact &contact)
{
    if (!isValidIndex(index))
        return;

    m_contacts[index] = contact;
    emitDataChanged(index);
    emit contactUpdated(index);
}

/**
 * Returns a copy of the contact at the specified index.
 * Safe method that validates index before access.
 */
Contact ContactListModel::getContact(int index) const
{
    if (!isValidIndex(index))
        return Contact();

    return m_contacts.at(index);
}

/**
 * Returns all contacts in the model.
 */
QVector<Contact> ContactListModel::getAllContacts() const
{
    return m_contacts;
}

/**
 * Removes all contacts from the model.
 */
void ContactListModel::clear()
{
    if (m_contacts.isEmpty())
        return;

    beginResetModel();
    m_contacts.clear();
    endResetModel();

    emit countChanged();
}

/**
 * Toggles the favorite status of a contact.
 */
void ContactListModel::toggleFavorite(int index)
{
    if (!isValidIndex(index))
        return;

    m_contacts[index].setIsFavorite(!m_contacts[index].isFavorite());
    emitDataChanged(index);
    emit contactUpdated(index);
}

/**
 * Sorts contacts by name (first name, then last name).
 */
void ContactListModel::sortByName(Qt::SortOrder order)
{
    beginResetModel();

    std::sort(m_contacts.begin(), m_contacts.end(), [order](const Contact &a, const Contact &b) {
        int cmp = a.fullName().compare(b.fullName(), Qt::CaseInsensitive);
        return order == Qt::AscendingOrder ? cmp < 0 : cmp > 0;
    });

    endResetModel();
}

/**
 * Sorts contacts by date added.
 */
void ContactListModel::sortByDateAdded(Qt::SortOrder order)
{
    beginResetModel();

    std::sort(m_contacts.begin(), m_contacts.end(), [order](const Contact &a, const Contact &b) {
        return order == Qt::AscendingOrder
            ? a.dateAdded() < b.dateAdded()
            : a.dateAdded() > b.dateAdded();
    });

    endResetModel();
}

/**
 * Sorts contacts by date modified.
 */
void ContactListModel::sortByDateModified(Qt::SortOrder order)
{
    beginResetModel();

    std::sort(m_contacts.begin(), m_contacts.end(), [order](const Contact &a, const Contact &b) {
        return order == Qt::AscendingOrder
            ? a.dateModified() < b.dateModified()
            : a.dateModified() > b.dateModified();
    });

    endResetModel();
}

/**
 * Sorts contacts by contact frequency.
 */
void ContactListModel::sortByFrequency(Qt::SortOrder order)
{
    beginResetModel();

    std::sort(m_contacts.begin(), m_contacts.end(), [order](const Contact &a, const Contact &b) {
        return order == Qt::AscendingOrder
            ? a.contactFrequency() < b.contactFrequency()
            : a.contactFrequency() > b.contactFrequency();
    });

    endResetModel();
}

/**
 * Validates that an index is within the valid range.
 */
bool ContactListModel::isValidIndex(int index) const
{
    return index >= 0 && index < m_contacts.size();
}

/**
 * Emits dataChanged for all roles of a contact at the given index.
 * This notifies views that the data has been updated.
 */
void ContactListModel::emitDataChanged(int index)
{
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex);
}
