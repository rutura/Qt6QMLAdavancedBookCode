import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root

    signal contactSelected(int index)
    signal addContactRequested()

    background: Rectangle {
        color: "#F9FAFB"
    }

    // Dummy contacts data
    ListModel {
         id: contactsModel

         Component.onCompleted: {
             const contacts = [
                 {
                     firstName: "Emily",
                     lastName: "Adams",
                     email: "emily.adams@example.com",
                     phone: "+1 (555) 100-1000",
                     company: "Tech Corp",
                     jobTitle: "Software Engineer",
                     avatarColor: "#16A34A",
                     isFavorite: true,
                     tags: ["client", "alumni"]
                 },
                 {
                     firstName: "Evelyn",
                     lastName: "Clark",
                     email: "evelyn.clark@example.com",
                     phone: "+1 (555) 101-1010",
                     company: "Innovation Labs",
                     jobTitle: "Designer",
                     avatarColor: "#0EA5E9",
                     isFavorite: true,
                     tags: ["alumni", "lead"]
                 },
                 {
                     firstName: "Evelyn",
                     lastName: "Nguyen",
                     email: "evelyn.nguyen@example.com",
                     phone: "+1 (555) 102-1020",
                     company: "Creative Solutions",
                     jobTitle: "Product Manager",
                     avatarColor: "#8B5CF6",
                     isFavorite: true,
                     tags: ["lead", "friends"]
                 },
                 {
                     firstName: "Ethan",
                     lastName: "Parker",
                     email: "ethan.parker@example.com",
                     phone: "+1 (555) 103-1030",
                     company: "Tech Corp",
                     jobTitle: "Sales Director",
                     avatarColor: "#0D9488",
                     isFavorite: true,
                     tags: ["friends", "vendor"]
                 },
                 {
                     firstName: "Penelope",
                     lastName: "Johnson",
                     email: "penelope.johnson@example.com",
                     phone: "+1 (555) 104-1040",
                     company: "Innovation Labs",
                     jobTitle: "Software Engineer",
                     avatarColor: "#EC4899",
                     isFavorite: true,
                     tags: ["vendor", "prospect"]
                 },
                 {
                     firstName: "Avery",
                     lastName: "Nguyen",
                     email: "avery.nguyen@example.com",
                     phone: "+1 (555) 105-1050",
                     company: "Creative Solutions",
                     jobTitle: "Designer",
                     avatarColor: "#6366F1",
                     isFavorite: true,
                     tags: ["prospect", "partner"]
                 },
                 {
                     firstName: "Hannah",
                     lastName: "Moore",
                     email: "hannah.moore@example.com",
                     phone: "+1 (555) 106-1060",
                     company: "Tech Corp",
                     jobTitle: "Product Manager",
                     avatarColor: "#F59E0B",
                     isFavorite: false,
                     tags: ["partner", "work"]
                 },
                 {
                     firstName: "Isabella",
                     lastName: "Garcia",
                     email: "isabella.garcia@example.com",
                     phone: "+1 (555) 107-1070",
                     company: "Innovation Labs",
                     jobTitle: "Sales Director",
                     avatarColor: "#EF4444",
                     isFavorite: false,
                     tags: ["work", "family"]
                 },
                 {
                     firstName: "Jacob",
                     lastName: "Rodriguez",
                     email: "jacob.rodriguez@example.com",
                     phone: "+1 (555) 108-1080",
                     company: "Creative Solutions",
                     jobTitle: "Software Engineer",
                     avatarColor: "#06B6D4",
                     isFavorite: false,
                     tags: ["family", "colleague"]
                 },
                 {
                     firstName: "Liam",
                     lastName: "Wilson",
                     email: "liam.wilson@example.com",
                     phone: "+1 (555) 109-1090",
                     company: "Tech Corp",
                     jobTitle: "Designer",
                     avatarColor: "#8B5CF6",
                     isFavorite: false,
                     tags: ["colleague", "client"]
                 }
             ]

             for (let contact of contacts) {
                 append(contact)
             }
         }
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
                 text: contactsModel.count + " contacts"
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

                     model: contactsModel

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
                             contactsModel.setProperty(index, "isFavorite", !model.isFavorite)
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
                     visible: root.selectedTags.length > 0 || contactsModel.count === 0
                     width: 300
                     height: 200

                     ColumnLayout {
                         anchors.centerIn: parent
                         spacing: 16

                         Text {
                             text: "📇"
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
