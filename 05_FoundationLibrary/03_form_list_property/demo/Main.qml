import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 440
    height: 520
    visible: true
    title: "QmlAdvCore — 03: List Properties"
    color: Theme.colors.background

    // FormGroup declared with child FormField elements.
    // The `fields` QQmlListProperty collects them via the append callback.
    // `fieldList` exposes the same list as QList<QObject*> for the Repeater.
    FormGroup {
        id: loginForm

        FormField {
            label: "Username"
            placeholder: "Enter username"
            fieldType: FormField.Text
        }
        FormField {
            label: "Password"
            placeholder: "Enter password"
            fieldType: FormField.Password
        }
        FormField {
            label: "Email"
            placeholder: "Enter email"
            fieldType: FormField.Email
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.md

        Text {
            text: "Login Form  (" + loginForm.fieldCount() + " fields)"
            font.pixelSize: 20
            font.bold: true
            color: Theme.colors.text
        }

        // Repeater uses fieldList — QList<QObject*> is a native QML sequence
        Repeater {
            model: loginForm.fieldList

            delegate: Column {
                width: parent.width
                spacing: Theme.spacing.xs

                Text {
                    text: modelData.label
                    font.pixelSize: 13
                    font.bold: true
                    color: Theme.colors.text
                }

                TextField {
                    width: parent.width
                    placeholderText: modelData.placeholder
                    echoMode: modelData.fieldType === FormField.Password
                              ? TextInput.Password
                              : TextInput.Normal
                    background: Rectangle {
                        radius: 4
                        color: Theme.colors.surface
                        border.color: Theme.colors.primary
                        border.width: parent.activeFocus ? 2 : 1
                    }
                    color: Theme.colors.text
                    onTextChanged: modelData.value = text
                }
            }
        }

        Button {
            text: "Submit"
            onClicked: {
                var summary = ""
                for (var i = 0; i < loginForm.fieldCount(); ++i) {
                    var f = loginForm.fieldAt(i)
                    summary += f.label + ": " + (f.value || "(empty)") + "\n"
                }
                resultText.text = summary
            }
        }

        Text {
            id: resultText
            color: Theme.colors.text
            font.pixelSize: 13
        }
    }
}
