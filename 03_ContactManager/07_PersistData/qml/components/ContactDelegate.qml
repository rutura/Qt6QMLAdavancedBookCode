import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * ContactDelegate - A modern swipeable contact list item
 *
 * Features:
 * - Swipe left to reveal delete button (red)
 * - Swipe right to reveal edit button (green)
 * - Tap to view contact details
 * - Displays contact information with avatar, name, email, and favorite status
 */
Item {
    id: root

    property string firstName: ""
    property string lastName: ""
    property string email: ""
    property bool isFavorite: false
    property string avatarColor: "#6366F1"
    property var tags: []

    signal clicked()
    signal favoriteToggled()
    signal deleteRequested()
    signal editRequested()

    width: parent.width
    height: 80

    // Background actions layer
    Item {
        anchors.fill: parent

        // Edit action (shown on swipe right)
        Rectangle {
            id: editAction
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 80
            color: "#10B981"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: "✎"
                    font.pixelSize: 28
                    color: "#FFFFFF"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Edit"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: "#FFFFFF"
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.editRequested()
                    contentItem.x = 0
                }
            }
        }

        // Delete action (shown on swipe left)
        Rectangle {
            id: deleteAction
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 80
            color: "#EF4444"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: "🗑"
                    font.pixelSize: 24
                    color: "#FFFFFF"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Delete"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: "#FFFFFF"
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.deleteRequested()
                    contentItem.x = 0
                }
            }
        }
    }

    // Main content item (swipeable)
    Rectangle {
        id: contentItem
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        color: contentMouseArea.pressed ? "#E5E7EB" : contentMouseArea.containsMouse ? "#F3F4F6" : "#FFFFFF"

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        // Bottom border
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: "#E5E7EB"
        }

        // Content layout
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 16

            // Avatar with initials
            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                Layout.alignment: Qt.AlignVCenter
                radius: 24
                color: root.avatarColor

                Text {
                    anchors.centerIn: parent
                    text: {
                        let initials = ""
                        if (root.firstName) initials += root.firstName.charAt(0).toUpperCase()
                        if (root.lastName) initials += root.lastName.charAt(0).toUpperCase()
                        return initials
                    }
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                }
            }

            // Contact info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: root.firstName + " " + root.lastName
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    color: "#111827"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: root.email
                    font.pixelSize: 13
                    color: "#6B7280"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            // Favorite button
            AbstractButton {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignVCenter

                onClicked: {
                    root.favoriteToggled()
                }

                contentItem: Text {
                    text: root.isFavorite ? "★" : "☆"
                    font.pixelSize: 24
                    color: root.isFavorite ? "#FDB022" : "#D1D5DB"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                scale: hovered ? 1.15 : 1.0

                Behavior on scale {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.favoriteToggled()
                }
            }

            // Chevron indicator
            Text {
                text: "›"
                font.pixelSize: 24
                color: "#D1D5DB"
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // Main tap area for viewing contact
        MouseArea {
            id: contentMouseArea
            anchors.fill: parent
            hoverEnabled: true

            property real dragStartX: 0
            property bool isDragging: false

            onPressed: function(mouse) {
                dragStartX = mouse.x
                isDragging = false
            }

            onPositionChanged: function(mouse) {
                if (pressed) {
                    let deltaX = mouse.x - dragStartX

                    // Start dragging if moved more than threshold
                    if (Math.abs(deltaX) > 5) {
                        isDragging = true
                    }

                    if (isDragging) {
                        // Update position with drag
                        let newX = contentItem.x + deltaX

                        // Limit swipe range: -80 to 80
                        contentItem.x = Math.max(-80, Math.min(80, newX))

                        dragStartX = mouse.x
                    }
                }
            }

            onReleased: function(mouse) {
                if (!isDragging) {
                    // It was a tap, not a drag
                    root.clicked()
                } else {
                    // Snap to position based on swipe distance
                    if (contentItem.x > 40) {
                        // Snap to show edit
                        snapToEdit()
                    } else if (contentItem.x < -40) {
                        // Snap to show delete
                        snapToDelete()
                    } else {
                        // Snap back to center
                        snapToCenter()
                    }
                }
                isDragging = false
            }

            onCanceled: {
                snapToCenter()
                isDragging = false
            }
        }

        // Smooth animation behavior
        Behavior on x {
            enabled: !contentMouseArea.isDragging
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
    }

    // Helper functions for snapping
    function snapToEdit() {
        contentItem.x = 80
    }

    function snapToDelete() {
        contentItem.x = -80
    }

    function snapToCenter() {
        contentItem.x = 0
    }

    // Auto-reset on model changes
    Component.onCompleted: {
        contentItem.x = 0
    }
}
