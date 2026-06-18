import QtQuick
import QtQuick.Controls
import QmlAdvCore

Window {
    width: 480
    height: 600
    visible: true
    title: "QmlAdvCore — 04: Default Properties"

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacing.medium

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Card with Default Property"
            font.pixelSize: 20
            font.bold: true
            color: Theme.colors.primary
        }

        // Card goes here
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: profileCard.width
            height: profileCard.implicitHeight
            color: Theme.colors.surface
            radius: 12
            border.color: Theme.colors.secondary
            border.width: 1
            Card {
                id: profileCard
                width: 360
                padding: Theme.spacing.medium
                spacing: Theme.spacing.small

                // children go here
                Rectangle {
                    height: 48
                    radius: 6
                    color: Theme.colors.primary
                    Text {
                        anchors.centerIn: parent
                        text: "Profile Header"
                        color: Theme.colors.onPrimary
                        font.pixelSize: 16
                        font.bold: true
                    }
                }

                Rectangle {
                    height: 44
                    radius: 6
                    color: "white"
                    border.color: Theme.colors.secondary
                    border.width: 1
                    Text {
                        anchors { left: parent.left; leftMargin: 12
                                    verticalCenter: parent.verticalCenter }
                        text: "Username field"
                        color: "#CAC4D0"
                        font.pixelSize: 13
                    }
                }

                Rectangle {
                    height: 44
                    radius: 6
                    color: "white"
                    border.color: Theme.colors.secondary
                    border.width: 1
                    Text {
                        anchors { left: parent.left; leftMargin: 12
                                    verticalCenter: parent.verticalCenter }
                        text: "Email field"
                        color: "#CAC4D0"
                        font.pixelSize: 13
                    }
                }

                Rectangle {
                    height: 44
                    radius: 8
                    color: Theme.colors.primary
                    Text {
                        anchors.centerIn: parent
                        text: "Save"
                        font.pixelSize: 14
                        font.bold: true
                        color: Theme.colors.onPrimary
                    }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Items in card: " + profileCard.contentItems.length
            font.pixelSize: 13
            color: Theme.colors.secondary
        }


    }
}