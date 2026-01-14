import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

/**
 * Main Application Window
 *
 * Portfolio-ready Contact Manager application demonstrating:
 * - Modern QML UI with animations
 * - Pure QML implementation with dummy data
 * - Responsive design and smooth interactions
 */
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

    // Contact list page as the main content
    ContactListPage {
        anchors.fill: parent
        
        onContactSelected: (index) => {
            // Future: Navigate to detail page
            console.log("Contact selected:", index)
        }

        onAddContactRequested: {
            // Future: Open add contact dialog
            console.log("Add contact requested")
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
                text: "Total: 45"
                font.pixelSize: 12
                color: "#6B7280"
            }

            Text {
                text: "Favorites: 6"
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
