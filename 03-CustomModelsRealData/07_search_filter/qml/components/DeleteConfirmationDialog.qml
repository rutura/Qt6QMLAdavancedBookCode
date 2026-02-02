import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * DeleteConfirmationDialog - Modern confirmation dialog for deleting a contact
 *
 * Shows contact name and asks for confirmation before deletion.
 * Light theme matching the rest of the application.
 */
Dialog {
    id: root

    modal: true
    anchors.centerIn: Overlay.overlay
    width: 420
    padding: 0

    // Contact being deleted
    property int contactIndex: -1
    property string contactName: ""
    property string contactAvatarColor: "#6366F1"

    signal deleteConfirmed(int index)

    // Function to set contact for deletion
    function setContact(index, firstName, lastName, avatarColor) {
        contactIndex = index
        contactName = (firstName + " " + lastName).trim()
        contactAvatarColor = avatarColor || "#6366F1"
    }

    // Solid white background
    background: Rectangle {
        color: "#FFFFFF"
        radius: 16
        border.color: "#E5E7EB"
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 0

        // Header with warning icon
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 100

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 12

                // Warning icon
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 56
                    height: 56
                    radius: 28
                    color: "#FEE2E2"

                    Text {
                        anchors.centerIn: parent
                        text: "\u26A0"
                        font.pixelSize: 28
                        color: "#DC2626"
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Delete Contact"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: "#111827"
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#F3F4F6"
        }

        // Content
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 120

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                // Contact being deleted
                Rectangle {
                    Layout.fillWidth: true
                    height: 56
                    radius: 10
                    color: "#F9FAFB"
                    border.color: "#E5E7EB"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12

                        // Avatar
                        Rectangle {
                            width: 36
                            height: 36
                            radius: 18
                            color: root.contactAvatarColor

                            Text {
                                anchors.centerIn: parent
                                text: {
                                    let parts = root.contactName.split(" ")
                                    let initials = ""
                                    if (parts.length > 0 && parts[0]) initials += parts[0].charAt(0).toUpperCase()
                                    if (parts.length > 1 && parts[1]) initials += parts[1].charAt(0).toUpperCase()
                                    return initials
                                }
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                color: "#FFFFFF"
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.contactName
                            font.pixelSize: 15
                            font.weight: Font.Medium
                            color: "#111827"
                            elide: Text.ElideRight
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: "Are you sure you want to delete this contact? This action cannot be undone."
                    font.pixelSize: 14
                    color: "#6B7280"
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#F3F4F6"
        }

        // Footer with buttons
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 72

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                spacing: 12

                Item { Layout.fillWidth: true }

                // Cancel button
                Rectangle {
                    width: cancelText.width + 32
                    height: 44
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
                    width: deleteText.width + 40
                    height: 44
                    radius: 10
                    color: deleteMouseArea.pressed ? "#B91C1C" : deleteMouseArea.containsMouse ? "#DC2626" : "#EF4444"

                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "\uD83D\uDDD1"
                            font.pixelSize: 14
                            color: "#FFFFFF"
                        }

                        Text {
                            id: deleteText
                            text: "Delete"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: "#FFFFFF"
                        }
                    }

                    MouseArea {
                        id: deleteMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.deleteConfirmed(root.contactIndex)
                            root.accept()
                        }
                    }
                }
            }
        }
    }
}
