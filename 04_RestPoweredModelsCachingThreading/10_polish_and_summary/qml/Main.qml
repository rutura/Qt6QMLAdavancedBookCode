import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

import RepoExplorerProApp

ApplicationWindow {
    id: window

    visible: true
    width: 1180
    height: 800
    minimumWidth: 900
    minimumHeight: 560
    title: "Repo Explorer Pro"

    color: Theme.background
    Behavior on color { ColorAnimation { duration: Theme.normalAnimation } }

    GitHubService {
        id: gitHubService
        // Restore the persisted PAT on startup; write changes straight back.
        authToken: AppSettings.authToken
        onAuthTokenChanged: AppSettings.authToken = authToken
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TabBar {
            id: tabBar
            Layout.fillWidth: true

            // Restore the last-used tab, and persist any change.
            Component.onCompleted: currentIndex = AppSettings.lastTabIndex
            onCurrentIndexChanged: AppSettings.lastTabIndex = currentIndex

            background: Rectangle {
                color: Theme.surface
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Theme.borderLight
                }
            }

            component AppTab: TabButton {
                id: tabCtl
                contentItem: Text {
                    text: tabCtl.text
                    color: tabCtl.checked ? Theme.accent : Theme.textSecondary
                    font.pixelSize: 14
                    font.weight: tabCtl.checked ? Font.DemiBold : Font.Normal
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Behavior on color { ColorAnimation { duration: Theme.fastAnimation } }
                }
                background: Rectangle {
                    color: "transparent"
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 2
                        color: tabCtl.checked ? Theme.accent : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.fastAnimation } }
                    }
                }
            }

            AppTab { text: "Repositories" }
            AppTab { text: "Issues" }
            AppTab { text: "Users" }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            RepositoryListPage {
                gitHubService: gitHubService
            }

            IssueListPage {}

            UserListPage {}
        }
    }
}
