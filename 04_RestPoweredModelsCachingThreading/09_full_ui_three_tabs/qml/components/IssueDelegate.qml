import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    required property int number
    required property string title
    required property string state
    required property string userLogin
    required property int commentsCount
    required property string htmlUrl

    height: contentLayout.implicitHeight + 24
    radius: 8
    color: "#FFFFFF"

    layer.enabled: true
    layer.effect: null

    ColumnLayout {
        id: contentLayout
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Rectangle {
                width: 8; height: 8; radius: 4
                color: root.state === "open" ? "#16A34A" : "#DC2626"
            }

            Label {
                text: "#" + root.number
                color: "#6B7280"
                font.pixelSize: 12
            }

            Label {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: 14
                font.weight: Font.Medium
                elide: Text.ElideRight
                color: "#111827"
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Label {
                text: "by " + root.userLogin
                color: "#6B7280"
                font.pixelSize: 12
            }

            Label {
                text: root.commentsCount + " comment" + (root.commentsCount === 1 ? "" : "s")
                color: "#6B7280"
                font.pixelSize: 12
            }
        }
    }
}
