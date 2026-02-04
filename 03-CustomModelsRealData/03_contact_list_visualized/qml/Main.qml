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




}
