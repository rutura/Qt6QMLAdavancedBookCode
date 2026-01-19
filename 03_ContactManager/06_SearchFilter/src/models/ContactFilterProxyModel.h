#ifndef CONTACTFILTERPROXYMODEL_H
#define CONTACTFILTERPROXYMODEL_H

#include <QSortFilterProxyModel>
#include <QStringList>
#include <QQmlEngine>

/**
 * @brief The ContactFilterProxyModel class provides filtering and sorting for contacts.
 *
 * This proxy model wraps the ContactListModel and provides:
 * - Filtering by favorites only
 * - Filtering by search text (name, email, phone)
 * - Filtering by tags (one or more)
 * - Sorting by name (ascending/descending)
 *
 * All filtering operations are dynamic and update the view immediately.
 */
class ContactFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(bool favoritesOnly READ favoritesOnly WRITE setFavoritesOnly NOTIFY favoritesOnlyChanged)
    Q_PROPERTY(QString searchText READ searchText WRITE setSearchText NOTIFY searchTextChanged)
    Q_PROPERTY(QStringList selectedTags READ selectedTags WRITE setSelectedTags NOTIFY selectedTagsChanged)
    Q_PROPERTY(bool sortAscending READ sortAscending WRITE setSortAscending NOTIFY sortAscendingChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit ContactFilterProxyModel(QObject *parent = nullptr);

    // Property getters
    bool favoritesOnly() const { return m_favoritesOnly; }
    QString searchText() const { return m_searchText; }
    QStringList selectedTags() const { return m_selectedTags; }
    bool sortAscending() const { return m_sortAscending; }
    int count() const { return rowCount(); }

    // Property setters
    void setFavoritesOnly(bool favoritesOnly);
    void setSearchText(const QString &searchText);
    void setSelectedTags(const QStringList &selectedTags);
    void setSortAscending(bool ascending);

    // Q_INVOKABLE methods for QML
    Q_INVOKABLE void toggleTag(const QString &tag);
    Q_INVOKABLE void clearFilters();
    Q_INVOKABLE int mapToSourceIndex(int proxyIndex) const;
    Q_INVOKABLE int mapFromSourceIndex(int sourceIndex) const;

signals:
    void favoritesOnlyChanged();
    void searchTextChanged();
    void selectedTagsChanged();
    void sortAscendingChanged();
    void countChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;

private:
    bool m_favoritesOnly;
    QString m_searchText;
    QStringList m_selectedTags;
    bool m_sortAscending;

    // Helper methods
    bool matchesSearchText(int sourceRow, const QModelIndex &sourceParent) const;
    bool matchesTags(int sourceRow, const QModelIndex &sourceParent) const;
    bool matchesFavorites(int sourceRow, const QModelIndex &sourceParent) const;
};

#endif // CONTACTFILTERPROXYMODEL_H
