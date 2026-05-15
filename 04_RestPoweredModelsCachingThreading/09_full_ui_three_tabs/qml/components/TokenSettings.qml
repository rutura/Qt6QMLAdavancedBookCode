import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Collapsible row for entering a GitHub Personal Access Token.
// Bind 'service' to the GitHubService that should receive the token.
ColumnLayout {
    id: root

    required property var service

    property bool expanded: false

    spacing: 4

    RowLayout {
        spacing: 6

        Label {
            text: "GitHub PAT"
            color: "#6B7280"
            font.pixelSize: 12
        }

        ToolButton {
            text: root.expanded ? "▲" : "▼"
            font.pixelSize: 10
            implicitWidth: 24
            implicitHeight: 24
            onClicked: root.expanded = !root.expanded
        }
    }

    TextField {
        Layout.fillWidth: true
        visible: root.expanded
        placeholderText: "ghp_…  (leave empty for 60 req/hr unauthenticated)"
        echoMode: TextInput.Password
        text: root.service ? root.service.authToken : ""
        onTextChanged: {
            if (root.service)
                root.service.authToken = text
        }
    }
}
