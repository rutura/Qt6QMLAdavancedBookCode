import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * EditContactDialog - Modern dialog for editing an existing contact
 *
 * Provides form fields for modifying all contact details.
 * Light theme matching the rest of the application.
 */
Dialog {
    id: root

    modal: true
    anchors.centerIn: Overlay.overlay
    width: 560
    height: Math.min(720, parent.height - 80)
    padding: 0

    // Contact index being edited
    property int contactIndex: -1

    // Available tags (same as FilterPanel)
    readonly property var availableTags: ["client", "alumni", "lead", "friends", "vendor", "prospect", "partner", "work", "family", "colleague"]
    property var selectedTags: []

    signal contactUpdated(int index, string firstName, string lastName, string email, string phone,
                          string company, string jobTitle, string address, string notes,
                          bool isFavorite, var tags)

    // Function to load contact data
    function loadContact(index, data) {
        contactIndex = index
        firstNameField.text = data.firstName || ""
        lastNameField.text = data.lastName || ""
        emailField.text = data.email || ""
        phoneField.text = data.phone || ""
        companyField.text = data.company || ""
        jobTitleField.text = data.jobTitle || ""
        addressField.text = data.address || ""
        notesField.text = data.notes || ""
        favoriteSwitch.checked = data.isFavorite || false
        selectedTags = data.tags ? data.tags.slice() : []
        contentFlickable.contentY = 0
    }

    // Solid white background
    background: Rectangle {
        color: "#FFFFFF"
        radius: 16
        border.color: "#E5E7EB"
        border.width: 1
    }

    onOpened: {
        firstNameField.forceActiveFocus()
    }

    onAccepted: {
        if (firstNameField.text.trim() !== "" || lastNameField.text.trim() !== "") {
            root.contactUpdated(
                contactIndex,
                firstNameField.text.trim(),
                lastNameField.text.trim(),
                emailField.text.trim(),
                phoneField.text.trim(),
                companyField.text.trim(),
                jobTitleField.text.trim(),
                addressField.text.trim(),
                notesField.text.trim(),
                favoriteSwitch.checked,
                selectedTags
            )
        }
    }

    // Custom header
    header: Item {
        height: 72

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
                anchors.leftMargin: 28
                anchors.rightMargin: 28

                Column {
                    spacing: 4

                    Text {
                        text: "Edit Contact"
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: "#111827"
                    }

                    Text {
                        text: "Update the contact details below"
                        font.pixelSize: 13
                        color: "#6B7280"
                    }
                }

                Item { Layout.fillWidth: true }

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
                        onClicked: root.reject()
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
        contentHeight: formColumn.height + 32
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
            id: formColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 28
            anchors.topMargin: 16
            spacing: 24

            // Personal Information Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                RowLayout {
                    spacing: 8

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 8
                        color: "#EEF2FF"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83D\uDC64"
                            font.pixelSize: 16
                        }
                    }

                    Text {
                        text: "Personal Information"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        color: "#111827"
                    }
                }

                // Name row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "First Name"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: "#374151"
                        }

                        TextField {
                            id: firstNameField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            placeholderText: "John"
                            font.pixelSize: 14
                            color: "#111827"
                            placeholderTextColor: "#9CA3AF"
                            leftPadding: 14
                            rightPadding: 14

                            background: Rectangle {
                                color: firstNameField.activeFocus ? "#FFFFFF" : "#F9FAFB"
                                border.color: firstNameField.activeFocus ? "#3B82F6" : "#E5E7EB"
                                border.width: firstNameField.activeFocus ? 2 : 1
                                radius: 10

                                Behavior on border.color { ColorAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "Last Name"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: "#374151"
                        }

                        TextField {
                            id: lastNameField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            placeholderText: "Doe"
                            font.pixelSize: 14
                            color: "#111827"
                            placeholderTextColor: "#9CA3AF"
                            leftPadding: 14
                            rightPadding: 14

                            background: Rectangle {
                                color: lastNameField.activeFocus ? "#FFFFFF" : "#F9FAFB"
                                border.color: lastNameField.activeFocus ? "#3B82F6" : "#E5E7EB"
                                border.width: lastNameField.activeFocus ? 2 : 1
                                radius: 10

                                Behavior on border.color { ColorAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }
                }

                // Contact row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "Email"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: "#374151"
                        }

                        TextField {
                            id: emailField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            placeholderText: "john.doe@example.com"
                            font.pixelSize: 14
                            color: "#111827"
                            placeholderTextColor: "#9CA3AF"
                            leftPadding: 14
                            rightPadding: 14
                            inputMethodHints: Qt.ImhEmailCharactersOnly

                            background: Rectangle {
                                color: emailField.activeFocus ? "#FFFFFF" : "#F9FAFB"
                                border.color: emailField.activeFocus ? "#3B82F6" : "#E5E7EB"
                                border.width: emailField.activeFocus ? 2 : 1
                                radius: 10

                                Behavior on border.color { ColorAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "Phone"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: "#374151"
                        }

                        TextField {
                            id: phoneField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            placeholderText: "+1 (555) 123-4567"
                            font.pixelSize: 14
                            color: "#111827"
                            placeholderTextColor: "#9CA3AF"
                            leftPadding: 14
                            rightPadding: 14
                            inputMethodHints: Qt.ImhDialableCharactersOnly

                            background: Rectangle {
                                color: phoneField.activeFocus ? "#FFFFFF" : "#F9FAFB"
                                border.color: phoneField.activeFocus ? "#3B82F6" : "#E5E7EB"
                                border.width: phoneField.activeFocus ? 2 : 1
                                radius: 10

                                Behavior on border.color { ColorAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#F3F4F6"
            }

            // Work Information Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                RowLayout {
                    spacing: 8

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 8
                        color: "#FEF3C7"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83D\uDCBC"
                            font.pixelSize: 16
                        }
                    }

                    Text {
                        text: "Work Information"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        color: "#111827"
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "Company"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: "#374151"
                        }

                        TextField {
                            id: companyField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            placeholderText: "Acme Inc."
                            font.pixelSize: 14
                            color: "#111827"
                            placeholderTextColor: "#9CA3AF"
                            leftPadding: 14
                            rightPadding: 14

                            background: Rectangle {
                                color: companyField.activeFocus ? "#FFFFFF" : "#F9FAFB"
                                border.color: companyField.activeFocus ? "#3B82F6" : "#E5E7EB"
                                border.width: companyField.activeFocus ? 2 : 1
                                radius: 10

                                Behavior on border.color { ColorAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "Job Title"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: "#374151"
                        }

                        TextField {
                            id: jobTitleField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            placeholderText: "Software Engineer"
                            font.pixelSize: 14
                            color: "#111827"
                            placeholderTextColor: "#9CA3AF"
                            leftPadding: 14
                            rightPadding: 14

                            background: Rectangle {
                                color: jobTitleField.activeFocus ? "#FFFFFF" : "#F9FAFB"
                                border.color: jobTitleField.activeFocus ? "#3B82F6" : "#E5E7EB"
                                border.width: jobTitleField.activeFocus ? 2 : 1
                                radius: 10

                                Behavior on border.color { ColorAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#F3F4F6"
            }

            // Address Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                RowLayout {
                    spacing: 8

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 8
                        color: "#DCFCE7"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83D\uDCCD"
                            font.pixelSize: 16
                        }
                    }

                    Text {
                        text: "Address"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        color: "#111827"
                    }
                }

                TextField {
                    id: addressField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    placeholderText: "123 Main St, City, Country"
                    font.pixelSize: 14
                    color: "#111827"
                    placeholderTextColor: "#9CA3AF"
                    leftPadding: 14
                    rightPadding: 14

                    background: Rectangle {
                        color: addressField.activeFocus ? "#FFFFFF" : "#F9FAFB"
                        border.color: addressField.activeFocus ? "#3B82F6" : "#E5E7EB"
                        border.width: addressField.activeFocus ? 2 : 1
                        radius: 10

                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#F3F4F6"
            }

            // Notes Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                RowLayout {
                    spacing: 8

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 8
                        color: "#E0E7FF"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83D\uDCDD"
                            font.pixelSize: 16
                        }
                    }

                    Text {
                        text: "Notes"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        color: "#111827"
                    }
                }

                TextArea {
                    id: notesField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 88
                    placeholderText: "Add any notes about this contact..."
                    font.pixelSize: 14
                    color: "#111827"
                    placeholderTextColor: "#9CA3AF"
                    wrapMode: TextArea.Wrap
                    leftPadding: 14
                    rightPadding: 14
                    topPadding: 12
                    bottomPadding: 12

                    background: Rectangle {
                        color: notesField.activeFocus ? "#FFFFFF" : "#F9FAFB"
                        border.color: notesField.activeFocus ? "#3B82F6" : "#E5E7EB"
                        border.width: notesField.activeFocus ? 2 : 1
                        radius: 10

                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#F3F4F6"
            }

            // Favorite Toggle
            Rectangle {
                Layout.fillWidth: true
                height: 56
                radius: 12
                color: favoriteSwitch.checked ? "#FEF9C3" : "#F9FAFB"
                border.color: favoriteSwitch.checked ? "#FDE047" : "#E5E7EB"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text {
                        text: "\u2605"
                        font.pixelSize: 22
                        color: favoriteSwitch.checked ? "#F59E0B" : "#D1D5DB"

                        Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Mark as Favorite"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: "#111827"
                        }

                        Text {
                            text: "Favorite contacts appear at the top of your list"
                            font.pixelSize: 12
                            color: "#6B7280"
                        }
                    }

                    Switch {
                        id: favoriteSwitch

                        indicator: Rectangle {
                            implicitWidth: 48
                            implicitHeight: 26
                            radius: 13
                            color: favoriteSwitch.checked ? "#F59E0B" : "#E5E7EB"

                            Behavior on color { ColorAnimation { duration: 200 } }

                            Rectangle {
                                x: favoriteSwitch.checked ? parent.width - width - 3 : 3
                                anchors.verticalCenter: parent.verticalCenter
                                width: 20
                                height: 20
                                radius: 10
                                color: "#FFFFFF"

                                Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#F3F4F6"
            }

            // Tags Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                RowLayout {
                    spacing: 8

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 8
                        color: "#FCE7F3"

                        Text {
                            anchors.centerIn: parent
                            text: "\uD83C\uDFF7\uFE0F"
                            font.pixelSize: 16
                        }
                    }

                    Text {
                        text: "Tags"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        color: "#111827"
                    }

                    Text {
                        text: "(optional)"
                        font.pixelSize: 13
                        color: "#9CA3AF"
                    }
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 10

                    Repeater {
                        model: root.availableTags

                        delegate: Rectangle {
                            id: tagChip

                            property bool isSelected: root.selectedTags.indexOf(modelData) >= 0

                            width: tagText.width + 28
                            height: 36
                            radius: 18
                            color: isSelected ? "#3B82F6" : "#F3F4F6"
                            border.width: isSelected ? 0 : 1
                            border.color: "#E5E7EB"

                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                id: tagText
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 13
                                font.weight: isSelected ? Font.Medium : Font.Normal
                                color: isSelected ? "#FFFFFF" : "#4B5563"

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    let tags = root.selectedTags.slice()
                                    let idx = tags.indexOf(modelData)

                                    if (idx >= 0) {
                                        tags.splice(idx, 1)
                                    } else {
                                        tags.push(modelData)
                                    }

                                    root.selectedTags = tags
                                }
                            }

                            // Checkmark for selected
                            Rectangle {
                                visible: tagChip.isSelected
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                width: 16
                                height: 16
                                radius: 8
                                color: "#FFFFFF"
                                opacity: 0.3
                            }
                        }
                    }
                }
            }

            // Bottom spacer for scrolling
            Item {
                Layout.fillWidth: true
                height: 8
            }
        }
    }

    // Custom footer with buttons
    footer: Item {
        height: 80

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

                // Required fields hint
                Text {
                    text: "* First or Last name required"
                    font.pixelSize: 12
                    color: "#9CA3AF"
                }

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

                // Save Changes button
                Rectangle {
                    width: saveText.width + 40
                    height: 44
                    radius: 10
                    color: saveMouseArea.pressed ? "#1D4ED8" : saveMouseArea.containsMouse ? "#2563EB" : "#3B82F6"

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        id: saveText
                        anchors.centerIn: parent
                        text: "Save Changes"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        id: saveMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.accept()
                    }
                }
            }
        }
    }
}
