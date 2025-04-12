// Main.qml
import QtQuick

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Connections Demo")

    Row {
        spacing: 20
        anchors.centerIn: parent

        // Red rectangle with MouseArea
        Rectangle {
            id: redRect
            width: 100
            height: 100
            color: "red"

            MouseArea {
                id: redMouseArea
                anchors.fill: parent
                onClicked: {
                    console.log("Red rectangle clicked")
                }
            }
        }

        Rectangle {
            id: greenRect
            width: 100
            height: 100
            color: "green"

            Connections {
                target: redMouseArea    // The ID of the element we want to steal the signal from
                function onClicked() {
                    console.log("Green rectangle heard the click!")
                }
            }
        }

        Rectangle {
            id: blueRect
            width: 100
            height: 100
            color: "blue"

            Connections {
                target: redMouseArea    //The ID of the element we want to steal the signal from
                function onClicked() {
                    console.log("Blue rectangle heard the click too!")
                }
            }

        }
    }
}
