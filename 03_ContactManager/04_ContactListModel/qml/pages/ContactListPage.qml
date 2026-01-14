import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

/**
 * ContactListPage - Main page showing the list of contacts
 *
 * Includes search, filtering, and the contact list with all interactions.
 */
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
            // Generate diverse dummy contacts
            const firstNames = ["Emily", "Evelyn", "Evelyn", "Ethan", "Penelope", "Avery", "Hannah", "Isabella", "Jacob", "Liam",
                              "Mia", "Noah", "Olivia", "Lucas", "Ava", "Mason", "Sophia", "Elijah", "Charlotte", "James",
                              "Amelia", "Benjamin", "Harper", "William", "Ella", "Michael", "Abigail", "Alexander", "Emily", "Daniel",
                              "Madison", "Henry", "Scarlett", "Matthew", "Grace", "David", "Chloe", "Joseph", "Victoria", "Samuel",
                              "Lily", "Jackson", "Aria", "Sebastian", "Zoe", "Jack"]
            
            const lastNames = ["Adams", "Clark", "Nguyen", "Parker", "Johnson", "Nguyen", "Moore", "Garcia", "Rodriguez", "Wilson",
                             "Martinez", "Anderson", "Taylor", "Thomas", "Hernandez", "Moore", "Martin", "Jackson", "Thompson", "White",
                             "Lopez", "Lee", "Gonzalez", "Harris", "Young", "King", "Wright", "Scott", "Green", "Baker",
                             "Adams", "Nelson", "Carter", "Mitchell", "Perez", "Roberts", "Turner", "Phillips", "Campbell", "Parker",
                             "Evans", "Edwards", "Collins", "Stewart", "Morris", "Rogers"]
            
            const avatarColors = ["#16A34A", "#0EA5E9", "#8B5CF6", "#0D9488", "#EC4899", "#6366F1", "#F59E0B", "#EF4444", 
                                 "#06B6D4", "#8B5CF6", "#10B981", "#F59E0B", "#6366F1", "#EC4899", "#14B8A6"]
            
            const tags = ["client", "alumni", "lead", "friends", "vendor", "prospect", "partner", "work", "family", "colleague"]
            
            for (let i = 0; i < 45; i++) {
                const firstName = firstNames[i % firstNames.length]
                const lastName = lastNames[i % lastNames.length]
                const isFavorite = i < 6
                
                append({
                    firstName: firstName,
                    lastName: lastName,
                    email: firstName.toLowerCase() + "." + lastName.toLowerCase() + "@example.com",
                    phone: "+1 (555) " + (100 + i).toString().padStart(3, '0') + "-" + (1000 + i * 10).toString().padStart(4, '0'),
                    company: i % 3 === 0 ? "Tech Corp" : i % 3 === 1 ? "Innovation Labs" : "Creative Solutions",
                    jobTitle: i % 4 === 0 ? "Software Engineer" : i % 4 === 1 ? "Designer" : i % 4 === 2 ? "Product Manager" : "Sales Director",
                    avatarColor: avatarColors[i % avatarColors.length],
                    isFavorite: isFavorite,
                    tags: [tags[i % tags.length], tags[(i + 1) % tags.length]]
                })
            }
        }
    }
    
    // Filtered model for search and filters
    property string searchText: ""
    property bool showFavoritesOnly: false
    property var selectedTags: []
    property string sortOrder: "asc" // "asc" or "desc"
    
    function matchesFilters(firstName, lastName, email, isFavorite, contactTags) {
        // Search filter
        if (searchText.length > 0) {
            const search = searchText.toLowerCase()
            const fullName = (firstName + " " + lastName).toLowerCase()
            const emailLower = email.toLowerCase()
            
            if (!fullName.includes(search) && !emailLower.includes(search)) {
                return false
            }
        }
        
        // Favorites filter
        if (showFavoritesOnly && !isFavorite) {
            return false
        }
        
        // Tags filter
        if (selectedTags.length > 0) {
            let hasMatchingTag = false
            for (let tag of selectedTags) {
                if (contactTags) {
                    // Handle both JavaScript arrays and QML ListModel
                    if (Array.isArray(contactTags)) {
                        if (contactTags.indexOf(tag) >= 0) {
                            hasMatchingTag = true
                            break
                        }
                    } else {
                        // contactTags is a ListModel - iterate through it
                        for (let i = 0; i < contactTags.count; i++) {
                            if (contactTags.get(i).modelData === tag) {
                                hasMatchingTag = true
                                break
                            }
                        }
                        if (hasMatchingTag) break
                    }
                }
            }
            if (!hasMatchingTag) {
                return false
            }
        }
        
        return true
    }

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
                text: {
                    let count = 0
                    for (let i = 0; i < contactsModel.count; i++) {
                        let contact = contactsModel.get(i)
                        if (matchesFilters(contact.firstName, contact.lastName, contact.email, 
                                         contact.isFavorite, contact.tags)) {
                            count++
                        }
                    }
                    return count + " contacts"
                }
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

                    model: contactsModel

                    delegate: ContactDelegate {
                        width: contactListView.width
                        
                        firstName: model.firstName
                        lastName: model.lastName
                        email: model.email
                        isFavorite: model.isFavorite
                        avatarColor: model.avatarColor
                        tags: model.tags
                        
                        visible: root.matchesFilters(model.firstName, model.lastName, model.email, model.isFavorite, model.tags)
                        height: visible ? 80 : 0
                        
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

                    // Empty state
                    Item {
                        anchors.centerIn: parent
                        visible: {
                            let hasVisible = false
                            for (let i = 0; i < contactsModel.count; i++) {
                                let contact = contactsModel.get(i)
                                if (root.matchesFilters(contact.firstName, contact.lastName, contact.email,
                                                       contact.isFavorite, contact.tags)) {
                                    hasVisible = true
                                    break
                                }
                            }
                            return !hasVisible
                        }
                        width: 300
                        height: 200
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 16
                            
                            Text {
                                text: "🔍"
                                font.pixelSize: 64
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: root.searchText ? "No matches found" : "No contacts"
                                font.pixelSize: 20
                                font.weight: Font.DemiBold
                                color: "#111827"
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: root.searchText ? "Try a different search term" : "Add your first contact to get started"
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
}
