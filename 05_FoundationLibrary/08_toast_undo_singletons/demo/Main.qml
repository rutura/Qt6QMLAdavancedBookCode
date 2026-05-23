import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    id: root
    width: 460
    height: 520
    visible: true
    title: "QmlAdvCore — 08: Singletons & Services"
    color: Theme.colors.background

    // ToastHost listens to the ToastManager singleton and renders toasts.
    // Drop it once; it works for the whole window automatically.
    ToastHost {}

    UndoStack { id: undoStack }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.lg

        Text {
            text: "Singletons & Services Demo"
            font.pixelSize: 20
            font.bold: true
            color: Theme.colors.text
        }

        // --- ToastManager demo ---
        Rectangle {
            width: parent.width
            height: toastSection.implicitHeight + Theme.spacing.lg * 2
            radius: 8
            color: Theme.colors.surface

            Column {
                id: toastSection
                anchors {
                    left: parent.left; right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: Theme.spacing.md
                }
                spacing: Theme.spacing.sm

                Text {
                    text: "ToastManager (singleton)"
                    font.bold: true
                    color: Theme.colors.text
                }

                Row {
                    spacing: Theme.spacing.sm
                    Button {
                        text: "Show Toast"
                        onClicked: ToastManager.show("Changes saved successfully!")
                    }
                    Button {
                        text: "Long Toast"
                        onClicked: ToastManager.show("This one stays for 5 seconds", 5000)
                    }
                }
            }
        }

        // --- UndoStack demo ---
        Rectangle {
            width: parent.width
            height: undoSection.implicitHeight + Theme.spacing.lg * 2
            radius: 8
            color: Theme.colors.surface

            Column {
                id: undoSection
                anchors {
                    left: parent.left; right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: Theme.spacing.md
                }
                spacing: Theme.spacing.sm

                Text {
                    text: "UndoStack (instantiable)"
                    font.bold: true
                    color: Theme.colors.text
                }

                Row {
                    spacing: Theme.spacing.xs

                    TextField {
                        id: colorInput
                        width: 120
                        placeholderText: "Color name"
                        text: "steelblue"
                        color: Theme.colors.text
                    }

                    Button {
                        text: "Apply"
                        onClicked: {
                            var prev = swatch.color
                            var next = colorInput.text
                            undoStack.push(
                                function() {
                                    swatch.color = prev
                                    ToastManager.show("Undone")
                                },
                                function() {
                                    swatch.color = next
                                    ToastManager.show("Redone")
                                }
                            )
                            swatch.color = next
                            ToastManager.show("Color applied — " +
                                undoStack.count + " action(s) on stack")
                        }
                    }
                }

                Rectangle {
                    id: swatch
                    width: parent.width
                    height: 40
                    radius: 4
                    color: "steelblue"
                }

                Row {
                    spacing: Theme.spacing.sm

                    Button {
                        text: "Undo"
                        enabled: undoStack.canUndo
                        onClicked: undoStack.undo()
                    }
                    Button {
                        text: "Redo"
                        enabled: undoStack.canRedo
                        onClicked: undoStack.redo()
                    }
                    Button {
                        text: "Clear"
                        onClicked: {
                            undoStack.clear()
                            ToastManager.show("Undo history cleared")
                        }
                    }
                }

                Text {
                    text: "Stack depth: " + undoStack.count
                    color: Theme.colors.text
                    font.pixelSize: 12
                }
            }
        }
    }
}
