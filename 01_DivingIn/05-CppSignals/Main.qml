import QtQuick
import QtQuick.Controls

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("C++ Signal Demo")

    Connections {
        target: CppSignalSender
        function onCppTimer(value) {
            displayText.text = value
        }

        function onCallQml(message) {
            console.log("QML received: " + message)
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 20

        Rectangle {
            width: 200
            height: 200
            color: "red"
            radius: 10

            Text {
                id: displayText
                anchors.centerIn: parent
                text: "0"
                color: "white"
                font.pointSize: 40
            }
        }

        Button {
            text: "Call C++ Slot"
            onClicked: {
                CppSignalSender.cppSlot()
            }
        }
    }
}
