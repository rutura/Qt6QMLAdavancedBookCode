import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    height: 40

    property var theme
    property int repositoryCount: 0
    property string currentView: "repositories"
    property bool isLoading: false
    property string lastUpdated: ""

    Rectangle {
        anchors.fill: parent
        color: theme.surface
        border.color: theme.borderLight
        border.width: 1

        Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
        Behavior on border.color { ColorAnimation { duration: theme.normalAnimation } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            spacing: 20

            //Content of the status bar laid out horizontally
            //Placeholder red rectangle
            /*
            Rectangle{
                color: "red"
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            */
            // Status indicator with count
            RowLayout {
                spacing: 12

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: {
                        if (root.isLoading) return theme.warning
                        if (root.repositoryCount > 0) return theme.success
                        return theme.textTertiary
                    }

                    Behavior on color { ColorAnimation { duration: theme.normalAnimation } }

                    // Pulse animation when loading
                    SequentialAnimation on scale {
                        running: root.isLoading
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.2; duration: 600 }
                        NumberAnimation { to: 1.0; duration: 600 }
                    }
                }

                Text {
                    text: {
                        if (root.isLoading) return "Loading repositories..."
                        if (root.repositoryCount === 0) return "No repositories found"
                        return `Found ${root.repositoryCount} ${root.repositoryCount === 1 ? 'repository' : 'repositories'}`
                    }
                    color: theme.textSecondary
                    font.pixelSize: 12

                    Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
                }
            }

            Rectangle {
                width: 1
                height: 20
                color: theme.borderLight

                Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
            }

            // Current view indicator
            Rectangle {
                width: viewText.implicitWidth + 20
                height: 24
                radius: 12
                color: Qt.alpha(theme.accent, 0.1)
                border.color: Qt.alpha(theme.accent, 0.2)
                border.width: 1

                Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
                Behavior on border.color { ColorAnimation { duration: theme.normalAnimation } }

                Text {
                    id: viewText
                    anchors.centerIn: parent
                    text: {
                        switch(root.currentView) {
                        case "search": return "🔍 Search Results"
                        case "user": return "👤 User Repositories"
                        case "myrepos": return "👤 My Repos"
                        default: return "🌟 Popular Repositories"
                        }
                    }
                    color: theme.accent
                    font.pixelSize: 10
                    font.weight: Font.Medium

                    Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
                }
            }

            Item { Layout.fillWidth: true }

            // Last updated info
            Text {
                visible: root.lastUpdated.length > 0
                text: `Updated ${root.lastUpdated}`
                color: theme.textTertiary
                font.pixelSize: 11

                Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
            }


            Rectangle {
                visible: root.lastUpdated.length > 0
                width: 1
                height: 20
                color: theme.borderLight

                Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
            }

            // API Status
            RowLayout {
                spacing: 8

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: theme.success

                    Behavior on color { ColorAnimation { duration: theme.normalAnimation } }

                    // Gentle pulse
                    SequentialAnimation on opacity {
                        running: true
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.5; duration: 2000 }
                        NumberAnimation { to: 1.0; duration: 2000 }
                    }
                }

                Text {
                    text: "GitHub API Connected"
                    color: theme.textTertiary
                    font.pixelSize: 10

                    Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
                }
            }


        }

    }

}
