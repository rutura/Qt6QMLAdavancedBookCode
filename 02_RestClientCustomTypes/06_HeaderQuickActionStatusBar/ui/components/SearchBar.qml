import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    height: 56

    property var theme
    property string lastQuery: ""
    property string lastUser: ""
    signal searchRequested(string query)
    signal userSearchRequested(string username)

    // Main container
    Rectangle {
        id: searchContainer
        anchors.centerIn: parent
        width: parent.width - 40
        height: 48
        radius: 24

        // Background with glassmorphism effect
        color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.8)

        // Themed border that's visible in all themes
        border.width: 1
        border.color: searchInput.focus ? theme.accent :
                     Qt.rgba(theme.border.r, theme.border.g, theme.border.b, 0.3)

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 8
            spacing: 12

            // Simple search icon
            Text {
                text: "🔍"
                font.pixelSize: 16
                color: theme.textSecondary
            }

            // Search input
            TextField {
                id: searchInput
                Layout.fillWidth: true
                placeholderText: "Search repositories or @username..."
                color: theme.textPrimary
                font.pixelSize: 14
                selectByMouse: true

                background: Rectangle {
                    color: "transparent"
                }

                placeholderTextColor: theme.textSecondary

                // Type indicator
                Rectangle {
                    visible: searchInput.text.length > 0
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 60
                    width: typeIndicator.contentWidth + 8
                    height: 18
                    radius: 9
                    color: searchInput.text.startsWith("@") ?
                        Qt.rgba(0.2, 0.7, 1, 0.2) :
                        Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.2)

                    Text {
                        id: typeIndicator
                        anchors.centerIn: parent
                        text: searchInput.text.startsWith("@") ? "USER" : "REPO"
                        font.pixelSize: 8
                        font.weight: Font.Bold
                        color: searchInput.text.startsWith("@") ? "#2196F3" : theme.accent
                    }
                }

                onAccepted: {
                    if (text.trim().length > 0) {
                        if (text.startsWith("@")) {
                            root.lastUser = text.substring(1)
                            root.userSearchRequested(text.substring(1))
                        } else {
                            root.lastQuery = text.trim()
                            root.searchRequested(text.trim())
                        }
                    }
                }

                Keys.onEscapePressed: {
                    text = ""
                    focus = false
                }

                onFocusChanged: {
                    if (focus) {
                        selectAll()
                    }
                }
            }

            // Custom search button using Rectangle
            Rectangle {
                id: searchButton
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 18
                color: searchButtonArea.pressed ?
                       Qt.darker(theme.accent, 1.2) :
                       searchButtonArea.containsMouse ?
                       Qt.lighter(theme.accent, 1.1) :
                       theme.accent

                Text {
                    anchors.centerIn: parent
                    text: "→"
                    color: theme.textOnAccent
                    font.pixelSize: 16
                    font.weight: Font.Medium
                }

                MouseArea {
                    id: searchButtonArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: searchInput.accepted()
                }

                // Subtle shadow for depth
                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: 1
                    z: -1
                    radius: parent.radius
                    color: Qt.rgba(0, 0, 0, 0.1)
                }
            }
        }

        // Container shadow
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 1
            z: -1
            radius: parent.radius
            color: Qt.rgba(0, 0, 0, 0.05)
        }
    }
}
