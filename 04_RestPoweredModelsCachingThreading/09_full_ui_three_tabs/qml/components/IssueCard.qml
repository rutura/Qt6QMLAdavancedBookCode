import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property int number: 0
    property string title: ""
    property string state: ""
    property string userLogin: ""
    property int commentsCount: 0

    signal clicked()

    implicitHeight: 92

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

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    width: 9; height: 9; radius: 4.5
                    color: root.state === "open" ? Theme.success : Theme.error
                }
                Text {
                    text: "#" + root.number
                    color: Theme.textTertiary
                    font.pixelSize: 12
                }
                Text {
                    Layout.fillWidth: true
                    text: root.title
                    color: Theme.textPrimary
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    Behavior on color { ColorAnimation { duration: Theme.normalAnimation } }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Text {
                    text: "by " + root.userLogin
                    color: Theme.textSecondary
                    font.pixelSize: 12
                }
                RowLayout {
                    spacing: 6
                    Text { text: "💬"; font.pixelSize: 11 }
                    Text {
                        text: root.commentsCount + (root.commentsCount === 1 ? " comment" : " comments")
                        color: Theme.textSecondary
                        font.pixelSize: 12
                    }
                }
                Item { Layout.fillWidth: true }
            }
        }
    }
}
