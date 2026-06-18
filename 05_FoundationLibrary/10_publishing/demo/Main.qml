import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    id: root
    width: 560
    height: 680
    visible: true
    title: "QmlAdvCore — 08: Non-Visual Singletons"

    Connections {
        target: UndoStack
        function onUndone(description, data) {
            itemModel.remove(itemModel.count - 1)
            ToastManager.show("Undone: " + description)
        }
        function onRedone(description, data) {
            itemModel.append({ itemColor: data })
            ToastManager.show("Redone: " + description)
        }
    }

    ListModel { id: itemModel }

    // main column goes here
    // main column goes here
    Column {
        anchors.fill: parent
        anchors.margins: Theme.spacing.medium
        spacing: Theme.spacing.medium

        Text {
            text: "Non-visual singletons: ToastManager & UndoStack"
            font.pixelSize: 18
            font.bold: true
            color: Theme.colors.primary
        }

        Rectangle {
            width: parent.width
            height: 300
            radius: 8
            color: Theme.colors.surface
            border.color: Theme.colors.secondary
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: Theme.spacing.small
                spacing: Theme.spacing.small

                Text {
                    text: "UndoStack — add coloured items"
                    font.pixelSize: 14
                    font.bold: true
                    color: Theme.colors.primary
                }

                // list goes here
                // list goes here
                ListView {
                    width: parent.width
                    height: 160
                    model: itemModel
                    clip: true
                    spacing: 4

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 36
                        radius: 6
                        color: model.itemColor

                        Text {
                            anchors.centerIn: parent
                            text: "Item " + (index + 1)
                            color: "white"
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }
                }

                // add buttons go here
                // add buttons go here
                Row {
                    spacing: Theme.spacing.small

                    Button {
                        text: "Add Red"
                        onClicked: {
                            const color = "#E53935"
                            itemModel.append({ itemColor: color })
                            UndoStack.push("Add red item", color)
                            ToastManager.show("Added red item")
                        }
                    }
                    Button {
                        text: "Add Blue"
                        onClicked: {
                            const color = "#1E88E5"
                            itemModel.append({ itemColor: color })
                            UndoStack.push("Add blue item", color)
                            ToastManager.show("Added blue item")
                        }
                    }
                    Button {
                        text: "Add Green"
                        onClicked: {
                            const color = "#43A047"
                            itemModel.append({ itemColor: color })
                            UndoStack.push("Add green item", color)
                            ToastManager.show("Added green item")
                        }
                    }
                }

                // undo/redo buttons go here
                // undo/redo buttons go here
                Row {
                    spacing: Theme.spacing.small

                    Button {
                        text: "Undo: " + (UndoStack.canUndo ? UndoStack.undoText : "")
                        enabled: UndoStack.canUndo
                        onClicked: UndoStack.undo()
                    }
                    Button {
                        text: "Redo: " + (UndoStack.canRedo ? UndoStack.redoText : "")
                        enabled: UndoStack.canRedo
                        onClicked: UndoStack.redo()
                    }
                    Button {
                        text: "Clear history"
                        enabled: UndoStack.count > 0
                        onClicked: {
                            UndoStack.clear()
                            ToastManager.show("History cleared")
                        }
                    }
                }

                // status line goes here
                // status line goes here
                Text {
                    text: "History depth: " + UndoStack.count +
                          "  |  canUndo: " + UndoStack.canUndo +
                          "  |  canRedo: " + UndoStack.canRedo
                    font.pixelSize: 11
                    color: Theme.colors.secondary
                }
            }
        }

        // ToastManager panel goes here
        // ToastManager panel goes here
        Rectangle {
            width: parent.width
            height: 120
            radius: 8
            color: Theme.colors.surface
            border.color: Theme.colors.secondary
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: Theme.spacing.small
                spacing: Theme.spacing.small

                Text {
                    text: "ToastManager — manual controls"
                    font.pixelSize: 14
                    font.bold: true
                    color: Theme.colors.primary
                }

                Row {
                    spacing: Theme.spacing.small

                    Button {
                        text: "Show toast (3 s)"
                        onClicked: ToastManager.show("Hello from ToastManager!")
                    }
                    Button {
                        text: "Show toast (1 s)"
                        onClicked: ToastManager.show("Quick toast!", 1000)
                    }
                    Button {
                        text: "Dismiss now"
                        enabled: ToastManager.visible
                        onClicked: ToastManager.dismiss()
                    }
                }

                Text {
                    text: "visible: " + ToastManager.visible +
                          "  |  duration default: " + ToastManager.duration + " ms"
                    font.pixelSize: 11
                    color: Theme.colors.secondary
                }
            }
        }
    }


    // toast overlay goes here
    // toast overlay goes here
    Rectangle {
        id: toastOverlay
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 32

        width: toastLabel.implicitWidth + Theme.spacing.large * 2
        height: 44
        radius: 22
        color: Theme.colors.primary
        opacity: ToastManager.visible ? 1.0 : 0.0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        Text {
            id: toastLabel
            anchors.centerIn: parent
            text: ToastManager.message
            color: "white"
            font.pixelSize: 14
        }
    }
}