import QtQuick
import "../Palette.js" as Palette
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import "../components"

Rectangle {
	id: root

	property string moduleId: ""
    readonly property real preferredHeight: contentColumn.implicitHeight + 32
	property var telemetry
	property var clockTime: new Date()
	property var worldClock
    property var audioMeter
	property var batteryHistory: []
	property string inspectorSlot: ""
	property var activeWindow: null
	property var inspectorData: root.telemetry && root.telemetry.snapshot.inspectors
		? root.telemetry.snapshot.inspectors[root.inspectorSlot]
		: null
	property string pendingPowerAction: ""
    property string powerMessage: ""
    function executePower(action) {
        if (powerProcess.running) return
        const systemctl = Quickshell.env("QS_SYSTEMCTL") || "systemctl"
        if (action === "shutdown") powerProcess.command = [systemctl, "poweroff"]
        else if (action === "reboot") powerProcess.command = [systemctl, "reboot"]
        else if (action === "uefi" && telemetry && telemetry.snapshot.uefiSetupSupported) powerProcess.command = [systemctl, "reboot", "--firmware-setup"]
        else return
        powerMessage = "Requesting " + action + "…"
        powerProcess.running = true
    }
    Process {
        id: powerProcess
        stderr: StdioCollector { id: powerError }
        onExited: (code, status) => {
            root.powerMessage = code === 0 ? "Power request sent." : "Power request failed (" + code + "): " + (powerError.text.trim() || "Check session permissions and systemd status.")
        }
    }
	property string clockPage: "calendar"
	property string networkSelection: ""
    readonly property var audioOutputs: Pipewire.nodes.values.filter(n => n && !n.isStream && n.isSink && n.audio && n.ready)
    readonly property var audioInputs: Pipewire.nodes.values.filter(n => n && !n.isStream && !n.isSink && n.audio && n.ready)
    property int selectedGpu: 0
    function gpuHistory() {
        return telemetry.history.gpu.map(sample => {
            const gpu = (sample.devices || [])[selectedGpu]
            return { time: sample.time, usage: gpu ? gpu.usage : null, vram: gpu ? gpu.vramUsedBytes : null, gtt: gpu ? gpu.gttUsedBytes : null }
        })
    }
    property string cpuSelection: "all"
    property int selectedCpu: -1
    property int selectedCore: -1
    property int selectedPackage: -1
    function cpuHistory() {
        if (cpuSelection === "all") return telemetry.history.cpu
        return telemetry.history.cpu.map(sample => {
            const cores = sample.cores || []
            if (cpuSelection === "core") {
                const core = cores.find(c => c.coreId === selectedCore && c.packageId === selectedPackage)
                return { time: sample.time, value: core && core.threads.every(t => Number.isFinite(t.usage)) ? core.threads.reduce((sum, t) => sum + t.usage, 0) : null }
            }
            for (const core of cores) {
                const thread = core.threads.find(t => t.cpuId === selectedCpu)
                if (thread) return { time: sample.time, value: thread.usage }
            }
            return { time: sample.time, value: null }
        })
    }
    function coreLoad(threads) {
        if (!threads || !threads.length || !threads.every(t => Number.isFinite(t.usage))) return null
        return threads.reduce((sum, thread) => sum + thread.usage, 0)
    }
    function compactCoverage(count, total) {
        if (count === null || count === undefined || !total || count <= 0) return "Unavailable"
        return count + "/" + total + (count >= total ? " · complete" : " · partial")
    }

    function cpuGraphMaximum() {
        if (cpuSelection !== "core") return 100
        const core = (telemetry.snapshot.cpu.cores || []).find(c => c.coreId === selectedCore && c.packageId === selectedPackage)
        return core ? Math.max(100, core.threads.length * 100) : 100
    }

    function networkRate(key) {
        const devices = telemetry && telemetry.snapshot ? (telemetry.snapshot.networks || []) : []
        if (!networkSelection) {
            if (!devices.length) return null
            let total = 0
            for (const device of devices) {
                const value = device[key]
                if (value === null || value === undefined || !Number.isFinite(Number(value))) return null
                total += Number(value)
            }
            return total
        }
        const device = devices.find(item => item.name === networkSelection)
        if (!device || device[key] === null || device[key] === undefined || !Number.isFinite(Number(device[key]))) return null
        return Number(device[key])
    }

	function networkHistory() {
		if (!networkSelection) return telemetry.history.network
		return telemetry.history.network.map(sample => {
			const entry = (sample.interfaces || []).find(item => item.name === networkSelection)
			return { time: sample.time, rx: entry ? entry.rxBytesPerSecond : null, tx: entry ? entry.txBytesPerSecond : null }
		})
	}

	// Never preserve an armed power action after closing or switching panels.
	onModuleIdChanged: { pendingPowerAction = ""; powerMessage = ""; if (scroll.contentItem) scroll.contentItem.contentY = 0 }

	// Resolve theme colors once in the root context. Repeater delegates can
	// otherwise lose access to imported singleton names in nested contexts.
	readonly property color paletteWhite: Palette.white
	readonly property color paletteBlack: Palette.black
	readonly property color paletteGray: Palette.gray
	readonly property color paletteDarkGray: Palette.darkGray
	readonly property color paletteGreen: Palette.green
	readonly property color paletteViolet: Palette.violet
	readonly property color paletteBlue: Palette.blue
	readonly property color paletteLightViolet: Palette.lightViolet

	color: root.paletteWhite
	border.width: 1
	border.color: root.paletteBlack
	radius: 0

    readonly property string inspectorAppId: activeWindow && activeWindow.handle && activeWindow.handle.appId ? String(activeWindow.handle.appId) : activeWindow && activeWindow.lastIpcObject ? String(activeWindow.lastIpcObject.class || activeWindow.lastIpcObject.initialClass || "") : ""
    readonly property var inspectorEntry: {
        if (!inspectorAppId) return null
        const direct = DesktopEntries.byId(inspectorAppId) || DesktopEntries.byId(inspectorAppId + ".desktop")
        if (direct) return direct
        const matches = DesktopEntries.applications.values.filter(e => e.startupClass && e.startupClass.toLowerCase() === inspectorAppId.toLowerCase())
        return matches.length === 1 ? matches[0] : null
    }
    readonly property string inspectorIcon: inspectorEntry && inspectorEntry.icon ? Quickshell.iconPath(inspectorEntry.icon, true) : ""
    function workspaceLabel() {
        const w = activeWindow && activeWindow.lastIpcObject ? activeWindow.lastIpcObject.workspace : null
        if (!w) return "N/A"
        if (typeof w !== "object") return String(w)
        return String(w.name || w.id || "N/A")
    }
    function advancedWindowFields() {
        const data = activeWindow && activeWindow.lastIpcObject
        if (!data) return []
        const fields = [
            ["VISIBLE", "visible"], ["ACCEPTS INPUT", "acceptsInput"], ["FULLSCREEN CLIENT", "fullscreenClient"],
            ["FULLSCREEN HANDLER", "fullscreenHandler"], ["PIN FULLSCREENED", "pinFullscreened"],
            ["ALLOWED OVER FULLSCREEN", "allowedOverFullscreen"], ["GROUPED WINDOWS", "grouped"],
            ["TAGS", "tags"], ["SWALLOWING", "swallowing"], ["FOCUS HISTORY ID", "focusHistoryID"],
            ["IDLE INHIBITED", "inhibitingIdle"], ["XDG TAG", "xdgTag"], ["XDG DESCRIPTION", "xdgDescription"],
            ["CONTENT TYPE", "contentType"], ["TEARING HINT", "tearingHint"], ["STABLE ID", "stableId"]
        ]
        return fields.filter(f => data[f[1]] !== undefined && data[f[1]] !== null).map(f => ({ label: f[0], value: windowField(f[1]) }))
    }
    function windowField(key) {
        const data = activeWindow && activeWindow.lastIpcObject
        if (!data || data[key] === undefined || data[key] === null) return "N/A"
        const value = data[key]
        if (typeof value === "object") return JSON.stringify(value)
        return String(value)
    }
    function coverage(count, total) {
        if (!total || !count) return "Unavailable"
        return (count === total ? "Available" : "Partial") + " · " + count + "/" + total + " tracked processes"
    }

	function fmtBytes(value, decimals) {
		if (value === null || value === undefined) return "N/A"
		const bytes = Number(value)
		if (!Number.isFinite(bytes)) return "N/A"
		return (bytes / 1073741824).toFixed(decimals === undefined ? 2 : decimals) + " GiB"
	}

    function fmtSmallBytes(value) {
        if (value === null || value === undefined || !Number.isFinite(Number(value))) return "N/A"
        const n = Number(value)
        if (n !== 0 && Math.abs(n) < 1048576) return (n / 1024).toFixed(2) + " KiB"
        if (n !== 0 && Math.abs(n) < 10737418.24) return (n / 1048576).toFixed(2) + " MiB"
        return fmtBytes(n)
    }

	function fmtRate(value) {
		if (value === null || value === undefined) return "N/A"
		const rate = Number(value)
		if (!Number.isFinite(rate)) return "N/A"
		return (rate / 1048576).toFixed(2) + " MiB/s"
	}

	function fmtMhz(value) {
		const mhz = Number(value)
		if (!Number.isFinite(mhz) || mhz <= 0) return "N/A"
		return (mhz / 1000).toFixed(2) + " GHz"
	}

	function fmtNumber(value, suffix) {
		if (value === null || value === undefined) return "N/A"
		const number = Number(value)
		return Number.isFinite(number) ? number.toFixed(1) + (suffix || "") : "N/A"
	}

	ScrollView {
		id: scroll
		anchors.fill: parent
		anchors.margins: 16
		clip: true
		contentWidth: availableWidth
		ScrollBar.vertical.policy: ScrollBar.AsNeeded

		Column {
            id: contentColumn
			width: scroll.availableWidth
			spacing: 14

			Row {
				width: parent.width
                spacing: 10
				Text {
					text: root.moduleId.toUpperCase()
					font.family: "JetBrainsMono Nerd Font"
					font.pixelSize: 14
					font.weight: Font.DemiBold
					color: root.paletteBlack
				}
				Text {
                    anchors.verticalCenter: parent.verticalCenter
					visible: ["cpu", "gpu", "ram", "disk", "network", "window"].includes(root.moduleId)
                    text: root.telemetry ? "TELEMETRY " + root.telemetry.status.toUpperCase() : "NO TELEMETRY"
					font.family: "JetBrainsMono Nerd Font"
					font.pixelSize: 9
					color: root.paletteDarkGray
			}
			}

			Column {
				visible: root.moduleId === "cpu"
				width: parent.width
				spacing: 8
				SectionHeader { text: "CPU OVERVIEW" }
				Row {
					width: parent.width
					spacing: 24
					Text { id: cpuOverviewValue; text: fmtNumber(root.telemetry.snapshot.cpu.usage, "%"); font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 26; font.weight: Font.DemiBold; color: root.paletteGreen }
					Column {
                        width: Math.max(0, parent.width - cpuOverviewValue.width - parent.spacing)
                        spacing: 4
						ValueRow { label: "AVERAGE FREQUENCY"; value: fmtMhz(root.telemetry.snapshot.cpu.frequencyMhz) }
						ValueRow { label: "TEMPERATURE"; value: fmtNumber(root.telemetry.snapshot.cpu.temperatureC, " °C") }
						ValueRow { label: "ONLINE LOGICAL CPUS"; value: String(root.telemetry.snapshot.cpu.onlineCpus) }
					}
				}

                ActionButton { label: root.cpuSelection === "all" ? "GRAPH: ALL CPU" : root.cpuSelection === "core" ? "GRAPH: CORE " + root.selectedCore + " · SHOW ALL" : "GRAPH: CPU " + root.selectedCpu + " · SHOW ALL"; onClicked: root.cpuSelection = "all" }
                HistoryGraph { width: parent.width; points: root.cpuHistory(); series: [{ key: "value", color: root.paletteViolet, label: root.cpuSelection === "core" ? "Core sum" : "CPU" }]; unit: "%"; minimum: 0; maximum: root.cpuGraphMaximum() }
                SectionHeader { text: "CPU FREQUENCY · GHz" }
                HistoryGraph { width: parent.width; points: root.telemetry.history.cpu.map(p => ({time: p.time, value: p.frequency === null || p.frequency === undefined ? null : p.frequency / 1000})); series: [{ key: "value", color: root.paletteBlue, label: "Frequency" }]; unit: "GHz"; autoRange: true }
                SectionHeader { text: "CPU TEMPERATURE · °C" }
                HistoryGraph { width: parent.width; points: root.telemetry.history.cpu.map(p => ({time: p.time, value: p.temperature})); series: [{ key: "value", color: root.paletteGreen, label: "Temperature" }]; unit: "°C"; autoRange: true }

				Row {
					width: parent.width
					spacing: 12
					ValueRow { width: 110; label: "LOAD 1"; value: fmtNumber(root.telemetry.snapshot.cpu.load1, "") }
					ValueRow { width: 110; label: "LOAD 5"; value: fmtNumber(root.telemetry.snapshot.cpu.load5, "") }
					ValueRow { width: 110; label: "LOAD 15"; value: fmtNumber(root.telemetry.snapshot.cpu.load15, "") }
				}
				SectionHeader { text: "PHYSICAL CORES / LOGICAL THREADS" }
                Text { width: parent.width; wrapMode: Text.Wrap; text: root.telemetry.snapshot.cpu.cores && root.telemetry.snapshot.cpu.cores.length ? "Select a core for its summed load, or a thread for its 0–100% load." : "Core topology unavailable."; color: root.paletteDarkGray; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11 }
                Repeater {
                    id: cpuCoreRepeater
                    model: (root.telemetry.snapshot.cpu.cores || []).length
                    delegate: Row {
                        id: coreRow
                        readonly property alias threadRepeater: cpuThreadRepeater
                        required property int index
                        readonly property var modelData: (root.telemetry.snapshot.cpu.cores || [])[index] || ({packageId:0, coreId:0, threads:[]})
                        width: parent.width; height: 46; spacing: 8
                        ActionButton {
                            id: coreButton
                            width: Math.min(190, parent.width * 0.36)
                            height: parent.height
                            label: "P" + modelData.packageId + " CORE " + modelData.coreId + "  " + (root.coreLoad(modelData.threads) === null ? "N/A" : root.coreLoad(modelData.threads).toFixed(0) + "/" + (modelData.threads.length * 100) + "%")
                            backgroundColor: root.cpuSelection === "core" && root.selectedCore === modelData.coreId && root.selectedPackage === modelData.packageId ? root.paletteLightViolet : root.paletteWhite
                            onClicked: { root.selectedCore = modelData.coreId; root.selectedPackage = modelData.packageId; root.cpuSelection = "core" }
                        }
                        Row {
                            id: threadRow
                            property int threadCount: Math.max(1, modelData.threads.length)
                            width: Math.max(0, parent.width - coreButton.width - parent.spacing)
                            spacing: 6
                            Repeater {
                                id: cpuThreadRepeater
                                model: (coreRow.modelData.threads || []).length
                                delegate: CpuLoadTile {
                                    required property int index
                                    readonly property var modelData: (coreRow.modelData.threads || [])[index] || ({cpuId:0, usage:null})
                                    width: Math.max(1, (threadRow.width - threadRow.spacing * (threadRow.threadCount - 1)) / threadRow.threadCount)
                                    cpuId: modelData.cpuId
                                    usage: modelData.usage
                                    selected: root.cpuSelection === "thread" && root.selectedCpu === modelData.cpuId
                                    onActivated: { root.selectedCpu = modelData.cpuId; root.cpuSelection = "thread" }
                                }
                            }
                        }
                    }
                }


			}

			Column {
				visible: root.moduleId === "gpu"
				width: parent.width
				spacing: 8
				SectionHeader { text: "DETECTED GRAPHICS DEVICES" }
                Text { visible: !(root.telemetry.snapshot.gpus && root.telemetry.snapshot.gpus.length); width: parent.width; text: "No supported graphics device detected."; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: root.paletteDarkGray }
                DevicePicker {
                    id: gpuPicker
                    overlayHost: root
                    visible: (root.telemetry.snapshot.gpus || []).length > 0
                    model: (root.telemetry.snapshot.gpus || []).map(gpu => gpu.name || "Unknown GPU")
                    currentIndex: Math.min(root.selectedGpu, Math.max(0, count - 1))
                    onActivated: index => root.selectedGpu = index
                }
                SectionHeader { text: "GPU UTILIZATION · %" }
                HistoryGraph { width: parent.width; points: root.gpuHistory(); series: [{key: "usage", color: root.paletteViolet, label: "GPU"}]; unit: "%"; minimum: 0; maximum: 100 }
                SectionHeader { text: "GPU MEMORY · GiB" }
                HistoryGraph { width: parent.width; points: root.gpuHistory().map(p => ({time: p.time, vram: p.vram === null || p.vram === undefined ? null : p.vram / 1073741824, gtt: p.gtt === null || p.gtt === undefined ? null : p.gtt / 1073741824})); series: [{key: "vram", color: root.paletteBlue, label: "VRAM / buffer"}, {key: "gtt", color: root.paletteGreen, label: "GTT"}]; unit: "GiB"; minimum: 0; maximum: 1; autoRange: true }
                SectionHeader { text: "GPU TEMPERATURE · °C" }
                HistoryGraph { width: parent.width; points: root.telemetry.history.gpu.map(p => ({time: p.time, value: (p.devices || [])[root.selectedGpu] ? p.devices[root.selectedGpu].temperatureC : null})); series: [{key: "value", color: root.paletteGreen, label: "Temperature"}]; unit: "°C"; autoRange: true }

				Repeater {
					model: root.telemetry.snapshot.gpus || []
					delegate: Column {
                        required property int index
						required property var modelData
                        visible: index === Math.min(root.selectedGpu, Math.max(0, gpuPicker.count - 1))
						width: parent.width
						spacing: 5
						Text { text: modelData.name + " · " + modelData.vendor.toUpperCase(); font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.DemiBold; color: root.paletteBlack }
						ValueRow { label: "GPU LOAD"; value: fmtNumber(modelData.usage, "%") }
						ValueRow { label: "TEMPERATURE"; value: fmtNumber(modelData.temperatureC, " °C") }
						ValueRow { label: "CORE FREQUENCY"; value: fmtMhz(modelData.frequencyMhz) }
                        ValueRow { label: "MEMORY FREQUENCY"; value: fmtMhz(modelData.memoryFrequencyMhz) }
                        ValueRow { label: "MEMORY CONTROLLER LOAD"; value: fmtNumber(modelData.memoryUsage, "%") }
						ValueRow { label: "POWER"; value: fmtNumber(modelData.powerW, " W") }
						ValueRow { label: modelData.vendor === "amd" ? "VRAM / FRAMEBUFFER" : "DEDICATED VRAM"; value: fmtBytes(modelData.vramUsedBytes) + " / " + fmtBytes(modelData.vramTotalBytes) }
                        ValueRow { visible: modelData.vendor !== "nvidia"; label: "GTT"; value: fmtBytes(modelData.gttUsedBytes) + " / " + fmtBytes(modelData.gttTotalBytes) }
                        Text { visible: modelData.vendor === "nvidia"; width: parent.width; wrapMode: Text.Wrap; text: "GTT: not exposed by the NVIDIA Linux driver / NVML."; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; color: root.paletteDarkGray }
						Text { text: "Source: " + modelData.source; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9; color: root.paletteDarkGray }
						Rectangle { width: parent.width; height: 1; color: root.paletteGray }
					}
				}
				Text {
					visible: !!root.telemetry.snapshot.gpuStatus
					text: root.telemetry.snapshot.gpuStatus || "No supported GPU telemetry provider found."
					font.family: "JetBrainsMono Nerd Font"
					font.pixelSize: 11
					color: root.paletteDarkGray
					width: parent.width
					wrapMode: Text.Wrap
				}
			}

			Column {
				visible: root.moduleId === "ram"
				width: parent.width
				spacing: 8
				SectionHeader { text: "MEMORY USAGE" }
				Row {
					width: parent.width
					spacing: 16
					Text { text: fmtBytes(root.telemetry.snapshot.memory.usedBytes) + " / " + fmtBytes(root.telemetry.snapshot.memory.totalBytes); font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 20; color: root.paletteBlack }
					Text { text: "Available " + fmtBytes(root.telemetry.snapshot.memory.availableBytes); font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; color: root.paletteDarkGray }
				}
				HistoryGraph { width: parent.width; points: root.telemetry.history.memory; series: [
					{ key: "used", color: root.paletteViolet, label: "Used" },
					{ key: "cached", color: root.paletteBlue, label: "Cached" },
					{ key: "available", color: root.paletteGreen, label: "Available" }
				]; valueDivisor: 1073741824; unit: "GiB"; minimum: 0; maximum: Math.max(1, root.telemetry.snapshot.memory.totalBytes) }
                MetricGrid { metrics: [
                    {label:"USED", value:fmtBytes(root.telemetry.snapshot.memory.usedBytes)},
                    {label:"AVAILABLE", value:fmtBytes(root.telemetry.snapshot.memory.availableBytes)},
                    {label:"CACHED (APPROX.)", value:fmtBytes(root.telemetry.snapshot.memory.cachedBytes)},
                    {label:"FREE", value:fmtBytes(root.telemetry.snapshot.memory.freeBytes)},
                    {label:"BUFFERS", value:fmtBytes(root.telemetry.snapshot.memory.buffersBytes)},
                    {label:"RECLAIMABLE", value:fmtBytes(root.telemetry.snapshot.memory.reclaimableBytes)},
                    {label:"SLAB", value:fmtBytes(root.telemetry.snapshot.memory.slabBytes)},
                    {label:"SHARED MEMORY", value:fmtBytes(root.telemetry.snapshot.memory.shmemBytes)},
                    {label:"PSI SOME · 10s", value:fmtNumber(root.telemetry.snapshot.memory.psiSomeAvg10, "%")}
                ] }
				Rectangle { width: parent.width; height: 1; color: root.paletteGray }
				SectionHeader { text: "SWAP" }
				ValueRow { label: "SWAP USED / TOTAL"; value: fmtBytes(root.telemetry.snapshot.memory.swapUsedBytes) + " / " + fmtBytes(root.telemetry.snapshot.memory.swapTotalBytes) }
                ValueRow { label: "SWAP IN / OUT"; value: root.telemetry.snapshot.memory.swapIoAvailable ? fmtRate(root.telemetry.snapshot.memory.swapInBytesPerSecond) + " / " + fmtRate(root.telemetry.snapshot.memory.swapOutBytesPerSecond) : "N/A" }
                ValueRow { label: "SWAP IN / OUT TOTAL"; value: root.telemetry.snapshot.memory.swapIoAvailable ? fmtBytes(root.telemetry.snapshot.memory.swapInBytes) + " / " + fmtBytes(root.telemetry.snapshot.memory.swapOutBytes) : "N/A" }
                Rectangle { width: parent.width; height: 1; color: root.paletteGray }
                SectionHeader { text: "ZRAM" }
                Text { visible: !(root.telemetry.snapshot.memory.zramCount > 0); text: "No zram devices detected."; font.pixelSize: 10; color: root.paletteDarkGray }
                MetricGrid {
                    visible: root.telemetry.snapshot.memory.zramCount > 0
                    metrics: [
                        {label:"ZRAM DEVICES", value:String(root.telemetry.snapshot.memory.zramCount)},
                        {label:"ZRAM CAPACITY", value:fmtBytes(root.telemetry.snapshot.memory.zramSizeBytes)},
                        {label:"ORIGINAL", value:fmtSmallBytes(root.telemetry.snapshot.memory.zramOriginalBytes)},
                        {label:"COMPRESSED", value:fmtSmallBytes(root.telemetry.snapshot.memory.zramCompressedBytes)},
                        {label:"MEMORY USED", value:fmtSmallBytes(root.telemetry.snapshot.memory.zramMemoryBytes)},
                        {label:"COMPRESSION RATIO", value:root.telemetry.snapshot.memory.zramCompressedBytes > 0 ? (root.telemetry.snapshot.memory.zramOriginalBytes / root.telemetry.snapshot.memory.zramCompressedBytes).toFixed(2) + ":1" : "N/A"},
                        {label:"ALGORITHMS", value:root.telemetry.snapshot.memory.zramAlgorithm || "N/A"}
                    ]
                }
			}

			Column {
				visible: root.moduleId === "disk"
				width: parent.width
				spacing: 8
				SectionHeader { text: "PHYSICAL STORAGE I/O" }
				HistoryGraph { width: parent.width; points: root.telemetry.history.disk; series: [
					{ key: "read", color: root.paletteBlue, label: "Read" },
					{ key: "write", color: root.paletteViolet, label: "Write" }
				]; valueDivisor: 1048576; unit: "MiB/s"; valuePrecision: 3; autoRange: true; minimum: 0; maximum: 1 }

				Loader { width: parent.width; active: root.moduleId === "disk"; sourceComponent: Component { DiskDiagnostics { width: parent.width; disks: root.telemetry.snapshot.disks || [] } } }
			}

			Column {
				visible: root.moduleId === "network"
				width: parent.width
				spacing: 8
				SectionHeader { text: "PHYSICAL NETWORK INTERFACES" }
                DevicePicker {
                    id: networkPicker
                    overlayHost: root
                    model: ["ALL INTERFACES"].concat((root.telemetry.snapshot.networks || []).map(item => item.name))
                    currentIndex: Math.max(0, model.indexOf(root.networkSelection || "ALL INTERFACES"))
                    onActivated: index => root.networkSelection = index === 0 ? "" : model[index]
                }
                ValueRow { label: "DOWNLOAD · " + (root.networkSelection || "ALL"); value: root.fmtRate(root.networkRate("rxBytesPerSecond")) }
                ValueRow { label: "UPLOAD · " + (root.networkSelection || "ALL"); value: root.fmtRate(root.networkRate("txBytesPerSecond")) }
                Text { visible: root.networkSelection !== "" && !(root.telemetry.snapshot.networks || []).some(item => item.name === root.networkSelection); width: parent.width; wrapMode: Text.Wrap; text: "Selected interface is unavailable. Select ALL or another interface."; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: root.paletteDarkGray }
				HistoryGraph { width: parent.width; points: root.networkHistory(); series: [
					{ key: "rx", color: root.paletteGreen, label: "Download" },
					{ key: "tx", color: root.paletteViolet, label: "Upload" }
				]; valueDivisor: 1048576; unit: "MiB/s"; valuePrecision: 3; autoRange: true; minimum: 0; maximum: 1 }
                Column {
                    width: parent.width; spacing: 4
                    readonly property var selectedInterface: (root.telemetry.snapshot.networks || []).find(item => item.name === root.networkSelection) || null
                    visible: !!selectedInterface
                    ValueRow { label: "TYPE / STATE"; value: parent.selectedInterface ? (parent.selectedInterface.type || "N/A") + " / " + (parent.selectedInterface.state || "N/A") : "N/A" }
                    ValueRow { label: "LINK SPEED"; value: fmtNumber(parent.selectedInterface ? parent.selectedInterface.linkSpeedMbps : null, " Mbit/s") }
                    ValueRow { label: "IP"; value: parent.selectedInterface && parent.selectedInterface.addresses && parent.selectedInterface.addresses.length ? parent.selectedInterface.addresses.join(", ") : "N/A" }
                    ValueRow { label: "MAC"; value: parent.selectedInterface ? parent.selectedInterface.mac || "N/A" : "N/A" }
                    ValueRow { label: "RX / TX TOTAL"; value: parent.selectedInterface ? fmtBytes(parent.selectedInterface.rxBytes) + " / " + fmtBytes(parent.selectedInterface.txBytes) : "N/A" }
                }
				Loader { width: parent.width; active: root.moduleId === "network"; sourceComponent: Component { NetworkControls { width: parent.width } } }
			}

			Column {
				visible: root.moduleId === "audio"
				width: parent.width
				spacing: 10
				SectionHeader { text: "OUTPUT DEVICE" }
                Text { objectName: "noAudioOutput"; visible: !(Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.ready && Pipewire.defaultAudioSink.audio); text: "No default output device available."; width: parent.width; wrapMode: Text.Wrap; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; color: root.paletteDarkGray }
				AudioDeviceControl {
					width: parent.width
					label: "OUTPUT"
                    signalLevel: root.audioMeter ? root.audioMeter.outputLevel : -1
					deviceNode: Pipewire.defaultAudioSink
				}
                DevicePicker {
                    id: outputPicker
                    overlayHost: root
                    visible: root.audioOutputs.length > 0
                    model: root.audioOutputs.map(node => node.description || node.name || "Output")
                    currentIndex: Math.max(0, root.audioOutputs.findIndex(node => Pipewire.defaultAudioSink && node.id === Pipewire.defaultAudioSink.id))
                    onActivated: index => { if (root.audioOutputs[index]) Pipewire.preferredDefaultAudioSink = root.audioOutputs[index] }
                }
				Rectangle { width: parent.width; height: 1; color: root.paletteGray }
				SectionHeader { text: "INPUT DEVICE" }
                Text { objectName: "noAudioInput"; visible: !(Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.ready && Pipewire.defaultAudioSource.audio); text: "No default input device available."; width: parent.width; wrapMode: Text.Wrap; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; color: root.paletteDarkGray }
				AudioDeviceControl {
					width: parent.width
					label: "INPUT"
                    signalLevel: root.audioMeter ? root.audioMeter.inputLevel : -1
					deviceNode: Pipewire.defaultAudioSource
				}
                DevicePicker {
                    id: inputPicker
                    overlayHost: root
                    visible: root.audioInputs.length > 0
                    model: root.audioInputs.map(node => node.description || node.name || "Input")
                    currentIndex: Math.max(0, root.audioInputs.findIndex(node => Pipewire.defaultAudioSource && node.id === Pipewire.defaultAudioSource.id))
                    onActivated: index => { if (root.audioInputs[index]) Pipewire.preferredDefaultAudioSource = root.audioInputs[index] }
                }
				Rectangle { width: parent.width; height: 1; color: root.paletteGray }
				AudioMixer { width: parent.width }
			}

			Column {
				visible: root.moduleId === "battery"
				width: parent.width
				spacing: 8
				SectionHeader { text: "POWER SUPPLY" }
				ValueRow { label: "PERCENTAGE"; value: UPower.displayDevice && UPower.displayDevice.ready ? Math.round(UPower.displayDevice.percentage * 100) + "%" : "N/A" }
				ValueRow { label: "STATE"; value: UPower.displayDevice && UPower.displayDevice.ready ? UPowerDeviceState.toString(UPower.displayDevice.state) : "N/A" }
				ValueRow { label: "CHANGE RATE"; value: UPower.displayDevice && UPower.displayDevice.ready ? fmtNumber(UPower.displayDevice.changeRate, " W") : "N/A" }
				ValueRow { label: "ENERGY"; value: UPower.displayDevice && UPower.displayDevice.ready ? fmtNumber(UPower.displayDevice.energy, " Wh") : "N/A" }
				ValueRow { label: "FULL CAPACITY"; value: UPower.displayDevice && UPower.displayDevice.ready ? fmtNumber(UPower.displayDevice.energyCapacity, " Wh") : "N/A" }
				ValueRow { label: "HEALTH"; value: UPower.displayDevice && UPower.displayDevice.healthSupported ? fmtNumber(UPower.displayDevice.healthPercentage, "%") : "N/A" }
				ValueRow { label: "TIME TO EMPTY"; value: UPower.displayDevice && UPower.displayDevice.timeToEmpty > 0 ? Math.round(UPower.displayDevice.timeToEmpty / 60) + " min" : "N/A" }
				ValueRow { label: "TIME TO FULL"; value: UPower.displayDevice && UPower.displayDevice.timeToFull > 0 ? Math.round(UPower.displayDevice.timeToFull / 60) + " min" : "N/A" }
                ValueRow { label: "EXTERNAL POWER"; value: root.telemetry.snapshot.powerDetails.acOnline === null || root.telemetry.snapshot.powerDetails.acOnline === undefined ? "N/A" : root.telemetry.snapshot.powerDetails.acOnline ? "ONLINE" : "OFFLINE" }
                Repeater {
                    model: root.telemetry.snapshot.powerDetails.batteries || []
                    delegate: Column {
                        required property var modelData
                        width: parent.width; spacing: 4
                        SectionHeader { text: "BATTERY " + modelData.name }
                        ValueRow { label: "BATTERY STATUS"; value: modelData.status || "N/A" }
                        ValueRow { label: "ENERGY NOW / FULL"; value: fmtNumber(modelData.energyWh, " Wh") + " / " + fmtNumber(modelData.fullWh, " Wh") }
                        ValueRow { label: "DESIGN ENERGY"; value: fmtNumber(modelData.designWh, " Wh") }
                        ValueRow { label: "CHARGE NOW / FULL"; value: fmtNumber(modelData.chargeAh, " Ah") + " / " + fmtNumber(modelData.fullAh, " Ah") }
                        ValueRow { label: "DESIGN CHARGE"; value: fmtNumber(modelData.designAh, " Ah") }
                        ValueRow { label: "CYCLES"; value: fmtNumber(modelData.cycleCount, "") }
                        ValueRow { label: "POWER · SYSFS"; value: fmtNumber(modelData.powerW, " W") }
                        ValueRow { label: "VOLTAGE / CURRENT"; value: fmtNumber(modelData.voltageV, " V") + " / " + fmtNumber(modelData.currentA, " A") }
                        ValueRow { label: "TEMPERATURE"; value: fmtNumber(modelData.temperatureC, " °C") }
                    }
                }
				SectionHeader { text: "BATTERY POWER HISTORY" }
				HistoryGraph { width: parent.width; points: root.batteryHistory; series: [{ key: "powerW", color: root.paletteViolet, label: "Power" }]; unit: "W"; autoRange: true; minimum: -1; maximum: 1 }
				Text { text: "Battery power is signed (charging positive), from sysfs when available, otherwise UPower. It is not whole-laptop AC power consumption."; width: parent.width; wrapMode: Text.Wrap; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; color: root.paletteDarkGray }
			}

			Column {
				visible: root.moduleId === "window"
				width: parent.width
				spacing: 8

				SectionHeader { text: "APPLICATION / WINDOW" }
                Row {
                    width: parent.width; height: 26; spacing: 8
                    Item {
                        width: 22; height: 22
                        Image { id: inspectorImage; anchors.fill: parent; source: root.inspectorIcon; visible: status === Image.Ready; fillMode: Image.PreserveAspectFit }
                        Text { anchors.centerIn: parent; visible: inspectorImage.status !== Image.Ready; text: "󰣆"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15; color: root.paletteDarkGray }
                    }
                    Text { width: Math.max(0, parent.width - 30); text: root.inspectorEntry ? root.inspectorEntry.name : root.inspectorAppId || "No active application"; elide: Text.ElideRight; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; font.weight: Font.DemiBold; color: root.paletteBlack }
                }
                Text { visible: !root.activeWindow; width: parent.width; wrapMode: Text.Wrap; text: "Focus an application window to inspect its details."; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: root.paletteDarkGray }
                Column {
                    width: parent.width; spacing: 8; visible: !!root.activeWindow
                MetricGrid { metrics: [
                    {label: "APPLICATION ID", value: root.inspectorAppId || "N/A"},
                    {label: "CLASS", value: root.activeWindow && root.activeWindow.lastIpcObject ? String(root.activeWindow.lastIpcObject.class || root.activeWindow.lastIpcObject.initialClass || "N/A") : "N/A"},
                    {label: "PID", value: root.activeWindow && root.activeWindow.lastIpcObject ? String(root.activeWindow.lastIpcObject.pid || "N/A") : "N/A"},
                    {label: "ADDRESS", value: root.activeWindow ? String(root.activeWindow.address) : "N/A"},
                    {label: "INITIAL CLASS", value: root.windowField("initialClass")},
                    {label: "CLIENT PROTOCOL", value: root.windowField("xwayland") === "N/A" ? "N/A" : root.windowField("xwayland") === "true" ? "XWayland" : "Wayland"},
                ] }
                SelectableLine { label: "TITLE"; value: root.activeWindow ? root.activeWindow.title : "N/A" }
                SelectableLine { label: "INITIAL TITLE"; value: root.windowField("initialTitle") }
                SectionHeader { text: "WINDOW / HYPRLAND STATE" }
                MetricGrid { metrics: [
                    {label: "WORKSPACE", value: root.workspaceLabel()},
                    {label: "MONITOR", value: root.windowField("monitor")},
                    {label: "POSITION", value: root.windowField("at")},
                    {label: "SIZE", value: root.windowField("size")},
                    {label: "MAPPED", value: root.windowField("mapped")},
                    {label: "HIDDEN", value: root.windowField("hidden")},
                    {label: "FLOATING", value: root.windowField("floating")},
                    {label: "FULLSCREEN", value: root.windowField("fullscreen")},
                    {label: "PINNED", value: root.windowField("pinned")},
                ] }

				SectionHeader { text: "APPLICATION RESOURCE USAGE" }
                MetricGrid { metrics: [
                    {label: "CPU / TOTAL CAPACITY", value: root.inspectorData && root.inspectorData.available ? fmtNumber(root.inspectorData.cpuNormalizedPercent, "%") : "N/A"},
                    {label: "RESIDENT MEMORY (RSS)", value: root.inspectorData && root.inspectorData.available ? fmtBytes(root.inspectorData.rssBytes, 2) : "N/A"},
                ] }
                ActionButton { label: "MEASURE PSS · ON DEMAND"; onClicked: root.telemetry.requestPss(root.inspectorSlot) }
                ValueRow { label: "PSS · LAST MEASUREMENT"; value: root.inspectorData && root.inspectorData.pssBytes !== null && root.inspectorData.pssBytes !== undefined ? fmtBytes(root.inspectorData.pssBytes, 2) + " · " + root.coverage(root.inspectorData.pssCoverage, root.inspectorData.pssTotal) : "Not measured / unavailable" }
                MetricGrid { metrics: [
                    {label: "VIRTUAL MEMORY (VSZ)", value: root.inspectorData && root.inspectorData.available ? fmtBytes(root.inspectorData.virtualBytes, 2) : "N/A"},
                    {label: "PROCESSES / THREADS", value: root.inspectorData ? root.inspectorData.processCount + " / " + root.inspectorData.threadCount : "N/A"},
                    {label: "DISK READ RATE", value: root.inspectorData && root.inspectorData.available ? fmtRate(root.inspectorData.readBytesPerSecond) : "N/A"},
                    {label: "DISK WRITE RATE", value: root.inspectorData && root.inspectorData.available ? fmtRate(root.inspectorData.writeBytesPerSecond) : "N/A"},
                    {label: "TOTAL READ / WRITE", value: root.inspectorData ? fmtBytes(root.inspectorData.readBytes, 2) + " / " + fmtBytes(root.inspectorData.writeBytes, 2) : "N/A"},
                    {label: "PROCESS UPTIME", value: root.inspectorData ? fmtNumber(root.inspectorData.uptimeSeconds, " s") : "N/A"},
                    {label: "USER / KERNEL CPU TIME", value: root.inspectorData ? fmtNumber(root.inspectorData.userSeconds, " s") + " / " + fmtNumber(root.inspectorData.systemSeconds, " s") : "N/A"},
                    {label: "CONTEXT SWITCHES", value: root.inspectorData ? (root.inspectorData.voluntarySwitches ?? "N/A") + " / " + (root.inspectorData.involuntarySwitches ?? "N/A") : "N/A"},
                    {label: "FILE DESCRIPTORS", value: root.inspectorData && root.inspectorData.fileDescriptors !== null && root.inspectorData.fileDescriptors !== undefined ? String(root.inspectorData.fileDescriptors) : "N/A"},
                    {label: "PRIORITY / NICE", value: root.inspectorData ? (root.inspectorData.priority ?? "N/A") + " / " + (root.inspectorData.nice ?? "N/A") : "N/A"},
                    {label: "PROCESS STATE", value: root.inspectorData ? (root.inspectorData.state || "N/A") : "N/A"},
                ] }

				SectionHeader { text: "COVERAGE AND ATTRIBUTION" }
                MetricGrid { metrics: [
                    {label: "COLLECTION METHOD", value: root.inspectorData ? root.inspectorData.method : "Waiting for active process"},
                    {label: "TRACKED PID", value: root.inspectorData ? String(root.inspectorData.pid) : "N/A"},
                    {label: "PROCESS SOURCE", value: root.inspectorData ? "/proc" : "N/A"},
                    {label: "CPU COVERAGE", value: root.inspectorData ? root.compactCoverage(root.inspectorData.cpuCoverage, root.inspectorData.groupCount) : "Unavailable"},
                    {label: "MEMORY COVERAGE", value: root.inspectorData ? root.compactCoverage(root.inspectorData.memoryCoverage, root.inspectorData.groupCount) : "Unavailable"},
                    {label: "DISK I/O COVERAGE", value: root.inspectorData ? root.compactCoverage(root.inspectorData.ioCoverage, root.inspectorData.groupCount) : "Unavailable"},
                    {label: "FD COVERAGE", value: root.inspectorData ? root.compactCoverage(root.inspectorData.fdCoverage, root.inspectorData.groupCount) : "Unavailable"},
                ] }
                Text { visible: !!root.inspectorData && !!root.inspectorData.issue; width: parent.width; wrapMode: Text.Wrap; text: root.inspectorData ? (root.inspectorData.issue || "") : ""; color: root.paletteDarkGray; font.pixelSize: 10 }
                MetricGrid { metrics: [
                    {label: "GPU PROCESS TELEMETRY", value: "Deferred / not collected"},
                    {label: "NETWORK / THERMAL ATTRIBUTION", value: "Not attributed per application"},
                ] }
                SectionHeader { text: "PROCESSES" }
                MetricGrid { labelFraction: 0.30; metrics: root.inspectorData && root.inspectorData.processes ? root.inspectorData.processes.map(p => ({label:"PID " + p.pid, value:p.name})) : [] }
				Text {
					width: parent.width
					text: "CPU is normalized against all online logical CPUs. RSS values are summed across tracked processes and can include shared pages. Per-process GPU attribution is deferred."
					wrapMode: Text.Wrap
					font.family: "JetBrainsMono Nerd Font"
					font.pixelSize: 10
					color: root.paletteDarkGray
				}

                SectionHeader { visible: root.advancedWindowFields().length > 0; text: "ADVANCED WINDOW STATE" }
                Repeater {
                    model: root.advancedWindowFields()
                    delegate: ValueRow { required property var modelData; width: parent.width; label: modelData.label; value: modelData.value }
                }
                }
			}

			Column {
				visible: root.moduleId === "clock"
				width: parent.width
				spacing: 10
				Row {
					spacing: 6
					ActionButton { label: "CALENDAR"; backgroundColor: root.clockPage === "calendar" ? Palette.lightViolet : Palette.white; onClicked: root.clockPage = "calendar" }
					ActionButton { label: "WORLD CLOCK"; backgroundColor: root.clockPage === "world" ? Palette.lightViolet : Palette.white; onClicked: root.clockPage = "world" }
				}
				Loader {
					width: parent.width
					active: root.moduleId === "clock"
                    visible: active && root.clockPage === "calendar"
					sourceComponent: Component { CalendarView { width: parent.width; currentTime: root.clockTime; worldClock: root.worldClock } }
				}
				Loader {
                    width: parent.width
                    active: root.moduleId === "clock"
                    visible: active && root.clockPage === "world"
                    sourceComponent: Component { WorldClockView { width: parent.width; service: root.worldClock } }
                }
			}

			Column {
				visible: root.moduleId === "power"
				width: parent.width
				spacing: 10
				SectionHeader { text: "SESSION POWER ACTIONS" }
                Text { visible: root.powerMessage !== ""; text: root.powerMessage; width: parent.width; wrapMode: Text.Wrap; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; color: root.paletteDarkGray }
				Text { visible: root.pendingPowerAction === ""; text: "Choose an action. Destructive actions require a second confirmation."; width: parent.width; wrapMode: Text.Wrap; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; color: root.paletteDarkGray }
				Column {
					visible: root.pendingPowerAction === ""
					width: parent.width
					spacing: 8
					Row {
						spacing: 8
						ActionButton { objectName: "powerShutdown"; enabled: !powerProcess.running; label: "SHUTDOWN"; danger: true; onClicked: root.pendingPowerAction = "shutdown" }
						ActionButton { objectName: "powerReboot"; enabled: !powerProcess.running; label: "REBOOT"; onClicked: root.pendingPowerAction = "reboot" }
					}
					ActionButton { objectName: "powerUefi"; enabled: !powerProcess.running; visible: !!root.telemetry.snapshot.uefiSetupSupported; label: "REBOOT TO UEFI"; onClicked: root.pendingPowerAction = "uefi" }
				}
				Column {
					visible: root.pendingPowerAction !== ""
					width: parent.width
					spacing: 8
					Text {
						width: parent.width
						wrapMode: Text.Wrap
						font.family: "JetBrainsMono Nerd Font"
						font.pixelSize: 12
						font.weight: Font.DemiBold
						color: root.paletteBlack
						text: root.pendingPowerAction === "shutdown" ? "Confirm system shutdown?" : root.pendingPowerAction === "reboot" ? "Confirm system reboot?" : "Confirm reboot into UEFI firmware setup? The next boot will open firmware settings."
					}
					Row {
						spacing: 8
						ActionButton {
                            objectName: "powerConfirm"
							label: "CONFIRM"
							danger: true
							onClicked: {
								const action = root.pendingPowerAction
								root.pendingPowerAction = ""
                                root.executePower(action)
							}
						}
						ActionButton { objectName: "powerCancel"; label: "CANCEL"; onClicked: root.pendingPowerAction = "" }
					}
				}
			}

			Text {
				visible: !["cpu", "gpu", "vram", "ram", "disk", "network", "audio", "battery", "window", "clock", "power"].includes(root.moduleId)
				text: "This module is not part of the first build."
				font.family: "JetBrainsMono Nerd Font"
				font.pixelSize: 11
				color: root.paletteDarkGray
			}
		}
	}
}
