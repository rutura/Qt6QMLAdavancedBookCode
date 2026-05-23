import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 400
    height: 280
    visible: true
    title: "QmlAdvCore — 01: Library Skeleton"

    Column {
        anchors.centerIn: parent
        spacing: 16

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "QmlAdvCore"
            font.pixelSize: 28
            font.bold: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Version: " + Version.string
            font.pixelSize: 18
            color: "#6750A4"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "QML_SINGLETON + QML_ELEMENT working ✓"
            font.pixelSize: 14
            color: "#49454F"
        }
    }
}
