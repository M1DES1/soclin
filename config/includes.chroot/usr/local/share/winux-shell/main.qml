import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

ShellRoot {
    PanelWindow {
        id: taskbar
        anchors.left: true
        anchors.right: true
        anchors.bottom: true
        implicitHeight: 58
        color: "transparent"

        // ── Live clock timer ─────────────────────────────
        Timer {
            id: clockTimer
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockLabel.text = Qt.formatDateTime(new Date(), "dd.MM.yyyy  HH:mm")
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6
            radius: 16
            color: "#D91F2023"
            border.width: 1
            border.color: "#335A5A5A"

            // Subtle gradient overlay
            Rectangle {
                anchors.fill: parent
                radius: 16
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#08FFFFFF" }
                    GradientStop { position: 1.0; color: "#00000000" }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 4

                // ── Left spacer ──────────────────────────
                Item { Layout.fillWidth: true }

                // ── Start button ─────────────────────────
                Rectangle {
                    id: startButton
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    radius: 10
                    color: startMouse.containsMouse ? "#406EA8FE" : "#256EA8FE"
                    scale: startMouse.pressed ? 0.92 : 1.0

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    // Windows logo approximation
                    Grid {
                        anchors.centerIn: parent
                        columns: 2
                        spacing: 2
                        Repeater {
                            model: 4
                            Rectangle {
                                width: 9; height: 9
                                radius: 1.5
                                color: "white"
                            }
                        }
                    }

                    MouseArea {
                        id: startMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: launcher.visible = !launcher.visible
                    }
                }

                // ── Pinned apps ──────────────────────────
                Repeater {
                    model: [
                        { label: "Pliki", icon: "📁", cmd: "thunar" },
                        { label: "Firefox", icon: "🌐", cmd: "firefox" },
                        { label: "Poczta", icon: "✉", cmd: "thunderbird" },
                        { label: "VLC", icon: "▶", cmd: "vlc" },
                        { label: "Lutris", icon: "🎮", cmd: "lutris" },
                        { label: "Notatnik", icon: "📝", cmd: "gnome-text-editor" }
                    ]

                    delegate: Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        radius: 10
                        color: pinMouse.containsMouse ? "#33FFFFFF" : "#18FFFFFF"
                        scale: pinMouse.pressed ? 0.92 : 1.0

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.pixelSize: 20
                        }

                        ToolTip {
                            visible: pinMouse.containsMouse
                            text: modelData.label
                            delay: 600
                        }

                        MouseArea {
                            id: pinMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Quickshell.execDetached([modelData.cmd])
                        }
                    }
                }

                // ── Right spacer ─────────────────────────
                Item { Layout.fillWidth: true }

                // ── System tray area ─────────────────────
                Row {
                    Layout.rightMargin: 4
                    spacing: 8

                    // Network indicator
                    Text {
                        text: "🌐"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Quickshell.execDetached(["nm-connection-editor"])
                        }
                    }

                    // Volume indicator
                    Text {
                        text: "🔊"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Quickshell.execDetached(["pavucontrol"])
                        }
                    }

                    // Separator
                    Rectangle {
                        width: 1
                        height: 24
                        color: "#33FFFFFF"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Clock
                    Label {
                        id: clockLabel
                        text: Qt.formatDateTime(new Date(), "dd.MM.yyyy  HH:mm")
                        color: "#EEFFFFFF"
                        font.pixelSize: 13
                        font.family: "Inter"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // ── Start Menu ───────────────────────────────────
        PopupWindow {
            id: launcher
            visible: false
            width: 680
            height: 560
            anchor.rect.x: (taskbar.width - width) / 2
            anchor.rect.y: taskbar.y - height - 14

            Rectangle {
                anchors.fill: parent
                radius: 20
                color: "#EE1C1D20"
                border.width: 1
                border.color: "#335A5A5A"

                // Glass gradient
                Rectangle {
                    anchors.fill: parent
                    radius: 20
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#0AFFFFFF" }
                        GradientStop { position: 0.5; color: "#00000000" }
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 20

                    // ── Search bar ────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42
                        radius: 21
                        color: "#22FFFFFF"
                        border.width: 1
                        border.color: "#22FFFFFF"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 8

                            Text {
                                text: "🔍"
                                font.pixelSize: 14
                            }

                            TextField {
                                id: searchField
                                Layout.fillWidth: true
                                background: Item {}
                                color: "white"
                                placeholderText: "Szukaj aplikacji, plików i ustawień"
                                placeholderTextColor: "#88FFFFFF"
                                font.pixelSize: 13
                                font.family: "Inter"
                            }
                        }
                    }

                    // ── Section header ────────────────────
                    Label {
                        text: "Przypięte"
                        color: "#CCFFFFFF"
                        font.pixelSize: 13
                        font.family: "Inter"
                        font.bold: true
                    }

                    // ── App grid ──────────────────────────
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 5
                        rowSpacing: 12
                        columnSpacing: 12

                        Repeater {
                            model: [
                                { name: "Pliki", icon: "📁", cmd: "thunar" },
                                { name: "Firefox", icon: "🌐", cmd: "firefox" },
                                { name: "Poczta", icon: "✉", cmd: "thunderbird" },
                                { name: "VLC", icon: "▶", cmd: "vlc" },
                                { name: "Notatnik", icon: "📝", cmd: "gnome-text-editor" },
                                { name: "Kalkulator", icon: "🔢", cmd: "gnome-calculator" },
                                { name: "Lutris", icon: "🎮", cmd: "lutris" },
                                { name: "Ustawienia Qt", icon: "⚙", cmd: "qt6ct" },
                                { name: "Głośność", icon: "🔊", cmd: "pavucontrol" },
                                { name: "Dyski", icon: "💽", cmd: "gnome-disks" }
                            ]

                            delegate: Rectangle {
                                Layout.preferredWidth: 115
                                Layout.preferredHeight: 88
                                radius: 12
                                color: appMouse.containsMouse ? "#28FFFFFF" : "#12FFFFFF"

                                Behavior on color { ColorAnimation { duration: 150 } }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 6

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.icon
                                        font.pixelSize: 28
                                    }

                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.name
                                        color: "#DDFFFFFF"
                                        font.pixelSize: 11
                                        font.family: "Inter"
                                    }
                                }

                                MouseArea {
                                    id: appMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        Quickshell.execDetached([modelData.cmd])
                                        launcher.visible = false
                                    }
                                }
                            }
                        }
                    }

                    // ── Bottom bar: user + power ─────────
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: "#22FFFFFF"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        // User label
                        Label {
                            text: "👤 winux"
                            color: "#CCFFFFFF"
                            font.pixelSize: 13
                            font.family: "Inter"
                        }

                        Item { Layout.fillWidth: true }

                        // Power button
                        Rectangle {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            radius: 18
                            color: powerMouse.containsMouse ? "#44FF5555" : "#22FFFFFF"

                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: "⏻"
                                color: "white"
                                font.pixelSize: 16
                            }

                            MouseArea {
                                id: powerMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: powerMenu.visible = !powerMenu.visible
                            }
                        }
                    }
                }
            }
        }

        // ── Power menu popup ─────────────────────────────
        PopupWindow {
            id: powerMenu
            visible: false
            width: 200
            height: 140
            anchor.rect.x: (taskbar.width + 100)
            anchor.rect.y: taskbar.y - 200

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: "#EE1C1D20"
                border.width: 1
                border.color: "#335A5A5A"

                Column {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Repeater {
                        model: [
                            { label: "🔄  Uruchom ponownie", cmd: "systemctl reboot" },
                            { label: "⏻  Wyłącz", cmd: "systemctl poweroff" },
                            { label: "🔒  Zablokuj", cmd: "swaylock -f -c 000000" }
                        ]

                        delegate: Rectangle {
                            width: parent.width
                            height: 38
                            radius: 8
                            color: pwrMouse.containsMouse ? "#28FFFFFF" : "transparent"

                            Behavior on color { ColorAnimation { duration: 150 } }

                            Label {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                text: modelData.label
                                color: "#EEFFFFFF"
                                font.pixelSize: 13
                                font.family: "Inter"
                            }

                            MouseArea {
                                id: pwrMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    powerMenu.visible = false
                                    launcher.visible = false
                                    Quickshell.execDetached(["bash", "-c", modelData.cmd])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
