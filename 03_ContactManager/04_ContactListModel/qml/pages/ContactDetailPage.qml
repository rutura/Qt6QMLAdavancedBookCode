import QtQuick
import QtQuick.Controls

/**
 * ContactDetailPage - Page for viewing detailed contact information
 */
Page {
    id: root

    property int contactIndex: -1

    signal backRequested()

    background: Rectangle {
        color: "#F9FAFB"
    }

    ContactDetailView {
        anchors.fill: parent
        contactIndex: root.contactIndex

        onEditRequested: {
            editDialog.contactIndex = root.contactIndex
            editDialog.open()
        }

        onDeleteRequested: {
            deleteDialog.open()
        }

        onCloseRequested: {
            root.backRequested()
        }
    }

    ContactFormDialog {
        id: editDialog
    }

    Dialog {
        id: deleteDialog
        title: "Delete Contact"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: Overlay.overlay

        Label {
            text: "Are you sure you want to delete this contact?"
        }

        onAccepted: {
            contactManager.removeContact(root.contactIndex)
            root.backRequested()
        }
    }
}
