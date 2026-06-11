import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 400
    height: 280
    visible: true
    title: "QmlAdvCore — 02: Object Properties"

    Column {
        anchors.centerIn: parent
        //spacing: 16
        spacing: Theme.spacing.medium

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

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 180
            height: 40
            radius: 8
            color: Theme.colors.primary

            Text {
                anchors.centerIn: parent
                text: "Theme.colors.primary"
                font.pixelSize: 12
                color: Theme.colors.onPrimary
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Primary: " + Theme.colors.primary
            font.pixelSize: 14
            color: "#49454F"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Spacing medium: " + Theme.spacing.medium
            font.pixelSize: 14
            color: "#49454F"
        }

        /*
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "QML_SINGLETON + QML_ELEMENT working ✓"
            font.pixelSize: 14
            color: "#49454F"
        }
        */
    }
}