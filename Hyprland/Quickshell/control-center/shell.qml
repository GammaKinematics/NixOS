import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "."

// Tabbed Control Center - Themed via Stylix
ShellRoot {
    id: root

    // =========================================================================
    // APU Tuning - Config & Script Integration
    // =========================================================================
    readonly property string ryzenAdjPath: Quickshell.env("HOME") + "/NixOS/RyzenAdj"
    readonly property string configPath: ryzenAdjPath + "/config.json"
    readonly property string scriptPath: ryzenAdjPath + "/power-tuning.sh"

    // Process to load a single profile from config
    Process {
        id: configLoadProc
        property string buffer: ""
        stdout: SplitParser {
            onRead: data => configLoadProc.buffer += data
        }
        onRunningChanged: {
            if (!running && buffer.length > 0) {
                try {
                    let profile = JSON.parse(buffer)
                    tuningTab.stapmSlider.value = profile.stapm / 1000
                    tuningTab.fastSlider.value = profile.fast / 1000
                    tuningTab.slowSlider.value = profile.slow / 1000
                    tuningTab.tempSlider.value = profile.temp
                } catch (e) {}
                buffer = ""
            }
        }
    }

    // Process to save a single profile to config
    Process { id: configSaveProc }

    // Process to apply power tuning
    Process {
        id: powerTuningProc
        command: [root.scriptPath, "apply"]
    }

    // Get config name from PPD profile enum
    function ppdToName(profile) {
        switch (profile) {
            case PowerProfile.PowerSaver: return "saver"
            case PowerProfile.Performance: return "performance"
            default: return "balanced"
        }
    }

    // Load config when PPD profile changes (including at startup)
    Connections {
        target: PowerProfiles
        function onProfileChanged() {
            loadProfileFromConfig(ppdToName(PowerProfiles.profile))
        }
    }

    // Load a profile from config into sliders
    function loadProfileFromConfig(name) {
        configLoadProc.buffer = ""
        configLoadProc.command = ["jq", "-c", "." + name, root.configPath]
        configLoadProc.running = true
    }

    // Save slider values to config file
    function saveProfileToConfig(name) {
        let profileJson = JSON.stringify({
            stapm: tuningTab.stapmSlider.value * 1000,
            fast: tuningTab.fastSlider.value * 1000,
            slow: tuningTab.slowSlider.value * 1000,
            temp: tuningTab.tempSlider.value
        })
        configSaveProc.command = ["sh", "-c",
            "jq '." + name + " = " + profileJson + "' '" + root.configPath + "' > /tmp/apu-tuning.tmp && mv /tmp/apu-tuning.tmp '" + root.configPath + "'"]
        configSaveProc.running = true
    }

    // Apply ryzenadj for current PPD profile
    function applyProfile() {
        powerTuningProc.running = true
    }

    PanelWindow {
        id: controlCenter

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell:control-center"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        property var targetScreen: Quickshell.screens.find(s => s.name === "DP-3") ?? Quickshell.screens[0]
        screen: targetScreen

        implicitWidth: 380
        implicitHeight: 500

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        margins {
            top: (targetScreen.height - 500) / 2
            bottom: (targetScreen.height - 500) / 2
            left: (targetScreen.width - 380) / 2
            right: (targetScreen.width - 380) / 2
        }

        visible: true
        color: "transparent"

        // Click outside to close
        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }

        // Main panel
        Rectangle {
            id: panel
            anchors.centerIn: parent
            width: 360
            height: 480
            radius: 24
            color: Theme.base
            border.color: Qt.rgba(137/255, 180/255, 250/255, 0.2)
            border.width: 1

            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            focus: true
            Keys.onEscapePressed: Qt.quit()

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                // Tab Bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 12
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 8

                        Repeater {
                            model: [
                                { icon: "󰕾", name: "Sound" },
                                { icon: "󰃟", name: "Brightness" },
                                { icon: "󰖩", name: "WiFi" },
                                { icon: "󰂯", name: "Bluetooth" },
                                { icon: "󰻠", name: "Tuning" }
                            ]

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 10
                                color: tabStack.currentIndex === index ? Theme.surface0 : "transparent"

                                Behavior on color { ColorAnimation { duration: 150 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.icon
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 20
                                    color: tabStack.currentIndex === index ? Theme.blue : Theme.overlay0
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: tabStack.currentIndex = index
                                }
                            }
                        }
                    }
                }

                // Tab Content Area - unified background
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 12
                    color: Theme.surface0

                    StackLayout {
                        id: tabStack
                        anchors.fill: parent
                        anchors.margins: 12
                        currentIndex: 0

                        SoundTab {}
                        BrightnessTab {}
                        WifiTab {}
                        BluetoothTab {}
                        TuningTab { id: tuningTab }
                    }
                }

                // Stats Bar
                Rectangle {
                    id: statsBar
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    radius: 8
                    color: "transparent"

                    property int cpuLoad: 0
                    property int cpuTemp: 0
                    property int gpuLoad: -1
                    property int gpuTemp: -1
                    property real ramUsed: 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12

                        Item { Layout.fillWidth: true }

                        // CPU group
                        Row {
                            spacing: 4
                            Text {
                                text: "󰻠"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                                color: Theme.blue
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: statsBar.cpuLoad + "%"
                                font.pixelSize: 12
                                color: Theme.subtext0
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: statsBar.cpuTemp + "°"
                                font.pixelSize: 12
                                color: Theme.overlay0
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // Separator
                        Rectangle {
                            width: 1
                            height: 18
                            color: Theme.surface1
                        }

                        // GPU group
                        Row {
                            spacing: 4
                            Text {
                                text: "󰢮"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                                color: Theme.green
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: statsBar.gpuLoad >= 0 ? statsBar.gpuLoad + "%" : "-"
                                font.pixelSize: 12
                                color: Theme.subtext0
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: statsBar.gpuTemp >= 0 ? statsBar.gpuTemp + "°" : "-"
                                font.pixelSize: 12
                                color: Theme.overlay0
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // Separator
                        Rectangle {
                            width: 1
                            height: 18
                            color: Theme.surface1
                        }

                        // RAM
                        Row {
                            spacing: 4
                            Text {
                                text: "󰍛"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                                color: Theme.yellow
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: statsBar.ramUsed.toFixed(1) + "G"
                                font.pixelSize: 12
                                color: Theme.subtext0
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // Separator
                        Rectangle {
                            width: 1
                            height: 18
                            color: Theme.surface1
                        }

                        // Battery
                        Row {
                            spacing: 4
                            property var bat: UPower.displayDevice
                            property int pct: bat.percentage * 100
                            property bool charging: bat.state === UPowerDeviceState.Charging

                            Text {
                                text: {
                                    if (parent.charging) return "󰂄"
                                    if (parent.pct >= 90) return "󰁹"
                                    if (parent.pct >= 70) return "󰂀"
                                    if (parent.pct >= 50) return "󰁾"
                                    if (parent.pct >= 30) return "󰁼"
                                    if (parent.pct >= 10) return "󰁻"
                                    return "󰁺"
                                }
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                                color: {
                                    if (parent.charging) return Theme.green
                                    if (parent.pct <= 20) return Theme.red
                                    return Theme.blue
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: parent.pct + "%"
                                font.pixelSize: 12
                                color: Theme.subtext0
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }

                    // Stats update timer
                    Timer {
                        interval: 2000
                        running: true
                        repeat: true
                        triggeredOnStart: true
                        onTriggered: glancesProc.running = true
                    }

                    // All stats from glances in one call
                    Process {
                        id: glancesProc
                        command: ["glances", "--stdout-json", "cpu,mem,sensors,gpu", "-1"]
                        stdout: SplitParser {
                            onRead: data => {
                                // glances outputs complete JSON objects, one per line
                                let lines = data.trim().split('\n')
                                for (let line of lines) {
                                    try {
                                        let stats = JSON.parse(line)

                                        // CPU load
                                        if (stats.cpu && stats.cpu.total !== undefined) {
                                            statsBar.cpuLoad = Math.round(stats.cpu.total)
                                        }

                                        // RAM used (bytes to GB)
                                        if (stats.mem && stats.mem.used !== undefined) {
                                            statsBar.ramUsed = stats.mem.used / 1073741824
                                        }

                                        // Temperatures from sensors
                                        if (stats.sensors) {
                                            for (let s of stats.sensors) {
                                                // CPU temp: look for Tctl (AMD) or coretemp
                                                if (s.label === "Tctl" || s.label.toLowerCase().includes("core")) {
                                                    statsBar.cpuTemp = Math.round(s.value)
                                                }
                                                // GPU temp: look for "edge" (AMD GPU)
                                                if (s.label === "edge") {
                                                    statsBar.gpuTemp = Math.round(s.value)
                                                }
                                            }
                                        }

                                        // GPU load and temp
                                        if (stats.gpu && stats.gpu.length > 0) {
                                            statsBar.gpuLoad = Math.round(stats.gpu[0].proc || 0)
                                            if (stats.gpu[0].temperature) {
                                                statsBar.gpuTemp = Math.round(stats.gpu[0].temperature)
                                            }
                                        }

                                        break // Only need first valid line
                                    } catch (e) {
                                        // Skip malformed lines
                                    }
                                }
                            }
                        }
                    }
                }

                // Power Profile Slider
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: 12
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 8

                        // Power saver icon
                        Text {
                            text: "󰾆"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            color: PowerProfiles.profile === PowerProfile.PowerSaver ? Theme.green : Theme.overlay0
                        }

                        // Clickable profile dots
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 24

                            // Line connecting dots
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width - 20
                                height: 2
                                radius: 1
                                color: Theme.surface1
                            }

                            // Profile dots
                            Row {
                                anchors.centerIn: parent
                                spacing: (parent.width - 3 * 20) / 2

                                Repeater {
                                    model: [
                                        { profile: PowerProfile.PowerSaver, color: Theme.green, name: "saver" },
                                        { profile: PowerProfile.Balanced, color: Theme.blue, name: "balanced" },
                                        { profile: PowerProfile.Performance, color: Theme.yellow, name: "performance" }
                                    ]

                                    Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 10
                                        property bool isActive: PowerProfiles.profile === modelData.profile
                                        color: isActive ? modelData.color : Theme.surface1
                                        border.width: isActive ? 0 : 2
                                        border.color: Theme.overlay0

                                        Behavior on color { ColorAnimation { duration: 150 } }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (PowerProfiles.profile === modelData.profile && tabStack.currentIndex === 4) {
                                                    // Re-click active profile on Tuning tab: save + apply
                                                    root.saveProfileToConfig(modelData.name)
                                                    root.applyProfile()
                                                } else if (PowerProfiles.profile !== modelData.profile) {
                                                    // Different profile: change PPD (Connections handles config load)
                                                    PowerProfiles.profile = modelData.profile
                                                    root.applyProfile()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Performance icon
                        Text {
                            text: "󰓅"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            color: PowerProfiles.profile === PowerProfile.Performance ? Theme.yellow : Theme.overlay0
                        }
                    }
                }

                // Power Buttons
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    radius: 12
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Repeater {
                            model: [
                                { icon: "󰐥", tooltip: "Shutdown", cmd: ["hyprshutdown", "-t", "Shutting down...", "--post-cmd", "shutdown -P 0"], accent: Theme.red },
                                { icon: "󰜉", tooltip: "Reboot", cmd: ["hyprshutdown", "-t", "Restarting...", "--post-cmd", "reboot"], accent: Theme.yellow },
                                { icon: "󰍃", tooltip: "Logout", cmd: ["hyprshutdown", "-t", "Logging out..."], accent: Theme.blue },
                                { icon: "󰌾", tooltip: "Lock", cmd: ["hyprlock"], accent: Theme.green }
                            ]

                            Rectangle {
                                id: powerBtn
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 10
                                color: powerMouse.containsMouse ? modelData.accent : Theme.surface1

                                Behavior on color { ColorAnimation { duration: 150 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.icon
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 22
                                    color: powerMouse.containsMouse ? Theme.base : Theme.text
                                }

                                MouseArea {
                                    id: powerMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        powerProc.command = modelData.cmd
                                        powerProc.running = true
                                    }
                                }

                                Process {
                                    id: powerProc
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Sound Tab Component - Native Pipewire with PwObjectTracker
    component SoundTab: Item {
        id: soundTab

        property bool sinkMenuOpen: false
        property bool sourceMenuOpen: false

        // Current sink/source from Pipewire defaults
        readonly property var currentSink: Pipewire.defaultAudioSink
        readonly property var currentSource: Pipewire.defaultAudioSource

        // PwObjectTracker binds the nodes so we can access their audio properties
        PwObjectTracker {
            id: audioTracker
            objects: [soundTab.currentSink, soundTab.currentSource]
        }

        // Check if nodes are bound and ready
        readonly property bool sinkReady: currentSink && currentSink.ready && currentSink.audio
        readonly property bool sourceReady: currentSource && currentSource.ready && currentSource.audio

        // Volume/mute properties (only valid when ready)
        readonly property int volume: sinkReady ? Math.round(currentSink.audio.volume * 100) : 0
        readonly property bool volumeMuted: sinkReady ? currentSink.audio.muted : false
        readonly property int micVolume: sourceReady ? Math.round(currentSource.audio.volume * 100) : 0
        readonly property bool micMuted: sourceReady ? currentSource.audio.muted : false

        // Force PwObjectTracker to rebind when sink changes (fixes volume not updating on switch back)
        onCurrentSinkChanged: {
            audioTracker.objects = []
            audioTracker.objects = [currentSink, currentSource].filter(x => x)
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            // Master Volume
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                radius: 12
                color: "transparent"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    RowLayout {
                        spacing: 8
                        Text {
                            text: soundTab.volumeMuted ? "󰝟" : (soundTab.volume > 66 ? "󰕾" : (soundTab.volume > 33 ? "󰖀" : "󰕿"))
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 16
                            color: soundTab.volumeMuted ? Theme.overlay0 : Theme.blue
                        }
                        Text {
                            text: "Volume"
                            font.pixelSize: 12
                            font.bold: true
                            color: Theme.text
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: soundTab.volume + "%"
                            font.pixelSize: 11
                            color: Theme.subtext0
                        }

                        // Mute toggle
                        Rectangle {
                            width: 28; height: 20; radius: 10
                            color: soundTab.volumeMuted ? Theme.surface1 : Theme.blue
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Rectangle {
                                width: 14; height: 14; radius: 7
                                x: soundTab.volumeMuted ? 3 : parent.width - width - 3
                                anchors.verticalCenter: parent.verticalCenter
                                color: Theme.text
                                Behavior on x { NumberAnimation { duration: 150 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (soundTab.sinkReady) soundTab.currentSink.audio.muted = !soundTab.currentSink.audio.muted
                            }
                        }
                    }

                    Slider {
                        id: volumeSlider
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        from: 0; to: 100; stepSize: 1
                        enabled: soundTab.sinkReady
                        onMoved: if (soundTab.sinkReady) soundTab.currentSink.audio.volume = value / 100

                        // Sync slider with volume changes
                        Connections {
                            target: soundTab
                            function onVolumeChanged() {
                                if (!volumeSlider.pressed) volumeSlider.value = soundTab.volume
                            }
                        }
                        Component.onCompleted: value = soundTab.volume

                        background: Rectangle {
                            x: volumeSlider.leftPadding
                            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                            width: volumeSlider.availableWidth; height: 4; radius: 2
                            color: Theme.surface1
                            Rectangle {
                                width: volumeSlider.visualPosition * parent.width
                                height: parent.height; radius: 2; color: Theme.blue
                            }
                        }
                        handle: Rectangle {
                            x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                            width: 14; height: 14; radius: 7; color: Theme.text
                        }
                    }
                }
            }

            // Output device selector
            Rectangle {
                id: sinkSelector
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: 8
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    Text {
                        text: "󰓃"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        color: Theme.blue
                    }
                    Text {
                        text: soundTab.currentSink ? soundTab.currentSink.description : "No output"
                        font.pixelSize: 10
                        color: Theme.text
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    Text {
                        text: soundTab.sinkMenuOpen ? "󰅀" : "󰅂"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        color: Theme.overlay0
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { soundTab.sourceMenuOpen = false; soundTab.sinkMenuOpen = !soundTab.sinkMenuOpen }
                }
            }

            // Microphone
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                radius: 12
                color: "transparent"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    RowLayout {
                        spacing: 8
                        Text {
                            text: soundTab.micMuted ? "󰍭" : "󰍬"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 16
                            color: soundTab.micMuted ? Theme.overlay0 : Theme.green
                        }
                        Text {
                            text: "Microphone"
                            font.pixelSize: 12
                            font.bold: true
                            color: Theme.text
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: soundTab.micVolume + "%"
                            font.pixelSize: 11
                            color: Theme.subtext0
                        }

                        // Mic mute toggle
                        Rectangle {
                            width: 28; height: 20; radius: 10
                            color: soundTab.micMuted ? Theme.surface1 : Theme.green
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Rectangle {
                                width: 14; height: 14; radius: 7
                                x: soundTab.micMuted ? 3 : parent.width - width - 3
                                anchors.verticalCenter: parent.verticalCenter
                                color: Theme.text
                                Behavior on x { NumberAnimation { duration: 150 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (soundTab.sourceReady) soundTab.currentSource.audio.muted = !soundTab.currentSource.audio.muted
                            }
                        }
                    }

                    Slider {
                        id: micSlider
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        from: 0; to: 100; stepSize: 1
                        enabled: soundTab.sourceReady
                        onMoved: if (soundTab.sourceReady) soundTab.currentSource.audio.volume = value / 100

                        // Sync slider with mic volume changes
                        Connections {
                            target: soundTab
                            function onMicVolumeChanged() {
                                if (!micSlider.pressed) micSlider.value = soundTab.micVolume
                            }
                        }
                        Component.onCompleted: value = soundTab.micVolume

                        background: Rectangle {
                            x: micSlider.leftPadding
                            y: micSlider.topPadding + micSlider.availableHeight / 2 - height / 2
                            width: micSlider.availableWidth; height: 4; radius: 2
                            color: Theme.surface1
                            Rectangle {
                                width: micSlider.visualPosition * parent.width
                                height: parent.height; radius: 2; color: Theme.green
                            }
                        }
                        handle: Rectangle {
                            x: micSlider.leftPadding + micSlider.visualPosition * (micSlider.availableWidth - width)
                            y: micSlider.topPadding + micSlider.availableHeight / 2 - height / 2
                            width: 14; height: 14; radius: 7; color: Theme.text
                        }
                    }
                }
            }

            // Input device selector
            Rectangle {
                id: sourceSelector
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: 8
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    Text {
                        text: "󰍬"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        color: Theme.green
                    }
                    Text {
                        text: soundTab.currentSource ? soundTab.currentSource.description : "No input"
                        font.pixelSize: 10
                        color: Theme.text
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    Text {
                        text: soundTab.sourceMenuOpen ? "󰅀" : "󰅂"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        color: Theme.overlay0
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { soundTab.sinkMenuOpen = false; soundTab.sourceMenuOpen = !soundTab.sourceMenuOpen }
                }
            }

            Item { Layout.fillHeight: true }
        }

        // Sink dropdown
        Rectangle {
            id: sinkMenu
            visible: soundTab.sinkMenuOpen && Pipewire.ready
            x: sinkSelector.x
            y: sinkSelector.y + sinkSelector.height + 4
            width: sinkSelector.width
            height: 128
            radius: 8
            color: Theme.base
            border.color: Theme.surface1
            border.width: 1
            z: 100
            clip: true

            ListView {
                anchors.fill: parent
                anchors.margins: 4
                model: Pipewire.nodes
                delegate: Rectangle {
                    width: sinkMenu.width - 8
                    property bool isSinkDevice: modelData && modelData.isSink && !modelData.isStream && modelData.audio
                    height: isSinkDevice ? 28 : 0
                    visible: height > 0
                    radius: 4
                    property bool isDefault: modelData === soundTab.currentSink
                    color: sinkMouseArea.containsMouse ? Theme.surface0 : "transparent"

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        verticalAlignment: Text.AlignVCenter
                        text: (isDefault ? "✓ " : "   ") + (modelData.description || modelData.name || "Unknown")
                        font.pixelSize: 10
                        color: isDefault ? Theme.blue : Theme.text
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        id: sinkMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Pipewire.preferredDefaultAudioSink = modelData
                            soundTab.sinkMenuOpen = false
                        }
                    }
                }
            }
        }

        // Source dropdown
        Rectangle {
            id: sourceMenu
            visible: soundTab.sourceMenuOpen && Pipewire.ready
            x: sourceSelector.x
            y: sourceSelector.y + sourceSelector.height + 4
            width: sourceSelector.width
            height: 128
            radius: 8
            color: Theme.base
            border.color: Theme.surface1
            border.width: 1
            z: 100
            clip: true

            ListView {
                anchors.fill: parent
                anchors.margins: 4
                model: Pipewire.nodes
                delegate: Rectangle {
                    width: sourceMenu.width - 8
                    property bool isSourceDevice: modelData && !modelData.isSink && !modelData.isStream && modelData.audio
                    height: isSourceDevice ? 28 : 0
                    visible: height > 0
                    radius: 4
                    property bool isDefault: modelData === soundTab.currentSource
                    color: sourceMouseArea.containsMouse ? Theme.surface0 : "transparent"

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        verticalAlignment: Text.AlignVCenter
                        text: (isDefault ? "✓ " : "   ") + (modelData.description || modelData.name || "Unknown")
                        font.pixelSize: 10
                        color: isDefault ? Theme.green : Theme.text
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        id: sourceMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Pipewire.preferredDefaultAudioSource = modelData
                            soundTab.sourceMenuOpen = false
                        }
                    }
                }
            }
        }
    }

    // Brightness Tab Component
    component BrightnessTab: ColumnLayout {
        spacing: 12

        property bool nightLightEnabled: false
        property int nightLightTemp: 4500

        Component.onCompleted: {
            monitorsProc.running = true
        }

        // Get monitors from hyprctl (buffer multiline JSON)
        Process {
            id: monitorsProc
            command: ["hyprctl", "monitors", "-j"]

            property string buffer: ""

            stdout: SplitParser {
                onRead: data => {
                    monitorsProc.buffer += data
                }
            }

            onRunningChanged: {
                if (!running && buffer.length > 0) {
                    monitorModel.clear()
                    try {
                        let monitors = JSON.parse(buffer)
                        for (let mon of monitors) {
                            let isInternal = mon.name.startsWith("eDP")
                            monitorModel.append({
                                name: mon.name,
                                description: mon.description || mon.name,
                                isInternal: isInternal,
                                brightness: 100
                            })
                        }
                        // Read current brightness for internal displays
                        brightnessGetProc.running = true
                    } catch (e) {
                        console.log("Failed to parse monitors:", e)
                    }
                    buffer = ""
                }
            }
        }

        // Get current brightness for internal display
        Process {
            id: brightnessGetProc
            command: ["brightnessctl", "-m"]
            stdout: SplitParser {
                onRead: data => {
                    // Output: "intel_backlight,backlight,3,100%,3000"
                    let match = data.match(/,(\d+)%,/)
                    if (match) {
                        for (let i = 0; i < monitorModel.count; i++) {
                            if (monitorModel.get(i).isInternal) {
                                monitorModel.setProperty(i, "brightness", parseInt(match[1]))
                            }
                        }
                    }
                }
            }
            onRunningChanged: {
                // After internal brightness is read, read external brightness
                if (!running) {
                    gammaGetProc.currentIndex = 0
                    gammaGetProc.readNextExternal()
                }
            }
        }

        // Get current brightness for external monitors from wl-gammarelay-rs
        Process {
            id: gammaGetProc
            property int currentIndex: 0

            function readNextExternal() {
                // Find next external monitor
                while (currentIndex < monitorModel.count) {
                    let mon = monitorModel.get(currentIndex)
                    if (!mon.isInternal) {
                        let outputPath = "/outputs/" + mon.name.replace(/-/g, "_")
                        command = ["busctl", "--user", "get-property",
                            "rs.wl-gammarelay", outputPath, "rs.wl.gammarelay", "Brightness"]
                        running = true
                        return
                    }
                    currentIndex++
                }
            }

            stdout: SplitParser {
                onRead: data => {
                    // Output: "d 0.75" (means 75%)
                    let match = data.match(/d\s+([\d.]+)/)
                    if (match) {
                        let brightness = Math.round(parseFloat(match[1]) * 100)
                        monitorModel.setProperty(gammaGetProc.currentIndex, "brightness", brightness)
                    }
                }
            }

            onRunningChanged: {
                if (!running) {
                    currentIndex++
                    readNextExternal()
                }
            }
        }

        ListModel {
            id: monitorModel
        }

        // Monitor brightness sliders
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 16
            color: "transparent"
            clip: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                ListView {
                    id: monitorList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8
                    model: monitorModel
                    clip: true

                    delegate: Rectangle {
                        width: monitorList.width
                        height: 56
                        radius: 8
                        color: "transparent"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            RowLayout {
                                spacing: 6
                                Text {
                                    text: model.isInternal ? "󰛩" : "󰍹"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 14
                                    color: Theme.yellow
                                }
                                ColumnLayout {
                                    spacing: 0
                                    Text {
                                        text: model.name
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: Theme.text
                                    }
                                    Text {
                                        text: model.description
                                        font.pixelSize: 9
                                        color: Theme.subtext0
                                        elide: Text.ElideRight
                                        Layout.maximumWidth: 180
                                    }
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: Math.round(monitorSlider.value) + "%"
                                    font.pixelSize: 10
                                    color: Theme.subtext0
                                }
                            }

                            Slider {
                                id: monitorSlider
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20
                                from: 5
                                to: 100
                                value: model.brightness

                                onMoved: {
                                    model.brightness = Math.round(value)
                                    if (model.isInternal) {
                                        brightnessSetProc.command = ["brightnessctl", "set", Math.round(value) + "%"]
                                    } else {
                                        // Use wl-gammarelay-rs for external monitors (software gamma)
                                        // Convert monitor name: "DP-3" → "DP_3"
                                        let outputPath = "/outputs/" + model.name.replace(/-/g, "_")
                                        let brightnessValue = (value / 100).toFixed(2)
                                        brightnessSetProc.command = ["busctl", "--user", "set-property",
                                            "rs.wl-gammarelay", outputPath, "rs.wl.gammarelay", "Brightness", "d", brightnessValue]
                                    }
                                    brightnessSetProc.running = true
                                }

                                background: Rectangle {
                                    x: monitorSlider.leftPadding
                                    y: monitorSlider.topPadding + monitorSlider.availableHeight / 2 - height / 2
                                    width: monitorSlider.availableWidth
                                    height: 4
                                    radius: 2
                                    color: Theme.base

                                    Rectangle {
                                        width: monitorSlider.visualPosition * parent.width
                                        height: parent.height
                                        radius: 2
                                        color: Theme.yellow
                                    }
                                }

                                handle: Rectangle {
                                    x: monitorSlider.leftPadding + monitorSlider.visualPosition * (monitorSlider.availableWidth - width)
                                    y: monitorSlider.topPadding + monitorSlider.availableHeight / 2 - height / 2
                                    width: 14
                                    height: 14
                                    radius: 7
                                    color: Theme.text
                                }
                            }
                        }

                        Process {
                            id: brightnessSetProc
                        }
                    }
                }

                Text {
                    visible: monitorModel.count === 0
                    text: "No monitors detected"
                    font.pixelSize: 11
                    color: Theme.overlay0
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // Night Light
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: nightLightEnabled ? 100 : 48
            radius: 16
            color: "transparent"

            Behavior on Layout.preferredHeight { NumberAnimation { duration: 200 } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    spacing: 8
                    Text {
                        text: "󰖔"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        color: nightLightEnabled ? Theme.yellow : Theme.overlay0
                    }
                    Text {
                        text: "Night Light"
                        font.pixelSize: 12
                        font.bold: true
                        color: Theme.text
                    }
                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 40
                        height: 22
                        radius: 11
                        color: nightLightEnabled ? Theme.yellow : Theme.surface1

                        Behavior on color { ColorAnimation { duration: 150 } }

                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            x: nightLightEnabled ? parent.width - width - 3 : 3
                            anchors.verticalCenter: parent.verticalCenter
                            color: Theme.text

                            Behavior on x { NumberAnimation { duration: 150 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                nightLightEnabled = !nightLightEnabled
                                if (nightLightEnabled) {
                                    nightLightOnProc.running = true
                                } else {
                                    nightLightOffProc.running = true
                                }
                            }
                        }
                    }
                }

                // Temperature slider (visible when enabled)
                RowLayout {
                    visible: nightLightEnabled
                    spacing: 8

                    Text {
                        text: "2500K"
                        font.pixelSize: 9
                        color: Theme.overlay0
                    }

                    Slider {
                        id: nightLightSlider
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        from: 2500
                        to: 6500
                        value: nightLightTemp
                        stepSize: 100

                        onMoved: {
                            nightLightTemp = Math.round(value)
                            if (nightLightEnabled) nightLightOnProc.running = true
                        }

                        background: Rectangle {
                            x: nightLightSlider.leftPadding
                            y: nightLightSlider.topPadding + nightLightSlider.availableHeight / 2 - height / 2
                            width: nightLightSlider.availableWidth
                            height: 4
                            radius: 2
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#ff9329" }
                                GradientStop { position: 1.0; color: "#fff5e6" }
                            }
                        }

                        handle: Rectangle {
                            x: nightLightSlider.leftPadding + nightLightSlider.visualPosition * (nightLightSlider.availableWidth - width)
                            y: nightLightSlider.topPadding + nightLightSlider.availableHeight / 2 - height / 2
                            width: 14
                            height: 14
                            radius: 7
                            color: Theme.text
                        }
                    }

                    Text {
                        text: "6500K"
                        font.pixelSize: 9
                        color: Theme.overlay0
                    }
                }
            }

            Process {
                id: nightLightOnProc
                command: ["hyprsunset", "-t", nightLightTemp.toString()]
            }

            Process {
                id: nightLightOffProc
                command: ["pkill", "hyprsunset"]
            }
        }
    }

    // WiFi Tab Component
    component WifiTab: ColumnLayout {
        id: wifiTab
        spacing: 12

        property bool wifiEnabled: true
        property bool scanning: false
        property bool connecting: false
        property string connectedSsid: ""
        property string selectedSsid: ""
        property bool connectError: false

        Component.onCompleted: {
            wifiActiveProc.running = true
            wifiRescanProc.running = true
            nmMonitor.running = true
        }

        // nmcli monitor for real-time connection events
        Process {
            id: nmMonitor
            command: ["nmcli", "monitor"]
            stdout: SplitParser {
                onRead: data => {
                    if (data.includes("connected") || data.includes("disconnected")) {
                        wifiActiveProc.running = true
                        wifiListProc.running = true
                    }
                }
            }
        }

        // Trigger WiFi rescan
        Process {
            id: wifiRescanProc
            command: ["nmcli", "device", "wifi", "rescan"]
            onRunningChanged: {
                if (running) wifiTab.scanning = true
                else wifiListProc.running = true
            }
        }

        // Get currently active WiFi connection
        Process {
            id: wifiActiveProc
            command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show", "--active"]
            property string buffer: ""
            stdout: SplitParser { onRead: data => wifiActiveProc.buffer += data + "\n" }
            onRunningChanged: {
                if (!running && buffer.length > 0) {
                    wifiTab.connectedSsid = ""
                    for (let line of buffer.trim().split('\n')) {
                        let parts = line.split(':')
                        if (parts[1]?.includes("wireless")) {
                            wifiTab.connectedSsid = parts[0]
                            break
                        }
                    }
                    buffer = ""
                }
            }
        }

        // WiFi Toggle
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            radius: 16
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Text {
                    text: wifiEnabled ? "󰖩" : "󰖪"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 20
                    color: wifiEnabled ? Theme.blue : Theme.overlay0
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "WiFi"
                        font.pixelSize: 13
                        font.bold: true
                        color: Theme.text
                    }
                    Text {
                        id: wifiStatusText
                        text: wifiTab.connectedSsid || (wifiEnabled ? "Scanning..." : "Disabled")
                        font.pixelSize: 11
                        color: wifiTab.connectedSsid ? Theme.green : Theme.subtext0
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 28; height: 28; radius: 14
                    color: wifiTab.scanning ? Theme.surface1 : (wifiRefreshMouse.containsMouse ? Theme.surface1 : "transparent")
                    opacity: wifiTab.scanning ? 0.5 : 1.0
                    Text {
                        anchors.centerIn: parent
                        text: "󰑓"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        color: wifiTab.scanning ? Theme.overlay0 : Theme.subtext0
                        RotationAnimation on rotation {
                            running: wifiTab.scanning
                            from: 0; to: 360
                            duration: 1000
                            loops: Animation.Infinite
                        }
                    }
                    MouseArea {
                        id: wifiRefreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: wifiTab.scanning ? Qt.ArrowCursor : Qt.PointingHandCursor
                        onClicked: {
                            if (!wifiTab.scanning) {
                                wifiRescanProc.running = true
                            }
                        }
                    }
                }

                Rectangle {
                    width: 44; height: 24; radius: 12
                    color: wifiEnabled ? Theme.blue : Theme.surface1
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Rectangle {
                        width: 18; height: 18; radius: 9
                        x: wifiEnabled ? parent.width - width - 3 : 3
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.text
                        Behavior on x { NumberAnimation { duration: 150 } }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            wifiEnabled = !wifiEnabled
                            wifiToggleProc.running = true
                        }
                    }
                }
            }

            Process {
                id: wifiToggleProc
                command: ["nmcli", "radio", "wifi", wifiEnabled ? "on" : "off"]
            }
        }

        // Networks List
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 16
            color: "transparent"
            clip: true

            ListView {
                id: wifiList
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4
                model: ListModel { id: wifiModel }

                delegate: Rectangle {
                    id: wifiDelegate
                    width: wifiList.width
                    height: 44
                    radius: 8
                    color: model.ssid === wifiTab.connectedSsid ? Qt.rgba(166/255, 227/255, 161/255, 0.15) :
                           (wifiItemMouse.containsMouse ? Theme.surface1 : "transparent")
                    border.color: model.ssid === wifiTab.connectedSsid ? Theme.green : "transparent"
                    border.width: model.ssid === wifiTab.connectedSsid ? 1 : 0

                    property bool showPasswordInput: wifiTab.selectedSsid === model.ssid

                    // Shake animation
                    property real shakeOffset: 0
                    x: shakeOffset
                    SequentialAnimation {
                        id: shakeAnim
                        loops: 2
                        NumberAnimation { target: wifiDelegate; property: "shakeOffset"; to: 8; duration: 50 }
                        NumberAnimation { target: wifiDelegate; property: "shakeOffset"; to: -8; duration: 50 }
                        NumberAnimation { target: wifiDelegate; property: "shakeOffset"; to: 0; duration: 50 }
                    }

                    // Network row (hidden when showing password input)
                    RowLayout {
                        visible: !wifiDelegate.showPasswordInput
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Text {
                            text: model.signal > 75 ? "󰤨" : (model.signal > 50 ? "󰤥" : (model.signal > 25 ? "󰤢" : "󰤟"))
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 16
                            color: model.ssid === wifiTab.connectedSsid ? Theme.green : Theme.blue
                        }

                        Text {
                            text: model.ssid
                            font.pixelSize: 12
                            font.bold: model.ssid === wifiTab.connectedSsid
                            color: model.ssid === wifiTab.connectedSsid ? Theme.green : Theme.text
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: model.security !== "--" && model.ssid !== wifiTab.connectedSsid ? "󰌾" : ""
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            color: Theme.overlay0
                        }
                    }

                    // Password input row (replaces network row)
                    RowLayout {
                        id: pwdRow
                        visible: wifiDelegate.showPasswordInput
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8
                        opacity: wifiTab.connecting ? 0.5 : 1.0

                        onVisibleChanged: {
                            if (visible) pwdField.forceActiveFocus()
                        }

                        Text {
                            text: wifiTab.connecting ? "󰑓" : "󰌾"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 16
                            color: wifiTab.connecting ? Theme.yellow : Theme.blue
                            RotationAnimation on rotation {
                                running: wifiTab.connecting
                                from: 0; to: 360
                                duration: 1000
                                loops: Animation.Infinite
                            }
                        }

                        TextField {
                            id: pwdField
                            Layout.fillWidth: true
                            enabled: !wifiTab.connecting
                            placeholderText: wifiTab.connecting ? "Connecting..." : (wifiTab.connectError ? "Wrong password" : model.ssid)
                            placeholderTextColor: wifiTab.connecting ? Theme.yellow : (wifiTab.connectError ? Theme.red : Theme.subtext0)
                            echoMode: TextInput.Password
                            font.pixelSize: 11
                            color: Theme.text
                            background: Rectangle {
                                radius: 6
                                color: wifiTab.connecting ? Theme.surface0 : Theme.surface1
                                border.color: wifiTab.connectError ? Theme.red : (pwdField.activeFocus ? Theme.blue : "transparent")
                                border.width: 1
                            }
                            Keys.onReturnPressed: tryConnect()
                            Keys.onEscapePressed: if (!wifiTab.connecting) { wifiTab.selectedSsid = ""; wifiTab.connectError = false }

                            function tryConnect() {
                                if (pwdField.text.length > 0 && !wifiTab.connecting) {
                                    wifiTab.connecting = true
                                    wifiTab.connectError = false
                                    wifiConnectProc.targetSsid = model.ssid
                                    wifiConnectProc.targetDelegate = wifiDelegate
                                    wifiConnectProc.targetPassword = pwdField.text
                                    // Delete existing profile to ensure fresh credentials
                                    wifiDeleteProfileProc.command = ["nmcli", "connection", "delete", model.ssid]
                                    wifiDeleteProfileProc.running = true
                                }
                            }
                        }

                        Rectangle {
                            visible: !wifiTab.connecting
                            width: 24; height: 24; radius: 12
                            color: pwdCancelMouse.containsMouse ? Theme.surface1 : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                color: Theme.overlay0
                            }
                            MouseArea {
                                id: pwdCancelMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { wifiTab.selectedSsid = ""; wifiTab.connectError = false }
                            }
                        }
                    }

                    MouseArea {
                        id: wifiItemMouse
                        anchors.fill: parent
                        visible: !wifiDelegate.showPasswordInput
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            wifiTab.connectError = false
                            if (model.ssid === wifiTab.connectedSsid) {
                                // Disconnect
                                wifiDisconnectProc.command = ["nmcli", "connection", "down", model.ssid]
                                wifiDisconnectProc.running = true
                            } else if (model.security !== "--") {
                                // Secured network - show password input
                                wifiTab.selectedSsid = model.ssid
                            } else {
                                // Open network - connect directly
                                wifiTab.connecting = true
                                wifiConnectProc.targetSsid = model.ssid
                                wifiConnectProc.targetDelegate = null
                                wifiConnectProc.command = ["nmcli", "--wait", "15", "device", "wifi", "connect", model.ssid]
                                wifiConnectProc.running = true
                                wifiConnectTimeout.start()
                            }
                        }
                    }
                }
            }

            // Get list of available WiFi networks
            Process {
                id: wifiListProc
                command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,IN-USE", "device", "wifi", "list"]
                property string buffer: ""
                stdout: SplitParser { onRead: data => wifiListProc.buffer += data + "\n" }
                onRunningChanged: {
                    if (!running && buffer.length > 0) {
                        wifiModel.clear()
                        let networkMap = {}
                        for (let line of buffer.trim().split('\n')) {
                            let parts = line.split(':')
                            if (parts[0]) {
                                let ssid = parts[0]
                                let signal = parseInt(parts[1]) || 0
                                let isConnected = parts[3] === "*"
                                if (isConnected) wifiTab.connectedSsid = ssid
                                if (!networkMap[ssid] || isConnected || signal > networkMap[ssid].signal) {
                                    networkMap[ssid] = { ssid, signal, security: parts[2] || "--", connected: isConnected }
                                }
                            }
                        }
                        // Sort: connected first, then by signal strength
                        let networks = Object.values(networkMap).sort((a, b) => {
                            if (a.connected !== b.connected) return a.connected ? -1 : 1
                            return b.signal - a.signal
                        })
                        for (let n of networks) wifiModel.append(n)
                        wifiTab.scanning = false
                        wifiTab.selectedSsid = ""
                        buffer = ""
                    }
                }
            }

            // Delete existing profile before connecting with new password
            Process {
                id: wifiDeleteProfileProc
                onRunningChanged: {
                    if (!running) {
                        wifiConnectProc.command = ["nmcli", "--wait", "15", "device", "wifi", "connect",
                            wifiConnectProc.targetSsid, "password", wifiConnectProc.targetPassword]
                        wifiConnectProc.running = true
                        wifiConnectTimeout.start()
                    }
                }
            }

            // Connect to WiFi network
            Process {
                id: wifiConnectProc
                property string targetSsid: ""
                property string targetPassword: ""
                property var targetDelegate: null
                property string buffer: ""
                stdout: SplitParser { onRead: data => wifiConnectProc.buffer += data + "\n" }
                stderr: SplitParser { onRead: data => wifiConnectProc.buffer += data + "\n" }
                onRunningChanged: if (!running) wifiConnectResultTimer.start()
            }

            // Delay to let output buffer settle before checking result
            Timer {
                id: wifiConnectResultTimer
                interval: 100
                onTriggered: {
                    let output = wifiConnectProc.buffer.toLowerCase()
                    wifiConnectTimeout.stop()
                    wifiTab.connecting = false

                    let hasError = output.includes("error") || output.includes("secrets were required") || output.includes("not found")
                    let hasSuccess = output.includes("successfully") || output.includes("activated")

                    if (hasSuccess && !hasError) {
                        wifiTab.connectedSsid = wifiConnectProc.targetSsid
                        wifiTab.selectedSsid = ""
                        wifiTab.connectError = false
                        wifiActiveProc.running = true
                    } else {
                        wifiTab.connectError = true
                        if (wifiConnectProc.targetDelegate) wifiConnectProc.targetDelegate.shakeAnim.start()
                    }
                    wifiConnectProc.buffer = ""
                }
            }

            // Connection timeout
            Timer {
                id: wifiConnectTimeout
                interval: 20000
                onTriggered: { wifiTab.connecting = false; wifiTab.connectError = true }
            }

            // Disconnect from WiFi
            Process {
                id: wifiDisconnectProc
                onRunningChanged: {
                    if (!running) {
                        wifiTab.connectedSsid = ""
                        wifiListProc.running = true
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "No networks found"
                color: Theme.overlay0
                font.pixelSize: 12
                visible: wifiModel.count === 0
            }
        }
    }

    // Bluetooth Tab Component - Native Quickshell.Bluetooth
    component BluetoothTab: ColumnLayout {
        id: btTab
        spacing: 12

        // Native adapter reference
        readonly property var adapter: Bluetooth.defaultAdapter
        readonly property bool btEnabled: adapter?.enabled ?? false
        readonly property bool scanning: adapter?.discovering ?? false

        // Find connected device name
        readonly property string connectedDeviceName: {
            for (let i = 0; i < Bluetooth.devices.count; i++) {
                let dev = Bluetooth.devices.get(i)
                if (dev.connected) return dev.name
            }
            return ""
        }

        // Bluetooth Toggle
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            radius: 16
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Text {
                    text: btTab.btEnabled ? "󰂯" : "󰂲"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 20
                    color: btTab.btEnabled ? Theme.blue : Theme.overlay0
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Bluetooth"
                        font.pixelSize: 13
                        font.bold: true
                        color: Theme.text
                    }
                    Text {
                        text: btTab.connectedDeviceName || (btTab.scanning ? "Scanning..." : (btTab.btEnabled ? Bluetooth.devices.count + " devices" : "Disabled"))
                        font.pixelSize: 11
                        color: btTab.connectedDeviceName ? Theme.green : Theme.subtext0
                    }
                }

                Item { Layout.fillWidth: true }

                // Scan button
                Rectangle {
                    width: 28; height: 28; radius: 14
                    color: btTab.scanning ? Theme.surface1 : (btRefreshMouse.containsMouse ? Theme.surface1 : "transparent")
                    opacity: btTab.scanning ? 0.5 : 1.0
                    Text {
                        anchors.centerIn: parent
                        text: "󰑓"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        color: btTab.scanning ? Theme.overlay0 : Theme.subtext0
                        RotationAnimation on rotation {
                            running: btTab.scanning
                            from: 0; to: 360
                            duration: 1000
                            loops: Animation.Infinite
                        }
                    }
                    MouseArea {
                        id: btRefreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: btTab.scanning ? Qt.ArrowCursor : Qt.PointingHandCursor
                        onClicked: {
                            if (btTab.adapter && !btTab.scanning) {
                                btTab.adapter.discovering = true
                            }
                        }
                    }
                }

                // Stop scan button (visible only when scanning)
                Rectangle {
                    visible: btTab.scanning
                    width: 28; height: 28; radius: 14
                    color: btStopMouse.containsMouse ? Theme.red : Theme.surface1
                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        color: btStopMouse.containsMouse ? Theme.base : Theme.subtext0
                    }
                    MouseArea {
                        id: btStopMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (btTab.adapter) btTab.adapter.discovering = false
                        }
                    }
                }

                Rectangle {
                    width: 44; height: 24; radius: 12
                    color: btTab.btEnabled ? Theme.blue : Theme.surface1
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Rectangle {
                        width: 18; height: 18; radius: 9
                        x: btTab.btEnabled ? parent.width - width - 3 : 3
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.text
                        Behavior on x { NumberAnimation { duration: 150 } }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (btTab.adapter) btTab.adapter.enabled = !btTab.btEnabled
                        }
                    }
                }
            }
        }

        // Devices List
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 16
            color: "transparent"
            clip: true

            ListView {
                id: btList
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4
                model: Bluetooth.devices

                delegate: Rectangle {
                    id: btDelegate
                    width: btList.width
                    height: 44
                    radius: 8
                    opacity: modelData.paired ? 1.0 : 0.6
                    color: modelData.connected ? Qt.rgba(166/255, 227/255, 161/255, 0.15) :
                           (btItemMouse.containsMouse ? Theme.surface1 : "transparent")
                    border.color: modelData.connected ? Theme.green : "transparent"
                    border.width: modelData.connected ? 1 : 0

                    property bool isPairing: modelData.pairing

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Text {
                            text: modelData.paired ? "󰂱" : "󰂰"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 16
                            color: modelData.connected ? Theme.green : (modelData.paired ? Theme.blue : Theme.overlay0)
                        }

                        Text {
                            text: modelData.name || modelData.address
                            font.pixelSize: 12
                            font.bold: modelData.connected
                            color: modelData.connected ? Theme.green : (modelData.paired ? Theme.text : Theme.subtext0)
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        // Battery indicator
                        RowLayout {
                            visible: modelData.batteryAvailable
                            spacing: 4
                            Text {
                                text: {
                                    let pct = modelData.battery * 100
                                    if (pct > 80) return "󰁹"
                                    if (pct > 60) return "󰂁"
                                    if (pct > 40) return "󰁿"
                                    if (pct > 20) return "󰁽"
                                    return "󰁻"
                                }
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                color: modelData.battery > 0.2 ? Theme.green : Theme.red
                            }
                            Text {
                                text: Math.round(modelData.battery * 100) + "%"
                                font.pixelSize: 10
                                color: Theme.subtext0
                            }
                        }

                        Text {
                            visible: !modelData.batteryAvailable
                            text: btDelegate.isPairing ? "Pairing..." : (modelData.connected ? "" : (modelData.paired ? "" : "Tap to pair"))
                            font.pixelSize: 10
                            color: btDelegate.isPairing ? Theme.yellow : Theme.overlay0
                        }
                    }

                    MouseArea {
                        id: btItemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (btDelegate.isPairing) return
                            if (modelData.connected) {
                                modelData.disconnect()
                            } else if (modelData.paired) {
                                modelData.connect()
                            } else {
                                modelData.pair()
                            }
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: Bluetooth.devices.count === 0 ? (btTab.scanning ? "Scanning for devices..." : "No devices found") : ""
                color: Theme.overlay0
                font.pixelSize: 12
                visible: Bluetooth.devices.count === 0
            }
        }
    }

    // APU Tuning Tab Component
    component TuningTab: ColumnLayout {
        spacing: 10

        property alias stapmSlider: stapmSlider
        property alias fastSlider: fastSlider
        property alias slowSlider: slowSlider
        property alias tempSlider: tempSlider

        // Sliders container
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            // STAPM Slider
            TuningSlider {
                id: stapmSlider
                label: "STAPM"
                icon: "󰓅"
                unit: "W"
                minVal: 10
                maxVal: 45
                accentColor: Theme.blue
                description: "Sustained power limit"
            }

            // Fast Limit Slider
            TuningSlider {
                id: fastSlider
                label: "Fast"
                icon: "󰑷"
                unit: "W"
                minVal: 10
                maxVal: 55
                accentColor: Theme.yellow
                description: "Boost power limit"
            }

            // Slow Limit Slider
            TuningSlider {
                id: slowSlider
                label: "Slow"
                icon: "󰾅"
                unit: "W"
                minVal: 10
                maxVal: 50
                accentColor: Theme.green
                description: "Average power limit"
            }

            // Temperature Limit Slider
            TuningSlider {
                id: tempSlider
                label: "Temp"
                icon: "󰔏"
                unit: "°C"
                minVal: 75
                maxVal: 100
                accentColor: Theme.red
                description: "Thermal throttle point"
            }

            Item { Layout.fillHeight: true }
        }
    }

    // Reusable tuning slider component
    component TuningSlider: ColumnLayout {
        id: tuningSliderRoot
        Layout.fillWidth: true
        spacing: 2

        property string label: "Label"
        property string icon: "󰓅"
        property string unit: "W"
        property string description: ""
        property int minVal: 0
        property int maxVal: 100
        property int stepSize: 1
        property int value: 50
        property color accentColor: Theme.blue

        RowLayout {
            spacing: 6

            Text {
                text: tuningSliderRoot.icon
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                color: tuningSliderRoot.accentColor
            }

            Text {
                text: tuningSliderRoot.label
                font.pixelSize: 11
                font.bold: true
                color: Theme.text
            }

            Text {
                text: tuningSliderRoot.description
                font.pixelSize: 9
                color: Theme.overlay0
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: tuningSliderRoot.value + tuningSliderRoot.unit
                font.pixelSize: 11
                font.bold: true
                color: tuningSliderRoot.accentColor
            }
        }

        Slider {
            id: tuningSlider
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            from: tuningSliderRoot.minVal
            to: tuningSliderRoot.maxVal
            stepSize: tuningSliderRoot.stepSize
            value: tuningSliderRoot.value

            onMoved: tuningSliderRoot.value = Math.round(value)

            background: Rectangle {
                x: tuningSlider.leftPadding
                y: tuningSlider.topPadding + tuningSlider.availableHeight / 2 - height / 2
                width: tuningSlider.availableWidth
                height: 4
                radius: 2
                color: Theme.surface1

                Rectangle {
                    width: tuningSlider.visualPosition * parent.width
                    height: parent.height
                    radius: 2
                    color: tuningSliderRoot.accentColor
                }
            }

            handle: Rectangle {
                x: tuningSlider.leftPadding + tuningSlider.visualPosition * (tuningSlider.availableWidth - width)
                y: tuningSlider.topPadding + tuningSlider.availableHeight / 2 - height / 2
                width: 14
                height: 14
                radius: 7
                color: Theme.text
            }
        }
    }
}
