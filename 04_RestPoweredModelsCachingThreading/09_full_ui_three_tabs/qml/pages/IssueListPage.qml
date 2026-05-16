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
                text: "is:issue qt qml"
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

                TokenField {
                    service: issueModel
                }
            }

            Label {
                Layout.fillWidth: true
                visible: issueModel.errorMessage.length > 0
                text: {
                    const msg = issueModel.errorMessage
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
                model: issueModel

                delegate: IssueCard {
                    required property var model
                    width: ListView.view ? ListView.view.width : implicitWidth
                    number: model.number
                    title: model.title
                    state: model.state
                    userLogin: model.userLogin
                    commentsCount: model.commentsCount
                }

                footerComponent: Item {
                    width: listContainer.view.width
                    height: visible ? 56 : 0
                    visible: issueModel.hasMore

                    onVisibleChanged: {
                        if (visible && !issueModel.isLoadingPage)
                            issueModel.loadMore()
                    }

                    BusyIndicator {
                        anchors.centerIn: parent
                        running: parent.visible && issueModel.isLoadingPage
                    }
                }
            }
        }
    }

    EmptyState {
        anchors.centerIn: parent
        visible: !issueModel.isLoadingPage
                 && issueModel.count === 0
                 && issueModel.errorMessage.length === 0
        glyph: "🐛"
        title: "Search Issues"
        subtitle: "Find issues across GitHub by keyword"
    }
}
