import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../Palette.js" as Palette

Column {
    id: root
    property var disks: []
    property var filesystems: []
    property string filesystemError: ""
    property string smartResult: "Choose CHECK to read SMART. Authentication may be requested if access is denied."
    property var smartHealth: ({})
    property string smartDevice: ""
    property bool smartTimedOut: false
    property bool smartNeedsAuth: false
    property bool smartAuthAttempted: false
    property int selectedFilesystem: -1
    readonly property alias ioViewport: ioFlick
    readonly property alias filesystemViewport: fsFlick
    readonly property alias ioRepeater: ioRows
    readonly property alias filesystemRepeater: fsRows
    readonly property int ioRowCount: ioRows.count
    readonly property int filesystemRowCount: fsRows.count
    spacing: 7

    function number(n, decimals) {
        if (n === null || n === undefined || !Number.isFinite(Number(n))) return "N/A"
        return Number(n).toFixed(decimals)
    }
    function gib(n) { return n === null || n === undefined || !Number.isFinite(Number(n)) ? "N/A" : (Number(n) / 1073741824).toFixed(2) }
    function rate(n) { return n === null || n === undefined || !Number.isFinite(Number(n)) ? "N/A" : (Number(n) / 1048576).toFixed(2) }
    function widths(weights) {
        const total = weights.reduce((a, b) => a + b, 0)
        return weights.map(w => Math.max(0, root.width - 2) * w / total)
    }
    readonly property var ioWidths: widths([80, 62, 62, 55, 55, 48, 52, 58])
    readonly property var fsWidths: widths([155, 50, 76, 76, 76, 55])
    function mapping(fs) { return fs.physicalDevices && fs.physicalDevices.length ? fs.physicalDevices.join(", ") + (fs.physicalMappingComplete ? "" : " (partial)") : "N/A" }
    function setHealth(name, value) { const next = Object.assign({}, smartHealth); next[name] = value; smartHealth = next }
    function scan() { if (!filesystemProcess.running) { filesystemError = ""; filesystemProcess.running = true } }
    function smart(name) {
        if (smartProcess.running || !/^[A-Za-z0-9_.-]+$/.test(name) || !disks.some(d => d.name === name)) return
        smartDevice = name; smartResult = "Reading SMART for " + name + "…"; smartTimedOut = false; smartNeedsAuth = false; smartAuthAttempted = false
        setHealth(name, "READING")
        smartProcess.command = [Quickshell.env("QS_SMARTCTL") || "smartctl", "--json", "--health", "--attributes", "/dev/" + name]
        smartProcess.running = true; smartTimeout.restart()
    }
    function retrySmartWithAuthentication() {
        const executable = Quickshell.env("QS_SMARTCTL") || "/run/current-system/sw/bin/smartctl"
        smartAuthAttempted = true
        smartNeedsAuth = false
        smartResult = "Authentication required to read SMART for " + smartDevice + "…"
        smartProcess.command = [Quickshell.env("QS_PKEXEC") || "pkexec", executable, "--json", "--health", "--attributes", "/dev/" + smartDevice]
        smartProcess.running = true
        smartTimeout.restart()
    }
    Component.onCompleted: scan()

    SectionHeader { text: "PHYSICAL DEVICES · I/O" }
    Flickable {
        id: ioFlick
        width: root.width; height: ioColumn.implicitHeight
        contentWidth: width; contentHeight: height; clip: true
        flickableDirection: Flickable.HorizontalFlick; boundsBehavior: Flickable.StopAtBounds
        ScrollBar.horizontal: ScrollBar { policy: ioFlick.contentWidth > ioFlick.width ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff }
        Column {
            id: ioColumn; width: ioFlick.contentWidth; spacing: 2
            DiskTableRow { columnWidths: root.ioWidths; cells: ["DEVICE", "R MiB/s", "W MiB/s", "R IOPS", "W IOPS", "BUSY %", "TEMP °C", "SMART"]; header: true }
            Repeater {
                id: ioRows
                model: root.disks
                delegate: DiskTableRow {
                    required property var modelData
                    columnWidths: root.ioWidths
                    cells: [modelData.name || "N/A", root.rate(modelData.readBytesPerSecond), root.rate(modelData.writeBytesPerSecond), root.number(modelData.readIops, 1), root.number(modelData.writeIops, 1), root.number(modelData.utilization, 1), root.number(modelData.temperatureC, 1), root.smartHealth[modelData.name] || "CHECK"]
                    actionIndex: 7
                    onAction: root.smart(modelData.name)
                }
            }
        }
    }
    Text { visible: root.disks.length === 0; text: "No physical block devices detected."; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: Palette.darkGray }
    Text { width: parent.width; wrapMode: Text.WrapAnywhere; text: root.smartResult; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; color: Palette.darkGray }

    Row {
        width: root.width; spacing: 8
        SectionHeader { text: "LOCAL FILESYSTEMS · CAPACITY"; anchors.verticalCenter: parent.verticalCenter; width: Math.max(0, parent.width - refreshButton.width - parent.spacing); elide: Text.ElideRight }
        ActionButton { id: refreshButton; label: filesystemProcess.running ? "READING…" : "REFRESH FILESYSTEMS"; onClicked: root.scan() }
    }
    Text { visible: root.filesystemError !== ""; width: parent.width; wrapMode: Text.Wrap; text: root.filesystemError; font.pixelSize: 10; color: Palette.darkGray }
    Text { visible: !filesystemProcess.running && root.filesystems.length === 0 && root.filesystemError === ""; text: "No mounted local /dev filesystems detected."; font.pixelSize: 10; color: Palette.darkGray }
    Flickable {
        id: fsFlick
        visible: root.filesystems.length > 0
        width: root.width; height: fsColumn.implicitHeight
        contentWidth: width; contentHeight: height; clip: true
        flickableDirection: Flickable.HorizontalFlick; boundsBehavior: Flickable.StopAtBounds
        ScrollBar.horizontal: ScrollBar { policy: fsFlick.contentWidth > fsFlick.width ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff }
        Column {
            id: fsColumn; width: fsFlick.contentWidth; spacing: 2
            DiskTableRow { columnWidths: root.fsWidths; cells: ["MOUNT", "FS", "USED GiB", "AVAIL GiB", "TOTAL GiB", "USED %"]; header: true }
            Repeater {
                id: fsRows
                model: root.filesystems
                delegate: DiskTableRow {
                    required property var modelData
                    required property int index
                    columnWidths: root.fsWidths; compactFirst: true; actionIndex: 0
                    selected: root.selectedFilesystem === index
                    cells: [modelData.mount || "N/A", modelData.type || "N/A", root.gib(modelData.usedBytes), root.gib(modelData.availableBytes), root.gib(modelData.totalBytes), modelData.totalBytes > 0 && modelData.usedBytes !== undefined ? root.number(100 * modelData.usedBytes / modelData.totalBytes, 1) : "N/A"]
                    onAction: root.selectedFilesystem = root.selectedFilesystem === index ? -1 : index
                }
            }
        }
    }
    Column {
        width: root.width; spacing: 4
        visible: root.selectedFilesystem >= 0 && root.selectedFilesystem < root.filesystems.length
        readonly property var fs: visible ? root.filesystems[root.selectedFilesystem] : ({})
        ValueRow { label: "MOUNT"; value: parent.fs.mount || "N/A" }
        ValueRow { label: "SOURCE"; value: parent.fs.source || "N/A" }
        ValueRow { label: "PHYSICAL"; value: root.mapping(parent.fs) }
    }
    Text { visible: root.filesystems.length > 0 && root.selectedFilesystem < 0; text: "Select a mount for its full path and device details."; width: parent.width; wrapMode: Text.Wrap; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: Palette.black }
    Repeater {
        model: root.filesystems.filter(fs => !!fs.error)
        delegate: Text {
            required property var modelData
            width: root.width; wrapMode: Text.WrapAnywhere
            text: (modelData.mount || "N/A") + ": " + modelData.error
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; color: Palette.darkGray
        }
    }
    Process {
        id: filesystemProcess
        command: [Quickshell.env("QS_FILESYSTEMS") || "qs-filesystems"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { const data = JSON.parse(text); root.filesystems = data.filesystems || []; root.filesystemError = data.error || "" }
                catch (e) { root.filesystemError = "Could not read filesystem capacities: " + e }
            }
        }
        onExited: (code, status) => { if (code !== 0) root.filesystemError = "Filesystem helper exited with code " + code }
    }
    Process {
        id: smartProcess
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.smartTimedOut) return
                try {
                    const data = JSON.parse(text)
                    const messages = data.smartctl && data.smartctl.messages ? data.smartctl.messages.map(m => m.string).join("; ") : ""
                    if (!root.smartAuthAttempted && /permission denied|operation not permitted/i.test(messages)) root.smartNeedsAuth = true
                    const health = data.smart_status && data.smart_status.passed !== undefined ? (data.smart_status.passed ? "PASSED" : "FAILED") : "N/A"
                    const temp = data.temperature && data.temperature.current !== undefined ? " · " + data.temperature.current + " °C" : ""
                    root.setHealth(root.smartDevice, health)
                    root.smartResult = root.smartDevice + ": health " + health + temp + (messages ? "\n" + messages : "")
                } catch (e) { root.setHealth(root.smartDevice, "N/A"); root.smartResult = root.smartDevice + ": SMART output unavailable. Check smartctl availability and device permissions." }
            }
        }
        stderr: StdioCollector { id: smartStderr }
        onExited: (code, status) => {
            smartTimeout.stop()
            if (root.smartTimedOut) return
            if (root.smartNeedsAuth && !root.smartAuthAttempted) { Qt.callLater(root.retrySmartWithAuthentication); return }
            if (root.smartAuthAttempted && code !== 0 && smartStderr.text.trim()) root.smartResult += "\nAuthentication / SMART error: " + smartStderr.text.trim()
            if (code !== 0) root.smartResult += "\nExit status: " + code + " (smartctl uses a bitmask; check device support or authentication)."
        }
    }
    Timer { id: smartTimeout; interval: 30000; onTriggered: { if (smartProcess.running) { root.smartTimedOut = true; smartProcess.running = false; root.setHealth(root.smartDevice, "N/A"); root.smartResult = "SMART request timed out." } } }
}
