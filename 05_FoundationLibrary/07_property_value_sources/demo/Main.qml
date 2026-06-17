import QtQuick
import QmlAdvCore

Window {
    width: 560
    height: 680
    visible: true
    title: "QmlAdvCore — 07: Property Value Sources (Pulse)"

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacing.large

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Pulse — property value source"
            font.pixelSize: 20
            font.bold: true
            color: Theme.colors.primary
        }

        // opacity pulse goes here
        // opacity pulse goes here
        Column {
            spacing: 4
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: "Pulse on opacity  { from: 0.2; to: 1.0; duration: 1200 }"
                font.pixelSize: 13
                color: Theme.colors.secondary
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 220; height: 60
                radius: 8
                color: Theme.colors.primary

                Pulse on opacity {
                    from:     0.2
                    to:       1.0
                    duration: 1200
                }

                Text {
                    anchors.centerIn: parent
                    text: "Opacity pulse"
                    color: "white"
                    font.pixelSize: 14
                }
            }
        }

        // scale pulse goes here
        // scale pulse goes here
        Column {
            spacing: 4
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: "Pulse on scale  { from: 0.85; to: 1.0; duration: 900 }"
                font.pixelSize: 13
                color: Theme.colors.secondary
            }

            Item {
                width: 220; height: 80
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.centerIn: parent
                    width: 140; height: 60
                    radius: 8
                    color: Theme.colors.secondary

                    Pulse on scale {
                        from:     0.85
                        to:       1.0
                        duration: 900
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Scale pulse"
                        color: "white"
                        font.pixelSize: 14
                    }
                }
            }
        }

        // fast pulse goes here
        // fast pulse goes here
        Column {
            spacing: 4
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: "Pulse on opacity  { from: 0.1; to: 1.0; duration: 400 }"
                font.pixelSize: 13
                color: Theme.colors.secondary
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 220; height: 60
                radius: 8
                color: Theme.colors.primary

                Pulse on opacity {
                    id: fastPulse
                    from:     0.1
                    to:       1.0
                    duration: 400
                }

                Text {
                    anchors.centerIn: parent
                    text: "Fast pulse"
                    color: "white"
                    font.pixelSize: 14
                }
            }
        }

        // toggle button goes here
        // toggle button goes here
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 220; height: 60
            radius: 8
            color: Theme.colors.secondary

            Text {
                anchors.centerIn: parent
                text: fastPulse.running ? qsTr("Pause fast pulse") : qsTr("Resume fast pulse")
                color: "white"
                font.pixelSize: 14
            }

            MouseArea {
                anchors.fill: parent
                onClicked: fastPulse.running = !fastPulse.running
            }
        }
    }
}