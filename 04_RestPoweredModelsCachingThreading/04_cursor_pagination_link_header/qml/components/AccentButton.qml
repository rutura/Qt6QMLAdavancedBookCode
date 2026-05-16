import QtQuick
import QtQuick.Controls

Button {
    id: control

    property color baseColor: Theme.accent

    implicitHeight: 38
    leftPadding: 18
    rightPadding: 18

    contentItem: Text {
        text: control.text
        font.pixelSize: 14
        font.weight: Font.Medium
        color: Theme.textOnAccent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: control.enabled ? 1.0 : 0.6
    }

    background: Rectangle {
        radius: 10
        color: !control.enabled ? Qt.alpha(control.baseColor, 0.4)
               : control.pressed ? Theme.accentPressed
               : control.hovered ? Theme.accentHover
               : control.baseColor

        Behavior on color {
            ColorAnimation { duration: Theme.fastAnimation }
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
        enabled: control.enabled
    }
}
