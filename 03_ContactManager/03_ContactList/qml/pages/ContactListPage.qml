import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import ContactManagerApp

/**
 * ContactListPage - Main page showing the list of contacts
 *
 * Includes search, filtering, and the contact list with all interactions.
 */
Page {
    id: root

    signal contactSelected(int index)
    signal addContactRequested()

    background: Rectangle {
        color: "#F9FAFB"
    }

    header: ToolBar {
        background: Rectangle {
            color: "#FFFFFF"
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            Text {
                text: "Contacts"
                font.pixelSize: 24
                font.weight: Font.Bold
                color: "#111827"
            }

            Item { Layout.fillWidth: true }

            Text {
                text: `${contactManager.proxyModel.count} contacts`
                font.pixelSize: 14
                color: "#6B7280"
            }

            CustomButton {
                text: "+ Add"
                variant: "primary"
                onClicked: root.addContactRequested()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24

        // Search bar
        SearchBar {
            id: searchBar
            Layout.fillWidth: true
            onSearchTextChanged: (text) => {
                contactManager.proxyModel.searchText = text
            }
        }

        // Main content area
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 24

            // Sidebar with filters
            /*
            FilterPanel {
                id: filterPanel
                Layout.preferredWidth: 300
                Layout.fillHeight: true

                onFavoritesToggled: (enabled) => {
                    contactManager.proxyModel.filterFavorites = enabled
                }

                onTagSelected: (tag) => {
                    contactManager.proxyModel.filterTags = filterPanel.selectedTags
                }

                onTagDeselected: (tag) => {
                    contactManager.proxyModel.filterTags = filterPanel.selectedTags
                }

                onSortChanged: (sortBy, ascending) => {
                    switch (sortBy) {
                    case "name":
                        contactManager.proxyModel.sortByName(ascending)
                        break
                    case "dateAdded":
                        contactManager.proxyModel.sortByDateAdded(ascending)
                        break
                    case "dateModified":
                        contactManager.proxyModel.sortByDateModified(ascending)
                        break
                    case "frequency":
                        contactManager.proxyModel.sortByFrequency(ascending)
                        break
                    }
                }

                onFiltersCleared: {
                    searchBar.text = ""
                    contactManager.proxyModel.clearFilters()
                }
            }
            */

            // Contact list
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#FFFFFF"
                radius: 8

                ListView {
                    id: contactListView
                    anchors.fill: parent
                    anchors.margins: 8
                    clip: true
                    spacing: 2

                    model: contactManager.proxyModel

                    delegate: ContactDelegate {
                        width: contactListView.width

                        onClicked: {
                            root.contactSelected(index)
                        }

                        onEditClicked: {
                            editDialog.contactIndex = index
                            editDialog.open()
                        }

                        onDeleteClicked: {
                            deleteDialog.contactIndex = index
                            deleteDialog.open()
                        }

                        onFavoriteToggled: {
                            contactManager.toggleFavorite(index)
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    // Empty state
                    EmptyState {
                        anchors.centerIn: parent
                        visible: contactListView.count === 0
                        title: searchBar.text ? "No matches found" : "No Contacts"
                        message: searchBar.text ? "Try a different search term" : "Add your first contact to get started"
                        buttonText: "Add Contact"
                        showButton: !searchBar.text
                        onButtonClicked: root.addContactRequested()
                    }
                }
            }
        }
    }

    // Dialogs
    ContactFormDialog {
        id: addDialog
        contactIndex: -1
    }

    ContactFormDialog {
        id: editDialog
    }

    Dialog {
        id: deleteDialog
        property int contactIndex: -1

        title: "Delete Contact"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: Overlay.overlay

        Label {
            text: "Are you sure you want to delete this contact?"
        }

        onAccepted: {
            if (contactIndex >= 0) {
                contactManager.removeContact(contactIndex)
            }
        }
    }

    Connections {
        target: root
        function onAddContactRequested() {
            addDialog.open()
        }
    }
}
