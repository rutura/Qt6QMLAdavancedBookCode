import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import RepoExplorerProApp

Item {
    id: root

    required property var gitHubService

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
                enabled: !repoModel.isLoadingPage && queryField.text.length > 0
                onClicked: repoModel.search(queryField.text)
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
                busy: repoModel.isLoadingPage
                statusText: repoModel.useCursor
                            ? (repoModel.count + " loaded · "
                               + (repoModel.hasMore ? "more available" : "end of results"))
                            : (repoModel.count + " of " + repoModel.totalCount
                               + "  ·  page " + repoModel.currentPage)

                PillBadge {
                    visible: repoModel.service.rateLimitRemaining >= 0
                    text: {
                        const r = repoModel.service.rateLimitRemaining
                        const t = repoModel.service.rateLimitTotal
                        const reset = repoModel.service.rateLimitReset
                        const resetStr = isNaN(reset.getTime()) ? ""
                            : (" · " + Qt.formatTime(reset, "hh:mm"))
                        return "rate " + r + "/" + t + resetStr
                    }
                    pillColor: repoModel.service.rateLimitRemaining <= 5
                               ? Theme.error : Theme.surfaceHover
                    textColor: repoModel.service.rateLimitRemaining <= 5
                               ? Theme.textOnAccent : Theme.textSecondary
                }

                PillBadge {
                    visible: repoModel.service.isParsing
                    text: "parsing…"
                    pillColor: Theme.info
                }

                ComboBox {
                    id: modeCombo
                    model: ["Offset", "Cursor"]
                    currentIndex: repoModel.useCursor ? 1 : 0
                    onActivated: repoModel.useCursor = (currentIndex === 1)
                }

                Switch {
                    text: "Auto-refresh"
                    checked: repoModel.autoRefresh
                    enabled: !repoModel.useCursor
                    onToggled: repoModel.autoRefresh = checked
                    contentItem: Text {
                        text: parent.text
                        color: Theme.textSecondary
                        font.pixelSize: 12
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: parent.indicator.width + 6
                    }
                }

                TokenField {
                    service: repoModel.service
                }
            }

            Label {
                Layout.fillWidth: true
                visible: repoModel.service.errorMessage.length > 0
                text: {
                    const msg = repoModel.service.errorMessage
                    if (msg.toLowerCase().includes("rate limit") || msg.toLowerCase().includes("secondary rate"))
                        return msg + "\n\nTip: add a GitHub token above to raise your rate limit, or wait for it to reset."
                    return msg
                }
                color: Theme.error
                wrapMode: Text.WordWrap
                font.pixelSize: 13
            }

            ListContainer {
                id: listContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: repoModel

                delegate: RepoCard {
                    required property var model
                    width: ListView.view ? ListView.view.width : implicitWidth
                    fullName: model.fullName
                    description: model.description
                    stargazersCount: model.stargazersCount
                    forksCount: model.forksCount
                    language: model.language
                    isNew: model.isNew
                }

                // Cursor-mode infinite scroll: the footer becomes visible when the
                // user scrolls past the last row, which triggers fetchNextPage().
                footerComponent: Item {
                    width: listContainer.view.width
                    height: visible ? 56 : 0
                    visible: repoModel.useCursor && repoModel.hasMore

                    onVisibleChanged: {
                        if (visible && !repoModel.isLoadingPage)
                            repoModel.fetchNextPage()
                    }

                    BusyIndicator {
                        anchors.centerIn: parent
                        running: parent.visible && repoModel.isLoadingPage
                    }
                }
            }

            // Offset mode keeps an explicit Load-more button.
            AccentButton {
                Layout.alignment: Qt.AlignHCenter
                visible: !repoModel.useCursor
                text: repoModel.isLoadingPage ? "Loading…" : "Load more"
                enabled: repoModel.hasMore && !repoModel.isLoadingPage
                onClicked: repoModel.loadMore()
            }
        }
    }

    EmptyState {
        anchors.centerIn: parent
        visible: !repoModel.isLoadingPage
                 && repoModel.count === 0
                 && repoModel.service.errorMessage.length === 0
        glyph: "🔍"
        title: "Search GitHub"
        subtitle: "Type a query and hit Search to explore repositories"
    }
}
