import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string login: ""
    property string avatarUrl: ""
    property string userType: ""

    signal clicked()

    implicitHeight: 84

    Rectangle {
        id: card
        anchors.fill: parent
        anchors.margins: 6
        radius: 14
        color: Theme.cardBackground
        border.color: Theme.cardBorder
        border.width: 1

        Behavior on color { ColorAnimation { duration: Theme.normalAnimation } }
        Behavior on border.color { ColorAnimation { duration: Theme.normalAnimation } }

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.leftMargin: 2
            anchors.rightMargin: 2
            z: -1
            radius: parent.radius
            color: Theme.cardShadow
            opacity: 0.3
        }

        Rectangle {
            id: hoverOverlay
            anchors.fill: parent
            radius: parent.radius
            color: Theme.surfaceHover
            opacity: 0
            Behavior on opacity { NumberAnimation { duration: Theme.fastAnimation } }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: hoverOverlay.opacity = 0.5
            onExited: hoverOverlay.opacity = 0
            onClicked: root.clicked()
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            Rectangle {
                width: 48; height: 48; radius: 24
                color: Theme.surfaceHover
                clip: true
                Image {
                    anchors.fill: parent
                    source: root.avatarUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Text {
                    text: root.login
                    color: Theme.textPrimary
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    Behavior on color { ColorAnimation { duration: Theme.normalAnimation } }
                }
                Text {
                    text: root.userType
                    color: Theme.textSecondary
                    font.pixelSize: 12
                }
            }

            Text {
                text: "↗"
                color: Theme.textTertiary
                font.pixelSize: 18
            }
        }
    }
}
