import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string glyph: "🔍"
    property string title: "Nothing here yet"
    property string subtitle: ""

    spacing: 12

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: root.glyph
        font.pixelSize: 56
        opacity: 0.7
    }
    Text {
        Layout.alignment: Qt.AlignHCenter
        text: root.title
        color: Theme.textPrimary
        font.pixelSize: 18
        font.weight: Font.DemiBold
    }
    Text {
        Layout.alignment: Qt.AlignHCenter
        visible: root.subtitle.length > 0
        text: root.subtitle
        color: Theme.textSecondary
        font.pixelSize: 13
    }
}
