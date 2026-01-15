import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * DeleteConfirmationDialog - Modern confirmation dialog for deleting contacts
 *
 * Provides a clear warning message with Cancel and Delete buttons
 */
Dialog {
    id: root

    modal: true
    anchors.centerIn: Overlay.overlay
    width: 400
    height: 200
    padding: 0

    property string contactName: ""

    signal deleteConfirmed()

    background: Rectangle {
        color: "#FFFFFF"
        radius: 16
        border.color: "#E5E7EB"
        border.width: 1
    }

    // Custom header
    header: Item {
        height: 60

        Rectangle {
            anchors.fill: parent
            color: "#FFFFFF"
            radius: 16

            // Cover bottom corners
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 16
                color: "#FFFFFF"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                spacing: 12

                // Warning icon
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: "#FEE2E2"
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        anchors.centerIn: parent
                        text: "⚠"
                        font.pixelSize: 22
                        color: "#EF4444"
                    }
                }

                Column {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "Delete Contact?"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: "#111827"
                    }

                    Text {
                        text: "This action cannot be undone"
                        font.pixelSize: 13
                        color: "#6B7280"
                    }
                }
            }

            // Bottom border
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#E5E7EB"
            }
        }
    }

    // Content area
    contentItem: Item {
        Text {
            anchors.fill: parent
            anchors.margins: 24
            text: "Are you sure you want to delete <b>" + root.contactName + "</b>? This contact will be permanently removed from your list."
            font.pixelSize: 14
            color: "#374151"
            wrapMode: Text.Wrap
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Custom footer with buttons
    footer: Item {
        height: 72

        Rectangle {
            anchors.fill: parent
            color: "#FFFFFF"
            radius: 16

            // Cover top corners
            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 16
                color: "#FFFFFF"
            }

            // Top border
            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: "#E5E7EB"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                spacing: 12

                Item { Layout.fillWidth: true }

                // Cancel button
                Rectangle {
                    width: cancelText.width + 32
                    height: 40
                    radius: 10
                    color: cancelMouseArea.containsMouse ? "#F3F4F6" : "#FFFFFF"
                    border.color: "#E5E7EB"
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        id: cancelText
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: "#374151"
                    }

                    MouseArea {
                        id: cancelMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.reject()
                    }
                }

                // Delete button
                Rectangle {
                    width: deleteText.width + 32
                    height: 40
                    radius: 10
                    color: deleteMouseArea.pressed ? "#B91C1C" : deleteMouseArea.containsMouse ? "#DC2626" : "#EF4444"

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        id: deleteText
                        anchors.centerIn: parent
                        text: "Delete Contact"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        id: deleteMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.deleteConfirmed()
                            root.close()
                        }
                    }
                }
            }
        }
    }
}
