import QtQuick
import QtQuick.Controls


Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Calling C++ from QML")

    Other{

    }

    Column {
        spacing: 10
        Row {
            Text { text: "regularMethod" }
            Button {
                text: "Call C++ method"
                onClicked: function() { BWorker.regularMethod(); }
            }
        }
        Row {
            Text { text: "cppSlot()" }
            Button {
                text: "Call C++ slot"
                onClicked: { BWorker.cppSlot(); }
            }
        }
        Row {
            TextField { id: nameFieldId; placeholderText: "name"; text: "John" }
            TextField { id: ageFieldId; placeholderText: "age"; text: "25" }
            Button {
                text: "Call C++ method with return"
                onClicked: {
                    var response = BWorker.regularMethodWithReturn(nameFieldId.text, parseInt(ageFieldId.text));
                    console.log(response);
                }
            }
        }
    }
}
