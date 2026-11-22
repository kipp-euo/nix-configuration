import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

QtObject {
    id: root
    property real inputLevel: -1
    property real outputLevel: -1
    property int outputSubscribers: 0
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property string sourceKey: source && source.ready && source.audio && !source.audio.muted && outputSubscribers > 0 ? String(source.id) : ""
    readonly property string sinkKey: sink && sink.ready && sink.audio && !sink.audio.muted && outputSubscribers > 0 ? String(sink.id) : ""
    property bool inputStopping: false
    property bool outputStopping: false
    function acquireOutput() { outputSubscribers++ }
    function releaseOutput() { outputSubscribers = Math.max(0, outputSubscribers - 1) }
    onSourceKeyChanged: {
        inputLevel = -1
        if (inputProc.running) { inputStopping = true; inputProc.running = false }
        inputRestart.interval = 200; inputRestart.restart()
    }
    onSinkKeyChanged: {
        outputLevel = -1
        if (outputProc.running) { outputStopping = true; outputProc.running = false }
        outputRestart.interval = 200; outputRestart.restart()
    }
    property Timer inputRestart: Timer { interval: 200; onTriggered: if (root.sourceKey !== "") inputProc.running = true }
    property Timer outputRestart: Timer { interval: 200; onTriggered: if (root.sinkKey !== "") outputProc.running = true }
    property Timer inputWatchdog: Timer { interval: 1200; onTriggered: root.inputLevel = -1 }
    property Timer outputWatchdog: Timer { interval: 1200; onTriggered: root.outputLevel = -1 }
    property Process inputProc: Process {
        command: [Quickshell.env("QS_AUDIOMETER") || "qs-audiometer", "input"]
        stdout: SplitParser { onRead: data => { const n = Number(data); if (Number.isFinite(n) && n >= 0 && n <= 1) { root.inputLevel = n; inputWatchdog.restart() } } }
        onExited: {
            root.inputLevel = -1
            const intentional = root.inputStopping; root.inputStopping = false
            if (root.sourceKey !== "") { inputRestart.interval = intentional ? 200 : 3000; inputRestart.restart() }
        }
    }
    property Process outputProc: Process {
        command: [Quickshell.env("QS_AUDIOMETER") || "qs-audiometer", "output"]
        stdout: SplitParser { onRead: data => { const n = Number(data); if (Number.isFinite(n) && n >= 0 && n <= 1) { root.outputLevel = n; outputWatchdog.restart() } } }
        onExited: {
            root.outputLevel = -1
            const intentional = root.outputStopping; root.outputStopping = false
            if (root.sinkKey !== "") { outputRestart.interval = intentional ? 200 : 3000; outputRestart.restart() }
        }
    }
}
