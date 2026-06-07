import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string login: ""
    property string avatarUrl: ""
    property string htmlUrl: ""
    property string userType: "User"

    signal clicked()

    implicitHeight: 88

    Rectangle {
        id: card
        anchors.fill: parent
        anchors.margins: 6
        radius: 16
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
            onPressed: hoverOverlay.opacity = 0.8
            onReleased: hoverOverlay.opacity = mouse.containsMouse ? 0.5 : 0
            onClicked: root.clicked()
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            // Avatar circle
            Rectangle {
                width: 48
                height: 48
                radius: 24
                color: Theme.surfaceHover
                clip: true

                Image {
                    anchors.fill: parent
                    source: root.avatarUrl
                    fillMode: Image.PreserveAspectCrop
                    smooth: true

                    // Placeholder while loading
                    Text {
                        anchors.centerIn: parent
                        visible: parent.status !== Image.Ready
                        text: root.login.length > 0 ? root.login[0].toUpperCase() : "?"
                        color: Theme.textSecondary
                        font.pixelSize: 20
                        font.weight: Font.Bold
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    spacing: 8

                    Text {
                        text: root.login
                        color: Theme.textPrimary
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        Behavior on color { ColorAnimation { duration: Theme.normalAnimation } }
                    }

                    // Type pill: Organization gets a distinct color
                    Rectangle {
                        visible: root.userType === "Organization"
                        radius: height / 2
                        implicitWidth: typeLabel.implicitWidth + 14
                        implicitHeight: 20
                        color: Qt.alpha(Theme.info, 0.18)

                        Text {
                            id: typeLabel
                            anchors.centerIn: parent
                            text: "Org"
                            color: Theme.info
                            font.pixelSize: 11
                            font.weight: Font.Medium
                        }
                    }
                }

                Text {
                    text: root.htmlUrl
                    color: Theme.accent
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            Text {
                text: "→"
                color: Theme.textTertiary
                font.pixelSize: 18
            }
        }
    }
}
