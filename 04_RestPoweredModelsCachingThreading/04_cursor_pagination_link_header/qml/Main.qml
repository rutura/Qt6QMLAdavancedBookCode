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

            Item {
                Label {
                    anchors.centerIn: parent
                    text: "Issues tab — activated in section 09"
                    font.pixelSize: 16
                    color: "#6B7280"
                }
            }

            Item {
                Label {
                    anchors.centerIn: parent
                    text: "Users tab — activated in section 09"
                    font.pixelSize: 16
                    color: "#6B7280"
                }
            }
        }
    }
}
