// Pattern: Object property
// Theme exposes ThemeColors and ThemeSpacing as child QObjects.
// Access nested values with the dot-syntax: Theme.colors.primary.
import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 420
    height: 320
    visible: true
    title: "Example — Object Property"
    color: Theme.colors.background

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacing.md

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Theme.colors / Theme.spacing"
            font.pixelSize: 18
            font.bold: true
            color: Theme.colors.text
        }

        Rectangle {
            width: 240; height: 56
            radius: 6
            color: Theme.colors.primary
            Text {
                anchors.centerIn: parent
                text: "Theme.colors.primary"
                color: Theme.colors.onPrimary
            }
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Theme.mode === "light" ? "Switch to Dark" : "Switch to Light"
            onClicked: Theme.setMode(Theme.mode === "light" ? "dark" : "light")
        }
    }
}
