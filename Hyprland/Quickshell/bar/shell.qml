import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "."

ShellRoot {
    id: root

    // Dynamic display role assignment
    // Primary = DP-3 if connected, otherwise first available screen
    // Secondary = eDP-1 only when multiple screens exist, otherwise null (treated as primary)
    readonly property var primaryDisplay: Quickshell.screens.find(s => s.name === "DP-3") ?? Quickshell.screens[0]
    readonly property var secondaryDisplay: Quickshell.screens.length > 1
                                            ? Quickshell.screens.find(s => s.name === "eDP-1")
                                            : null

    // Global styling
    readonly property int basePadding: 4      // Base text offset and background spacing
    readonly property int accentPadding: 6    // Active workspace stickout
    readonly property int cornerRadius: 8
    readonly property color panelColor: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.7)

    // =========================================================================
    // Workspace Islands - One per monitor, right edge
    // =========================================================================
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: workspacePanel

            property var modelData

            // Attach to correct screen
            screen: modelData

            // Check if this is the secondary (side) display
            // Only true when there's an external monitor AND this is the internal display
            property bool isSideMonitor: root.secondaryDisplay !== null
                                         && modelData.name === root.secondaryDisplay.name

            // Floating island style
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "quickshell-bar"
            exclusionMode: ExclusionMode.Ignore

            // Position: flush against screen edge
            anchors {
                right: !isSideMonitor
                left: isSideMonitor
                top: false
                bottom: false
            }

            property int baseWidth: 18
            property int activeWidth: baseWidth + root.accentPadding - root.basePadding
            property int itemHeight: 14
            property int activeItemHeight: 26

            implicitWidth: activeWidth
            implicitHeight: workspaceColumn.implicitHeight + (root.basePadding * 2)

            color: "transparent"

            // Get sorted workspaces for this monitor
            property var monitorWorkspaces: Hyprland.workspaces.values.filter(ws =>
                ws.monitor?.name === modelData.name
            ).sort((a, b) => a.id - b.id)
            property bool firstIsActive: monitorWorkspaces.length > 0 &&
                Hyprland.focusedWorkspace?.id === monitorWorkspaces[0]?.id
            property bool lastIsActive: monitorWorkspaces.length > 0 &&
                Hyprland.focusedWorkspace?.id === monitorWorkspaces[monitorWorkspaces.length - 1]?.id
            property int heightDiff: (activeItemHeight - itemHeight) / 2

            // Thin base rectangle (full height) - for inactive workspaces
            Rectangle {
                id: baseBg
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: workspacePanel.firstIsActive ? workspacePanel.heightDiff : 0
                anchors.bottomMargin: workspacePanel.lastIsActive ? workspacePanel.heightDiff : 0
                anchors.right: workspacePanel.isSideMonitor ? undefined : parent.right
                anchors.left: workspacePanel.isSideMonitor ? parent.left : undefined
                width: workspacePanel.baseWidth
                color: root.panelColor

                Behavior on anchors.topMargin { NumberAnimation { duration: 100 } }
                Behavior on anchors.bottomMargin { NumberAnimation { duration: 100 } }

                topLeftRadius: workspacePanel.isSideMonitor ? 0 : root.cornerRadius
                bottomLeftRadius: workspacePanel.isSideMonitor ? 0 : root.cornerRadius
                topRightRadius: workspacePanel.isSideMonitor ? root.cornerRadius : 0
                bottomRightRadius: workspacePanel.isSideMonitor ? root.cornerRadius : 0
            }

            // Workspace buttons
            ColumnLayout {
                id: workspaceColumn
                anchors.right: workspacePanel.isSideMonitor ? undefined : parent.right
                anchors.left: workspacePanel.isSideMonitor ? parent.left : undefined
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Repeater {
                    model: Hyprland.workspaces.values.filter(ws =>
                        ws.monitor?.name === modelData.name
                    ).sort((a, b) => a.id - b.id)

                    Item {
                        id: wsItem
                        required property var modelData

                        property int wsId: modelData.id
                        property bool isActive: Hyprland.focusedWorkspace?.id === wsId

                        Layout.preferredWidth: workspacePanel.activeWidth
                        Layout.preferredHeight: isActive ? workspacePanel.activeItemHeight : workspacePanel.itemHeight

                        Behavior on Layout.preferredHeight { NumberAnimation { duration: 100 } }

                        // Active workspace background (wider, sticks out)
                        Rectangle {
                            visible: wsItem.isActive
                            anchors.right: workspacePanel.isSideMonitor ? undefined : parent.right
                            anchors.left: workspacePanel.isSideMonitor ? parent.left : undefined
                            anchors.verticalCenter: parent.verticalCenter
                            width: workspacePanel.activeWidth
                            height: workspacePanel.activeItemHeight
                            radius: root.cornerRadius
                            color: root.panelColor

                            // Flat edge on screen side
                            topLeftRadius: workspacePanel.isSideMonitor ? 0 : root.cornerRadius
                            bottomLeftRadius: workspacePanel.isSideMonitor ? 0 : root.cornerRadius
                            topRightRadius: workspacePanel.isSideMonitor ? root.cornerRadius : 0
                            bottomRightRadius: workspacePanel.isSideMonitor ? root.cornerRadius : 0
                        }

                        // KiCad logo for workspaces in 100 range
                        Image {
                            visible: wsItem.wsId >= 100 && wsItem.wsId < 200
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: workspacePanel.isSideMonitor ? undefined : parent.right
                            anchors.left: workspacePanel.isSideMonitor ? parent.left : undefined
                            anchors.rightMargin: workspacePanel.isSideMonitor ? 0 : (wsItem.isActive ? root.accentPadding : root.basePadding)
                            anchors.leftMargin: workspacePanel.isSideMonitor ? (wsItem.isActive ? root.accentPadding : root.basePadding) : 0
                            source: "kicad.png"
                            width: wsItem.isActive ? 14 : 11
                            height: width
                            fillMode: Image.PreserveAspectFit

                            Behavior on width { NumberAnimation { duration: 100 } }
                            Behavior on anchors.rightMargin { NumberAnimation { duration: 100 } }
                            Behavior on anchors.leftMargin { NumberAnimation { duration: 100 } }
                        }

                        // Number for regular workspaces
                        Text {
                            visible: wsItem.wsId < 100 || wsItem.wsId >= 200
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: workspacePanel.isSideMonitor ? undefined : parent.right
                            anchors.left: workspacePanel.isSideMonitor ? parent.left : undefined
                            anchors.rightMargin: workspacePanel.isSideMonitor ? 0 : (wsItem.isActive ? root.accentPadding : root.basePadding)
                            anchors.leftMargin: workspacePanel.isSideMonitor ? (wsItem.isActive ? root.accentPadding : root.basePadding) : 0
                            text: wsItem.wsId
                            color: wsItem.isActive ? Theme.blue : Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: wsItem.isActive ? 14 : 11
                            font.bold: wsItem.isActive

                            Behavior on font.pixelSize { NumberAnimation { duration: 100 } }
                            Behavior on anchors.rightMargin { NumberAnimation { duration: 100 } }
                            Behavior on anchors.leftMargin { NumberAnimation { duration: 100 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Hyprland.dispatch("workspace " + wsItem.wsId)
                        }
                    }
                }
            }
        }
    }

    // =========================================================================
    // Clock Island - Left edge of main monitor only
    // =========================================================================
    PanelWindow {
        id: clockPanel

        // Only show on primary display
        screen: root.primaryDisplay

        // Floating island style
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell-bar"
        exclusionMode: ExclusionMode.Ignore

        // Position: flush against left edge
        anchors {
            left: true
            top: false
            bottom: false
        }

        // Size
        implicitWidth: clockColumn.implicitWidth + (root.basePadding * 2)
        implicitHeight: clockBg.implicitHeight

        color: "transparent"

        // Background with rounded corners on right side only
        Rectangle {
            id: clockBg
            anchors.fill: parent
            color: root.panelColor
            implicitHeight: clockColumn.implicitHeight + (root.basePadding * 2)

            topLeftRadius: 0
            bottomLeftRadius: 0
            topRightRadius: root.cornerRadius
            bottomRightRadius: root.cornerRadius

            // Clock display
            ColumnLayout {
                id: clockColumn
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: root.basePadding
                spacing: 0

                // Hours
                Text {
                    text: Qt.formatDateTime(new Date(), "HH")
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                }

                // Minutes
                Text {
                    text: Qt.formatDateTime(new Date(), "mm")
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                }
            }

            // Update clock every second
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    clockColumn.children[0].text = Qt.formatDateTime(new Date(), "HH")
                    clockColumn.children[1].text = Qt.formatDateTime(new Date(), "mm")
                }
            }
        }
    }
}
