import QtQuick
import QtQuick.Controls

Item {
    id: root

    property var theme
    property string currentView: ""
    property bool isVisible: true

    Rectangle {
        anchors.centerIn: parent
        width: 300
        height: 200
        color: "transparent"
        visible: root.isVisible

        Column {
            anchors.centerIn: parent
            spacing: 16

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "📂"
                font.pixelSize: 48
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: {
                    switch(currentView) {
                        case "search": return "No search results found"
                        case "user": return "No user repositories found"
                        default: return "No repositories loaded"
                    }
                }
                color: root.theme.textSecondary
                font.pixelSize: 16
                font.weight: Font.Medium

                Behavior on color { ColorAnimation { duration: root.theme.normalAnimation } }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Try searching or loading popular repositories"
                color: root.theme.textTertiary
                font.pixelSize: 14

                Behavior on color { ColorAnimation { duration: root.theme.normalAnimation } }
            }
        }
    }
}
