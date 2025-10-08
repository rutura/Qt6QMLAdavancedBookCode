import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property alias theme: headerRect.theme
    property alias githubService: searchBar.githubService

    signal searchRequested(string query)
    signal userSearchRequested(string username)
    signal tokenChanged(string token)

    Rectangle {
        id: headerRect
        anchors.fill: parent
        color: theme.surface
        border.color: theme.borderLight
        border.width: 1

        property var theme

        Behavior on color {
            ColorAnimation {
                duration: theme.normalAnimation
            }
        }
        Behavior on border.color {
            ColorAnimation { duration: theme.normalAnimation }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 32
            spacing: 32

            // App branding
            RowLayout {
                spacing: 20

                // Modern logo
                Rectangle {
                    width: 56
                    height: 56
                    radius: 16
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: headerRect.theme.accent }
                        GradientStop { position: 1.0; color: headerRect.theme.accentHover }
                    }

                    // Subtle glow effect
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + 4
                        height: parent.height + 4
                        radius: parent.radius + 2
                        color: "transparent"
                        border.color: Qt.alpha(headerRect.theme.accent, 0.3)
                        border.width: 1

                        Behavior on border.color { ColorAnimation { duration: headerRect.theme.normalAnimation } }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "🚀"
                        font.pixelSize: 28
                    }
                }

                Column {
                    spacing: 4

                    Text {
                        text: "GitHub Explorer"
                        color: headerRect.theme.textPrimary
                        font.pixelSize: 28
                        font.weight: Font.Bold

                        Behavior on color { ColorAnimation { duration: headerRect.theme.normalAnimation } }
                    }

                    Text {
                        text: "Discover amazing repositories"
                        color: headerRect.theme.textSecondary
                        font.pixelSize: 14

                        Behavior on color { ColorAnimation { duration: headerRect.theme.normalAnimation } }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Search section
            RowLayout {
                spacing: 20

                SearchBar {
                    id: searchBar
                    Layout.preferredWidth: 400
                    theme: headerRect.theme
                    property var githubService
                    onSearchRequested: function(query) {
                        root.searchRequested(query)
                    }
                    onUserSearchRequested: function(username) {
                        root.userSearchRequested(username)
                    }
                }

                ThemeToggle {
                    theme: headerRect.theme
                }

                TokenInput {
                    Layout.preferredWidth: 240
                    Layout.preferredHeight: 36
                    theme: headerRect.theme
                    onTokenChanged: function(token) {
                        root.tokenChanged(token)
                    }
                }
            }
        }
    }
}
