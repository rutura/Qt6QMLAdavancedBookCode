import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    height: 160

    property var repositoryData
    property var theme
    signal clicked()

    Rectangle {
        id: cardBackground
        anchors.fill: parent
        anchors.margins: 8
        radius: 16
        color: theme.cardBackground
        border.color: theme.cardBorder
        border.width: 1

        // Custom shadow effect using multiple rectangles
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.leftMargin: 2
            anchors.rightMargin: 2
            z: -1
            radius: parent.radius
            color: theme.cardShadow
            opacity: 0.3

            Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
        }

        // Smooth theme transitions
        Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
        Behavior on border.color { ColorAnimation { duration: theme.normalAnimation } }

        // Hover effect
        Rectangle {
            id: hoverOverlay
            anchors.fill: parent
            radius: parent.radius
            color: theme.surfaceHover
            opacity: 0

            Behavior on opacity { NumberAnimation { duration: theme.fastAnimation } }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onEntered: hoverOverlay.opacity = 0.5
            onExited: hoverOverlay.opacity = 0
            onPressed: hoverOverlay.opacity = 0.8
            onReleased: hoverOverlay.opacity = mouseArea.containsMouse ? 0.5 : 0
            onClicked: root.clicked()
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            // Header row with repo name and status
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: repositoryData ? repositoryData.fullName : ""
                    color: theme.textPrimary
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                    elide: Text.ElideRight

                    Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
                }

                Rectangle {
                    width: statusText.implicitWidth + 16
                    height: 24
                    radius: 12
                    color: repositoryData && repositoryData.isPrivate ? theme.error : theme.success

                    Text {
                        id: statusText
                        anchors.centerIn: parent
                        text: repositoryData && repositoryData.isPrivate ? "Private" : "Public"
                        color: theme.textOnAccent
                        font.pixelSize: 10
                        font.weight: Font.Medium
                    }

                    Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
                }
            }

            // Description
            Text {
                text: repositoryData && repositoryData.description ?
                      repositoryData.description : "No description available"
                color: theme.textSecondary
                font.pixelSize: 13
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight

                Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
            }

            // Stats row
            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                // Language
                RowLayout {
                    spacing: 8
                    visible: repositoryData && repositoryData.language

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: theme.getLanguageColor(repositoryData ? repositoryData.language : "")

                        Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
                    }

                    Text {
                        text: repositoryData ? repositoryData.language : ""
                        color: theme.textSecondary
                        font.pixelSize: 12

                        Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
                    }
                }

                // Stars
                RowLayout {
                    spacing: 6

                    Text {
                        text: "★"
                        color: theme.warning
                        font.pixelSize: 12

                        Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
                    }

                    Text {
                        text: formatNumber(repositoryData ? repositoryData.stargazersCount : 0)
                        color: theme.textSecondary
                        font.pixelSize: 12

                        Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
                    }
                }

                // Forks
                RowLayout {
                    spacing: 6

                    Text {
                        text: "⚡"
                        color: theme.info
                        font.pixelSize: 12

                        Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
                    }

                    Text {
                        text: formatNumber(repositoryData ? repositoryData.forksCount : 0)
                        color: theme.textSecondary
                        font.pixelSize: 12

                        Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
                    }
                }

                Item { Layout.fillWidth: true }

                // Updated time
                Text {
                    text: formatDate(repositoryData ? repositoryData.updatedAt : new Date())
                    color: theme.textTertiary
                    font.pixelSize: 11

                    Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
                }
            }

            // Bottom accent line
            Rectangle {
                Layout.fillWidth: true
                height: 3
                radius: 1.5
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.3; color: theme.accent }
                    GradientStop { position: 0.7; color: theme.accent }
                    GradientStop { position: 1.0; color: "transparent" }
                }

                Behavior on color { ColorAnimation { duration: theme.normalAnimation } }
            }
        }
    }

    function formatNumber(num) {
        if (num >= 1000000) return (num / 1000000).toFixed(1) + "M"
        if (num >= 1000) return (num / 1000).toFixed(1) + "k"
        return num.toString()
    }

    function formatDate(date) {
        if (!date) return ""
        const now = new Date()
        const diffTime = Math.abs(now - date)
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))

        if (diffDays === 0) return "Today"
        if (diffDays === 1) return "Yesterday"
        if (diffDays < 7) return diffDays + " days ago"
        if (diffDays < 30) return Math.ceil(diffDays / 7) + " weeks ago"
        if (diffDays < 365) return Math.ceil(diffDays / 30) + " months ago"
        return Math.ceil(diffDays / 365) + " years ago"
    }
}
