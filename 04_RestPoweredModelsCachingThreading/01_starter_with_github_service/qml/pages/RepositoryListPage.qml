import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import RepoExplorerProApp

Item {
    id: root

    required property var gitHubService

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        AppHeader {
            Layout.fillWidth: true

            SearchField {
                id: queryField
                Layout.preferredWidth: 380
                placeholderText: "Search GitHub repositories…"
                text: "qt"
                onAccepted: searchButton.clicked()
            }

            AccentButton {
                id: searchButton
                text: "Search"
                enabled: !root.gitHubService.isLoading && queryField.text.length > 0
                onClicked: root.gitHubService.searchRepositories(queryField.text)
            }

            ThemeToggle {}
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 24
            spacing: 14

            StatusStrip {
                Layout.fillWidth: true
                busy: root.gitHubService.isLoading
                statusText: root.gitHubService.isLoading
                            ? "Loading…"
                            : root.gitHubService.repositories.length + " repositories"

                TokenField {
                    service: root.gitHubService
                }
            }

            Label {
                Layout.fillWidth: true
                visible: root.gitHubService.errorMessage.length > 0
                text: {
                    const msg = root.gitHubService.errorMessage
                    if (msg.toLowerCase().includes("rate limit") || msg.toLowerCase().includes("secondary rate"))
                        return msg + "\n\nTip: add a GitHub token above to raise your rate limit, or wait for it to reset."
                    return msg
                }
                color: Theme.error
                wrapMode: Text.WordWrap
                font.pixelSize: 13
            }

            ListContainer {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: root.gitHubService.repositories

                delegate: RepoCard {
                    required property var modelData
                    width: ListView.view ? ListView.view.width : implicitWidth
                    fullName: modelData.fullName
                    description: modelData.description
                    stargazersCount: modelData.stargazersCount
                    forksCount: modelData.forksCount
                    language: modelData.language
                    isPrivate: modelData.isPrivate
                    updatedAt: modelData.updatedAt
                }
            }
        }
    }

    EmptyState {
        anchors.centerIn: parent
        visible: !root.gitHubService.isLoading
                 && root.gitHubService.repositories.length === 0
                 && root.gitHubService.errorMessage.length === 0
        glyph: "🔍"
        title: "Search GitHub"
        subtitle: "Type a query and hit Search to explore repositories"
    }
}
