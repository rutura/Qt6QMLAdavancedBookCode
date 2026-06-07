import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import RepoExplorerProApp

Item {
    id: root

    UserListModel {
        id: userModel
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        AppHeader {
            Layout.fillWidth: true

            SearchField {
                id: queryField
                Layout.preferredWidth: 380
                placeholderText: "Search GitHub users…"
                text: "qt"
                onAccepted: searchButton.clicked()
            }

            AccentButton {
                id: searchButton
                text: "Search"
                enabled: !userModel.isLoadingPage && queryField.text.length > 0
                onClicked: userModel.search(queryField.text)
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
                busy: userModel.isLoadingPage
                statusText: userModel.count + " of " + userModel.totalCount
                             + "  ·  page " + userModel.currentPage

                TokenField {
                    service: userModel.service
                }
            }

            Label {
                Layout.fillWidth: true
                visible: userModel.service.errorMessage.length > 0
                text: {
                    const msg = userModel.service.errorMessage
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
                model: userModel

                delegate: UserCard {
                    required property var model
                    width: ListView.view ? ListView.view.width : implicitWidth
                    login: model.login
                    avatarUrl: model.avatarUrl
                    htmlUrl: model.htmlUrl
                    userType: model.userType
                }
            }

            AccentButton {
                Layout.alignment: Qt.AlignHCenter
                text: userModel.isLoadingPage ? "Loading…" : "Load more"
                enabled: userModel.hasMore && !userModel.isLoadingPage
                visible: userModel.count > 0
                onClicked: userModel.loadMore()
            }
        }
    }

    EmptyState {
        anchors.centerIn: parent
        visible: !userModel.isLoadingPage
                 && userModel.count === 0
                 && userModel.service.errorMessage.length === 0
        glyph: "👤"
        title: "Search Users"
        subtitle: "Type a query and hit Search to explore GitHub users"
    }
}
