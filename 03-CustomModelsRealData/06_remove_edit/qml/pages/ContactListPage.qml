import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root

    // ContactManager is passed in from Main.qml
    required property ContactManager contactManager

    signal contactSelected(int index)
    signal addContactRequested()
    signal editContactRequested(int index)
    signal deleteContactRequested(int index, string firstName, string lastName, string avatarColor)

    background: Rectangle {
        color: "#F9FAFB"
    }

    // Properties for UI state (filtering/sorting will be implemented later)
     property string searchText: ""
     property bool showFavoritesOnly: false
     property var selectedTags: []
     property string sortOrder: "asc" // "asc" or "desc"

     header: ToolBar {
         height: 80

         background: Rectangle {
             color: "#FFFFFF"

             Rectangle {
                 anchors.bottom: parent.bottom
                 width: parent.width
                 height: 1
                 color: "#E5E7EB"
             }
         }

         RowLayout {
             anchors.fill: parent
             anchors.leftMargin: 24
             anchors.rightMargin: 24
             spacing: 16

             Text {
                 text: "Contacts"
                 font.pixelSize: 28
                 font.weight: Font.Bold
                 color: "#111827"
             }

             Item { Layout.fillWidth: true }

             Text {
                 //text: contactsModel.count + " contacts"
                 text: root.contactManager.contactModel.count + " contacts"

                 font.pixelSize: 14
                 color: "#6B7280"
             }

             Button {
                 text: "+ Add"

                 background: Rectangle {
                     color: parent.pressed ? "#2563EB" : parent.hovered ? "#3B82F6" : "#3B82F6"
                     radius: 10

                     Behavior on color {
                         ColorAnimation { duration: 150 }
                     }
                 }

                 contentItem: Text {
                     text: parent.text
                     font.pixelSize: 14
                     font.weight: Font.Medium
                     color: "#FFFFFF"
                     horizontalAlignment: Text.AlignHCenter
                     verticalAlignment: Text.AlignVCenter
                     leftPadding: 20
                     rightPadding: 20
                     topPadding: 10
                     bottomPadding: 10
                 }

                 onClicked: root.addContactRequested()
             }
         }
     }

     RowLayout {
         anchors.fill: parent
         anchors.margins: 24
         spacing: 24

         // Left sidebar - Filters
         FilterPanel {
             id: filterPanel
             Layout.preferredWidth: 280
             Layout.fillHeight: true

             onFavoritesToggled: (enabled) => {
                 root.showFavoritesOnly = enabled
             }

             onSortChanged: (sortBy, ascending) => {
                 root.sortOrder = ascending ? "asc" : "desc"
             }

             onTagToggled: (tag) => {
                 root.selectedTags = filterPanel.selectedTags
             }
         }


         // Right side - Search and Contact List
         ColumnLayout {
             Layout.fillWidth: true
             Layout.fillHeight: true
             spacing: 16

             // Search bar
             SearchBar {
                 id: searchBar
                 Layout.fillWidth: true
                 onSearchTextChanged: (text) => {
                     root.searchText = text
                 }
             }

             // Contact List will show up here
             // Contact list
             Rectangle {
                 Layout.fillWidth: true
                 Layout.fillHeight: true
                 color: "#FFFFFF"
                 radius: 12

                 ListView {
                     id: contactListView
                     anchors.fill: parent
                     anchors.margins: 8
                     clip: true
                     spacing: 0
                     visible: root.selectedTags.length === 0

                     //model: contactsModel
                     model: root.contactManager.contactModel


                     delegate: ContactDelegate {
                         width: contactListView.width
                         height: 80

                         firstName: model.firstName
                         lastName: model.lastName
                         email: model.email
                         isFavorite: model.isFavorite
                         avatarColor: model.avatarColor
                         tags: model.tags

                         onClicked: root.contactSelected(index)

                         onFavoriteToggled: {
                            //contactsModel.toggleFavorite(index)
                            root.contactManager.toggleFavorite(index)

                         }

                         // Swipe right to edit
                         onEditRequested: {
                             root.editContactRequested(index)
                         }

                         // Swipe left to delete
                         onDeleteRequested: {
                             root.deleteContactRequested(index, model.firstName, model.lastName, model.avatarColor)
                         }

                     }

                     ScrollBar.vertical: ScrollBar {
                         policy: ScrollBar.AsNeeded

                         background: Rectangle {
                             color: "transparent"
                         }

                         contentItem: Rectangle {
                             implicitWidth: 6
                             radius: 3
                             color: parent.pressed ? "#9CA3AF" : "#D1D5DB"

                             Behavior on color {
                                 ColorAnimation { duration: 150 }
                             }
                         }
                     }
                 }

                 // Empty state
                 Item {
                     anchors.centerIn: parent
                     //visible: root.selectedTags.length > 0 || contactsModel.count === 0
                     visible: root.selectedTags.length > 0 || root.contactManager.contactModel.count === 0

                     width: 300
                     height: 200

                     ColumnLayout {
                         anchors.centerIn: parent
                         spacing: 16

                         Text {
                             text: "\uD83D\uDCC7"
                             font.pixelSize: 64
                             Layout.alignment: Qt.AlignHCenter
                         }

                         Text {
                             text: "No contacts"
                             font.pixelSize: 20
                             font.weight: Font.DemiBold
                             color: "#111827"
                             Layout.alignment: Qt.AlignHCenter
                         }

                         Text {
                             text: "Add your first contact to get started"
                             font.pixelSize: 14
                             color: "#6B7280"
                             Layout.alignment: Qt.AlignHCenter
                         }
                     }
                 }
             }
         }
     }
}
