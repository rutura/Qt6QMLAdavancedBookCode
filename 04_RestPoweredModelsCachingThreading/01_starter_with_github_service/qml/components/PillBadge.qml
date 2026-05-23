import QtQuick

Rectangle {
    id: root

    property string text: ""
    property color pillColor: Theme.accent
    property color textColor: Theme.textOnAccent

    implicitWidth: label.implicitWidth + 18
    implicitHeight: 22
    radius: height / 2
    color: pillColor

    Behavior on color { ColorAnimation { duration: Theme.normalAnimation } }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.textColor
        font.pixelSize: 10
        font.weight: Font.Medium
    }
}
