import QtQuick
import QtQuick.Layouts

// App branding bar with a right-side slot. Pages fill `controls` with their
// search field / toggle / token entry — the slot keeps the diff localized.
Rectangle {
    id: root

    default property alias controlItems: controlRow.data

    implicitHeight: 96
    color: Theme.surface

    Behavior on color { ColorAnimation { duration: Theme.normalAnimation } }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Theme.borderLight
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 28
        anchors.rightMargin: 28
        spacing: 24

        RowLayout {
            spacing: 16

            Rectangle {
                width: 52
                height: 52
                radius: 14
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.accent }
                    GradientStop { position: 1.0; color: Theme.accentHover }
                }
                Text {
                    anchors.centerIn: parent
                    text: "🚀"
                    font.pixelSize: 26
                }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: "Repo Explorer Pro"
                    color: Theme.textPrimary
                    font.pixelSize: 24
                    font.weight: Font.Bold
                    Behavior on color { ColorAnimation { duration: Theme.normalAnimation } }
                }
                Text {
                    text: "Browse GitHub, powered by Qt models"
                    color: Theme.textSecondary
                    font.pixelSize: 13
                    Behavior on color { ColorAnimation { duration: Theme.normalAnimation } }
                }
            }
        }

        Item { Layout.fillWidth: true }

        RowLayout {
            id: controlRow
            spacing: 14
        }
    }
}
