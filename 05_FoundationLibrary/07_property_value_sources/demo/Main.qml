import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 500
    height: 480
    visible: true
    title: "QmlAdvCore — 06: Attached Properties"

    Column {
        anchors.centerIn: parent
        width: 380
        spacing: 16

        // fields go here
        // fields go here
        Column {
            width: parent.width
            spacing: 4

            Row {
                spacing: 4
                Label { text: "Email"; font.bold: true; color: Theme.colors.primary }
                Label { text: "*"; color: Theme.colors.primary;
                        visible: emailField.Form.required }
            }
            TextField {
                id: emailField
                width: parent.width
                placeholderText: "you@example.com"

                Form.field:    "email"
                Form.label:    "Email"
                Form.required: true
                Form.hint:     "we'll never share this"

                Form.onErrorChanged: {
                    console.log("[QML] emailField.Form.onErrorChanged — error:", Form.error)
                    emailError.text = Form.error
                }

                onTextChanged: {
                    console.log("[QML] emailField.onTextChanged — calling Form.validate()")
                    Form.validate(text)
                }
            }
            Label {
                id: emailError
                color: "red"
                font.pixelSize: 11
                visible: text.length > 0
            }
            Label {
                text: emailField.Form.hint
                font.pixelSize: 11
                color: Theme.colors.secondary
            }
        }

        // password field goes here
        // password field goes here
        Column {
            width: parent.width
            spacing: 4

            Row {
                spacing: 4
                Label { text: "Password"; font.bold: true; color: Theme.colors.primary }
                Label { text: "*"; color: Theme.colors.primary;
                        visible: passwordField.Form.required }
            }
            TextField {
                id: passwordField
                width: parent.width
                echoMode: TextField.Password
                placeholderText: "at least 8 characters"

                Form.field:    "password"
                Form.label:    "Password"
                Form.required: true
                Form.hint:     "at least 8 characters"

                Form.onErrorChanged: {
                    console.log("[QML] passwordField.Form.onErrorChanged — error:", Form.error)
                    passwordError.text = Form.error
                }

                onTextChanged: {
                    console.log("[QML] passwordField.onTextChanged — calling Form.validate()")
                    Form.validate(text)
                }
            }
            Label {
                id: passwordError
                color: "red"
                font.pixelSize: 11
                visible: text.length > 0
            }
            Label {
                text: passwordField.Form.hint
                font.pixelSize: 11
                color: Theme.colors.secondary
            }
        }
        // displayName field goes here
        // displayName field goes here
        Column {
            width: parent.width
            spacing: 4

            Label { text: "Display Name"; font.bold: true; color: Theme.colors.primary }
            TextField {
                id: displayNameField
                width: parent.width
                placeholderText: "optional"

                Form.field:    "displayName"
                Form.label:    "Display Name"
                Form.required: false
                Form.hint:     "optional, max 50 chars"

                onTextChanged: Form.validate(text)
            }
            Label {
                text: displayNameField.Form.hint
                font.pixelSize: 11
                color: Theme.colors.secondary
            }
        }

        // submit button goes here
        // submit button goes here
        Rectangle {
            width: parent.width
            height: 44
            radius: 8
            color: Theme.colors.primary

            Text {
                anchors.centerIn: parent
                text: "Sign In"
                font.pixelSize: 14
                font.bold: true
                color: Theme.colors.onPrimary
            }
        }
    }
}