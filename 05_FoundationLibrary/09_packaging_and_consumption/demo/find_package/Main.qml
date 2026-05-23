import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 400
    height: 300
    visible: true
    title: "QmlAdvCore — find_package Demo (09)"
    color: Theme.colors.background

    ToastHost {}

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacing.lg

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "find_package Consumption"
            font.pixelSize: 20
            font.bold: true
            color: Theme.colors.text
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Library version: " + Version.string
            color: Theme.colors.text
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Show Toast"
            onClicked: ToastManager.show("Hello from installed package!")
        }
    }
}
