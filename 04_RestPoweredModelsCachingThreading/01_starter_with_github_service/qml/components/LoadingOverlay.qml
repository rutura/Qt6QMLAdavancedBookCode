import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property bool active: false

    visible: opacity > 0
    opacity: active ? 1 : 0
    color: Qt.alpha(Theme.background, 0.6)

    Behavior on opacity { NumberAnimation { duration: Theme.fastAnimation } }

    // Swallow clicks while loading.
    MouseArea { anchors.fill: parent; enabled: root.active }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 14

        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: root.active
            implicitWidth: 48
            implicitHeight: 48
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Loading…"
            color: Theme.textSecondary
            font.pixelSize: 13
        }
    }
}
