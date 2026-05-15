// Pattern: Attached properties + singleton
// Form attaches `field`, `required`, `pattern` to any QML item and also
// exposes the aggregated `values` map / `submit()` method as a singleton.
import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 460; height: 340
    visible: true
    title: "Example — Attached Properties"
    color: Theme.colors.background

    Connections {
        target: Form
        function onSubmitted(values) {
            output.text = JSON.stringify(values, null, 2)
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.sm

        TextField {
            width: parent.width
            placeholderText: "Email"
            Form.field: "email"
            Form.required: true
        }

        TextField {
            width: parent.width
            placeholderText: "Name"
            Form.field: "name"
            Form.required: true
        }

        Button {
            text: "Submit (" + Form.fieldCount + " fields)"
            onClicked: Form.submit()
        }

        Text {
            id: output
            color: Theme.colors.text
            font.family: "monospace"
            font.pixelSize: 12
        }
    }
}
