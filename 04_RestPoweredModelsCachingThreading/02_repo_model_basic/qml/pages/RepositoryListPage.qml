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
                enabled: !repoModel.service.isLoading && queryField.text.length > 0
                onClicked: repoModel.search(queryField.text)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Label {
                visible: repoModel.service.isLoading
                text: "Loading…"
                color: "#6B7280"
            }
            Label {
                text: repoModel.count + " results"
                color: "#6B7280"
            }
        }

        Label {
            Layout.fillWidth: true
            visible: repoModel.service.errorMessage.length > 0
            text: {
                const msg = repoModel.service.errorMessage
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
                text: repoModel.service.authToken
                onTextChanged: repoModel.service.authToken = text
            }
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
    }
}
