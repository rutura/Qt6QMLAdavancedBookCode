import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 480
    height: 580
    visible: true
    title: "QmlAdvCore — 05: Grouped Properties"

    FormGroup {
        id: loginForm
        title: "Sign In"
        fields: [
            FormField {
                label: "Username"
                placeholder: "Enter username"
                validation.required: true
                validation.minLength: 3
                validation.maxLength: 20
            },
            FormField {
                label: "Password"
                placeholder: "Enter password"
                validation.required: true
                validation.minLength: 8
            },
            FormField {
                label: "Display name"
                placeholder: "Optional (max 50 chars)"
                validation.maxLength: 50
            }
        ]
    }

    // Column layout goes here
    // Column layout goes here
    Column {
        anchors.centerIn: parent
        spacing: Theme.spacing.medium
        width: 380

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: loginForm.title
            font.pixelSize: 22
            font.bold: true
            color: Theme.colors.primary
        }

        // Repeater goes here
        // Repeater goes here
        Repeater {
            model: loginForm.fieldCount
            delegate: Column {
                width: 380
                spacing: 4

                Row {
                    spacing: 4
                    Text {
                        text: loginForm.fieldAt(index).label
                        font.pixelSize: 14
                        color: "#1C1B1F"
                    }
                    Text {
                        visible: loginForm.fieldAt(index).validation.required
                        text: "*"
                        font.pixelSize: 14
                        color: Theme.colors.primary
                    }
                }

                // Input box and hint row go here
                // Input box and hint row go here
                Rectangle {
                    width: 380
                    height: 44
                    radius: 6
                    color: Theme.colors.surface
                    border.color: Theme.colors.secondary
                    border.width: 1

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: Theme.spacing.small
                            verticalCenter: parent.verticalCenter
                        }
                        text: loginForm.fieldAt(index).placeholder
                        font.pixelSize: 13
                        color: "#CAC4D0"
                    }
                }

                // Hint row goes here
                // Hint row goes here
                Row {
                    spacing: 8
                    Text {
                        visible: loginForm.fieldAt(index).validation.minLength > 0
                        text: "min " + loginForm.fieldAt(index).validation.minLength + " chars"
                        font.pixelSize: 11
                        color: Theme.colors.secondary
                    }
                    Text {
                        visible: loginForm.fieldAt(index).validation.maxLength > 0
                        text: "max " + loginForm.fieldAt(index).validation.maxLength + " chars"
                        font.pixelSize: 11
                        color: Theme.colors.secondary
                    }
                }
            }
        }

        // Submit button goes here
        // Submit button goes here
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 160
            height: 44
            radius: 8
            color: Theme.colors.primary

            Text {
                anchors.centerIn: parent
                text: "Submit"
                font.pixelSize: 14
                font.bold: true
                color: Theme.colors.onPrimary
            }
        }
    }
}