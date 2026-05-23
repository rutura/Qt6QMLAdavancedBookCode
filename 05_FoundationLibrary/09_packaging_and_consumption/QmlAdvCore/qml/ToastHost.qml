import QtQuick
import QtQuick.Controls
import QmlAdvCore

// ToastHost renders toast messages emitted by ToastManager.
// Place it once at the root of your UI tree:
//
//     ApplicationWindow {
//         ToastHost {}
//         // rest of your app
//     }
//
// It connects to the ToastManager singleton's `toastShown` signal and
// dynamically creates a toast item for each call to ToastManager.show().
Item {
    id: root

    anchors.fill: parent
    // Toasts float above all other content
    z: 9999

    Connections {
        target: ToastManager
        function onToastShown(text, durationMs) {
            var item = toastComponent.createObject(root, {
                message: text,
                duration: durationMs
            })
            if (item)
                item.show()
        }
    }

    Component {
        id: toastComponent

        Rectangle {
            id: toast

            property string message: ""
            property int    duration: 3000

            function show() {
                visible = true
                hideTimer.start()
            }

            anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
            y: parent ? parent.height - height - Theme.spacing.xl : 0

            width: Math.min(toastLabel.implicitWidth + Theme.spacing.xl * 2, 360)
            height: toastLabel.implicitHeight + Theme.spacing.md * 2
            radius: height / 2

            color: Theme.colors.text
            opacity: 0
            visible: false

            Text {
                id: toastLabel
                anchors.centerIn: parent
                text: toast.message
                color: Theme.colors.background
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            Timer {
                id: hideTimer
                interval: toast.duration
                onTriggered: fadeOut.start()
            }

            SequentialAnimation {
                id: showAnimation
                running: true
                NumberAnimation { target: toast; property: "opacity"; to: 0.92; duration: 200 }
            }

            SequentialAnimation {
                id: fadeOut
                NumberAnimation { target: toast; property: "opacity"; to: 0; duration: 300 }
                ScriptAction    { script: toast.destroy() }
            }
        }
    }
}
