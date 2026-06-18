import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 480
    height: 520
    visible: true
    title: "QmlAdvCore — 03: List Properties"

    FormGroup {
        id: loginForm
        title: "Sign In"
        fields: [
            FormField {
                label: "Username"
                placeholder: "Enter username"
                required: true
            },
            FormField {
                label: "Password"
                placeholder: "Enter password"
                required: true
            },
            FormField {
                label: "Display name"
                placeholder: "Optional display name"
            }
        ]
    }

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

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Fields in group: " + loginForm.fieldCount
            font.pixelSize: 13
            color: Theme.colors.secondary
        }

        //Repeater here
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
                        visible: loginForm.fieldAt(index).required
                        text: "*"
                        font.pixelSize: 14
                        color: Theme.colors.primary
                    }
                }

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
            }
        }

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