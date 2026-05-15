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
                text: repoModel.count + " of " + repoModel.totalCount + " (page " + repoModel.currentPage + ")"
                color: "#6B7280"
            }
            Item { Layout.fillWidth: true }
        }

        Label {
            Layout.fillWidth: true
            visible: repoModel.service.errorMessage.length > 0
            text: repoModel.service.errorMessage
            color: "#B91C1C"
            wrapMode: Text.WordWrap
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
            }

            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
        }

        Button {
            Layout.alignment: Qt.AlignHCenter
            text: repoModel.isLoadingPage ? "Loading…" : "Load more"
            enabled: repoModel.hasMore && !repoModel.isLoadingPage
            onClicked: repoModel.loadMore()
        }
    }
}
