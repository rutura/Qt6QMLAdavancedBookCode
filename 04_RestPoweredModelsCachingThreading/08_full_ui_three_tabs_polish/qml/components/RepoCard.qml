import QtQuick
import QtQuick.Layouts

Item {
    id: root

    // Bound per-section to either gitHubService.repositories entries (01)
    // or model roles (02+). All optional so a missing field degrades gracefully.
    property string fullName: ""
    property string description: ""
    property int stargazersCount: 0
    property int forksCount: 0
    property string language: ""
    property bool isPrivate: false
    property var updatedAt: undefined

    signal clicked()

    implicitHeight: 168

    Rectangle {
        id: card
        anchors.fill: parent
        anchors.margins: 6
        radius: 16
        color: Theme.cardBackground
        border.color: Theme.cardBorder
        border.width: 1

        // Soft offset shadow.
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.leftMargin: 2
            anchors.rightMargin: 2
            z: -1
            radius: parent.radius
            color: Theme.cardShadow
            opacity: 0.3
        }

        Rectangle {
            id: hoverOverlay
            anchors.fill: parent
            radius: parent.radius
            color: Theme.surfaceHover
            opacity: 0
            Behavior on opacity { NumberAnimation { duration: Theme.fastAnimation } }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: hoverOverlay.opacity = 0.5
            onExited: hoverOverlay.opacity = 0
            onPressed: hoverOverlay.opacity = 0.8
            onReleased: hoverOverlay.opacity = mouse.containsMouse ? 0.5 : 0
            onClicked: root.clicked()
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: root.fullName
                    color: Theme.textPrimary
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    Behavior on color { ColorAnimation { duration: Theme.normalAnimation } }
                }

                PillBadge {
                    text: root.isPrivate ? "Private" : "Public"
                    pillColor: root.isPrivate ? Theme.error : Theme.success
                }
            }

            Text {
                text: root.description && root.description.length > 0
                      ? root.description : "No description available"
                color: Theme.textSecondary
                font.pixelSize: 13
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                Behavior on color { ColorAnimation { duration: Theme.normalAnimation } }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                RowLayout {
                    spacing: 8
                    visible: root.language.length > 0

                    Rectangle {
                        width: 12; height: 12; radius: 6
                        color: Theme.getLanguageColor(root.language)
                    }
                    Text {
                        text: root.language
                        color: Theme.textSecondary
                        font.pixelSize: 12
                    }
                }

                RowLayout {
                    spacing: 6
                    Text { text: "★"; color: Theme.warning; font.pixelSize: 12 }
                    Text {
                        text: root.formatNumber(root.stargazersCount)
                        color: Theme.textSecondary
                        font.pixelSize: 12
                    }
                }

                RowLayout {
                    spacing: 6
                    Text { text: "⑂"; color: Theme.info; font.pixelSize: 12 }
                    Text {
                        text: root.formatNumber(root.forksCount)
                        color: Theme.textSecondary
                        font.pixelSize: 12
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    visible: root.updatedAt !== undefined
                    text: root.formatDate(root.updatedAt)
                    color: Theme.textTertiary
                    font.pixelSize: 11
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 3
                radius: 1.5
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.3; color: Theme.accent }
                    GradientStop { position: 0.7; color: Theme.accent }
                    GradientStop { position: 1.0; color: "transparent" }
                }
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
        const d = (date instanceof Date) ? date : new Date(date)
        if (isNaN(d.getTime())) return ""
        const diffDays = Math.ceil(Math.abs(new Date() - d) / (1000 * 60 * 60 * 24))
        if (diffDays <= 1) return "Yesterday"
        if (diffDays < 7) return diffDays + " days ago"
        if (diffDays < 30) return Math.ceil(diffDays / 7) + " weeks ago"
        if (diffDays < 365) return Math.ceil(diffDays / 30) + " months ago"
        return Math.ceil(diffDays / 365) + " years ago"
    }
}
