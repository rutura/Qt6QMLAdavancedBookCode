import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 460
    height: 520
    visible: true
    title: "QmlAdvCore — 05: Grouped Properties"
    color: Theme.colors.background

    // The fields are declared with grouped-property syntax.
    // `validation.required`, `validation.minLength`, `style.borderColor`
    // are plain property assignments on the sub-objects — no special syntax.
    FormGroup {
        id: form

        FormField {
            id: nameField
            label: "Name"
            placeholder: "At least 3 characters"
            validation.required: true
            validation.minLength: 3
            validation.maxLength: 40
            style.radius: 6
            style.borderColor: Theme.colors.primary
        }

        FormField {
            id: emailField
            label: "Email"
            placeholder: "name@example.com"
            fieldType: FormField.Email
            validation.required: true
            validation.pattern: "^[\\w.]+@[\\w]+\\.[a-z]{2,}$"
            style.radius: 6
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.md

        Text {
            text: "Grouped Properties Demo"
            font.pixelSize: 20
            font.bold: true
            color: Theme.colors.text
        }

        Repeater {
            model: form.fieldList

            delegate: Column {
                width: parent.width
                spacing: Theme.spacing.xs

                Text {
                    text: modelData.label +
                          (modelData.validation.required ? " *" : "")
                    font.pixelSize: 13
                    font.bold: true
                    color: Theme.colors.text
                }

                TextField {
                    id: tf
                    width: parent.width
                    placeholderText: modelData.placeholder
                    echoMode: modelData.fieldType === FormField.Password
                              ? TextInput.Password : TextInput.Normal
                    background: Rectangle {
                        radius: modelData.style.radius
                        color: Theme.colors.surface
                        border.color: modelData.style.borderColor
                        border.width: tf.activeFocus
                                      ? modelData.style.borderWidth + 1
                                      : modelData.style.borderWidth
                    }
                    color: Theme.colors.text
                    onTextChanged: modelData.value = text
                }

                Text {
                    visible: modelData.validation.errorText !== ""
                    text: modelData.validation.errorText
                    color: "red"
                    font.pixelSize: 11
                }
            }
        }

        Button {
            text: "Validate"
            onClicked: {
                var ok = true
                for (var i = 0; i < form.fieldCount(); ++i) {
                    var f = form.fieldAt(i)
                    if (!f.validation.validate(f.value))
                        ok = false
                }
                resultText.text = ok ? "All fields valid ✓" : "Fix errors above"
                resultText.color = ok ? "green" : "red"
            }
        }

        Text {
            id: resultText
            font.pixelSize: 14
            font.bold: true
        }
    }
}
