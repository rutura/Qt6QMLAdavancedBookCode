import QtQuick
import ExtraModule
import Backend

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Qml Modules")

    Column{
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "Main Application Window"
            font.pixelSize: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Extra {
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "Click the component above to interact with the Extra module!"
            font.pixelSize: 14
            anchors.horizontalCenter: parent.horizontalCenter
            color: "gray"
        }

        // Backend component integration
        Rectangle {
                    width: 300
                    height: 150
                    color: "lightyellow"
                    border.color: "orange"
                    border.width: 2
                    radius: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Backend {
                        id: backendInstance
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: backendInstance.message
                            font.pixelSize: 16
                            color: "darkblue"
                        }

                        Text {
                            text: "Counter: " + backendInstance.counter
                            font.pixelSize: 16
                            color: "darkblue"
                        }

                        Row {
                            spacing: 10
                            anchors.horizontalCenter: parent.horizontalCenter

                            Rectangle {
                                width: 100
                                height: 30
                                color: "orange"
                                radius: 5

                                Text {
                                    anchors.centerIn: parent
                                    text: "Increment"
                                    color: "white"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: backendInstance.incrementCounter()
                                }
                            }

                            Rectangle {
                                width: 100
                                height: 30
                                color: "orange"
                                radius: 5

                                Text {
                                    anchors.centerIn: parent
                                    text: "Reset"
                                    color: "white"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: backendInstance.resetCounter()
                                }
                            }
                        }
                    }
                }

    }
}
