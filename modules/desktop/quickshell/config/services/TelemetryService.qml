import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

QtObject {
	id: root

	property var snapshot: ({
		cpu: ({ usage: null, frequencyMhz: null, temperatureC: null, load1: 0, load5: 0, load15: 0, onlineCpus: 0, cores: [] }),
		gpus: [],
		gpuStatus: "Waiting for GPU provider detection",
        powerDetails: ({ batteries: [], acOnline: null }),
		fans: [],
		hwmonTemperatures: [],
		memory: ({ totalBytes: null, usedBytes: null, availableBytes: null, cachedBytes: null, swapTotalBytes: null, swapUsedBytes: null, zramOriginalBytes: null, zramCompressedBytes: null, zramMemoryBytes: null, zramAlgorithm: "" }),
		disks: [],
		networks: [],
		keyboardLayout: "N/A",
		uefiSetupSupported: false,
		inspectors: ({})
	})

	property var history: ({ cpu: [], memory: [], gpu: [], disk: [], network: [] })
	property int historyCapacity: 3600
	property string status: "starting"
    property var refreshLastMs: ({})
    property string keyboardError: ""
    property string keyboardBeforeSwitch: ""

	signal snapshotUpdated(var data)
	signal collectorError(string message)

	function appendHistory(seriesName, sample) {
		const updatedSeries = history[seriesName].slice(0)
		updatedSeries.push(sample)
		if (updatedSeries.length > historyCapacity) {
			updatedSeries.splice(0, updatedSeries.length - historyCapacity)
		}

		const updatedHistory = ({})
		for (const key in history) updatedHistory[key] = history[key]
		updatedHistory[seriesName] = updatedSeries
		history = updatedHistory
	}

	function ingestLine(line) {
		const trimmed = String(line).trim()
		if (trimmed.length === 0) return

		try {
			const patch = JSON.parse(trimmed)
			const merged = ({})
			for (const key in snapshot) merged[key] = snapshot[key]
			for (const key in patch) merged[key] = patch[key]
			snapshot = merged
            if (patch.keyboardLayout && patch.keyboardLayout !== keyboardBeforeSwitch && keyboardError.startsWith("Layout did not change.")) keyboardError = ""
			status = "ready"

			const time = patch.timestampMs || Date.now()
			if (patch.cpu) appendHistory("cpu", { time: time, value: patch.cpu.usage, frequency: patch.cpu.frequencyMhz, temperature: patch.cpu.temperatureC, cores: patch.cpu.cores || [] })
			if (patch.memory) appendHistory("memory", {
				time: time,
					used: patch.memory.usedBytes,
					cached: patch.memory.cachedBytes,
					available: patch.memory.availableBytes
			})
			if (patch.gpus) appendHistory("gpu", { time: time, devices: patch.gpus })
			if (patch.disks) appendHistory("disk", { time: time, read: totalDiskRead(), write: totalDiskWrite() })
			if (patch.networks) appendHistory("network", { time: time, rx: totalNetworkRx(), tx: totalNetworkTx(), interfaces: patch.networks })

			snapshotUpdated(snapshot)
		} catch (error) {
			status = "parse-error"
			collectorError("Invalid telemetry JSON: " + error)
		}
	}

	function forceRefresh(moduleId) {
		if (!collectorProcess.running) return

		let group = ""
		switch (moduleId) {
		case "cpu": group = "cpu"; break
		case "gpu": group = "gpu"; break
		case "vram": group = "vram"; break
		case "ram": group = "ram"; break
		case "disk": group = "disk"; break
		case "network": group = "network"; break
        case "battery": group = "battery"; break
		default: return
		}
        const throttleKey = group === "vram" ? "gpu" : group
        const now = Date.now()
        if (refreshLastMs[throttleKey] !== undefined && now - refreshLastMs[throttleKey] < 750) return
        const updated = Object.assign({}, refreshLastMs); updated[throttleKey] = now; refreshLastMs = updated
		collectorProcess.write("refresh " + group + "\n")
	}

	function setInspector(slot, pid) {
		if (!collectorProcess.running || !slot || !Number.isFinite(Number(pid)) || Number(pid) <= 0) return
		collectorProcess.write("inspect " + String(slot) + " " + Math.trunc(Number(pid)) + "\n")
	}

    function requestPss(slot) {
        if (collectorProcess.running && slot) collectorProcess.write("pss " + String(slot) + "\n")
    }

	function clearInspector(slot) {
		if (!collectorProcess.running || !slot) return
		collectorProcess.write("uninspect " + String(slot) + "\n")
	}

    function completeTotal(entries, key) {
        if (!entries || entries.length === 0) return null
        let total = 0
        for (const item of entries) {
            const value = item[key]
            if (value === null || value === undefined || !Number.isFinite(Number(value))) return null
            total += Number(value)
        }
        return total
    }
    function totalDiskRead() { return completeTotal(snapshot.disks, "readBytesPerSecond") }
    function totalDiskWrite() { return completeTotal(snapshot.disks, "writeBytesPerSecond") }
    function totalNetworkRx() { return completeTotal(snapshot.networks, "rxBytesPerSecond") }
    function totalNetworkTx() { return completeTotal(snapshot.networks, "txBytesPerSecond") }

    function switchKeyboardLayout() {
        if (collectorProcess.running) { keyboardError = ""; keyboardBeforeSwitch = snapshot.keyboardLayout; collectorProcess.write("switch keyboard\n"); keyboardVerify.restart() }
        else keyboardError = "Telemetry collector is not running; layout switch was not sent."
    }
    function refreshKeyboard() {
        if (collectorProcess.running) collectorProcess.write("refresh keyboard\n")
    }
    property Timer keyboardVerify: Timer {
        interval: 1500
        onTriggered: {
            root.refreshKeyboard()
            if (!root.keyboardError && root.snapshot.keyboardLayout === root.keyboardBeforeSwitch)
                root.keyboardError = "Layout did not change. Check configured layouts and the active keyboard in Hyprland."
        }
    }
    // Hyprland emits one event per keyboard; coalesce them and query the
    // main keyboard rather than trusting the last event from any device.
    property Connections keyboardEvents: Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activelayout") keyboardRefreshTimer.restart()
        }
    }
    property Timer keyboardRefreshTimer: Timer {
        interval: 75
        onTriggered: root.refreshKeyboard()
    }

	property Process collectorProcess: Process {
		command: [Quickshell.env("QS_TELEMETRY") || "qs-telemetry"]
		stdinEnabled: true
		running: true

		stdout: SplitParser {
			splitMarker: "\n"
			onRead: data => root.ingestLine(data)
		}

		stderr: SplitParser {
			onRead: data => {
                const message = String(data).trim()
                if (message.startsWith("Keyboard layout switch failed:")) root.keyboardError = message
				root.collectorError(message)
				console.warn("qs-telemetry:", data)
			}
		}

		onStarted: root.status = "ready"
		onExited: (exitCode, exitStatus) => {
			root.status = "restarting"
			restartTimer.start()
		}
	}

	property Timer restartTimer: Timer {
		interval: 2000
		repeat: false
		onTriggered: collectorProcess.running = true
	}
}
