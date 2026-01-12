import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ContactManagerApp

/**
 * ContactFormDialog - Dialog for adding or editing contacts
 *
 * Provides a comprehensive form with validation for all contact fields.
 */
Dialog {
    id: root

    // Properties
    property int contactIndex: -1  // -1 for new contact
    property bool isEditMode: contactIndex >= 0

    // Contact data properties
    property string firstName: ""
    property string lastName: ""
    property string email: ""
    property string phone: ""
    property string company: ""
    property string jobTitle: ""
    property string address: ""
    property string notes: ""
    property var tags: []
    property bool favorite: false

    title: isEditMode ? "Edit Contact" : "New Contact"
    modal: true
    width: Math.min(600, parent.width - 2 * 24)
    height: Math.min(700, parent.height - 2 * 24)

    anchors.centerIn: Overlay.overlay

    standardButtons: Dialog.Save | Dialog.Cancel

    onAboutToShow: {
        if (isEditMode && contactIndex >= 0) {
            loadContactData()
        }
    }

    contentItem: Flickable {
        contentHeight: formColumn.implicitHeight
        clip: true

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        ColumnLayout {
            id: formColumn
            width: parent.width
            spacing: 24

            // Name section
            GroupBox {
                Layout.fillWidth: true
                title: "Name"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 16

                    TextField {
                        id: firstNameField
                        Layout.fillWidth: true
                        placeholderText: "First Name *"
                        text: root.firstName
                        font.pixelSize: 14
                    }

                    TextField {
                        id: lastNameField
                        Layout.fillWidth: true
                        placeholderText: "Last Name *"
                        text: root.lastName
                        font.pixelSize: 14
                    }
                }
            }

            // Contact info section
            GroupBox {
                Layout.fillWidth: true
                title: "Contact Information"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 16

                    TextField {
                        id: emailField
                        Layout.fillWidth: true
                        placeholderText: "Email"
                        text: root.email
                        font.pixelSize: 14
                        inputMethodHints: Qt.ImhEmailCharactersOnly
                    }

                    TextField {
                        id: phoneField
                        Layout.fillWidth: true
                        placeholderText: "Phone"
                        text: root.phone
                        font.pixelSize: 14
                        inputMethodHints: Qt.ImhDialableCharactersOnly
                    }
                }
            }

            // Work info section
            GroupBox {
                Layout.fillWidth: true
                title: "Work Information"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 16

                    TextField {
                        id: companyField
                        Layout.fillWidth: true
                        placeholderText: "Company"
                        text: root.company
                        font.pixelSize: 14
                    }

                    TextField {
                        id: jobTitleField
                        Layout.fillWidth: true
                        placeholderText: "Job Title"
                        text: root.jobTitle
                        font.pixelSize: 14
                    }
                }
            }

            // Address section
            GroupBox {
                Layout.fillWidth: true
                title: "Address"

                TextField {
                    id: addressField
                    anchors.fill: parent
                    placeholderText: "Full Address"
                    text: root.address
                    font.pixelSize: 14
                }
            }

            // Notes section
            GroupBox {
                Layout.fillWidth: true
                title: "Notes"

                TextArea {
                    id: notesField
                    anchors.fill: parent
                    placeholderText: "Additional notes..."
                    text: root.notes
                    font.pixelSize: 14
                    wrapMode: TextArea.Wrap
                }
            }

            // Tags section
            GroupBox {
                Layout.fillWidth: true
                title: "Tags"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12

                    // Tag input field
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        TextField {
                            id: tagInputField
                            Layout.fillWidth: true
                            placeholderText: "Add a tag (e.g., family, work, client)..."
                            font.pixelSize: 14

                            Keys.onReturnPressed: {
                                if (tagInputField.text.trim() !== "") {
                                    addTag(tagInputField.text.trim())
                                    tagInputField.text = ""
                                }
                            }
                        }

                        Button {
                            text: "Add"
                            enabled: tagInputField.text.trim() !== ""
                            onClicked: {
                                if (tagInputField.text.trim() !== "") {
                                    addTag(tagInputField.text.trim())
                                    tagInputField.text = ""
                                }
                            }
                        }
                    }

                    // Display current tags as chips
                    Flow {
                        Layout.fillWidth: true
                        spacing: 8

                        Repeater {
                            model: root.tags

                            Rectangle {
                                height: 32
                                width: tagRow.implicitWidth + 20
                                radius: 16
                                color: "#EFF6FF"
                                border.color: "#3B82F6"
                                border.width: 1

                                RowLayout {
                                    id: tagRow
                                    anchors.centerIn: parent
                                    spacing: 8

                                    Text {
                                        text: modelData
                                        font.pixelSize: 14
                                        color: "#111827"
                                    }

                                    Text {
                                        text: "×"
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#6B7280"

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                removeTag(index)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Suggested tags
                    Text {
                        text: "Suggested: family, friends, work, colleague, client, vendor, partner, prospect, alumni, lead"
                        font.pixelSize: 12
                        color: "#6B7280"
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                }
            }

            // Favorite toggle
            CheckBox {
                id: favoriteCheckBox
                text: "Mark as Favorite ⭐"
                checked: root.favorite
                font.pixelSize: 14
            }
        }
    }

    onAccepted: {
        if (validate()) {
            saveContact()
        }
    }

    function validate() {
        if (firstNameField.text.trim() === "" || lastNameField.text.trim() === "") {
            return false
        }
        return true
    }

    function addTag(tag) {
        // Convert to lowercase for consistency
        const normalizedTag = tag.toLowerCase()

        // Check if tag already exists
        if (root.tags.indexOf(normalizedTag) === -1) {
            root.tags = root.tags.concat([normalizedTag])
        }
    }

    function removeTag(index) {
        let newTags = []
        for (let i = 0; i < root.tags.length; i++) {
            if (i !== index) {
                newTags.push(root.tags[i])
            }
        }
        root.tags = newTags
    }

    function loadContactData() {
        const contact = contactManager.proxyModel.getContact(contactIndex)
        firstNameField.text = contact.firstName
        lastNameField.text = contact.lastName
        emailField.text = contact.email
        phoneField.text = contact.phone
        companyField.text = contact.company
        jobTitleField.text = contact.jobTitle
        addressField.text = contact.address
        notesField.text = contact.notes
        favoriteCheckBox.checked = contact.isFavorite
        root.tags = contact.tags || []
    }

    function saveContact() {
        if (isEditMode) {
            contactManager.updateContact(
                contactIndex,
                firstNameField.text.trim(),
                lastNameField.text.trim(),
                emailField.text.trim(),
                phoneField.text.trim(),
                companyField.text.trim(),
                jobTitleField.text.trim(),
                addressField.text.trim(),
                notesField.text.trim(),
                root.tags,
                favoriteCheckBox.checked
            )
        } else {
            contactManager.addContact(
                firstNameField.text.trim(),
                lastNameField.text.trim(),
                emailField.text.trim(),
                phoneField.text.trim()
            )

            // Update additional fields
            const newIndex = contactManager.totalContacts - 1
            contactManager.updateContact(
                newIndex,
                firstNameField.text.trim(),
                lastNameField.text.trim(),
                emailField.text.trim(),
                phoneField.text.trim(),
                companyField.text.trim(),
                jobTitleField.text.trim(),
                addressField.text.trim(),
                notesField.text.trim(),
                root.tags,
                favoriteCheckBox.checked
            )
        }
    }
}
