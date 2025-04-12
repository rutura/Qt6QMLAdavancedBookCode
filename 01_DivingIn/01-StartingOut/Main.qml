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
            id: textId
            text : "Hello World";
            color: "red"
            font.pointSize: 20
        }
        Button{
            id:buttonId
            text: "Click here"
            onClicked: function(){
                textId.text = "Hello Qt!"
            }
        }
    }
}
