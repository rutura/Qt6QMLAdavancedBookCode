import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 500
    height: 500
    visible: true
    title: "QmlAdvCore — 04: Default Property"
    color: Theme.colors.background

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacing.lg

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Default Property Demo"
            font.pixelSize: 20
            font.bold: true
            color: Theme.colors.text
        }

        // The magic: children declared inside Card {} without any property
        // keyword — they go straight into `contentItems` because of
        // Q_CLASSINFO("DefaultProperty", "contentItems").
        // Compare with Qt's own Rectangle where children go into `data`.
        Rectangle {
            width: 340
            height: card.implicitHeight + 16
            radius: 12
            color: Theme.colors.surface
            border.color: Theme.colors.primary
            border.width: 1

            Card {
                id: card
                anchors {
                    top: parent.top; left: parent.left
                    topMargin: 8; leftMargin: 8
                }
                width: parent.width - 16
                padding: Theme.spacing.md
                spacing: Theme.spacing.sm

                // No "contentItems:" keyword — DefaultProperty handles it
                Text {
                    text: "Card title"
                    font.pixelSize: 16
                    font.bold: true
                    color: Theme.colors.text
                }

                Text {
                    text: "Any child declared here is collected into\n" +
                          "contentItems via QQmlListProperty — the same\n" +
                          "pattern Qt uses for Rectangle's data property."
                    font.pixelSize: 13
                    color: Theme.colors.text
                    wrapMode: Text.WordWrap
                    width: 280
                }

                Button {
                    text: "I live inside a Card"
                    onClicked: statusText.text = "Button clicked! Card has " +
                               card.contentItems.length + " children."
                }
            }
        }

        Text {
            id: statusText
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Click the button"
            color: Theme.colors.text
            font.pixelSize: 13
        }
    }
}
