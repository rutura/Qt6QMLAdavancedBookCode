import QtQuick
import QtQuick.Controls

Item {
    id: root

    property var theme
    property bool isLoading: false

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(root.theme.background, 0.8)
        visible: root.isLoading

        Behavior on color { ColorAnimation { duration: root.theme.normalAnimation } }

        Column {
            anchors.centerIn: parent
            spacing: 20

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 40
                height: 40
                radius: 20
                color: root.theme.accent

                Behavior on color { ColorAnimation { duration: root.theme.normalAnimation } }

                RotationAnimation on rotation {
                    running: root.isLoading
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                }

                Text {
                    anchors.centerIn: parent
                    text: "⚡"
                    font.pixelSize: 20
                    color: root.theme.textOnAccent
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Loading repositories..."
                color: root.theme.textPrimary
                font.pixelSize: 16
                font.weight: Font.Medium

                Behavior on color { ColorAnimation { duration: root.theme.normalAnimation } }
            }
        }
    }
}
