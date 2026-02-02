import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property alias text: searchInput.text

    signal searchTextChanged(string text)

    implicitHeight: 48
    color: "#FFFFFF"
    radius: 12
    border.width: searchInput.activeFocus ? 2 : 1
    border.color: searchInput.activeFocus ? "#3B82F6" : "#E5E7EB"

    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }

    Behavior on border.width {
        NumberAnimation { duration: 150 }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12

        // Search icon
        Text {
            text: "🔍"
            font.pixelSize: 20
            opacity: 0.6
        }

        // Search input
        TextField {
            id: searchInput

            Layout.fillWidth: true

            placeholderText: "Search contacts..."
            font.pixelSize: 14
            color: "#111827"

            background: Item {}

            onTextChanged: root.searchTextChanged(text)

            Keys.onEscapePressed: {
                text = ""
                focus = false
            }
        }

        // Clear button
        AbstractButton {
            visible: searchInput.text.length > 0
            implicitWidth: 20
            implicitHeight: 20

            contentItem: Text {
                text: "✕"
                font.pixelSize: 16
                color: "#9CA3AF"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: searchInput.text = ""

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: searchInput.text = ""
            }

            opacity: hovered ? 1.0 : 0.7

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }
    }
}
