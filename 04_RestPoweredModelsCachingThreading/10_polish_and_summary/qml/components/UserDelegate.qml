import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    required property string login
    required property string avatarUrl
    required property string htmlUrl
    required property string userType

    height: contentLayout.implicitHeight + 24
    radius: 8
    color: "#FFFFFF"

    RowLayout {
        id: contentLayout
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
        spacing: 12

        Rectangle {
            width: 40; height: 40; radius: 20
            color: "#E5E7EB"
            clip: true
            Image {
                anchors.fill: parent
                source: root.avatarUrl
                fillMode: Image.PreserveAspectCrop
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Label {
                text: root.login
                font.pixelSize: 14
                font.weight: Font.Medium
                color: "#111827"
            }

            Label {
                text: root.userType
                color: "#6B7280"
                font.pixelSize: 12
            }
        }
    }
}
