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
            // Future: Navigate to detail page
            console.log("Contact selected:", index)
        }

        onAddContactRequested: {
            addContactDialog.open()
        }
    }

    // Add Contact Dialog
    AddContactDialog {
        id: addContactDialog

        onContactAdded: (firstName, lastName, email, phone, company, jobTitle, address, notes, isFavorite, tags) => {
            contactManager.addContactFull(firstName, lastName, email, phone, company, jobTitle, address, notes, isFavorite, tags)

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
