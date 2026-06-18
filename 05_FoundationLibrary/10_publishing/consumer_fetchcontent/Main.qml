import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 440; height: 340
    visible: true
    title: "QmlAdvCore — FetchContent consumer demo"

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacing.large

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Consumed via FetchContent!"
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
                text: "Toast"
                onClicked: ToastManager.show("FetchContent works!")
            }
            Button {
                text: "Push"
                onClicked: {
                    UndoStack.push("FC action #" + (UndoStack.count + 1))
                    ToastManager.show("Pushed: " + UndoStack.undoText)
                }
            }
            Button {
                text: "Undo"
                enabled: UndoStack.canUndo
                onClicked: UndoStack.undo()
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Stack depth: " + UndoStack.count
            font.pixelSize: 11
            color: Theme.colors.secondary
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20
        width: fcLabel.implicitWidth + Theme.spacing.large * 2
        height: 38; radius: 19
        color: Theme.colors.primary
        opacity: ToastManager.visible ? 1.0 : 0.0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        Text {
            id: fcLabel
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