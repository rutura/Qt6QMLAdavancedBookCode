import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property var theme
    property string currentView: ""
    property var githubService

    signal viewChanged(string view)
    signal refreshRequested()

    Rectangle {
        anchors.fill: parent
        color: theme.surface
        border.color: theme.borderLight
        border.width: 1

        Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
        Behavior on border.color { ColorAnimation { duration: theme.normalAnimation } }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // Quick action buttons
            Button {
                text: "🌟 Popular"
                flat: true

                background: Rectangle {
                    radius: 12
                    color: currentView === "repositories" ?
                           Qt.alpha(root.theme.accent, 0.15) :
                           (parent.hovered ? root.theme.surfaceHover : "transparent")
                    border.color: currentView === "repositories" ? root.theme.accent : "transparent"
                    border.width: currentView === "repositories" ? 1 : 0

                    Behavior on color { ColorAnimation { duration: root.theme.normalAnimation } }
                    Behavior on border.color { ColorAnimation { duration: root.theme.normalAnimation } }
                }

                contentItem: Text {
                    text: parent.text
                    color: currentView === "repositories" ? root.theme.accent : root.theme.textSecondary
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    Behavior on color { ColorAnimation { duration: root.theme.normalAnimation } }
                }

                onClicked: {
                    root.viewChanged("repositories")
                    githubService.searchRepositories("stars:>10000", "stars", "desc")
                }
            }

            Button {
                text: "👤 My Repos"
                flat: true
                visible: githubService.authToken.length > 0

                background: Rectangle {
                    radius: 12
                    color: currentView === "myrepos" ?
                                Qt.alpha(root.theme.accent, 0.15) :
                                (parent.hovered ? root.theme.surfaceHover : "transparent")
                    border.color: currentView === "myrepos" ? root.theme.accent : "transparent"
                    border.width: currentView === "myrepos" ? 1 : 0

                    Behavior on color { ColorAnimation { duration: root.theme.normalAnimation } }
                    Behavior on border.color { ColorAnimation { duration: root.theme.normalAnimation } }
                }

                contentItem: Text {
                    text: parent.text
                    color: currentView === "myrepos" ? root.theme.accent : root.theme.textSecondary
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    Behavior on color { ColorAnimation { duration: root.theme.normalAnimation } }
                }

                onClicked: {
                    root.viewChanged("myrepos")
                    githubService.fetchAuthenticatedUserRepositories()
                }
            }



            Button {
                text: "🔄 Refresh"
                flat: true

                background: Rectangle {
                    radius: 12
                    color: parent.hovered ? root.theme.surfaceHover : "transparent"

                    Behavior on color { ColorAnimation { duration: root.theme.normalAnimation } }
                }

                contentItem: Text {
                    text: parent.text
                    color: root.theme.textSecondary
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    Behavior on color { ColorAnimation { duration: root.theme.normalAnimation } }
                }

                onClicked: {
                    root.refreshRequested()
                }
            }

            Item { Layout.fillWidth: true }

            // View status
            Text {
                text: {
                    switch(currentView) {
                        case "search": return "🔍 Search Results"
                        case "user": return "👤 User Repositories"
                        case "myrepos": return "👤 My Repositories"
                        default: return "🌟 Popular Repositories"
                    }
                }
                color: root.theme.textTertiary
                font.pixelSize: 12

                Behavior on color { ColorAnimation { duration: root.theme.normalAnimation } }
            }
        }
    }
}
