import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import GitHubClient 1.0

Window {
    id: window
    width: 1400
    height: 900
    visible: true
    title: "GitHub Explorer"


    // Modern theme system
    Theme {
        id: appTheme
    }

    property string currentView: "repositories" // "repositories", "search", "user"
    property string lastUpdated: ""
    property string lastSearchQuery: ""
    property string lastUsername: ""

    // GitHub Service
    GitHubService {
        id: githubService

        onRepositoriesChanged: {
            lastUpdated = new Date().toLocaleTimeString(Qt.locale(), "hh:mm")
        }
    }

    // Dummy repository data
    /*
    property var repositories: [
        {
            fullName: "microsoft/vscode",
            description: "Visual Studio Code - Open source code editor",
            language: "TypeScript",
            stargazersCount: 142000,
            forksCount: 25000,
            isPrivate: false,
            updatedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
            htmlUrl: "https://github.com/microsoft/vscode"
        },
        {
            fullName: "microsoft/vscode",
            description: "Visual Studio Code - Open source code editor",
            language: "TypeScript",
            stargazersCount: 142000,
            forksCount: 25000,
            isPrivate: false,
            updatedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
            htmlUrl: "https://github.com/microsoft/vscode"
        },
        {
            fullName: "microsoft/vscode",
            description: "Visual Studio Code - Open source code editor",
            language: "TypeScript",
            stargazersCount: 142000,
            forksCount: 25000,
            isPrivate: false,
            updatedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
            htmlUrl: "https://github.com/microsoft/vscode"
        },
        {
            fullName: "microsoft/vscode",
            description: "Visual Studio Code - Open source code editor",
            language: "TypeScript",
            stargazersCount: 142000,
            forksCount: 25000,
            isPrivate: false,
            updatedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
            htmlUrl: "https://github.com/microsoft/vscode"
        },
        {
            fullName: "microsoft/vscode",
            description: "Visual Studio Code - Open source code editor",
            language: "TypeScript",
            stargazersCount: 142000,
            forksCount: 25000,
            isPrivate: false,
            updatedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
            htmlUrl: "https://github.com/microsoft/vscode"
        },
        {
            fullName: "microsoft/vscode",
            description: "Visual Studio Code - Open source code editor",
            language: "TypeScript",
            stargazersCount: 142000,
            forksCount: 25000,
            isPrivate: false,
            updatedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
            htmlUrl: "https://github.com/microsoft/vscode"
        },
        {
            fullName: "microsoft/vscode",
            description: "Visual Studio Code - Open source code editor",
            language: "TypeScript",
            stargazersCount: 142000,
            forksCount: 25000,
            isPrivate: false,
            updatedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
            htmlUrl: "https://github.com/microsoft/vscode"
        },
        {
            fullName: "microsoft/vscode",
            description: "Visual Studio Code - Open source code editor",
            language: "TypeScript",
            stargazersCount: 142000,
            forksCount: 25000,
            isPrivate: false,
            updatedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
            htmlUrl: "https://github.com/microsoft/vscode"
        },
        {
            fullName: "microsoft/vscode",
            description: "Visual Studio Code - Open source code editor",
            language: "TypeScript",
            stargazersCount: 142000,
            forksCount: 25000,
            isPrivate: false,
            updatedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
            htmlUrl: "https://github.com/microsoft/vscode"
        },
        {
            fullName: "microsoft/vscode",
            description: "Visual Studio Code - Open source code editor",
            language: "TypeScript",
            stargazersCount: 142000,
            forksCount: 25000,
            isPrivate: false,
            updatedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
            htmlUrl: "https://github.com/microsoft/vscode"
        },

        {
            fullName: "facebook/react",
            description: "The library for web and native user interfaces",
            language: "JavaScript",
            stargazersCount: 218000,
            forksCount: 44000,
            isPrivate: false,
            updatedAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
            htmlUrl: "https://github.com/facebook/react"
        },
        {
            fullName: "python/cpython",
            description: "The Python programming language",
            language: "Python",
            stargazersCount: 55000,
            forksCount: 28000,
            isPrivate: false,
            updatedAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
            htmlUrl: "https://github.com/python/cpython"
        },
        {
            fullName: "rust-lang/rust",
            description: "Empowering everyone to build reliable and efficient software",
            language: "Rust",
            stargazersCount: 89000,
            forksCount: 11500,
            isPrivate: false,
            updatedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
            htmlUrl: "https://github.com/rust-lang/rust"
        },
        {
            fullName: "golang/go",
            description: "The Go programming language",
            language: "Go",
            stargazersCount: 118000,
            forksCount: 16800,
            isPrivate: false,
            updatedAt: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000),
            htmlUrl: "https://github.com/golang/go"
        },
        {
            fullName: "torvalds/linux",
            description: "Linux kernel source tree",
            language: "C",
            stargazersCount: 165000,
            forksCount: 48000,
            isPrivate: false,
            updatedAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
            htmlUrl: "https://github.com/torvalds/linux"
        }
    ]
    */

    // Background with theme-aware gradient
    Rectangle {
        anchors.fill: parent
        color: appTheme.background

        Behavior on color { ColorAnimation { duration: appTheme.normalAnimation } }
    }

    ColumnLayout{
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        //Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            color: appTheme.surface
            border.color: appTheme.borderLight
            border.width: 1

            Behavior on color {
                ColorAnimation {
                    duration: appTheme.normalAnimation
                }
            }
            Behavior on border.color {
                ColorAnimation { duration: appTheme.normalAnimation }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 32
                anchors.rightMargin: 32
                spacing: 32

                // App branding
                RowLayout {
                    spacing: 20

                    // Modern logo
                    Rectangle {
                        width: 56
                        height: 56
                        radius: 16
                        Layout.alignment: Qt.AlignVCenter
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: appTheme.accent }
                            GradientStop { position: 1.0; color: appTheme.accentHover }
                        }

                        //Subtle glow effect: visible better around the logo in dark mode
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width + 4
                            height: parent.height + 4
                            radius: parent.radius + 2
                            color: "transparent"
                            border.color: Qt.alpha(appTheme.accent, 0.3)
                            border.width: 1

                            Behavior on border.color { ColorAnimation { duration: appTheme.normalAnimation } }
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
                            color: appTheme.textPrimary
                            font.pixelSize: 28
                            font.weight: Font.Bold

                            Behavior on color { ColorAnimation { duration: appTheme.normalAnimation } }
                        }

                        Text {
                            text: "Discover amazing repositories"
                            color: appTheme.textSecondary
                            font.pixelSize: 14

                            Behavior on color { ColorAnimation { duration: appTheme.normalAnimation } }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                RowLayout{
                    spacing: 20

                    SearchBar {
                        Layout.preferredWidth: 400
                        theme: appTheme
                        onSearchRequested: function(query) {
                            if (query.trim().length > 0) {
                                githubService.searchRepositories(query)
                                currentView = "search"
                                console.log(query)
                            }
                        }
                        onUserSearchRequested: function(username) {
                            if (username.trim().length > 0) {
                                githubService.fetchUserRepositories(username)
                                currentView = "user"
                                console.log(username)
                            }
                        }
                    }

                    ThemeToggle {
                        theme: appTheme
                    }

                    TokenInput {
                        Layout.preferredWidth: 240
                        Layout.preferredHeight: 36
                        theme: appTheme
                        onTokenChanged: function(token) {
                            githubService.authToken = token
                        }
                    }

                }

            }
        }

        // Quick Actions toolbar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: appTheme.surface
            border.color: appTheme.borderLight
            border.width: 1

            Behavior on color { ColorAnimation { duration: appTheme.normalAnimation } }
            Behavior on border.color { ColorAnimation { duration: appTheme.normalAnimation } }

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
                                   Qt.alpha(appTheme.accent, 0.15) :
                                   (parent.hovered ? appTheme.surfaceHover : "transparent")
                        border.color: currentView === "repositories" ? appTheme.accent : "transparent"
                        border.width: currentView === "repositories" ? 1 : 0

                        Behavior on color { ColorAnimation { duration: appTheme.normalAnimation } }
                        Behavior on border.color { ColorAnimation { duration: appTheme.normalAnimation } }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: currentView === "repositories" ? appTheme.accent : appTheme.textSecondary
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        Behavior on color { ColorAnimation { duration: appTheme.normalAnimation } }
                    }

                    onClicked: {
                        currentView = "repositories"
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
                                   Qt.alpha(appTheme.accent, 0.15) :
                                   (parent.hovered ? appTheme.surfaceHover : "transparent")
                        border.color: currentView === "myrepos" ? appTheme.accent : "transparent"
                        border.width: currentView === "myrepos" ? 1 : 0

                        Behavior on color { ColorAnimation { duration: appTheme.normalAnimation } }
                        Behavior on border.color { ColorAnimation { duration: appTheme.normalAnimation } }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: currentView === "myrepos" ? appTheme.accent : appTheme.textSecondary
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        Behavior on color { ColorAnimation { duration: appTheme.normalAnimation } }
                    }

                    onClicked: {
                        window.currentView = "myrepos"
                        window.lastSearchQuery = ""
                        window.lastUsername = ""
                        githubService.fetchAuthenticatedUserRepositories()
                    }
                }

                Button {
                    text: "🔄 Refresh"
                    flat: true

                    background: Rectangle {
                        radius: 12
                        color: parent.hovered ? appTheme.surfaceHover : "transparent"

                        Behavior on color { ColorAnimation { duration: appTheme.normalAnimation } }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: appTheme.textSecondary
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        Behavior on color { ColorAnimation { duration: appTheme.normalAnimation } }
                    }

                    onClicked: {
                        switch(currentView) {
                        case "search":
                            if (window.lastSearchQuery.length > 0) {
                                githubService.searchRepositories(window.lastSearchQuery)
                            }
                            break
                        case "user":
                            if (window.lastUsername.length > 0) {
                                githubService.fetchUserRepositories(window.lastUsername)
                            }
                            break
                        case "myrepos":
                            githubService.fetchAuthenticatedUserRepositories()
                            break
                        default:
                            githubService.searchRepositories("stars:>10000", "stars", "desc")
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // View status
                Text {
                    text: {
                        switch(currentView) {
                        case "search": return "🔍 Search Results"
                        case "user": return "👤 User Repositories"
                        default: return "🌟 Popular Repositories"
                        }
                    }
                    color: appTheme.textTertiary
                    font.pixelSize: 12

                    Behavior on color { ColorAnimation { duration: appTheme.normalAnimation } }
                }


            }
        }



        //Grid Layout with cards
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth

            background: Rectangle {
                color: appTheme.background
                Behavior on color { ColorAnimation { duration: appTheme.normalAnimation } }
            }

            GridView {
                id: repositoryGrid
                anchors.fill: parent
                anchors.margins: 20
                model: githubService.repositories
                cellWidth: Math.floor(width / Math.max(1, Math.floor(width / 380)))
                cellHeight: 180

                delegate: RepoCard {
                    width: repositoryGrid.cellWidth
                    height: repositoryGrid.cellHeight
                    repositoryData: modelData
                    theme: appTheme

                    onClicked: {
                        console.log("Repository clicked:", repositoryData.fullName)
                        if (repositoryData.htmlUrl) {
                            Qt.openUrlExternally(repositoryData.htmlUrl)
                        }
                    }
                }
            }
        }

        // Status bar
        StatusBar {
            Layout.fillWidth: true
            theme: appTheme
            repositoryCount: githubService.repositories.length
            currentView: window.currentView
            isLoading: githubService.isLoading
            lastUpdated: window.lastUpdated
        }
    }
}
