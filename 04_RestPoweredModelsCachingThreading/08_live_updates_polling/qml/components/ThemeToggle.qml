import QtQuick
import QtQuick.Controls

AbstractButton {
    id: root

    implicitWidth: 64
    implicitHeight: 32

    onClicked: Theme.toggleTheme()

    background: Rectangle {
        radius: height / 2
        color: Theme.isDark ? Theme.surfaceHover : Theme.accent

        Behavior on color { ColorAnimation { duration: Theme.normalAnimation } }

        Rectangle {
            id: knob
            width: 26
            height: 26
            radius: 13
            y: 3
            x: Theme.isDark ? 3 : parent.width - width - 3
            color: Theme.surface

            Behavior on x {
                NumberAnimation { duration: Theme.normalAnimation; easing.type: Easing.OutCubic }
            }
            Behavior on color { ColorAnimation { duration: Theme.normalAnimation } }

            Text {
                anchors.centerIn: parent
                text: Theme.isDark ? "🌙" : "☀️"
                font.pixelSize: 13
            }
        }
    }

    HoverHandler { cursorShape: Qt.PointingHandCursor }
}
