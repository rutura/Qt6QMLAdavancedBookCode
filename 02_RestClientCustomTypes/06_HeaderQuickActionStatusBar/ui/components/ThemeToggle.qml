import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item{
    id: root
    width: 80
    height: 36

    property var theme
    signal themeToggled()

    Rectangle {
        id: toggleBackground
        anchors.fill: parent
        radius: 18
        color: theme.surface
        border.color: theme.border
        border.width: 1

        Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
        Behavior on border.color { ColorAnimation { duration: theme.normalAnimation } }

        // Gradient overlay
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: theme.isDark ? Qt.alpha("#fbbf24", 0.1) : Qt.alpha("#1e293b", 0.1)
                }
                GradientStop {
                    position: 1.0
                    color: "transparent"
                }
            }

            Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
        }


        // Sliding indicator
        Rectangle {
            id: slider
            width: 28
            height: 28
            radius: 14
            x: theme.isDark ? parent.width - width - 4 : 4
            y: 4
            color: theme.isDark ? "#fbbf24" : "#1e293b"

            Behavior on x { NumberAnimation { duration: theme.normalAnimation; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: theme.normalAnimation } }

            // Inner glow
            Rectangle {
                anchors.centerIn: parent
                width: 20
                height: 20
                radius: 10
                color: "transparent"
                border.color: Qt.alpha(theme.textOnAccent, 0.3)
                border.width: 1
            }

            Text {
                anchors.centerIn: parent
                text: theme.isDark ? "☀️" : "🌙"
                font.pixelSize: 12
            }
        }

        // Icons on sides
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: "🌙"
            font.pixelSize: 10
            opacity: theme.isDark ? 0.3 : 0.8

            Behavior on opacity { NumberAnimation { duration: theme.normalAnimation } }
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: "☀️"
            font.pixelSize: 10
            opacity: theme.isDark ? 0.8 : 0.3

            Behavior on opacity { NumberAnimation { duration: theme.normalAnimation } }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                theme.toggleTheme()
                root.themeToggled()

                // Add haptic-like feedback
                toggleBackground.scale = 0.95
                scaleBackAnimation.start()
            }
        }

        // Click feedback
        NumberAnimation {
            id: scaleBackAnimation
            target: toggleBackground
            property: "scale"
            from: 0.95
            to: 1.0
            duration: theme.fastAnimation
            easing.type: Easing.OutBack
        }




    }

}
