#include "ContactFilterProxyModel.h"
#include "ContactListModel.h"

ContactFilterProxyModel::ContactFilterProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent)
    , m_favoritesOnly(false)
    , m_sortAscending(true)
{
    // Enable dynamic sorting
    setDynamicSortFilter(true);

    // Connect to rowCount changes for count property
    connect(this, &QAbstractItemModel::rowsInserted, this, &ContactFilterProxyModel::countChanged);
    connect(this, &QAbstractItemModel::rowsRemoved, this, &ContactFilterProxyModel::countChanged);
    connect(this, &QAbstractItemModel::modelReset, this, &ContactFilterProxyModel::countChanged);
    connect(this, &QAbstractItemModel::layoutChanged, this, &ContactFilterProxyModel::countChanged);
}

void ContactFilterProxyModel::setFavoritesOnly(bool favoritesOnly)
{
    if (m_favoritesOnly == favoritesOnly)
        return;

    m_favoritesOnly = favoritesOnly;
    invalidateFilter();
    emit favoritesOnlyChanged();
    emit countChanged();
}

void ContactFilterProxyModel::setSearchText(const QString &searchText)
{
    if (m_searchText == searchText)
        return;

    m_searchText = searchText;
    invalidateFilter();
    emit searchTextChanged();
    emit countChanged();
}

void ContactFilterProxyModel::setSelectedTags(const QStringList &selectedTags)
{
    if (m_selectedTags == selectedTags)
        return;

    m_selectedTags = selectedTags;
    invalidateFilter();
    emit selectedTagsChanged();
    emit countChanged();
}

void ContactFilterProxyModel::setSortAscending(bool ascending)
{
    if (m_sortAscending == ascending)
        return;

    m_sortAscending = ascending;
    sort(0, ascending ? Qt::AscendingOrder : Qt::DescendingOrder);
    emit sortAscendingChanged();
}

void ContactFilterProxyModel::toggleTag(const QString &tag)
{
    QStringList tags = m_selectedTags;
    if (tags.contains(tag)) {
        tags.removeAll(tag);
    } else {
        tags.append(tag);
    }
    setSelectedTags(tags);
}

void ContactFilterProxyModel::clearFilters()
{
    m_favoritesOnly = false;
    m_searchText.clear();
    m_selectedTags.clear();
    invalidateFilter();
    emit favoritesOnlyChanged();
    emit searchTextChanged();
    emit selectedTagsChanged();
    emit countChanged();
}

int ContactFilterProxyModel::mapToSourceIndex(int proxyIndex) const
{
    QModelIndex proxyIdx = index(proxyIndex, 0);
    QModelIndex sourceIdx = mapToSource(proxyIdx);
    return sourceIdx.row();
}

int ContactFilterProxyModel::mapFromSourceIndex(int sourceIndex) const
{
    QModelIndex sourceIdx = sourceModel()->index(sourceIndex, 0);
    QModelIndex proxyIdx = mapFromSource(sourceIdx);
    return proxyIdx.row();
}

bool ContactFilterProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    // Check favorites filter
    if (!matchesFavorites(sourceRow, sourceParent))
        return false;

    // Check search text filter
    if (!matchesSearchText(sourceRow, sourceParent))
        return false;

    // Check tags filter
    if (!matchesTags(sourceRow, sourceParent))
        return false;

    return true;
}

bool ContactFilterProxyModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    // Sort by full name
    QVariant leftData = sourceModel()->data(left, ContactListModel::FullNameRole);
    QVariant rightData = sourceModel()->data(right, ContactListModel::FullNameRole);

    return leftData.toString().toLower() < rightData.toString().toLower();
}

bool ContactFilterProxyModel::matchesSearchText(int sourceRow, const QModelIndex &sourceParent) const
{
    if (m_searchText.isEmpty())
        return true;

    QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
    QString searchLower = m_searchText.toLower();

    // Search in first name
    QString firstName = sourceModel()->data(index, ContactListModel::FirstNameRole).toString();
    if (firstName.toLower().contains(searchLower))
        return true;

    // Search in last name
    QString lastName = sourceModel()->data(index, ContactListModel::LastNameRole).toString();
    if (lastName.toLower().contains(searchLower))
        return true;

    // Search in full name
    QString fullName = sourceModel()->data(index, ContactListModel::FullNameRole).toString();
    if (fullName.toLower().contains(searchLower))
        return true;

    // Search in email
    QString email = sourceModel()->data(index, ContactListModel::EmailRole).toString();
    if (email.toLower().contains(searchLower))
        return true;

    // Search in phone
    QString phone = sourceModel()->data(index, ContactListModel::PhoneRole).toString();
    if (phone.contains(searchLower))
        return true;

    return false;
}

bool ContactFilterProxyModel::matchesTags(int sourceRow, const QModelIndex &sourceParent) const
{
    if (m_selectedTags.isEmpty())
        return true;

    QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
    QStringList contactTags = sourceModel()->data(index, ContactListModel::TagsRole).toStringList();

    // Contact must have at least one of the selected tags
    for (const QString &tag : m_selectedTags) {
        if (contactTags.contains(tag))
            return true;
    }

    return false;
}

bool ContactFilterProxyModel::matchesFavorites(int sourceRow, const QModelIndex &sourceParent) const
{
    if (!m_favoritesOnly)
        return true;

    QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
    return sourceModel()->data(index, ContactListModel::IsFavoriteRole).toBool();
}
