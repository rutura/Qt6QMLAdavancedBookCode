import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 460
    height: 480
    visible: true
    title: "QmlAdvCore — 06: Attached Properties"
    color: Theme.colors.background

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
            text: "Any TextField can opt into Form tracking by setting\n" +
                  "Form.field — no subclassing, no wrapper component."
            font.pixelSize: 13
            color: Theme.colors.text
            wrapMode: Text.WordWrap
            width: parent.width
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
                // Form.required defaults to false — field is optional

                background: Rectangle {
                    radius: 4
                    color: Theme.colors.surface
                    border.color: Theme.colors.primary
                    border.width: parent.activeFocus ? 2 : 1
                }
                color: Theme.colors.text
            }
        }

        Button {
            text: "Read attached state"
            onClicked: {
                resultText.text =
                    "email field key: '" + emailField.Form.field + "'\n" +
                    "email required: " + emailField.Form.required + "\n" +
                    "email pattern: " + emailField.Form.pattern + "\n\n" +
                    "name key: '" + nameField.Form.field + "'\n" +
                    "website key: '" + websiteField.Form.field + "'\n" +
                    "website required: " + websiteField.Form.required
            }
        }

        Text {
            id: resultText
            color: Theme.colors.text
            font.pixelSize: 12
            font.family: "monospace"
        }
    }
}
