import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Per-page status row. `statusText` carries count/page info; `extras` is a
// right-aligned slot later sections drop pills/controls into (parsing badge,
// mode combo, auto-refresh switch) without restructuring.
RowLayout {
    id: root

    property string statusText: ""
    property bool busy: false
    default property alias extraItems: extras.data

    spacing: 12

    BusyIndicator {
        running: root.busy
        visible: running
        implicitWidth: 22
        implicitHeight: 22
    }

    Label {
        text: root.statusText
        color: Theme.textSecondary
        font.pixelSize: 13
        Behavior on color { ColorAnimation { duration: Theme.normalAnimation } }
    }

    Item { Layout.fillWidth: true }

    RowLayout {
        id: extras
        spacing: 10
    }
}
