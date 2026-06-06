import QtQuick
import QtQuick.Controls

// Themed scroll surface around a ListView. Pages set `model` and `delegate`;
// `footerItem` is a slot for the load-more / cursor-sentinel pattern (03/04).
Rectangle {
    id: root

    property alias model: view.model
    property alias delegate: view.delegate
    property alias view: view
    property Component footerComponent: null

    color: "transparent"

    ListView {
        id: view
        anchors.fill: parent
        anchors.margins: 4
        clip: true
        spacing: 10
        cacheBuffer: 600

        footer: root.footerComponent

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            contentItem: Rectangle {
                implicitWidth: 6
                radius: 3
                color: Theme.border
                opacity: 0.6
            }
        }
    }
}
