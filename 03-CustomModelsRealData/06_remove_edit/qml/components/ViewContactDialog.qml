import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * ViewContactDialog - Modern dialog for viewing contact details (read-only)
 *
 * Displays all contact information in a clean, organized layout.
 * Light theme matching the rest of the application.
 */

Dialog {
    id: root

    modal: true
    anchors.centerIn: Overlay.overlay
    width: 520
    height: Math.min(640, parent.height - 80)
    padding: 0

    property string contactFirstName: ""
    property string contactLastName: ""
    property string contactEmail: ""
    property string contactPhone: ""
    property string contactCompany: ""
    property string contactJobTitle: ""
    property string contactAddress: ""
    property string contactNotes: ""
    property bool contactIsFavorite: false
    property var contactTags: []
    property string contactAvatarColor: "#6366F1"
    property int contactIndex: -1

    signal editRequested(int index)

    function loadContact(index, data) {
        contactIndex = index
        contactFirstName = data.firstName || ""
        contactLastName = data.lastName || ""
        contactEmail = data.email || ""
        contactPhone = data.phone || ""
        contactCompany = data.company || ""
        contactJobTitle = data.jobTitle || ""
        contactAddress = data.address || ""
        contactNotes = data.notes || ""
        contactIsFavorite = data.isFavorite || false
        contactTags = data.tags || []
        contactAvatarColor = data.avatarColor || "#6366F1"
    }

    background: Rectangle {
        color: "#FFFFFF"
        radius: 16
        border.color: "#E5E7EB"
        border.width: 1
    }

    // We'll build this incrementally

    //Header
    header: Item {
        height: 140

        Rectangle {
            anchors.fill: parent
            color: "#FFFFFF"
            radius: 16

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 16
                color: "#FFFFFF"
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 28
                anchors.rightMargin: 28
                anchors.topMargin: 20
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    // Avatar
                    Rectangle {
                        width: 72
                        height: 72
                        radius: 36
                        color: root.contactAvatarColor

                        Text {
                            anchors.centerIn: parent
                            text: {
                                let initials = ""
                                if (root.contactFirstName) initials += root.contactFirstName.charAt(0).toUpperCase()
                                if (root.contactLastName) initials += root.contactLastName.charAt(0).toUpperCase()
                                return initials
                            }
                            font.pixelSize: 28
                            font.weight: Font.DemiBold
                            color: "#FFFFFF"
                        }

                        // Favorite badge
                        Rectangle {
                            visible: root.contactIsFavorite
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.rightMargin: -2
                            anchors.bottomMargin: -2
                            width: 24
                            height: 24
                            radius: 12
                            color: "#FEF3C7"
                            border.color: "#FFFFFF"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "\u2605"
                                font.pixelSize: 14
                                color: "#F59E0B"
                            }
                        }

                        //Can add favorite badge here
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: root.contactFirstName + " " + root.contactLastName
                            font.pixelSize: 22
                            font.weight: Font.Bold
                            color: "#111827"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            visible: root.contactJobTitle !== "" || root.contactCompany !== ""
                            text: {
                                if (root.contactJobTitle && root.contactCompany) {
                                    return root.contactJobTitle + " at " + root.contactCompany
                                } else if (root.contactJobTitle) {
                                    return root.contactJobTitle
                                } else {
                                    return root.contactCompany
                                }
                            }
                            font.pixelSize: 14
                            color: "#6B7280"
                        }
                    }

                    // Close button
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: closeMouseArea.containsMouse ? "#F3F4F6" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "\u2715"
                            font.pixelSize: 16
                            color: "#6B7280"
                        }

                        MouseArea {
                            id: closeMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.close()
                        }
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#E5E7EB"
            }
        }
    }

    // Content
    contentItem: Flickable {
        id: contentFlickable
        clip: true
        contentHeight: detailsColumn.height + 32
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        ColumnLayout {
            id: detailsColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 28
            spacing: 20

            // Contact info section (email, phone)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                visible: root.contactEmail !== "" || root.contactPhone !== ""

                RowLayout {
                    spacing: 8

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: "#EEF2FF"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83D\uDCDE"
                            font.pixelSize: 14
                        }
                    }

                    Text {
                        text: "Contact"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: "#111827"
                    }
                }

                // Email row
                RowLayout {
                    visible: root.contactEmail !== ""
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 8
                        color: "#F3F4F6"

                        Text {
                            anchors.centerIn: parent
                            text: "\u2709"
                            font.pixelSize: 18
                            color: "#6B7280"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Email"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: "#9CA3AF"
                        }

                        Text {
                            text: root.contactEmail
                            font.pixelSize: 14
                            color: "#3B82F6"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                //Phone row
                // Phone
                RowLayout {
                    visible: root.contactPhone !== ""
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 8
                        color: "#F3F4F6"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83D\uDCF1"
                            font.pixelSize: 18
                            color: "#6B7280"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Phone"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: "#9CA3AF"
                        }

                        Text {
                            text: root.contactPhone
                            font.pixelSize: 14
                            color: "#111827"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                // Phone row (similar structure to email)
                // ... add phone section here following the same pattern
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#F3F4F6"
                visible: (root.contactEmail !== "" || root.contactPhone !== "") &&
                         (root.contactCompany !== "" || root.contactJobTitle !== "")
            }

            // Work Information Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                visible: root.contactCompany !== "" || root.contactJobTitle !== ""

                RowLayout {
                    spacing: 8

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: "#FEF3C7"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83C\uDFE2"
                            font.pixelSize: 14
                        }
                    }

                    Text {
                        text: "Work"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: "#111827"
                    }
                }

                // Company
                RowLayout {
                    visible: root.contactCompany !== ""
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 8
                        color: "#F3F4F6"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83D\uDCBC"
                            font.pixelSize: 18
                            color: "#6B7280"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Company"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: "#9CA3AF"
                        }

                        Text {
                            text: root.contactCompany
                            font.pixelSize: 14
                            color: "#111827"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                // Job Title
                RowLayout {
                    visible: root.contactJobTitle !== ""
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 8
                        color: "#F3F4F6"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83D\uDCCB"
                            font.pixelSize: 18
                            color: "#6B7280"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Job Title"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: "#9CA3AF"
                        }

                        Text {
                            text: root.contactJobTitle
                            font.pixelSize: 14
                            color: "#111827"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }
            }


            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#F3F4F6"
                visible: (root.contactCompany !== "" || root.contactJobTitle !== "") && root.contactAddress !== ""
            }

            // Address Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                visible: root.contactAddress !== ""

                RowLayout {
                    spacing: 8

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: "#DCFCE7"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83D\uDCCD"
                            font.pixelSize: 14
                        }
                    }

                    Text {
                        text: "Address"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: "#111827"
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 8
                        color: "#F3F4F6"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83C\uDFE0"
                            font.pixelSize: 18
                            color: "#6B7280"
                        }
                    }

                    Text {
                        text: root.contactAddress
                        font.pixelSize: 14
                        color: "#111827"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }



            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#F3F4F6"
                visible: root.contactAddress !== "" && root.contactNotes !== ""
            }

            // Notes Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                visible: root.contactNotes !== ""

                RowLayout {
                    spacing: 8

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: "#E0E7FF"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83D\uDCDD"
                            font.pixelSize: 14
                        }
                    }

                    Text {
                        text: "Notes"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: "#111827"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: notesText.height + 24
                    radius: 10
                    color: "#F9FAFB"
                    border.color: "#E5E7EB"
                    border.width: 1

                    Text {
                        id: notesText
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        text: root.contactNotes
                        font.pixelSize: 14
                        color: "#374151"
                        wrapMode: Text.WordWrap
                    }
                }
            }



            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#F3F4F6"
                visible: root.contactTags.length > 0
            }

            // Tags Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                visible: root.contactTags.length > 0

                RowLayout {
                    spacing: 8

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: "#FCE7F3"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83C\uDFF7\uFE0F"
                            font.pixelSize: 14
                        }
                    }

                    Text {
                        text: "Tags"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: "#111827"
                    }
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: root.contactTags

                        delegate: Rectangle {
                            width: tagLabel.width + 20
                            height: 30
                            radius: 15
                            color: "#EEF2FF"

                            Text {
                                id: tagLabel
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: "#4F46E5"
                            }
                        }
                    }
                }
            }

            // Bottom spacer
            Item {
                Layout.fillWidth: true
                height: 8
            }


            // Add more sections for work info, address, notes, tags
            // following the same pattern
        }
    }

    footer: Item {
        height: 72

        Rectangle {
            anchors.fill: parent
            color: "#FFFFFF"
            radius: 16

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: "#E5E7EB"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 28
                anchors.rightMargin: 28
                spacing: 12

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: closeText.width + 32
                    height: 44
                    radius: 10
                    color: closeButtonArea.containsMouse ? "#F3F4F6" : "#FFFFFF"
                    border.color: "#E5E7EB"
                    border.width: 1

                    Text {
                        id: closeText
                        anchors.centerIn: parent
                        text: "Close"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: "#374151"
                    }

                    MouseArea {
                        id: closeButtonArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.close()
                    }
                }

                Rectangle {
                    width: editText.width + 40
                    height: 44
                    radius: 10
                    color: editMouseArea.pressed ? "#1D4ED8" : editMouseArea.containsMouse ? "#2563EB" : "#3B82F6"

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "\u270F"
                            font.pixelSize: 14
                            color: "#FFFFFF"
                        }

                        Text {
                            id: editText
                            text: "Edit Contact"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: "#FFFFFF"
                        }
                    }

                    MouseArea {
                        id: editMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.close()
                            root.editRequested(root.contactIndex)
                        }
                    }
                }
            }
        }
    }



}





