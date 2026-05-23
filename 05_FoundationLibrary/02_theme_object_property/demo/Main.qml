import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 480
    height: 420
    visible: true
    title: "QmlAdvCore — 02: Object Properties"

    // The window background binds to Theme.colors.background.
    // When setMode() is called, ThemeColors emits backgroundChanged()
    // and this binding re-evaluates — even though the `colors` pointer
    // itself never changes (it is CONSTANT on Theme).
    color: Theme.colors.background

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacing.md       // Theme.spacing.md == 16

        // Title
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Object Properties Demo"
            font.pixelSize: 22
            font.bold: true
            color: Theme.colors.text
        }

        // Primary colour swatch
        Rectangle {
            width: 280
            height: 64
            radius: 8
            color: Theme.colors.primary

            Text {
                anchors.centerIn: parent
                text: "Theme.colors.primary"
                color: Theme.colors.onPrimary
                font.pixelSize: 14
            }
        }

        // Surface swatch
        Rectangle {
            width: 280
            height: 64
            radius: 8
            color: Theme.colors.surface
            border.color: Theme.colors.primary
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "Theme.colors.surface"
                color: Theme.colors.text
                font.pixelSize: 14
            }
        }

        // Spacing visualisation
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Repeater {
                model: [
                    { label: "xs", size: Theme.spacing.xs },
                    { label: "sm", size: Theme.spacing.sm },
                    { label: "md", size: Theme.spacing.md },
                    { label: "lg", size: Theme.spacing.lg },
                    { label: "xl", size: Theme.spacing.xl }
                ]

                delegate: Column {
                    spacing: 4
                    Rectangle {
                        width: modelData.size
                        height: modelData.size
                        color: Theme.colors.primary
                        opacity: 0.7
                    }
                    Text {
                        text: modelData.label
                        font.pixelSize: 10
                        color: Theme.colors.text
                    }
                }
            }
        }

        // Toggle button
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Theme.mode === "light" ? "Switch to Dark" : "Switch to Light"
            onClicked: Theme.setMode(Theme.mode === "light" ? "dark" : "light")
        }
    }
}
