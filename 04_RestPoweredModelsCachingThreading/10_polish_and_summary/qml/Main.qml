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
        // Restore PAT from persisted settings on startup.
        authToken: AppSettings.authToken
        onAuthTokenChanged: AppSettings.authToken = authToken
    }

    // Keyboard shortcuts for the search bar in the active tab.
    Shortcut {
        sequence: "Ctrl+L"
        onActivated: {
            const page = stackLayout.itemAt(tabBar.currentIndex)
            if (page && page.focusSearchField)
                page.focusSearchField()
        }
    }

    Shortcut {
        sequence: StandardKey.Cancel
        onActivated: {
            const page = stackLayout.itemAt(tabBar.currentIndex)
            if (page && page.clearSearchField)
                page.clearSearchField()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TabBar {
            id: tabBar
            Layout.fillWidth: true
            // Persist and restore the active tab across runs.
            currentIndex: AppSettings.lastTabIndex
            onCurrentIndexChanged: AppSettings.lastTabIndex = currentIndex

            TabButton { text: "Repositories" }
            TabButton { text: "Issues" }
            TabButton { text: "Users" }
        }

        StackLayout {
            id: stackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            RepositoryListPage {
                gitHubService: gitHubService
            }

            IssueListPage {
            }

            UserListPage {
            }
        }
    }
}

