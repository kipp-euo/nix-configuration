import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    property var data: ({ zones: [], favorites: [], recent: [], reference: "UTC", error: "", localZone: "", localOffset: "" })
    property string status: "idle"
    property int subscribers: 0
    function acquire() {
        subscribers += 1
        if (!backend.running) backend.running = true
    }
    function release() {
        subscribers = Math.max(0, subscribers - 1)
        if (subscribers === 0) { restart.stop(); backend.running = false; status = "idle" }
    }
    function send(action, id) {
        if (backend.running) backend.write(JSON.stringify({action: action, id: id}) + "\n")
    }
    function zone(id) { return data.zones.find(row => row.id === id) || null }
    function favorite(id) { return data.favorites.indexOf(id) !== -1 }
    property Process backend: Process {
        command: [Quickshell.env("QS_WORLDCLOCK") || "qs-worldclock"]
        stdinEnabled: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                try { root.data = JSON.parse(data); root.status = "ready" }
                catch (e) { root.status = "invalid response"; console.warn("World clock:", e) }
            }
        }
        stderr: SplitParser { onRead: data => console.warn("World clock:", data) }
        onExited: (exitCode, exitStatus) => { root.status = root.subscribers > 0 ? "unavailable" : "idle"; if (root.subscribers > 0) restart.start() }
    }
    property Timer restart: Timer { interval: 5000; onTriggered: backend.running = true }
}
