// Pattern: List property (QQmlListProperty)
// FormGroup accepts FormField children declared inline, and exposes them
// as a Repeater-friendly QList<QObject*> via `fieldList`.
import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 420; height: 360
    visible: true
    title: "Example — List Property"
    color: Theme.colors.background

    FormGroup {
        id: form
        FormField { label: "First name" }
        FormField { label: "Last name"  }
        FormField { label: "Email"; fieldType: FormField.Email }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.sm

        Text {
            text: form.fieldCount() + " fields declared as child elements"
            color: Theme.colors.text
            font.bold: true
        }

        Repeater {
            model: form.fieldList
            delegate: Row {
                spacing: Theme.spacing.sm
                Text { text: modelData.label + ":"; color: Theme.colors.text; width: 100 }
                TextField {
                    width: 200
                    placeholderText: modelData.placeholder || modelData.label
                    onTextChanged: modelData.value = text
                }
            }
        }
    }
}
