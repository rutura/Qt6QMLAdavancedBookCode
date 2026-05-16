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
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TabBar {
            id: tabBar
            Layout.fillWidth: true

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
