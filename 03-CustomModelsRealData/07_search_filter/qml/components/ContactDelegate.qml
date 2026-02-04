import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

SwipeDelegate {
    id: root

    property string firstName: ""
    property string lastName: ""
    property string email: ""
    property bool isFavorite: false
    property string avatarColor: "#6366F1"
    property var tags: []

    signal favoriteToggled()
    signal editRequested()
    signal deleteRequested()

    width: parent.width
    height: 80

    swipe.right: Button {
        id: deleteButton
        width: 80
        height: parent.height
        anchors.right: parent.right

        onClicked: {
            swipe.close()
            root.deleteRequested()
        }

        background: Rectangle {
            color: "transparent"

            Rectangle {
                anchors.centerIn: parent
                width: 60
                height: 60
                radius: 12
                color: deleteButton.pressed ? "#DC2626" : "#EF4444"

                // Shadow layer
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -2
                    z: -1
                    radius: 14
                    color: "#20000000"
                }

                Behavior on color {
                    ColorAnimation { duration: 100 }
                }
            }
        }

        contentItem: Item {
            Column {
                anchors.centerIn: parent
                spacing: 2

                // Icon placeholder - replace with Image { source: "qrc:/icons/delete.svg" }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🗑"
                    font.pixelSize: 18
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Delete"
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    color: "#FFFFFF"
                }
            }
        }
    }

    swipe.left: Button {
        id: editButton
        width: 80
        height: parent.height

        onClicked: {
            swipe.close()
            root.editRequested()
        }

        background: Rectangle {
            color: "transparent"

            Rectangle {
                anchors.centerIn: parent
                width: 60
                height: 60
                radius: 12
                color: editButton.pressed ? "#2563EB" : "#3B82F6"

                // Shadow layer
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -2
                    z: -1
                    radius: 14
                    color: "#20000000"
                }

                Behavior on color {
                    ColorAnimation { duration: 100 }
                }
            }
        }

        contentItem: Item {
            Column {
                anchors.centerIn: parent
                spacing: 2

                // Icon placeholder - replace with Image { source: "qrc:/icons/edit.svg" }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "✏"
                    font.pixelSize: 18
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Edit"
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    color: "#FFFFFF"
                }
            }
        }
    }

    background: Rectangle {
        color: root.pressed ? "#E5E7EB" : root.hovered ? "#F3F4F6" : "#FFFFFF"

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: "#E5E7EB"
        }

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    contentItem: RowLayout {
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
                mouse.accepted = true
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.favoriteToggled()
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
        }

        // Chevron indicator
        Text {
            text: "›"
            font.pixelSize: 24
            color: "#D1D5DB"
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
