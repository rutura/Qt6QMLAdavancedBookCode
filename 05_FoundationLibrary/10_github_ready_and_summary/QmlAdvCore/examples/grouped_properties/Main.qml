// Pattern: Grouped properties
// FormField exposes `validation` and `style` as child QObjects so QML can use
// nested syntax: validation.required, style.borderColor.
import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 420; height: 360
    visible: true
    title: "Example — Grouped Properties"
    color: Theme.colors.background

    FormField {
        id: field
        label: "Username"
        placeholder: "min 3 chars"
        validation.required: true
        validation.minLength: 3
        validation.maxLength: 20
        style.radius: 6
        style.borderColor: Theme.colors.primary
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.sm

        Text {
            text: field.label + (field.validation.required ? " *" : "")
            color: Theme.colors.text; font.bold: true
        }

        TextField {
            id: input
            width: parent.width
            placeholderText: field.placeholder
            onTextChanged: field.value = text
            background: Rectangle {
                radius: field.style.radius
                color: Theme.colors.surface
                border.color: field.style.borderColor
                border.width: input.activeFocus ? 2 : 1
            }
        }

        Button {
            text: "Validate"
            onClicked: result.text = field.validation.validate(field.value)
                       ? "Valid ✓" : field.validation.errorText
        }
        Text { id: result; color: Theme.colors.text }
    }
}
