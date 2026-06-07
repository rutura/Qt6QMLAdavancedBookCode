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
        spacing: 0

        AppHeader {
            Layout.fillWidth: true

            SearchField {
                id: queryField
                Layout.preferredWidth: 380
                placeholderText: "Search GitHub issues…"
                text: "qt"
                onAccepted: searchButton.clicked()
            }

            AccentButton {
                id: searchButton
                text: "Search"
                enabled: !issueModel.isLoadingPage && queryField.text.length > 0
                onClicked: issueModel.search(queryField.text)
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
                busy: issueModel.isLoadingPage
                statusText: issueModel.count + " of " + issueModel.totalCount
                             + "  ·  page " + issueModel.currentPage

                PillBadge {
                    visible: issueModel.service.isParsing
                    text: "parsing…"
                    pillColor: Theme.info
                }

                TokenField {
                    service: issueModel.service
                }
            }

            Label {
                Layout.fillWidth: true
                visible: issueModel.service.errorMessage.length > 0
                text: {
                    const msg = issueModel.service.errorMessage
                    if (msg.toLowerCase().includes("rate limit") || msg.toLowerCase().includes("secondary rate"))
                        return msg + "\n\nTip: add a GitHub token above to raise your rate limit."
                    return msg
                }
                color: Theme.error
                wrapMode: Text.WordWrap
                font.pixelSize: 13
            }

            ListContainer {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: issueModel

                delegate: IssueCard {
                    required property var model
                    width: ListView.view ? ListView.view.width : implicitWidth
                    number: model.number
                    title: model.title
                    issueState: model.state
                    repoFullName: model.repoFullName
                    commentsCount: model.commentsCount
                    userLogin: model.userLogin
                    createdAt: model.createdAt
                }
            }

            AccentButton {
                Layout.alignment: Qt.AlignHCenter
                text: issueModel.isLoadingPage ? "Loading…" : "Load more"
                enabled: issueModel.hasMore && !issueModel.isLoadingPage
                visible: issueModel.count > 0
                onClicked: issueModel.loadMore()
            }
        }
    }

    EmptyState {
        anchors.centerIn: parent
        visible: !issueModel.isLoadingPage
                 && issueModel.count === 0
                 && issueModel.service.errorMessage.length === 0
        glyph: "🐛"
        title: "Search Issues"
        subtitle: "Type a query and hit Search to explore GitHub issues"
    }
}
