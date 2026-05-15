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
                enabled: !repoModel.isLoadingPage && queryField.text.length > 0
                onClicked: repoModel.search(queryField.text)
            }

            ComboBox {
                id: modeCombo
                model: ["Offset", "Cursor"]
                currentIndex: repoModel.useCursor ? 1 : 0
                onActivated: repoModel.useCursor = (currentIndex === 1)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            BusyIndicator {
                running: repoModel.isLoadingPage
                visible: running
                implicitWidth: 20
                implicitHeight: 20
            }
            Label {
                text: repoModel.useCursor
                      ? (repoModel.count + " loaded — " + (repoModel.hasMore ? "more available" : "end of results"))
                      : (repoModel.count + " of " + repoModel.totalCount + " (page " + repoModel.currentPage + ")")
                color: "#6B7280"
            }
            Label {
                visible: repoModel.service.isParsing
                text: "parsing…"
                color: "#9333EA"
                font.italic: true
            }
            Item { Layout.fillWidth: true }
        }

        // Rate limit status — hidden until we've received at least one response.
        Label {
            Layout.fillWidth: true
            visible: repoModel.service.rateLimitTotal > 0
            text: {
                const rem = repoModel.service.rateLimitRemaining
                const tot = repoModel.service.rateLimitTotal
                const reset = repoModel.service.rateLimitReset
                const resetStr = reset.toLocaleTimeString(Qt.locale(), "HH:mm")
                return "rate limit: " + rem + "/" + tot + ", resets at " + resetStr
            }
            color: repoModel.service.rateLimitRemaining < 10 ? "#B45309" : "#6B7280"
            font.pixelSize: 11
        }

        Label {
            Layout.fillWidth: true
            visible: repoModel.service.errorMessage.length > 0
            text: repoModel.service.errorMessage
            color: "#B91C1C"
            wrapMode: Text.WordWrap
        }

        TokenSettings {
            Layout.fillWidth: true
            service: repoModel.service
        }

        // Live-refresh controls.
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label { text: "Auto-refresh:"; color: "#6B7280"; font.pixelSize: 12 }

            Switch {
                id: autoRefreshSwitch
                checked: repoModel.autoRefresh
                onToggled: repoModel.autoRefresh = checked
            }

            Label {
                text: "every"
                color: "#6B7280"
                font.pixelSize: 12
                visible: autoRefreshSwitch.checked
            }

            ComboBox {
                visible: autoRefreshSwitch.checked
                model: ["30 s", "60 s", "120 s"]
                currentIndex: 1
                onActivated: {
                    const ms = [30000, 60000, 120000][currentIndex]
                    repoModel.refreshIntervalMs = ms
                }
            }

            Item { Layout.fillWidth: true }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 6
            model: repoModel

            delegate: RepoDelegate {
                fullName: model.fullName
                description: model.description
                stargazersCount: model.stargazersCount
                forksCount: model.forksCount
                language: model.language
                isNew: model.isNew
            }

            // Cursor-mode infinite-scroll trigger: footer becomes visible when the user
            // scrolls past the last row, which fires fetchNextPage(). Offset mode keeps
            // its explicit Load-more button below the list.
            footer: Item {
                width: listView.width
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

            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
        }

        Button {
            Layout.alignment: Qt.AlignHCenter
            visible: !repoModel.useCursor
            text: repoModel.isLoadingPage ? "Loading…" : "Load more"
            enabled: repoModel.hasMore && !repoModel.isLoadingPage
            onClicked: repoModel.loadMore()
        }
    }
}
