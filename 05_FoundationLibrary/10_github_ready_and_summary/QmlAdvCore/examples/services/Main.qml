// Pattern: Non-visual services as singletons
// ToastManager is a QML_SINGLETON; UndoStack is instantiable.
import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 420; height: 320
    visible: true
    title: "Example — Services"
    color: Theme.colors.background

    ToastHost {}
    UndoStack { id: stack }

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacing.md

        Row {
            spacing: Theme.spacing.sm
            Button {
                text: "Push action"
                onClicked: {
                    var n = stack.count + 1
                    stack.push(
                        function() { ToastManager.show("Undo #" + n) },
                        function() { ToastManager.show("Redo #" + n) }
                    )
                    ToastManager.show("Pushed action #" + n)
                }
            }
            Button { text: "Undo"; enabled: stack.canUndo; onClicked: stack.undo() }
            Button { text: "Redo"; enabled: stack.canRedo; onClicked: stack.redo() }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Stack depth: " + stack.count
            color: Theme.colors.text
        }
    }
}