/*
Dialog {
    id: root

    modal: true
    anchors.centerIn: Overlay.overlay
    width: 520
    height: Math.min(640, parent.height - 80)
    padding: 0

    // Contact data properties
    property string contactFirstName: ""
    property string contactLastName: ""
    property string contactEmail: ""
    property string contactPhone: ""
    property string contactCompany: ""
    property string contactJobTitle: ""
    property string contactAddress: ""
    property string contactNotes: ""
    property bool contactIsFavorite: false
    property var contactTags: []
    property string contactAvatarColor: "#6366F1"
    property int contactIndex: -1

    signal editRequested(int index)

    // Function to load contact data
    function loadContact(index, data) {
        contactIndex = index
        contactFirstName = data.firstName || ""
        contactLastName = data.lastName || ""
        contactEmail = data.email || ""
        contactPhone = data.phone || ""
        contactCompany = data.company || ""
        contactJobTitle = data.jobTitle || ""
        contactAddress = data.address || ""
        contactNotes = data.notes || ""
        contactIsFavorite = data.isFavorite || false
        contactTags = data.tags || []
        contactAvatarColor = data.avatarColor || "#6366F1"
        contentFlickable.contentY = 0
    }

    // Solid white background
    background: Rectangle {
        color: "#FFFFFF"
        radius: 16
        border.color: "#E5E7EB"
        border.width: 1
    }

    // Custom header with avatar
    header: Item {
        height: 140

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

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 28
                anchors.rightMargin: 28
                anchors.topMargin: 20
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    // Avatar
                    Rectangle {
                        width: 72
                        height: 72
                        radius: 36
                        color: root.contactAvatarColor

                        Text {
                            anchors.centerIn: parent
                            text: {
                                let initials = ""
                                if (root.contactFirstName) initials += root.contactFirstName.charAt(0).toUpperCase()
                                if (root.contactLastName) initials += root.contactLastName.charAt(0).toUpperCase()
                                return initials
                            }
                            font.pixelSize: 28
                            font.weight: Font.DemiBold
                            color: "#FFFFFF"
                        }

                        // Favorite badge
                        Rectangle {
                            visible: root.contactIsFavorite
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.rightMargin: -2
                            anchors.bottomMargin: -2
                            width: 24
                            height: 24
                            radius: 12
                            color: "#FEF3C7"
                            border.color: "#FFFFFF"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "\u2605"
                                font.pixelSize: 14
                                color: "#F59E0B"
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: root.contactFirstName + " " + root.contactLastName
                            font.pixelSize: 22
                            font.weight: Font.Bold
                            color: "#111827"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            visible: root.contactJobTitle !== "" || root.contactCompany !== ""
                            text: {
                                if (root.contactJobTitle && root.contactCompany) {
                                    return root.contactJobTitle + " at " + root.contactCompany
                                } else if (root.contactJobTitle) {
                                    return root.contactJobTitle
                                } else {
                                    return root.contactCompany
                                }
                            }
                            font.pixelSize: 14
                            color: "#6B7280"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // Close button
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: closeMouseArea.containsMouse ? "#F3F4F6" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "\u2715"
                            font.pixelSize: 16
                            color: "#6B7280"
                        }

                        MouseArea {
                            id: closeMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.close()
                        }
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
    contentItem: Flickable {
        id: contentFlickable
        clip: true
        contentHeight: detailsColumn.height + 32
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded

            background: Rectangle {
                color: "transparent"
            }

            contentItem: Rectangle {
                implicitWidth: 6
                radius: 3
                color: parent.pressed ? "#9CA3AF" : "#D1D5DB"
            }
        }

        ColumnLayout {
            id: detailsColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 28
            anchors.topMargin: 16
            spacing: 20

            // Contact Information Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                visible: root.contactEmail !== "" || root.contactPhone !== ""

                RowLayout {
                    spacing: 8

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: "#EEF2FF"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83D\uDCDE"
                            font.pixelSize: 14
                        }
                    }

                    Text {
                        text: "Contact"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: "#111827"
                    }
                }

                // Email
                RowLayout {
                    visible: root.contactEmail !== ""
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 8
                        color: "#F3F4F6"

                        Text {
                            anchors.centerIn: parent
                            text: "\u2709"
                            font.pixelSize: 18
                            color: "#6B7280"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Email"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: "#9CA3AF"
                        }

                        Text {
                            text: root.contactEmail
                            font.pixelSize: 14
                            color: "#3B82F6"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                // Phone
                RowLayout {
                    visible: root.contactPhone !== ""
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 8
                        color: "#F3F4F6"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83D\uDCF1"
                            font.pixelSize: 18
                            color: "#6B7280"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Phone"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: "#9CA3AF"
                        }

                        Text {
                            text: root.contactPhone
                            font.pixelSize: 14
                            color: "#111827"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#F3F4F6"
                visible: (root.contactEmail !== "" || root.contactPhone !== "") &&
                         (root.contactCompany !== "" || root.contactJobTitle !== "")
            }

            // Work Information Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                visible: root.contactCompany !== "" || root.contactJobTitle !== ""

                RowLayout {
                    spacing: 8

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: "#FEF3C7"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83C\uDFE2"
                            font.pixelSize: 14
                        }
                    }

                    Text {
                        text: "Work"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: "#111827"
                    }
                }

                // Company
                RowLayout {
                    visible: root.contactCompany !== ""
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 8
                        color: "#F3F4F6"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83D\uDCBC"
                            font.pixelSize: 18
                            color: "#6B7280"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Company"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: "#9CA3AF"
                        }

                        Text {
                            text: root.contactCompany
                            font.pixelSize: 14
                            color: "#111827"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                // Job Title
                RowLayout {
                    visible: root.contactJobTitle !== ""
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 8
                        color: "#F3F4F6"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83D\uDCCB"
                            font.pixelSize: 18
                            color: "#6B7280"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Job Title"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: "#9CA3AF"
                        }

                        Text {
                            text: root.contactJobTitle
                            font.pixelSize: 14
                            color: "#111827"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#F3F4F6"
                visible: (root.contactCompany !== "" || root.contactJobTitle !== "") && root.contactAddress !== ""
            }

            // Address Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                visible: root.contactAddress !== ""

                RowLayout {
                    spacing: 8

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: "#DCFCE7"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83D\uDCCD"
                            font.pixelSize: 14
                        }
                    }

                    Text {
                        text: "Address"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: "#111827"
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 8
                        color: "#F3F4F6"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83C\uDFE0"
                            font.pixelSize: 18
                            color: "#6B7280"
                        }
                    }

                    Text {
                        text: root.contactAddress
                        font.pixelSize: 14
                        color: "#111827"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#F3F4F6"
                visible: root.contactAddress !== "" && root.contactNotes !== ""
            }

            // Notes Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                visible: root.contactNotes !== ""

                RowLayout {
                    spacing: 8

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: "#E0E7FF"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83D\uDCDD"
                            font.pixelSize: 14
                        }
                    }

                    Text {
                        text: "Notes"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: "#111827"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: notesText.height + 24
                    radius: 10
                    color: "#F9FAFB"
                    border.color: "#E5E7EB"
                    border.width: 1

                    Text {
                        id: notesText
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        text: root.contactNotes
                        font.pixelSize: 14
                        color: "#374151"
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#F3F4F6"
                visible: root.contactTags.length > 0
            }

            // Tags Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                visible: root.contactTags.length > 0

                RowLayout {
                    spacing: 8

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: "#FCE7F3"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83C\uDFF7\uFE0F"
                            font.pixelSize: 14
                        }
                    }

                    Text {
                        text: "Tags"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: "#111827"
                    }
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: root.contactTags

                        delegate: Rectangle {
                            width: tagLabel.width + 20
                            height: 30
                            radius: 15
                            color: "#EEF2FF"

                            Text {
                                id: tagLabel
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: "#4F46E5"
                            }
                        }
                    }
                }
            }

            // Bottom spacer
            Item {
                Layout.fillWidth: true
                height: 8
            }
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
                anchors.leftMargin: 28
                anchors.rightMargin: 28
                spacing: 12

                Item { Layout.fillWidth: true }

                // Close button
                Rectangle {
                    width: closeText.width + 32
                    height: 44
                    radius: 10
                    color: closeButtonArea.containsMouse ? "#F3F4F6" : "#FFFFFF"
                    border.color: "#E5E7EB"
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        id: closeText
                        anchors.centerIn: parent
                        text: "Close"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: "#374151"
                    }

                    MouseArea {
                        id: closeButtonArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.close()
                    }
                }

                // Edit button
                Rectangle {
                    width: editText.width + 40
                    height: 44
                    radius: 10
                    color: editMouseArea.pressed ? "#1D4ED8" : editMouseArea.containsMouse ? "#2563EB" : "#3B82F6"

                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "\u270F"
                            font.pixelSize: 14
                            color: "#FFFFFF"
                        }

                        Text {
                            id: editText
                            text: "Edit Contact"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: "#FFFFFF"
                        }
                    }

                    MouseArea {
                        id: editMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.close()
                            root.editRequested(root.contactIndex)
                        }
                    }
                }
            }
        }
    }
}
*/
