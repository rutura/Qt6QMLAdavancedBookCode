import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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

        // Dummy repository data
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
                                GradientStop { position: 0.0; color: appTheme.accent }
                                GradientStop { position: 1.0; color: appTheme.accentHover }
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

                    // Simple theme toggle
                    Rectangle {
                        width: 60
                        height: 32
                        radius: 16
                        color: appTheme.surface
                        border.color: appTheme.border
                        border.width: 1

                        Rectangle {
                            id: toggleKnob
                            width: 24
                            height: 24
                            radius: 12
                            anchors.verticalCenter: parent.verticalCenter
                            x: appTheme.isDark ? parent.width - width - 4 : 4
                            color: appTheme.accent

                            Behavior on x { NumberAnimation { duration: appTheme.normalAnimation } }

                            Text {
                                anchors.centerIn: parent
                                text: appTheme.isDark ? "🌙" : "☀️"
                                font.pixelSize: 12
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: appTheme.toggleTheme()
                        }
                    }
                }
            }



            //Grid Layout with cards
            // Repository grid
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
                    model: repositories
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



            //Status bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: appTheme.surface
                border.color: appTheme.borderLight
                border.width: 1

                Behavior on color { ColorAnimation { duration: appTheme.normalAnimation } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16

                    Text {
                        text: repositories.length + " repositories"
                        color: appTheme.textSecondary
                        font.pixelSize: 12

                        Behavior on color { ColorAnimation { duration: appTheme.normalAnimation } }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "Ready"
                        color: appTheme.textSecondary
                        font.pixelSize: 12

                        Behavior on color { ColorAnimation { duration: appTheme.normalAnimation } }
                    }
                }
            }
        }
}
