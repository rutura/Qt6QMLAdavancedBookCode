import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    required property string fullName
    required property string description
    required property int stargazersCount
    required property int forksCount
    required property string language
    required property bool isNew

    width: ListView.view ? ListView.view.width : implicitWidth
    implicitWidth: 400
    implicitHeight: layout.implicitHeight + 16
    // Soft yellow when the item was just inserted; fades back to white when isNew clears.
    color: root.isNew ? "#FEF9C3" : "#FFFFFF"
    border.color: "#E5E7EB"
    radius: 4

    Behavior on color {
        ColorAnimation { duration: 600 }
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 8
        spacing: 2

        Text {
            text: root.fullName
            font.pixelSize: 14
            font.bold: true
            color: "#111827"
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
        Text {
            text: root.description && root.description.length > 0
                  ? root.description
                  : "(no description)"
            font.pixelSize: 12
            color: "#4B5563"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
        Text {
            text: "★ " + root.stargazersCount
                  + "    ⑂ " + root.forksCount
                  + "    " + (root.language || "—")
            font.pixelSize: 11
            color: "#6B7280"
        }
    }
}
