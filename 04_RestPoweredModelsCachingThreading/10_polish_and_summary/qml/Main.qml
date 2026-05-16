import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

import RepoExplorerProApp

ApplicationWindow {
    id: window

    visible: true
    width: 1100
    height: 750
    minimumWidth: 800
    minimumHeight: 500
    title: "Repo Explorer Pro"

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

            TabButton { text: "Repositories" }
            TabButton { text: "Issues" }
            TabButton { text: "Users" }
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
