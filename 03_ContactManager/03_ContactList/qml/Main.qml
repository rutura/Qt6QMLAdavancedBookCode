import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

/**
 * Main Application Window
 *
 * Portfolio-ready Contact Manager application demonstrating:
 * - QAbstractListModel implementation
 * - QSortFilterProxyModel for search/filtering
 * - Modern QML UI with animations
 * - Complete CRUD operations
 * - Data persistence with JSON
 */
ApplicationWindow {
    id: window

    visible: true
    width: 1200
    height: 800
    minimumWidth: 800
    minimumHeight: 600

    title: "Contact Manager - Qt6 QML Custom Models"

    // Modern window styling
    color: "#F9FAFB"

    // Stack-based navigation
    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: ContactListPage {
            onContactSelected: (index) => {
                stackView.push(detailPageComponent, { contactIndex: index })
            }

            onAddContactRequested: {
                addDialog.open()
            }
        }

        // Page transition animations
        pushEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 250
                easing.type: Easing.InOutQuad
            }
            PropertyAnimation {
                property: "x"
                from: stackView.width
                to: 0
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        pushExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        popEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        popExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 250
                easing.type: Easing.InOutQuad
            }
            PropertyAnimation {
                property: "x"
                from: 0
                to: stackView.width
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }

    // Component for detail page
    Component {
        id: detailPageComponent

        ContactDetailPage {
            onBackRequested: {
                stackView.pop()
            }
        }
    }

    // Global add contact dialog
    ContactFormDialog {
        id: addDialog
        contactIndex: -1
    }

    // Status bar footer
    footer: ToolBar {
        height: 32

        background: Rectangle {
            color: "#FFFFFF"
            border.width: 1
            border.color: "#E5E7EB"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 24

            Text {
                text: `Total: ${contactManager.totalContacts}`
                font.pixelSize: 12
                color: "#6B7280"
            }

            Text {
                text: `Favorites: ${contactManager.favoritesCount}`
                font.pixelSize: 12
                color: "#6B7280"
            }

            Text {
                text: `Filtered: ${contactManager.proxyModel.count}`
                font.pixelSize: 12
                color: "#6B7280"
                visible: contactManager.proxyModel.count !== contactManager.totalContacts
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "Contact Manager v1.0"
                font.pixelSize: 12
                color: "#9CA3AF"
            }
        }
    }

    // Toast notification for feedback
    Popup {
        id: toast
        x: (parent.width - width) / 2
        y: parent.height - height - 24
        width: Math.min(400, parent.width - 2 * 24)
        height: 48
        modal: false
        focus: false
        closePolicy: Popup.NoAutoClose

        background: Rectangle {
            color: "#111827"
            radius: 8
            opacity: 0.9
        }

        contentItem: Text {
            id: toastText
            text: ""
            color: "#FFFFFF"
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 150
            }
        }

        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 150
            }
        }

        Timer {
            id: toastTimer
            interval: 3000
            onTriggered: toast.close()
        }

        function show(message) {
            toastText.text = message
            toast.open()
            toastTimer.restart()
        }
    }

    // Connections for feedback
    Connections {
        target: contactManager

        function onContactsLoaded(success, count) {
            if (success) {
                toast.show(`Loaded ${count} contacts`)
            }
        }

        function onContactsSaved(success) {
            if (success) {
                toast.show("Contacts saved successfully")
            }
        }

        function onErrorOccurred(message) {
            toast.show(`Error: ${message}`)
        }
    }

    // Keyboard shortcuts
    Shortcut {
        sequence: "Ctrl+N"
        onActivated: addDialog.open()
    }

    Shortcut {
        sequence: "Ctrl+F"
        onActivated: {
            if (stackView.depth === 1) {
                // Focus search bar on list page
                stackView.currentItem.forceActiveFocus()
            }
        }
    }

    Shortcut {
        sequence: StandardKey.Back
        onActivated: {
            if (stackView.depth > 1) {
                stackView.pop()
            }
        }
    }
}
