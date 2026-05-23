import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    id: root
    width: 500
    height: 600
    visible: true
    title: "QmlAdvCore v" + Version.string + " — Chapter 5 Summary"
    color: Theme.colors.background

    ToastHost {}
    UndoStack { id: undoStack }

    Flickable {
        anchors.fill: parent
        contentHeight: content.implicitHeight + Theme.spacing.xl * 2
        clip: true

        Column {
            id: content
            anchors {
                left: parent.left; right: parent.right
                top: parent.top
                margins: Theme.spacing.lg
            }
            spacing: Theme.spacing.lg

            // ── Header ────────────────────────────────────────────────
            Text {
                text: "QmlAdvCore — Chapter 5 Summary"
                font.pixelSize: 22
                font.bold: true
                color: Theme.colors.text
            }
            Text {
                text: "Version: " + Version.string
                font.pixelSize: 14
                color: Theme.colors.text
                opacity: 0.7
            }

            // ── Theme ─────────────────────────────────────────────────
            SectionBox {
                title: "Theme (object property)"
                Row {
                    spacing: Theme.spacing.sm
                    Repeater {
                        model: [
                            { name: "primary",    color: Theme.colors.primary    },
                            { name: "surface",    color: Theme.colors.surface    },
                            { name: "background", color: Theme.colors.background },
                            { name: "text",       color: Theme.colors.text       }
                        ]
                        delegate: Column {
                            spacing: 2
                            Rectangle { width: 56; height: 32; color: modelData.color; radius: 4 }
                            Text { text: modelData.name; font.pixelSize: 10; color: Theme.colors.text }
                        }
                    }
                }
                Button {
                    text: "Toggle " + (Theme.mode === "light" ? "Dark" : "Light")
                    onClicked: Theme.setMode(Theme.mode === "light" ? "dark" : "light")
                }
            }

            // ── Toast + Undo ───────────────────────────────────────────
            SectionBox {
                title: "ToastManager + UndoStack"
                Row {
                    spacing: Theme.spacing.sm
                    Button {
                        text: "Show Toast"
                        onClicked: ToastManager.show("Hello from QmlAdvCore 1.0!")
                    }
                    Button {
                        text: "Undo  (" + undoStack.count + ")"
                        enabled: undoStack.canUndo
                        onClicked: undoStack.undo()
                    }
                    Button {
                        text: "Redo"
                        enabled: undoStack.canRedo
                        onClicked: undoStack.redo()
                    }
                }
                Row {
                    spacing: Theme.spacing.sm
                    TextField {
                        id: colorField
                        width: 120
                        text: "tomato"
                        placeholderText: "Color"
                        color: Theme.colors.text
                    }
                    Button {
                        text: "Apply Color"
                        onClicked: {
                            var prev = colorSwatch.color
                            var next = colorField.text
                            undoStack.push(
                                function() { colorSwatch.color = prev },
                                function() { colorSwatch.color = next }
                            )
                            colorSwatch.color = next
                            ToastManager.show("Color applied")
                        }
                    }
                }
                Rectangle {
                    id: colorSwatch
                    width: parent.width
                    height: 36
                    radius: 4
                    color: "steelblue"
                }
            }

            // ── Pulse ──────────────────────────────────────────────────
            SectionBox {
                title: "Pulse (property value source)"
                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Pulsing Button"
                    Pulse on opacity { from: 0.4; to: 1.0; period: 800 }
                }
            }
        }
    }

    // ── Inline SectionBox component ────────────────────────────────────
    component SectionBox : Rectangle {
        property string title: ""
        default property alias children: col.data

        width: content.width
        height: col.implicitHeight + Theme.spacing.lg * 2
        radius: 8
        color: Theme.colors.surface

        Column {
            id: col
            anchors {
                left: parent.left; right: parent.right
                top: parent.top
                margins: Theme.spacing.md
            }
            spacing: Theme.spacing.sm

            Text {
                text: parent.parent.title
                font.bold: true
                font.pixelSize: 15
                color: Theme.colors.text
            }
        }
    }
}
