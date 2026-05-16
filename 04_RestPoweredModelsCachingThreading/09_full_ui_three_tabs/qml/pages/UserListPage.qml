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
                text: "qt developer"
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

                TokenField {
                    service: userModel
                }
            }

            Label {
                Layout.fillWidth: true
                visible: userModel.errorMessage.length > 0
                text: {
                    const msg = userModel.errorMessage
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
                model: userModel

                delegate: UserCard {
                    required property var model
                    width: ListView.view ? ListView.view.width : implicitWidth
                    login: model.login
                    avatarUrl: model.avatarUrl
                    userType: model.userType
                }

                footerComponent: Item {
                    width: listContainer.view.width
                    height: visible ? 56 : 0
                    visible: userModel.hasMore

                    onVisibleChanged: {
                        if (visible && !userModel.isLoadingPage)
                            userModel.loadMore()
                    }

                    BusyIndicator {
                        anchors.centerIn: parent
                        running: parent.visible && userModel.isLoadingPage
                    }
                }
            }
        }
    }

    EmptyState {
        anchors.centerIn: parent
        visible: !userModel.isLoadingPage
                 && userModel.count === 0
                 && userModel.errorMessage.length === 0
        glyph: "👤"
        title: "Search Users"
        subtitle: "Discover GitHub users and organizations"
    }
}
