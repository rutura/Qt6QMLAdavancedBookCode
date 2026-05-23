import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 400
    height: 300
    visible: true
    title: "QmlAdvCore — In-Tree Demo (09)"
    color: Theme.colors.background

    ToastHost {}

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacing.lg

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "In-Tree Consumption"
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
            onClicked: ToastManager.show("Hello from in-tree build!")
        }
    }
}
