import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

ApplicationWindow {
    id: window

    visible: true
    width: 1200
    height: 800
    minimumWidth: 900
    minimumHeight: 600

    title: "Contact Manager - Qt6 QML Custom Models"

    // Modern window styling
    color: "#F9FAFB"

    // Create ContactManager instance at the application level
    ContactManager {
        id: contactManager
    }

    // Contact list page as the main content
    ContactListPage {
        anchors.fill: parent

        // Pass the contact manager to the page
        contactManager: contactManager

        onContactSelected: (index) => {
            let data = contactManager.getContactData(index)
            viewContactDialog.loadContact(index, data)
            viewContactDialog.open()
        }

        onAddContactRequested: {
            addContactDialog.open()
        }

        onEditContactRequested: (index) => {
            let data = contactManager.getContactData(index)
            editContactDialog.loadContact(index, data)
            editContactDialog.open()
        }

        onDeleteContactRequested: (index, firstName, lastName, avatarColor) => {
            deleteConfirmationDialog.setContact(index, firstName, lastName, avatarColor)
            deleteConfirmationDialog.open()
        }
    }

    // Add Contact Dialog
    AddContactDialog {
        id: addContactDialog

        onContactAdded: (firstName, lastName, email, phone, company, jobTitle, address, notes, isFavorite, tags) => {
            contactManager.addContactFull(firstName, lastName, email, phone, company, jobTitle, address, notes, isFavorite, tags)
        }
    }

    // Edit Contact Dialog
    EditContactDialog {
        id: editContactDialog

        onContactUpdated: (index, firstName, lastName, email, phone, company, jobTitle, address, notes, isFavorite, tags) => {
            contactManager.updateContactFull(index, firstName, lastName, email, phone, company, jobTitle, address, notes, isFavorite, tags)
        }
    }

    // View Contact Dialog (read-only)
    ViewContactDialog {
        id: viewContactDialog

        onEditRequested: (index) => {
            let data = contactManager.getContactData(index)
            editContactDialog.loadContact(index, data)
            editContactDialog.open()
        }
    }

    // Delete Confirmation Dialog
    DeleteConfirmationDialog {
        id: deleteConfirmationDialog

        onDeleteConfirmed: (index) => {
            contactManager.removeContact(index)
        }
    }



    // Status bar footer
    footer: ToolBar {
        height: 36

        background: Rectangle {
            color: "#FFFFFF"

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: "#E5E7EB"
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            spacing: 24

            Text {
                //text: "Total: 45"
                text: "Total: " + contactManager.totalContacts
                font.pixelSize: 12
                color: "#6B7280"
            }

            Text {
                //text: "Favorites: 6"
                text: "Favorites: " + contactManager.favoritesCount
                font.pixelSize: 12
                color: "#6B7280"
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "Contact Manager v1.0"
                font.pixelSize: 12
                color: "#9CA3AF"
            }
        }
    }

}
