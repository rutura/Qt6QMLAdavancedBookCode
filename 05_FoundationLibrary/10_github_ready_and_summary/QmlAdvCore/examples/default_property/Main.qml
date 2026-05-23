// Pattern: Default property
// Card has Q_CLASSINFO("DefaultProperty", "contentItems"), so children
// declared inside Card {} go directly into `contentItems` — no keyword.
import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 420; height: 340
    visible: true
    title: "Example — Default Property"
    color: Theme.colors.background

    Rectangle {
        anchors.centerIn: parent
        width: 340
        height: card.implicitHeight + 16
        radius: 12
        color: Theme.colors.surface
        border.color: Theme.colors.primary

        Card {
            id: card
            anchors {
                top: parent.top; left: parent.left
                topMargin: 8; leftMargin: 8
            }
            width: parent.width - 16
            padding: Theme.spacing.md
            spacing: Theme.spacing.sm

            // Children declared without `contentItems:` — DefaultProperty magic
            Text {
                text: "Card title"
                font.pixelSize: 16; font.bold: true
                color: Theme.colors.text
            }
            Text {
                text: "Same syntax Qt uses for Rectangle's `data`."
                color: Theme.colors.text; wrapMode: Text.WordWrap
                width: 280
            }
            Button { text: "I live inside a Card" }
        }
    }
}
