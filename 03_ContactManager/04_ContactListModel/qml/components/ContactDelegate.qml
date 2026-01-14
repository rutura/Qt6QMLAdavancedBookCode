import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * ContactDelegate - A modern contact list item
 * 
 * Displays contact information with avatar, name, email, and favorite status
 */
ItemDelegate {
    id: root
    
    property string firstName: ""
    property string lastName: ""
    property string email: ""
    property bool isFavorite: false
    property string avatarColor: "#6366F1"
    property var tags: []
    
    signal favoriteToggled()
    
    width: parent.width
    height: 80
    
    background: Rectangle {
        //color: root.hovered ? "#F3F4F6" : "transparent"
        color: root.pressed ? "#E5E7EB" : root.hovered ? "#F3F4F6" : "#FFFFFF"

        
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: "#E5E7EB"
        }
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
    
    contentItem: RowLayout {
        spacing: 16
        
        // Avatar with initials
        Rectangle {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            Layout.alignment: Qt.AlignVCenter
            radius: 24
            color: root.avatarColor
            
            Text {
                anchors.centerIn: parent
                text: {
                    let initials = ""
                    if (root.firstName) initials += root.firstName.charAt(0).toUpperCase()
                    if (root.lastName) initials += root.lastName.charAt(0).toUpperCase()
                    return initials
                }
                font.pixelSize: 18
                font.weight: Font.DemiBold
                color: "#FFFFFF"
            }
        }
        
        // Contact info
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            
            Text {
                text: root.firstName + " " + root.lastName
                font.pixelSize: 15
                font.weight: Font.Medium
                color: "#111827"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            
            Text {
                text: root.email
                font.pixelSize: 13
                color: "#6B7280"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
        
        // Favorite button
        AbstractButton {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignVCenter
            
            onClicked: {
                root.favoriteToggled()
                mouse.accepted = true
            }
            
            MouseArea {
                id: mouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.favoriteToggled()
            }
            
            contentItem: Text {
                text: root.isFavorite ? "★" : "☆"
                font.pixelSize: 24
                color: root.isFavorite ? "#FDB022" : "#D1D5DB"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
            
            scale: hovered ? 1.15 : 1.0
            
            Behavior on scale {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
        }
        
        // Chevron indicator
        Text {
            text: "›"
            font.pixelSize: 24
            color: "#D1D5DB"
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
