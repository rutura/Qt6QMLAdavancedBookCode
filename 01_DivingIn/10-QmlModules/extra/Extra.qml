import QtQuick

Rectangle {
    id: rootId
    width: 200
    height: 100
    color: "lightblue"
    border.color: "darkblue"
    border.width: 2
    radius: 10
    
    property bool isToggled: false
    
    Text {
        anchors.centerIn: parent
        text: "Extra Module Component"
        font.pixelSize: 16
        color: "darkblue"
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log("Extra module clicked!")
            rootId.isToggled = !rootId.isToggled
            rootId.color = rootId.isToggled ? "lightgreen" : "lightblue"
        }
    }
}