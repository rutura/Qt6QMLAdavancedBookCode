import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import RepoExplorerProApp

Item {
    id: root

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
                enabled: !repoModel.isLoadingPage && queryField.text.length > 0   // CHANGED
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
                statusText: repoModel.useCursor                                       // CHANGED
                                ? (repoModel.count + " loaded · "
                                   + (repoModel.hasMore ? "more available" : "end of results"))
                                : (repoModel.count + " of " + repoModel.totalCount
                                   + "  ·  page " + repoModel.currentPage)

                // NEW: live rate-limit pill
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

                ComboBox {                                                            // NEW
                    id: modeCombo
                    model: ["Offset", "Cursor"]
                    currentIndex: repoModel.useCursor ? 1 : 0
                    onActivated: repoModel.useCursor = (currentIndex === 1)
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
                id: listContainer                                 // NEW: footer references its view
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
                }

                // Cursor-mode infinite scroll: a Connections block watches
                // atYEnd so fetchNextPage() fires only on an actual scroll event.
                footerComponent: Item {
                    width: listContainer.view.width
                    // Reserve room only while the "load more" spinner is showing,
                    // so an empty list doesn't carry dead space at the top.
                    height: footerSpinner.visible ? 56 : 0

                    BusyIndicator {
                        id: footerSpinner
                        anchors.centerIn: parent
                        // Only for cursor-mode "load more" — never the first fetch,
                        // where StatusStrip's spinner already covers the loading state.
                        visible: repoModel.useCursor && repoModel.isLoadingPage && repoModel.count > 0
                        running: parent.visible
                        contentItem: Item {
                            implicitWidth: 32
                            implicitHeight: 32
                            Rectangle {        // faint track ring
                                anchors.fill: parent
                                radius: width / 2
                                color: "transparent"
                                border { width: 3; color: Qt.alpha(Theme.accent, 0.25) }
                            }
                            Rectangle {        // leading dot
                                width: 8; height: 8; radius: 4
                                color: Theme.accent
                                anchors { horizontalCenter: parent.horizontalCenter
                                            top: parent.top; topMargin: -1 }
                            }
                            RotationAnimator on rotation {
                                running: true; loops: Animation.Infinite
                                from: 0; to: 360; duration: 900
                            }
                        }
                    }
                }
            }

            Connections {
                target: listContainer.view
                function onAtYEndChanged() {
                    if (listContainer.view.atYEnd
                            && repoModel.useCursor
                            && repoModel.hasMore
                            && !repoModel.isLoadingPage)
                        repoModel.fetchNextPage()
                }
            }

            // NEW: Load more button
            AccentButton {
                Layout.alignment: Qt.AlignHCenter
                visible: !repoModel.useCursor                     // NEW
                text: repoModel.isLoadingPage ? "Loading…" : "Load more"
                enabled: repoModel.hasMore && !repoModel.isLoadingPage
                onClicked: repoModel.loadMore()
            }
        }
    }

    EmptyState {
        anchors.centerIn: parent
        visible: !repoModel.isLoadingPage                                  // CHANGED
                 && repoModel.count === 0                                  // CHANGED
                 && repoModel.service.errorMessage.length === 0            // CHANGED
        glyph: "🔍"
        title: "Search GitHub"
        subtitle: "Type a query and hit Search to explore repositories"
    }
}
