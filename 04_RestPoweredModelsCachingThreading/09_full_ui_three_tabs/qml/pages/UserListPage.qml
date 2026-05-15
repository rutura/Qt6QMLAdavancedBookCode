import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import RepoExplorerProApp

Item {
    id: root

    UserListModel {
        id: userModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            TextField {
                id: queryField
                Layout.fillWidth: true
                placeholderText: "Search GitHub users…"
                text: "qt developer"
                onAccepted: searchButton.clicked()
            }

            Button {
                id: searchButton
                text: "Search"
                enabled: !userModel.isLoadingPage && queryField.text.length > 0
                onClicked: userModel.search(queryField.text)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            BusyIndicator {
                running: userModel.isLoadingPage
                visible: running
                implicitWidth: 20
                implicitHeight: 20
            }

            Label {
                text: userModel.count + " of " + userModel.totalCount
                color: "#6B7280"
            }

            Item { Layout.fillWidth: true }
        }

        Label {
            Layout.fillWidth: true
            visible: userModel.errorMessage.length > 0
            text: userModel.errorMessage
            color: "#B91C1C"
            wrapMode: Text.WordWrap
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            clip: true

            model: userModel

            delegate: UserDelegate {
                width: listView.width
                login:     model.login
                avatarUrl: model.avatarUrl
                htmlUrl:   model.htmlUrl
                userType:  model.userType
            }

            footer: Item {
                width: listView.width
                height: userModel.hasMore ? 60 : 0
                visible: userModel.hasMore

                Button {
                    anchors.centerIn: parent
                    text: userModel.isLoadingPage ? "Loading…" : "Load More"
                    enabled: !userModel.isLoadingPage
                    onClicked: userModel.loadMore()
                }
            }
        }
    }
}
