import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: taskbar
    anchors.left: true
    anchors.right: true
    anchors.bottom: true
    implicitHeight: 58
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        anchors.margins: 8
        radius: 18
        color: "#D91F2023"
        border.color: "#335A5A5A"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 12

            Item { Layout.fillWidth: true }

            Rectangle {
                id: startButton
                Layout.preferredWidth: 42
                Layout.preferredHeight: 42
                radius: 12
                color: "#256EA8FE"

                Text {
                    anchors.centerIn: parent
                    text: "W"
                    color: "white"
                    font.pixelSize: 20
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: launcher.visible = !launcher.visible
                }
            }

            Repeater {
                model: [
                    { label: "Pliki", cmd: "thunar" },
                    { label: "Firefox", cmd: "firefox" },
                    { label: "Poczta", cmd: "thunderbird" },
                    { label: "VLC", cmd: "vlc" },
                    { label: "Lutris", cmd: "lutris" }
                ]

                delegate: Rectangle {
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 42
                    radius: 12
                    color: "#22000000"

                    Text {
                        anchors.centerIn: parent
                        text: modelData.label.substring(0, 1)
                        color: "white"
                        font.pixelSize: 16
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Quickshell.execDetached([modelData.cmd])
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Label {
                Layout.rightMargin: 12
                text: Qt.formatDateTime(new Date(), "dd.MM.yyyy  HH:mm")
                color: "white"
                font.pixelSize: 14
            }
        }
    }

    PopupWindow {
        id: launcher
        visible: false
        width: 720
        height: 520
        anchor.rect.x: (taskbar.width - width) / 2
        anchor.rect.y: taskbar.y - height - 12

        Rectangle {
            anchors.fill: parent
            radius: 24
            color: "#E61C1D20"
            border.color: "#335A5A5A"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                TextField {
                    Layout.fillWidth: true
                    placeholderText: "Szukaj aplikacji, plikow i ustawien"
                }

                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 4
                    rowSpacing: 16
                    columnSpacing: 16

                    Repeater {
                        model: [
                            { name: "Pliki", cmd: "thunar" },
                            { name: "Firefox", cmd: "firefox" },
                            { name: "Poczta", cmd: "thunderbird" },
                            { name: "VLC", cmd: "vlc" },
                            { name: "Notatnik", cmd: "gnome-text-editor" },
                            { name: "Kalkulator", cmd: "gnome-calculator" },
                            { name: "Lutris", cmd: "lutris" },
                            { name: "Ustawienia Qt", cmd: "qt6ct" }
                        ]

                        delegate: Rectangle {
                            Layout.preferredWidth: 150
                            Layout.preferredHeight: 92
                            radius: 16
                            color: "#22000000"

                            Text {
                                anchors.centerIn: parent
                                text: modelData.name
                                color: "white"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    Quickshell.execDetached([modelData.cmd])
                                    launcher.visible = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
