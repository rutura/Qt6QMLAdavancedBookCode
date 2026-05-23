import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 480
    height: 560
    visible: true
    title: "QmlAdvCore — 06: Attached Properties"
    color: Theme.colors.background

    // Form is both a singleton and an attached-property owner.
    // Connections listens for the `submitted` signal fired from Form.submit().
    Connections {
        target: Form
        function onSubmitted(values) {
            resultText.text = "Submitted: " + JSON.stringify(values, null, 2)
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.md

        Text {
            text: "Attached Properties Demo"
            font.pixelSize: 20
            font.bold: true
            color: Theme.colors.text
        }

        Text {
            width: parent.width
            text: "Any TextField can opt into Form tracking by setting\n" +
                  "Form.field — no subclassing, no wrapper component.\n" +
                  "Form.values auto-aggregates each field's text."
            font.pixelSize: 13
            color: Theme.colors.text
            wrapMode: Text.WordWrap
        }

        // Email field — opts into Form with attached properties
        Column {
            width: parent.width
            spacing: Theme.spacing.xs

            Text {
                text: "Email " + (emailField.Form.required ? "*" : "")
                font.bold: true
                color: Theme.colors.text
            }

            TextField {
                id: emailField
                width: parent.width
                placeholderText: "name@example.com"

                // Attached properties — set on any QML item, no base class needed
                Form.field: "email"
                Form.required: true
                Form.pattern: "^[\\w.]+@[\\w]+\\.[a-z]{2,}$"

                background: Rectangle {
                    radius: 4
                    color: Theme.colors.surface
                    border.color: Theme.colors.primary
                    border.width: parent.activeFocus ? 2 : 1
                }
                color: Theme.colors.text
            }
        }

        // Name field
        Column {
            width: parent.width
            spacing: Theme.spacing.xs

            Text {
                text: "Name " + (nameField.Form.required ? "*" : "")
                font.bold: true
                color: Theme.colors.text
            }

            TextField {
                id: nameField
                width: parent.width
                placeholderText: "Full name"

                Form.field: "name"
                Form.required: true

                background: Rectangle {
                    radius: 4
                    color: Theme.colors.surface
                    border.color: Theme.colors.primary
                    border.width: parent.activeFocus ? 2 : 1
                }
                color: Theme.colors.text
            }
        }

        // Optional field — no Form.required
        Column {
            width: parent.width
            spacing: Theme.spacing.xs

            Text {
                text: "Website (optional)"
                font.bold: true
                color: Theme.colors.text
            }

            TextField {
                id: websiteField
                width: parent.width
                placeholderText: "https://..."

                Form.field: "website"
                // Form.required defaults to false

                background: Rectangle {
                    radius: 4
                    color: Theme.colors.surface
                    border.color: Theme.colors.primary
                    border.width: parent.activeFocus ? 2 : 1
                }
                color: Theme.colors.text
            }
        }

        Row {
            spacing: Theme.spacing.sm

            Button {
                text: "Submit (" + Form.fieldCount + " fields)"
                onClicked: Form.submit()
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Live values: " + JSON.stringify(Form.values)
                font.pixelSize: 11
                color: Theme.colors.text
                elide: Text.ElideRight
                width: 240
            }
        }

        Text {
            id: resultText
            color: Theme.colors.text
            font.pixelSize: 12
            font.family: "monospace"
            wrapMode: Text.WordWrap
            width: parent.width
        }
    }
}
