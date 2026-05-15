import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var gitHubService

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            TextField {
                id: queryField
                Layout.fillWidth: true
                placeholderText: "Search GitHub repositories…"
                text: "qt"
                onAccepted: searchButton.clicked()
            }

            Button {
                id: searchButton
                text: "Search"
                enabled: !root.gitHubService.isLoading && queryField.text.length > 0
                onClicked: root.gitHubService.searchRepositories(queryField.text)
            }
        }

        Label {
            Layout.fillWidth: true
            visible: root.gitHubService.isLoading
            text: "Loading…"
            color: "#6B7280"
        }

        Label {
            Layout.fillWidth: true
            visible: root.gitHubService.errorMessage.length > 0
            text: {
                const msg = root.gitHubService.errorMessage
                if (msg.toLowerCase().includes("rate limit") || msg.toLowerCase().includes("secondary rate"))
                    return msg + "\n\nTip: enter a GitHub PAT in the field below to raise your limit to 30 requests/minute, or wait for the limit to reset."
                return msg
            }
            color: "#B91C1C"
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                text: "GitHub PAT:"
                color: "#6B7280"
                font.pixelSize: 12
            }

            TextField {
                Layout.fillWidth: true
                placeholderText: "ghp_… (optional — raises rate limit from 10 to 30 req/min)"
                echoMode: TextInput.Password
                text: root.gitHubService.authToken
                onTextChanged: root.gitHubService.authToken = text
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            Column {
                width: parent.width
                spacing: 6

                Repeater {
                    model: root.gitHubService.repositories

                    delegate: Rectangle {
                        width: parent.width
                        height: contentColumn.implicitHeight + 16
                        color: "#FFFFFF"
                        border.color: "#E5E7EB"
                        radius: 4

                        Column {
                            id: contentColumn
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 2

                            Text {
                                text: modelData.fullName
                                font.pixelSize: 14
                                font.bold: true
                                color: "#111827"
                            }
                            Text {
                                text: modelData.description && modelData.description.length > 0
                                      ? modelData.description
                                      : "(no description)"
                                font.pixelSize: 12
                                color: "#4B5563"
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                            Text {
                                text: "★ " + modelData.stargazersCount
                                      + "    ⑂ " + modelData.forksCount
                                      + "    " + (modelData.language || "—")
                                font.pixelSize: 11
                                color: "#6B7280"
                            }
                        }
                    }
                }
            }
        }
    }
}
