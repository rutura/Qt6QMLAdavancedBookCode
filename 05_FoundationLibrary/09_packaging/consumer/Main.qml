import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 440; height: 360
    visible: true
    title: "QmlAdvCore Consumer (find_package demo)"

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacing.large

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Consumed via find_package!"
            font.pixelSize: 17
            font.bold: true
            color: Theme.colors.primary
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Library version: " + Version.string
            font.pixelSize: 13
            color: Theme.colors.secondary
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacing.small

            Button {
                text: "Show toast"
                onClicked: ToastManager.show("Hello from the consumer!")
            }
            Button {
                text: "Quick toast"
                onClicked: ToastManager.show("Short toast", 1200)
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacing.small

            Button {
                text: "Push command"
                onClicked: {
                    UndoStack.push("Action #" + (UndoStack.count + 1))
                    ToastManager.show("Pushed: " + UndoStack.undoText)
                }
            }
            Button {
                text: "Undo"
                enabled: UndoStack.canUndo
                onClicked: UndoStack.undo()
            }
            Button {
                text: "Redo"
                enabled: UndoStack.canRedo
                onClicked: UndoStack.redo()
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "History: " + UndoStack.count +
                  "  canUndo: " + UndoStack.canUndo
            font.pixelSize: 11
            color: Theme.colors.secondary
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 24
        width: toastLabel.implicitWidth + Theme.spacing.large * 2
        height: 40; radius: 20
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
            color: "white"; font.pixelSize: 13
        }
    }

    Connections {
        target: UndoStack
        function onUndone(description, data) {
            ToastManager.show("Undone: " + description)
        }
        function onRedone(description, data) {
            ToastManager.show("Redone: " + description)
        }
    }
}