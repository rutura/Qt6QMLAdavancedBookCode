// Pattern: Property value source
// Pulse implements QQmlPropertyValueSource — the same interface used by
// NumberAnimation, Behavior, and SmoothedAnimation.
import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 380; height: 280
    visible: true
    title: "Example — Property Value Source"
    color: Theme.colors.background

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacing.xl

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Pulsing button"
            Pulse on opacity { from: 0.4; to: 1.0; period: 800 }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 100; height: 100; radius: 50
            color: Theme.colors.primary
            Pulse on scale { from: 0.85; to: 1.15; period: 1200 }
        }
    }
}
