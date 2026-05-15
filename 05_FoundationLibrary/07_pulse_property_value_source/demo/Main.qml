import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 440
    height: 420
    visible: true
    title: "QmlAdvCore — 07: Property Value Source"
    color: Theme.colors.background

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacing.xl

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Property Value Source Demo"
            font.pixelSize: 20
            font.bold: true
            color: Theme.colors.text
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 380
            text: "Pulse uses the same interface as NumberAnimation and\n" +
                  "Behavior. The `on opacity` syntax tells QML to call\n" +
                  "setTarget(property) on the Pulse instance."
            font.pixelSize: 13
            color: Theme.colors.text
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        // Primary button — pulsing opacity to draw attention
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Save Changes"
            font.pixelSize: 16

            // "Pulse on opacity" — property value source syntax.
            // QML creates a Pulse, sets its target to this button's `opacity`
            // property, and Pulse drives it from 0.4 to 1.0 and back.
            Pulse on opacity {
                from: 0.4
                to: 1.0
                period: 900
            }
        }

        // A rectangle with a pulsing scale effect via x offset
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 120
            height: 120
            radius: 60
            color: Theme.colors.primary

            Text {
                anchors.centerIn: parent
                text: "●"
                font.pixelSize: 48
                color: Theme.colors.onPrimary

                // Pulse drives `scale` — any writable numeric property works
                Pulse on scale {
                    from: 0.85
                    to: 1.15
                    period: 1200
                }
            }
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Static Button (no Pulse)"
            font.pixelSize: 14
        }
    }
}
