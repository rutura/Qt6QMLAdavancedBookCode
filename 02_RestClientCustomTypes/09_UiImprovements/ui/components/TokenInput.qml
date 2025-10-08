import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: 240
    height: 36

    property var theme
    property alias text: tokenField.text
    property alias placeholderText: tokenField.placeholderText

    signal tokenChanged(string token)

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: theme.surface
        border.color: theme.border
        border.width: 1

        Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
        Behavior on border.color { ColorAnimation { duration: theme.normalAnimation } }

        TextField {
            id: tokenField
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.topMargin: 8
            anchors.bottomMargin: 8
            placeholderText: "Enter GitHub Token..."
            color: theme.textPrimary
            font.pixelSize: 13
            selectByMouse: true
            echoMode: TextInput.Password
            verticalAlignment: TextInput.AlignVCenter

            background: Rectangle { color: "transparent" }
            placeholderTextColor: theme.textTertiary

            Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
            Behavior on placeholderTextColor { ColorAnimation { duration: theme.normalAnimation } }

            onTextChanged: root.tokenChanged(text)
        }
    }
}
