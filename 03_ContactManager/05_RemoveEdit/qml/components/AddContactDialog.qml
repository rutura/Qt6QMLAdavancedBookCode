import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * AddContactDialog - Multi-mode dialog for contact management
 *
 * Supports three modes: add, edit, view
 * - add: Create a new contact
 * - edit: Modify an existing contact
 * - view: Display contact details (read-only)
 *
 * Light theme matching the rest of the application.
 */
Dialog {
    id: root

    modal: true
    anchors.centerIn: Overlay.overlay
    width: 560
    height: Math.min(720, parent.height - 80)
    padding: 0

    // Mode: "add", "edit", or "view"
    property string mode: "add"

    // Contact data (for edit and view modes)
    property string contactId: ""
    property int contactIndex: -1

    // Available tags (same as FilterPanel)
    readonly property var availableTags: ["client", "alumni", "lead", "friends", "vendor", "prospect", "partner", "work", "family", "colleague"]
    property var selectedTags: []

    // Computed properties for UI
    readonly property bool isAddMode: mode === "add"
    readonly property bool isEditMode: mode === "edit"
    readonly property bool isViewMode: mode === "view"
    readonly property bool isReadOnly: mode === "view"

    signal contactAdded(string firstName, string lastName, string email, string phone,
                        string company, string jobTitle, string address, string notes,
                        bool isFavorite, var tags)
    signal contactUpdated(int index, string firstName, string lastName, string email, string phone,
                         string company, string jobTitle, string address, string notes,
                         bool isFavorite, var tags)

    // Helper function to open dialog in different modes
    function openAdd() {
        mode = "add"
        contactId = ""
        contactIndex = -1
        open()
    }

    function openEdit(index, contact) {
        mode = "edit"
        contactIndex = index
        contactId = contact.contactId || ""

        // Prefill fields
        firstNameField.text = contact.firstName || ""
        lastNameField.text = contact.lastName || ""
        emailField.text = contact.email || ""
        phoneField.text = contact.phone || ""
        companyField.text = contact.company || ""
        jobTitleField.text = contact.jobTitle || ""
        addressField.text = contact.address || ""
        notesField.text = contact.notes || ""
        favoriteSwitch.checked = contact.isFavorite || false
        selectedTags = contact.tags || []

        open()
    }

    function openView(index, contact) {
        mode = "view"
        contactIndex = index
        contactId = contact.contactId || ""

        // Prefill fields
        firstNameField.text = contact.firstName || ""
        lastNameField.text = contact.lastName || ""
        emailField.text = contact.email || ""
        phoneField.text = contact.phone || ""
        companyField.text = contact.company || ""
        jobTitleField.text = contact.jobTitle || ""
        addressField.text = contact.address || ""
        notesField.text = contact.notes || ""
        favoriteSwitch.checked = contact.isFavorite || false
        selectedTags = contact.tags || []

        open()
    }

    // Solid white background
    background: Rectangle {
        color: "#FFFFFF"
        radius: 16
        border.color: "#E5E7EB"
        border.width: 1
    }

    // Reset form when dialog opens (only in add mode)
    onOpened: {
        if (isAddMode) {
            firstNameField.text = ""
            lastNameField.text = ""
            emailField.text = ""
            phoneField.text = ""
            companyField.text = ""
            jobTitleField.text = ""
            addressField.text = ""
            notesField.text = ""
            favoriteSwitch.checked = false
            selectedTags = []
        }
        contentFlickable.contentY = 0
        if (!isViewMode) {
            firstNameField.forceActiveFocus()
        }
    }

    onAccepted: {
        if (firstNameField.text.trim() !== "" || lastNameField.text.trim() !== "") {
            if (isAddMode) {
                root.contactAdded(
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
            } else if (isEditMode) {
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
                        text: {
                            if (root.isAddMode) return "Add New Contact"
                            if (root.isEditMode) return "Edit Contact"
                            return "Contact Details"
                        }
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: "#111827"
                    }

                    Text {
                        text: {
                            if (root.isAddMode) return "Fill in the details below to create a new contact"
                            if (root.isEditMode) return "Update the contact information below"
                            return "View contact information"
                        }
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
                        text: "✕"
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
                            text: "👤"
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
                            readOnly: root.isReadOnly

                            background: Rectangle {
                                color: root.isReadOnly ? "#F9FAFB" : (firstNameField.activeFocus ? "#FFFFFF" : "#F9FAFB")
                                border.color: root.isReadOnly ? "#E5E7EB" : (firstNameField.activeFocus ? "#3B82F6" : "#E5E7EB")
                                border.width: firstNameField.activeFocus && !root.isReadOnly ? 2 : 1
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
                            readOnly: root.isReadOnly

                            background: Rectangle {
                                color: root.isReadOnly ? "#F9FAFB" : (lastNameField.activeFocus ? "#FFFFFF" : "#F9FAFB")
                                border.color: root.isReadOnly ? "#E5E7EB" : (lastNameField.activeFocus ? "#3B82F6" : "#E5E7EB")
                                border.width: lastNameField.activeFocus && !root.isReadOnly ? 2 : 1
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
                            readOnly: root.isReadOnly

                            background: Rectangle {
                                color: root.isReadOnly ? "#F9FAFB" : (emailField.activeFocus ? "#FFFFFF" : "#F9FAFB")
                                border.color: root.isReadOnly ? "#E5E7EB" : (emailField.activeFocus ? "#3B82F6" : "#E5E7EB")
                                border.width: emailField.activeFocus && !root.isReadOnly ? 2 : 1
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
                            readOnly: root.isReadOnly

                            background: Rectangle {
                                color: root.isReadOnly ? "#F9FAFB" : (phoneField.activeFocus ? "#FFFFFF" : "#F9FAFB")
                                border.color: root.isReadOnly ? "#E5E7EB" : (phoneField.activeFocus ? "#3B82F6" : "#E5E7EB")
                                border.width: phoneField.activeFocus && !root.isReadOnly ? 2 : 1
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
                            text: "💼"
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
                            readOnly: root.isReadOnly

                            background: Rectangle {
                                color: root.isReadOnly ? "#F9FAFB" : (companyField.activeFocus ? "#FFFFFF" : "#F9FAFB")
                                border.color: root.isReadOnly ? "#E5E7EB" : (companyField.activeFocus ? "#3B82F6" : "#E5E7EB")
                                border.width: companyField.activeFocus && !root.isReadOnly ? 2 : 1
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
                            readOnly: root.isReadOnly

                            background: Rectangle {
                                color: root.isReadOnly ? "#F9FAFB" : (jobTitleField.activeFocus ? "#FFFFFF" : "#F9FAFB")
                                border.color: root.isReadOnly ? "#E5E7EB" : (jobTitleField.activeFocus ? "#3B82F6" : "#E5E7EB")
                                border.width: jobTitleField.activeFocus && !root.isReadOnly ? 2 : 1
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
                            text: "📍"
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
                    readOnly: root.isReadOnly

                    background: Rectangle {
                        color: root.isReadOnly ? "#F9FAFB" : (addressField.activeFocus ? "#FFFFFF" : "#F9FAFB")
                        border.color: root.isReadOnly ? "#E5E7EB" : (addressField.activeFocus ? "#3B82F6" : "#E5E7EB")
                        border.width: addressField.activeFocus && !root.isReadOnly ? 2 : 1
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
                            text: "📝"
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
                    readOnly: root.isReadOnly

                    background: Rectangle {
                        color: root.isReadOnly ? "#F9FAFB" : (notesField.activeFocus ? "#FFFFFF" : "#F9FAFB")
                        border.color: root.isReadOnly ? "#E5E7EB" : (notesField.activeFocus ? "#3B82F6" : "#E5E7EB")
                        border.width: notesField.activeFocus && !root.isReadOnly ? 2 : 1
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
                        text: "★"
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
                        enabled: !root.isReadOnly

                        indicator: Rectangle {
                            implicitWidth: 48
                            implicitHeight: 26
                            radius: 13
                            color: favoriteSwitch.checked ? "#F59E0B" : "#E5E7EB"
                            opacity: favoriteSwitch.enabled ? 1.0 : 0.5

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
                            text: "🏷️"
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
                                enabled: !root.isReadOnly
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
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

                // Required fields hint (hide in view mode)
                Text {
                    visible: !root.isViewMode
                    text: "* First or Last name required"
                    font.pixelSize: 12
                    color: "#9CA3AF"
                }

                Item { Layout.fillWidth: true }

                // Cancel/Close button
                Rectangle {
                    visible: !root.isViewMode
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

                // Primary action button (Add/Save/Close)
                Rectangle {
                    width: actionText.width + 40
                    height: 44
                    radius: 10
                    color: {
                        if (root.isViewMode) {
                            return actionMouseArea.pressed ? "#E5E7EB" : actionMouseArea.containsMouse ? "#F3F4F6" : "#FFFFFF"
                        }
                        return actionMouseArea.pressed ? "#1D4ED8" : actionMouseArea.containsMouse ? "#2563EB" : "#3B82F6"
                    }
                    border.color: root.isViewMode ? "#E5E7EB" : "transparent"
                    border.width: root.isViewMode ? 1 : 0

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        id: actionText
                        anchors.centerIn: parent
                        text: {
                            if (root.isViewMode) return "Close"
                            if (root.isEditMode) return "Save Changes"
                            return "Add Contact"
                        }
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: root.isViewMode ? "#374151" : "#FFFFFF"
                    }

                    MouseArea {
                        id: actionMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.isViewMode) {
                                root.reject()
                            } else {
                                root.accept()
                            }
                        }
                    }
                }
            }
        }
    }
}
