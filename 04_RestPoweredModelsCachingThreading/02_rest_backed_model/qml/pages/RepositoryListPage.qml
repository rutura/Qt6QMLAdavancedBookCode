import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import RepoExplorerProApp

Item {
    id: root

    required property var gitHubService

    // NEW: the model that now drives this page
    RepositoryListModel {
        id: repoModel
    }

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
                enabled: !repoModel.service.isLoading && queryField.text.length > 0   // CHANGED
                onClicked: repoModel.search(queryField.text)                          // CHANGED
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
                busy: repoModel.service.isLoading                                  // CHANGED
                statusText: repoModel.service.isLoading                            // CHANGED
                            ? "Loading…"
                            : repoModel.count + " repositories"                    // CHANGED

                TokenField {
                    service: repoModel.service                                     // CHANGED
                }
            }

            Label {

                Layout.fillWidth: true
                visible: repoModel.service.errorMessage.length > 0                 // CHANGED
                text: {
                    const msg = repoModel.service.errorMessage                     // CHANGED
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
                model: repoModel                                  // CHANGED: the model, not a QVariantList

                delegate: RepoCard {
                    required property var model                   // CHANGED: model, not modelData
                    width: ListView.view ? ListView.view.width : implicitWidth
                    fullName: model.fullName                      // CHANGED
                    description: model.description                 // CHANGED
                    stargazersCount: model.stargazersCount         // CHANGED
                    forksCount: model.forksCount                   // CHANGED
                    language: model.language                       // CHANGED
                }
            }
        }
    }

    EmptyState {
        anchors.centerIn: parent
        visible: !repoModel.service.isLoading
                 && repoModel.count === 0                                  // CHANGED
                 && repoModel.service.errorMessage.length === 0            // CHANGED
        glyph: "🔍"
        title: "Search GitHub"
        subtitle: "Type a query and hit Search to explore repositories"
    }
}
