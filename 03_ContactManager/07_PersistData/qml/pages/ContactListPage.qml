import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import ContactManagerApp

/**
 * ContactListPage - Main page showing the list of contacts
 *
 * Displays the contact list from C++ ContactListModel via ContactFilterProxyModel.
 * Supports swipe gestures for edit/delete and tap to view.
 * Features filtering by favorites, tags, search text, and sorting by name.
 */
Page {
    id: root

    // ContactManager is passed in from Main.qml
    required property ContactManager contactManager

    signal contactSelected(int index)

    // Track which contact is being deleted
    property int deleteContactIndex: -1
    property string deleteContactName: ""

    background: Rectangle {
        color: "#F9FAFB"
    }

    // Avatar color palette (maps avatarColorIndex to actual colors)
    readonly property var avatarColors: [
        "#16A34A", "#0EA5E9", "#8B5CF6", "#0D9488",
        "#EC4899", "#6366F1", "#F59E0B", "#EF4444"
    ]

    // Helper function to get avatar color from index
    function getAvatarColor(colorIndex) {
        return avatarColors[colorIndex % avatarColors.length]
    }

    header: ToolBar {
        height: 80

        background: Rectangle {
            color: "#FFFFFF"

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#E5E7EB"
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            spacing: 16

            Text {
                text: "Contacts"
                font.pixelSize: 28
                font.weight: Font.Bold
                color: "#111827"
            }

            Item { Layout.fillWidth: true }

            Text {
                text: root.contactManager.proxyModel.count + " contacts"
                font.pixelSize: 14
                color: "#6B7280"
            }

            Button {
                text: "+ Add"

                background: Rectangle {
                    color: parent.pressed ? "#2563EB" : parent.hovered ? "#3B82F6" : "#3B82F6"
                    radius: 10

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 20
                    rightPadding: 20
                    topPadding: 10
                    bottomPadding: 10
                }

                onClicked: contactDialog.openAdd()
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24

        // Left sidebar - Filters
        FilterPanel {
            id: filterPanel
            Layout.preferredWidth: 280
            Layout.fillHeight: true

            onFavoritesToggled: function(enabled) {
                root.contactManager.proxyModel.favoritesOnly = enabled
            }

            onSortChanged: function(sortBy, ascending) {
                root.contactManager.proxyModel.sortAscending = ascending
            }

            onTagToggled: function(tag) {
                root.contactManager.proxyModel.selectedTags = filterPanel.selectedTags
            }
        }

        // Right side - Search and Contact List
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16

            // Search bar
            SearchBar {
                id: searchBar
                Layout.fillWidth: true

                onSearchTextChanged: function(text) {
                    root.contactManager.proxyModel.searchText = text
                }
            }

            // Contact list
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#FFFFFF"
                radius: 12

                ListView {
                    id: contactListView
                    anchors.fill: parent
                    anchors.margins: 8
                    clip: true
                    spacing: 0

                    model: root.contactManager.proxyModel

                    delegate: ContactDelegate {
                        width: contactListView.width
                        height: 80

                        firstName: model.firstName
                        lastName: model.lastName
                        email: model.email
                        isFavorite: model.isFavorite
                        avatarColor: root.getAvatarColor(model.avatarColorIndex)
                        tags: model.tags

                        // Tap to view contact details
                        onClicked: {
                            // Map proxy index to source index for operations
                            let sourceIndex = root.contactManager.proxyModel.mapToSourceIndex(index)
                            // Get full contact data from model
                            let contact = {
                                firstName: model.firstName,
                                lastName: model.lastName,
                                email: model.email,
                                phone: model.phone,
                                company: model.company,
                                jobTitle: model.jobTitle,
                                address: model.address,
                                notes: model.notes,
                                isFavorite: model.isFavorite,
                                tags: model.tags,
                                contactId: model.contactId
                            }
                            contactDialog.openView(sourceIndex, contact)
                        }

                        onFavoriteToggled: {
                            let sourceIndex = root.contactManager.proxyModel.mapToSourceIndex(index)
                            root.contactManager.toggleFavorite(sourceIndex)
                        }

                        // Swipe right to edit
                        onEditRequested: {
                            let sourceIndex = root.contactManager.proxyModel.mapToSourceIndex(index)
                            let contact = {
                                firstName: model.firstName,
                                lastName: model.lastName,
                                email: model.email,
                                phone: model.phone,
                                company: model.company,
                                jobTitle: model.jobTitle,
                                address: model.address,
                                notes: model.notes,
                                isFavorite: model.isFavorite,
                                tags: model.tags,
                                contactId: model.contactId
                            }
                            contactDialog.openEdit(sourceIndex, contact)
                        }

                        // Swipe left to delete
                        onDeleteRequested: {
                            let sourceIndex = root.contactManager.proxyModel.mapToSourceIndex(index)
                            root.deleteContactIndex = sourceIndex
                            root.deleteContactName = model.firstName + " " + model.lastName
                            deleteDialog.open()
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded

                        background: Rectangle {
                            color: "transparent"
                        }

                        contentItem: Rectangle {
                            implicitWidth: 6
                            radius: 3
                            color: parent.pressed ? "#9CA3AF" : "#D1D5DB"

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }
                    }

                    // Empty state - no contacts at all
                    Item {
                        anchors.centerIn: parent
                        visible: root.contactManager.contactModel.count === 0
                        width: 300
                        height: 200

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 16

                            Text {
                                text: "No contacts found"
                                font.pixelSize: 64
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: "No contacts"
                                font.pixelSize: 20
                                font.weight: Font.DemiBold
                                color: "#111827"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: "Add your first contact to get started"
                                font.pixelSize: 14
                                color: "#6B7280"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // Empty state - filters yielded no results
                    Item {
                        anchors.centerIn: parent
                        visible: root.contactManager.contactModel.count > 0 && root.contactManager.proxyModel.count === 0
                        width: 300
                        height: 200

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 16

                            Text {
                                text: "🔍"
                                font.pixelSize: 64
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: "No matching contacts"
                                font.pixelSize: 20
                                font.weight: Font.DemiBold
                                color: "#111827"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: filterPanel.selectedTags.length > 0
                                      ? "No contacts found with the selected tags"
                                      : "Try adjusting your search or filters"
                                font.pixelSize: 14
                                color: "#6B7280"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
    }

    // Multi-mode contact dialog (Add/Edit/View)
    ContactDialog {
        id: contactDialog

        onContactAdded: function(firstName, lastName, email, phone, company, jobTitle, address, notes, isFavorite, tags) {
            root.contactManager.addContactFull(firstName, lastName, email, phone, company, jobTitle, address, notes, isFavorite, tags)
        }

        onContactUpdated: function(index, firstName, lastName, email, phone, company, jobTitle, address, notes, isFavorite, tags) {
            root.contactManager.updateContactFull(index, firstName, lastName, email, phone, company, jobTitle, address, notes, isFavorite, tags)
        }
    }

    // Delete confirmation dialog
    DeleteConfirmationDialog {
        id: deleteDialog

        contactName: root.deleteContactName

        onDeleteConfirmed: {
            if (root.deleteContactIndex >= 0) {
                root.contactManager.removeContact(root.deleteContactIndex)
                root.deleteContactIndex = -1
                root.deleteContactName = ""
            }
        }
    }
}
