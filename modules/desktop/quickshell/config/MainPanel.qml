import QtQuick
import QtQuick.Controls
import QtQuick.Window
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Wayland
import "Palette.js" as Palette
import "components"
import "popups"

Item {
	id: root

	property string activePopup: ""
	property var activeToplevel: Hyprland.activeToplevel
	property var audioMeter
	property bool audioMeterHeld: false
	property var batteryHistory: []
	property var clockTime: new Date()
	property var inspectedToplevel: null
	property int moduleSpacing: 5
	property var panelWindow
	property string pendingInspectorAddress: ""
	property real popupAnchorX: 12
	readonly property int popupGap: 8
	property var screen
	property int sideWidth: Math.max(0, Math.floor((width - workspaceZone.width) / 2 - moduleSpacing))
	property var telemetry
	readonly property var trayItems: SystemTray.items.values.filter(item => item.status !== Status.Passive)
	readonly property int trayWidth: trayItems.length ? 12 + trayItems.length * 26 + Math.max(0, trayItems.length - 1) * 4 : 0
	property var worldClock
	property bool worldClockHeld: false

	function audioPercent(node) {
		return node && node.audio ? Math.round(node.audio.volume * 100) + "%" : "N/A";
	}
	function barRate(value) {
		if (value === null || !Number.isFinite(value))
			return "N/A";
		const rate = value / 1048576;
		return rate.toFixed(rate >= 1000 ? 0 : 1);
	}
	function batteryGlyph(state) {
		if (state === UPowerDeviceState.Charging || state === UPowerDeviceState.PendingCharge)
			return "󰂄";
		if (state === UPowerDeviceState.Discharging || state === UPowerDeviceState.PendingDischarge)
			return "󰂃";
		if (state === UPowerDeviceState.FullyCharged)
			return "󰁹";
		if (state === UPowerDeviceState.Empty)
			return "󰂎";
		return "󰂑";
	}
	function completeTotal(entries, key) {
		if (!entries || entries.length === 0)
			return null;
		let total = 0;
		for (const item of entries) {
			const value = item[key];
			if (value === null || value === undefined || !Number.isFinite(Number(value)))
				return null;
			total += Number(value);
		}
		return total;
	}
	function forceRefresh(moduleId) {
		telemetry.forceRefresh(moduleId);
	}
	function formatGiB(bytes) {
		if (bytes === null || bytes === undefined)
			return "N/A";
		const value = Number(bytes);
		return Number.isFinite(value) ? (value / 1073741824).toFixed(1) + " GiB" : "N/A";
	}
	function formatRate(bytesPerSecond) {
		if (bytesPerSecond === null || bytesPerSecond === undefined)
			return "N/A";
		const value = Number(bytesPerSecond);
		return Number.isFinite(value) ? (value / 1048576).toFixed(1) + " MiB/s" : "N/A";
	}
	function formatTopbarClock(value) {
		const weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
		return weekdays[value.getDay()] + ", " + value.getFullYear() + "-" + pad2(value.getMonth() + 1) + "-" + pad2(value.getDate()) + ", " + pad2(value.getHours()) + ":" + pad2(value.getMinutes()) + ":" + pad2(value.getSeconds());
	}
	function gpuTileValue(gpu, includeFrequency = true) {
		if (!gpu)
			return "N/A";
		const values = [];
		values.push(Number.isFinite(gpu.usage) ? gpu.usage.toFixed(0) + "%" : "N/A");
		if (includeFrequency && Number.isFinite(gpu.frequencyMhz))
			values.push((gpu.frequencyMhz / 1000).toFixed(2) + " GHz");
		if (Number.isFinite(gpu.vramUsedBytes))
			values.push((gpu.vramUsedBytes / 1073741824).toFixed(1) + " GiB VRAM");
		else if (Number.isFinite(gpu.gttUsedBytes))
			values.push((gpu.gttUsedBytes / 1073741824).toFixed(1) + " GiB GTT");
		else
			values.push("MEM N/A");
		return values.length ? values.join(" ") : "N/A";
	}
	function inspectorSlot() {
		return String(screen && screen.name ? screen.name : "screen").replace(/[^A-Za-z0-9_.-]/g, "_");
	}
	function microphoneVolume() {
		const node = Pipewire.defaultAudioSource;
		return "󰍬 " + (node && node.ready ? audioPercent(node) : "N/A");
	}
	function networkGlyph() {
		const interfaces = telemetry.snapshot.networks || [];
		let wifi = false, wired = false;
		for (const device of interfaces) {
			if (device.state !== "up")
				continue;
			if (device.type === "Wi-Fi")
				wifi = true;
			else
				wired = true;
		}
		if (wifi && wired)
			return "󰛳"; // multiple active link types; no default-route assumption
		if (wifi)
			return "󰖩";
		if (wired)
			return "󰈀";
		return "󰖪"; // no physical interface reports an up link
	}
	function pad2(value) {
		const text = String(value);
		return text.length < 2 ? "0" + text : text;
	}
	function ramTileValue(memory) {
		if (!memory || !Number.isFinite(memory.usedBytes))
			return "N/A";
		return (memory.usedBytes / 1073741824).toFixed(1) + " GiB";
	}
	function togglePopup(moduleId, sourceItem) {
		if (activePopup === moduleId) {
			activePopup = "";
			if (moduleId === "window")
				inspectedToplevel = null;
			return;
		}
		if (moduleId === "window") {
			pendingInspectorAddress = activeToplevel ? activeToplevel.address : "";
			inspectedToplevel = activeToplevel;
			Hyprland.refreshToplevels();
			inspectorRefreshTimer.restart();
		} else {
			inspectedToplevel = null;
		}
		activePopup = moduleId;
		const point = sourceItem.mapToItem(root, sourceItem.width / 2, sourceItem.height);
		popupAnchorX = Math.max(8, Math.min(width - 8, point.x));
	}
	function totalDiskRead() {
		return completeTotal(telemetry.snapshot.disks, "readBytesPerSecond");
	}
	function totalDiskWrite() {
		return completeTotal(telemetry.snapshot.disks, "writeBytesPerSecond");
	}
	function totalNetworkRx() {
		return completeTotal(telemetry.snapshot.networks, "rxBytesPerSecond");
	}
	function totalNetworkTx() {
		return completeTotal(telemetry.snapshot.networks, "txBytesPerSecond");
	}
	function updateInspector() {
		if (activePopup !== "window" || !inspectedToplevel) {
			telemetry.clearInspector(inspectorSlot());
			return;
		}
		const client = inspectedToplevel.lastIpcObject || null;
		const pid = client && client.pid ? Number(client.pid) : 0;
		if (pid > 0)
			telemetry.setInspector(inspectorSlot(), pid);
		else
			telemetry.clearInspector(inspectorSlot());
	}

	anchors.fill: parent

	Component.onDestruction: {
		if (worldClockHeld && worldClock)
			worldClock.release();
		if (audioMeterHeld && audioMeter)
			audioMeter.releaseOutput();
		if (telemetry && activePopup === "window")
			telemetry.clearInspector(inspectorSlot());
	}
	onActivePopupChanged: {
		updateInspector();
		if (activePopup === "audio" && audioMeter && !audioMeterHeld) {
			audioMeterHeld = true;
			audioMeter.acquireOutput();
		} else if (activePopup !== "audio" && audioMeterHeld) {
			audioMeterHeld = false;
			if (audioMeter)
				audioMeter.releaseOutput();
		}
		if (activePopup === "clock" && worldClock && !worldClockHeld) {
			worldClockHeld = true;
			worldClock.acquire();
		} else if (activePopup !== "clock" && worldClockHeld) {
			worldClockHeld = false;
			worldClock.release();
		}
	}

	Timer {
		id: inspectorRefreshTimer

		interval: 100
		repeat: false

		onTriggered: {
			if (root.activePopup !== "window")
				return;
			const refreshed = Hyprland.toplevels.values.find(item => item.address === root.pendingInspectorAddress);
			if (refreshed)
				root.inspectedToplevel = refreshed;
			root.updateInspector();
		}
	}
	Row {
		id: leftZone

		readonly property bool compactMetrics: fullCpuMeasure.implicitWidth + fullGpuMeasure.implicitWidth + 68 + Math.min(ramTile.implicitWidth, ramTile.maxWidth) + Math.min(diskTile.implicitWidth, diskTile.maxWidth) + Math.min(networkTile.implicitWidth, networkTile.maxWidth) + spacing * 4 > width
		readonly property var currentGpu: root.telemetry.snapshot.gpus.length ? root.telemetry.snapshot.gpus[0] : null
		readonly property string fullCpuText: (Number.isFinite(root.telemetry.snapshot.cpu.usage) ? root.telemetry.snapshot.cpu.usage.toFixed(0) + "%" : "N/A") + (Number.isFinite(root.telemetry.snapshot.cpu.frequencyMhz) ? " " + (root.telemetry.snapshot.cpu.frequencyMhz / 1000).toFixed(2) + " GHz" : "")
		readonly property real naturalTileWidth: Math.min(cpuTile.implicitWidth, cpuTile.maxWidth) + Math.min(gpuTile.implicitWidth, gpuTile.maxWidth) + Math.min(ramTile.implicitWidth, ramTile.maxWidth) + Math.min(diskTile.implicitWidth, diskTile.maxWidth) + Math.min(networkTile.implicitWidth, networkTile.maxWidth)
		readonly property real scaleFactor: naturalTileWidth > 0 ? Math.max(0, Math.min(1, (width - spacing * 4) / naturalTileWidth)) : 1

		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
		clip: true
		height: 30
		spacing: root.moduleSpacing
		width: root.sideWidth

		Text {
			id: fullCpuMeasure

			font.family: "JetBrainsMono Nerd Font"
			font.pixelSize: 12
			text: leftZone.fullCpuText
			visible: false
		}
		Text {
			id: fullGpuMeasure

			font.family: "JetBrainsMono Nerd Font"
			font.pixelSize: 12
			text: root.gpuTileValue(leftZone.currentGpu)
			visible: false
		}
		MetricTile {
			id: cpuTile

			glyph: "󰻠"
			maxWidth: 240
			moduleId: "cpu"
			tooltipText: "CPU · left click: details · right click: refresh"
			valueText: leftZone.compactMetrics ? (Number.isFinite(root.telemetry.snapshot.cpu.usage) ? root.telemetry.snapshot.cpu.usage.toFixed(0) + "%" : "N/A") : leftZone.fullCpuText
			width: Math.min(implicitWidth, maxWidth) * leftZone.scaleFactor

			onActivated: (id, source) => root.togglePopup(id, source)
			onRefreshRequested: id => root.forceRefresh(id)
		}
		MetricTile {
			id: gpuTile

			glyph: "󰢮"
			maxWidth: 320
			moduleId: "gpu"
			tooltipText: "GPU · left click: details · right click: refresh"
			valueText: root.gpuTileValue(leftZone.currentGpu, !leftZone.compactMetrics)
			width: Math.min(implicitWidth, maxWidth) * leftZone.scaleFactor

			onActivated: (id, source) => root.togglePopup(id, source)
			onRefreshRequested: id => root.forceRefresh(id)
		}
		MetricTile {
			id: ramTile

			glyph: ""
			maxWidth: 220
			moduleId: "ram"
			tooltipText: "RAM · left click: details · right click: refresh"
			valueText: root.ramTileValue(root.telemetry.snapshot.memory)
			width: Math.min(implicitWidth, maxWidth) * leftZone.scaleFactor

			onActivated: (id, source) => root.togglePopup(id, source)
			onRefreshRequested: id => root.forceRefresh(id)
		}
		MetricTile {
			id: diskTile

			glyph: "󰋊"
			maxWidth: 270
			moduleId: "disk"
			tooltipText: "Physical disk I/O · left click: details · right click: refresh"
			valueText: "R " + root.barRate(root.totalDiskRead()) + " W " + root.barRate(root.totalDiskWrite()) + " MiB/s"
			width: Math.min(implicitWidth, maxWidth) * leftZone.scaleFactor

			onActivated: (id, source) => root.togglePopup(id, source)
			onRefreshRequested: id => root.forceRefresh(id)
		}
		MetricTile {
			id: networkTile

			glyph: root.networkGlyph()
			maxWidth: 270
			moduleId: "network"
			tooltipText: "Physical network interfaces · left click: details · right click: refresh"
			valueText: "↓ " + root.barRate(root.totalNetworkRx()) + " ↑ " + root.barRate(root.totalNetworkTx()) + " MiB/s"
			width: Math.min(implicitWidth, maxWidth) * leftZone.scaleFactor

			onActivated: (id, source) => root.togglePopup(id, source)
			onRefreshRequested: id => root.forceRefresh(id)
		}
	}
	Row {
		id: workspaceZone

		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
		height: 30
		spacing: 4

		Repeater {
			model: Hyprland.workspaces

			delegate: WorkspaceButton {
				required property var modelData

				active: modelData.active
				label: modelData.name && modelData.name.length > 0 ? modelData.name : String(modelData.id)
				urgent: modelData.urgent
				visible: modelData.monitor && modelData.monitor.name === root.screen.name

				onActivated: modelData.activate()
			}
		}
	}
	Row {
		id: rightZone

		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		height: 30
		spacing: root.moduleSpacing
		width: implicitWidth

		WindowTitleTile {
			id: windowTile

			appId: root.activeToplevel && root.activeToplevel.handle && root.activeToplevel.handle.appId ? root.activeToplevel.handle.appId : root.activeToplevel && root.activeToplevel.lastIpcObject ? (root.activeToplevel.lastIpcObject.class || root.activeToplevel.lastIpcObject.initialClass || "") : ""
			width: Math.min(implicitWidth, Math.max(0, root.sideWidth - (trayContainer.width + audioTile.width + batteryTile.width + languageTile.width + clockTile.width + powerTile.width + root.moduleSpacing * 6)))

			onActivated: (id, source) => root.togglePopup(id, source)
		}
		Rectangle {
			id: trayContainer

			border.color: Palette.black
			border.width: 1
			color: Palette.white
			height: 30
			visible: root.trayWidth > 0
			width: root.trayWidth

			Row {
				anchors.centerIn: parent
				spacing: 4

				Repeater {
					id: trayRepeater

					model: root.trayItems

					delegate: TrayIcon {
						required property var modelData

						// display() expects Quickshell's PanelWindow wrapper,
						// not the underlying Qt Window.window.
						hostWindow: root.panelWindow
						trayItem: modelData
					}
				}
			}
		}
		MetricTile {
			id: audioTile

			glyph: "󰕾"
			horizontalPadding: 7
			maxWidth: 160
			moduleId: "audio"
			valueText: root.audioPercent(Pipewire.defaultAudioSink) + "  " + root.microphoneVolume()

			onActivated: (id, source) => root.togglePopup(id, source)
			onRefreshRequested: id => root.forceRefresh(id)
		}
		MetricTile {
			id: batteryTile

			glyph: root.batteryGlyph(UPower.displayDevice && UPower.displayDevice.ready ? UPower.displayDevice.state : UPowerDeviceState.Unknown)
			horizontalPadding: 7
			maxWidth: 80
			moduleId: "battery"
			valueText: UPower.displayDevice && UPower.displayDevice.ready ? Math.round(UPower.displayDevice.percentage * 100) + "%" : "—"
			visible: !!(UPower.displayDevice && UPower.displayDevice.ready && UPower.displayDevice.isLaptopBattery)
			width: visible ? Math.min(implicitWidth, maxWidth) : 0

			onActivated: (id, source) => root.togglePopup(id, source)
			onRefreshRequested: id => root.forceRefresh(id)
		}
		Rectangle {
			id: languageTile

			border.color: Palette.black
			border.width: 1
			color: Palette.white
			height: 30
			width: root.telemetry.snapshot.keyboardLayout === "RU" || root.telemetry.snapshot.keyboardLayout === "EN" ? 42 : Math.max(42, Math.min(120, languageText.implicitWidth + 14))

			Image {
				id: keyboardFlag

				anchors.centerIn: parent
				fillMode: Image.PreserveAspectFit
				height: 18
				smooth: true
				source: root.telemetry.snapshot.keyboardLayout === "RU" ? "icons/flag-ru.png" : root.telemetry.snapshot.keyboardLayout === "EN" ? "icons/flag-us.png" : ""
				visible: root.telemetry.snapshot.keyboardLayout === "RU" || root.telemetry.snapshot.keyboardLayout === "EN"
				width: 28
			}
			Text {
				id: languageText

				anchors.centerIn: parent
				color: Palette.darkGray
				elide: Text.ElideRight
				font.family: "JetBrainsMono Nerd Font"
				font.pixelSize: 10
				text: root.telemetry.snapshot.keyboardLayout || "N/A"
				visible: root.telemetry.snapshot.keyboardLayout !== "RU" && root.telemetry.snapshot.keyboardLayout !== "EN"
				width: Math.min(implicitWidth, Math.max(0, parent.width - 14))
			}
		}
		MetricTile {
			id: clockTile

			glyph: "󰥔"
			horizontalPadding: 7
			maxWidth: 240
			moduleId: "clock"
			valueText: root.formatTopbarClock(root.clockTime)

			onActivated: (id, source) => root.togglePopup(id, source)
			onRefreshRequested: id => root.forceRefresh(id)
		}
		Rectangle {
			id: powerTile

			border.color: Palette.black
			border.width: 1
			color: Palette.white
			height: width
			width: 30

			Canvas {
				anchors.centerIn: parent
				height: 16
				width: 16

				onPaint: {
					const ctx = getContext("2d");
					ctx.reset();
					ctx.strokeStyle = Palette.black;
					ctx.lineWidth = 1.8;
					ctx.lineCap = "round";
					ctx.beginPath();
					ctx.arc(8, 8.5, 5, -Math.PI / 4, Math.PI * 5 / 4);
					ctx.stroke();
					ctx.beginPath();
					ctx.moveTo(8, 2);
					ctx.lineTo(8, 8.5);
					ctx.stroke();
				}
			}
			MouseArea {
				acceptedButtons: Qt.LeftButton | Qt.RightButton
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor

				onClicked: mouse => {
					if (mouse.button === Qt.LeftButton)
						root.togglePopup("power", powerTile);
					else if (mouse.button === Qt.RightButton)
						root.forceRefresh("power");
				}
			}
		}
	}

	// A non-grabbing xdg PopupWindow cannot reliably receive keyboard input
	// when its layer-shell parent is non-focusable. A separate on-demand
	// layer window supports text input without auto-closing on outside clicks.
	PanelWindow {
		id: popupWindow

		WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
		WlrLayershell.namespace: "quickshell-topbar-popup"
		anchors.left: true
		anchors.top: true
		color: "transparent"
		exclusionMode: ExclusionMode.Ignore
		implicitHeight: Math.min(Math.max(1, Math.floor((root.screen ? root.screen.height : 1080) * 2 / 3) - (12 + root.height + root.popupGap)), Math.max(1, popupPanel.preferredHeight))
		implicitWidth: Math.min(root.activePopup === "power" ? 420 : (root.activePopup === "audio" || root.activePopup === "battery") ? 540 : 620, Math.max(1, root.width - 16))
		margins.left: 12 + Math.max(0, Math.min(root.width - width, root.popupAnchorX - width / 2))
		margins.top: 12 + root.height + root.popupGap
		screen: root.screen
		visible: root.activePopup !== ""

		PopupPanel {
			id: popupPanel

			activeWindow: root.inspectedToplevel
			anchors.fill: parent
			audioMeter: root.audioMeter
			batteryHistory: root.batteryHistory
			clockTime: root.clockTime
			inspectorSlot: root.inspectorSlot()
			moduleId: root.activePopup
			telemetry: root.telemetry
			worldClock: root.worldClock
		}
	}
}
