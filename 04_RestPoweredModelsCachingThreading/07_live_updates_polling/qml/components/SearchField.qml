import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property alias text: input.text
    property alias placeholderText: input.placeholderText
    signal accepted()

    implicitWidth: 360
    implicitHeight: 40
    radius: 10
    color: Theme.surface
    border.width: 1
    border.color: input.activeFocus ? Theme.accent : Theme.border

    Behavior on border.color { ColorAnimation { duration: Theme.fastAnimation } }
    Behavior on color { ColorAnimation { duration: Theme.normalAnimation } }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "🔍"
            font.pixelSize: 15
            opacity: 0.7
        }

        TextField {
            id: input
            width: parent.width - 34
            anchors.verticalCenter: parent.verticalCenter
            background: null
            color: Theme.textPrimary
            placeholderTextColor: Theme.textTertiary
            font.pixelSize: 14
            verticalAlignment: TextInput.AlignVCenter
            onAccepted: root.accepted()
        }
    }
}
