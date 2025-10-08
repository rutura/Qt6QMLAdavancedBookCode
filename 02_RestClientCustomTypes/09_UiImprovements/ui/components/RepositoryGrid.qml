import QtQuick
import QtQuick.Controls

Item {
    id: root

    property var theme
    property var githubService
    property string currentView: ""

    signal repositoryClicked(var repositoryData)

    ScrollView {
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth

        background: Rectangle {
            color: root.theme.background
            Behavior on color { ColorAnimation { duration: root.theme.normalAnimation } }
        }

        GridView {
            id: repositoryGrid
            anchors.fill: parent
            anchors.margins: 20
            model: root.githubService.repositories
            cellWidth: Math.floor(width / Math.max(1, Math.floor(width / 380)))
            cellHeight: 180

            delegate: RepoCard {
                width: repositoryGrid.cellWidth
                height: repositoryGrid.cellHeight
                repositoryData: modelData
                theme: root.theme

                onClicked: {
                    root.repositoryClicked(repositoryData)
                }
            }

            // Empty state
            EmptyState {
                anchors.centerIn: parent
                theme: root.theme
                currentView: root.currentView
                isVisible: repositoryGrid.count === 0 && !root.githubService.isLoading
            }

            // Loading overlay
            LoadingOverlay {
                anchors.fill: parent
                theme: root.theme
                isLoading: root.githubService.isLoading
            }
        }
    }
}
