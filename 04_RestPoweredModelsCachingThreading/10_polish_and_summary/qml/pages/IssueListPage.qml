import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import RepoExplorerProApp

Item {
    id: root

    IssueListModel {
        id: issueModel
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
                placeholderText: "Search GitHub issues…"
                text: "is:issue qt qml"
                onAccepted: searchButton.clicked()
            }

            Button {
                id: searchButton
                text: "Search"
                enabled: !issueModel.isLoadingPage && queryField.text.length > 0
                onClicked: issueModel.search(queryField.text)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            BusyIndicator {
                running: issueModel.isLoadingPage
                visible: running
                implicitWidth: 20
                implicitHeight: 20
            }

            Label {
                text: issueModel.count + " of " + issueModel.totalCount
                color: "#6B7280"
            }

            Item { Layout.fillWidth: true }
        }

        Label {
            Layout.fillWidth: true
            visible: issueModel.errorMessage.length > 0
            text: {
                const msg = issueModel.errorMessage
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
                text: issueModel.authToken
                onTextChanged: issueModel.authToken = text
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            clip: true

            model: issueModel

            delegate: IssueDelegate {
                width: listView.width
                number:       model.number
                title:        model.title
                state:        model.state
                userLogin:    model.userLogin
                commentsCount: model.commentsCount
                htmlUrl:      model.htmlUrl
            }

            footer: Item {
                width: listView.width
                height: issueModel.hasMore ? 60 : 0
                visible: issueModel.hasMore

                Button {
                    anchors.centerIn: parent
                    text: issueModel.isLoadingPage ? "Loading…" : "Load More"
                    enabled: !issueModel.isLoadingPage
                    onClicked: issueModel.loadMore()
                }

                // Sentinel: entering viewport triggers load-more automatically.
                ListView.onAdd: {
                    if (listView.atYEnd && issueModel.hasMore && !issueModel.isLoadingPage)
                        issueModel.loadMore()
                }
            }
        }
    }
}
