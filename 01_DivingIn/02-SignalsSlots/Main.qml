import QtQuick
import QtQuick.Controls

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Column{
        anchors.centerIn: parent
        Text {
            text : "Hello World"
            color: "red"
            font.pointSize: 20
        }

        Button{
            text: "Click me"
            onClicked: console.log("Hello, world!")
        }

        Button {
            text: "Click me too!"

            onClicked: printMessage()

            function printMessage() {
                console.log("Button was clicked!")
            }
        }
    }
}
