import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Collapsible GitHub PAT entry. Bind `service` to the GitHubService that
// owns the authToken property. Polished replacement for the raw inline row.
ColumnLayout {
    id: root

    required property var service
    property bool expanded: false

    spacing: 6

    RowLayout {
        spacing: 8

        Text {
            text: "🔑"
            font.pixelSize: 13
        }
        Label {
            text: "GitHub Token"
            color: Theme.textSecondary
            font.pixelSize: 12
        }
        Label {
            text: root.service && root.service.authToken.length > 0 ? "• set" : ""
            color: Theme.success
            font.pixelSize: 11
        }
        AbstractButton {
            implicitWidth: 22
            implicitHeight: 22
            onClicked: root.expanded = !root.expanded
            HoverHandler { cursorShape: Qt.PointingHandCursor }
            contentItem: Text {
                text: root.expanded ? "▲" : "▼"
                color: Theme.textSecondary
                font.pixelSize: 9
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        visible: root.expanded
        implicitHeight: 38
        radius: 10
        color: Theme.surface
        border.width: 1
        border.color: tokenInput.activeFocus ? Theme.accent : Theme.border

        Behavior on border.color { ColorAnimation { duration: Theme.fastAnimation } }

        TextField {
            id: tokenInput
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            background: null
            color: Theme.textPrimary
            placeholderTextColor: Theme.textTertiary
            font.pixelSize: 13
            verticalAlignment: TextInput.AlignVCenter
            echoMode: TextInput.Password
            placeholderText: "ghp_…  (optional — raises rate limit)"
            text: root.service ? root.service.authToken : ""
            onTextChanged: {
                if (root.service)
                    root.service.authToken = text
            }
        }
    }
}
