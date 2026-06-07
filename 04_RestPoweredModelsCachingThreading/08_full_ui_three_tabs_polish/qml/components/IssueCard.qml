import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property int number: 0
    property string title: ""
    property string issueState: "open"
    property string repoFullName: ""
    property int commentsCount: 0
    property string userLogin: ""
    property var createdAt: undefined

    signal clicked()

    implicitHeight: 120

    Rectangle {
        id: card
        anchors.fill: parent
        anchors.margins: 6
        radius: 16
        color: Theme.cardBackground
        border.color: Theme.cardBorder
        border.width: 1

        Behavior on color { ColorAnimation { duration: Theme.normalAnimation } }
        Behavior on border.color { ColorAnimation { duration: Theme.normalAnimation } }

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
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // State pill: open = green, closed = purple
                Rectangle {
                    radius: height / 2
                    implicitWidth: stateLabel.implicitWidth + 16
                    implicitHeight: 22
                    color: root.issueState === "open" ? Qt.alpha(Theme.success, 0.18) : Qt.alpha("#8b5cf6", 0.18)

                    Text {
                        id: stateLabel
                        anchors.centerIn: parent
                        text: root.issueState === "open" ? "open" : "closed"
                        color: root.issueState === "open" ? Theme.success : "#8b5cf6"
                        font.pixelSize: 11
                        font.weight: Font.Medium
                    }
                }

                Text {
                    text: root.repoFullName
                    color: Theme.textSecondary
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: "#" + root.number
                    color: Theme.textTertiary
                    font.pixelSize: 12
                }
            }

            Text {
                text: root.title
                color: Theme.textPrimary
                font.pixelSize: 14
                font.weight: Font.DemiBold
                Layout.fillWidth: true
                elide: Text.ElideRight
                Behavior on color { ColorAnimation { duration: Theme.normalAnimation } }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Text {
                    text: "by " + root.userLogin
                    color: Theme.textSecondary
                    font.pixelSize: 12
                }

                RowLayout {
                    spacing: 6
                    Text { text: "💬"; font.pixelSize: 11 }
                    Text {
                        text: root.commentsCount
                        color: Theme.textSecondary
                        font.pixelSize: 12
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    visible: root.createdAt !== undefined
                    text: root.formatDate(root.createdAt)
                    color: Theme.textTertiary
                    font.pixelSize: 11
                }
            }
        }
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
