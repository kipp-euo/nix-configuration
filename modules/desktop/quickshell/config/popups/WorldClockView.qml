import QtQuick
import QtQuick.Controls
import "../Palette.js" as Palette
import "../components"

Column {
    id: root
    property var service
    property string query: ""
    property var resultIds: []
    readonly property alias resultList: resultList
    function offsetSeconds(text) {
        const match = text.trim().toLowerCase().match(/^(?:utc|gmt)?([+-])(\d{1,2})(?::?(\d{2}))?$/)
        if (!match || Number(match[2]) > 23 || Number(match[3] || 0) > 59) return null
        return (match[1] === "-" ? -1 : 1) * (Number(match[2]) * 3600 + Number(match[3] || 0) * 60)
    }
    function updateResults() {
        if (!service) return
        const q = query.trim().toLowerCase().replace(/_/g, " ")
        const offset = offsetSeconds(q)
        const ids = service.data.zones.filter(z => !q || (offset !== null ? z.offsetSeconds === offset : (z.id + " " + z.label + " " + z.country + " " + z.aliases + " " + z.abbr).toLowerCase().replace(/_/g, " ").includes(q))).map(z => z.id)
        // Keep ListView model identity stable when only clock values change;
        // otherwise the list jumps back to the top every second.
        if (ids.join("\n") !== resultIds.join("\n")) resultIds = ids
    }
    onQueryChanged: updateResults()
    onServiceChanged: updateResults()
    Connections { target: root.service; function onDataChanged() { root.updateResults() } }

    spacing: 8
    function shift(n) { return n === 0 ? "same day" : (n > 0 ? "+" : "") + n + (Math.abs(n) === 1 ? " day" : " days") }
    function delta(n) { const sign = n >= 0 ? "+" : "-"; const mins = Math.floor(Math.abs(n) / 60); return sign + Math.floor(mins / 60) + "h " + (mins % 60) + "m vs local" }
    SectionHeader { text: "WORLD CLOCK EXPLORER" }
    Text { text: root.service ? "Reference: " + root.service.data.reference + " · Local: " + root.service.data.localZone + " UTC" + root.service.data.localOffset : "World clock unavailable"; width: parent.width; wrapMode: Text.Wrap; font.pixelSize: 11; color: Palette.black }
    Text { visible: !!root.service && root.service.data.error !== ""; text: "Could not save clock settings: " + (root.service ? root.service.data.error : ""); width: parent.width; wrapMode: Text.Wrap; color: Palette.darkGray; font.pixelSize: 10 }
    TextField {
        id: search
        width: parent.width
        placeholderText: "City, country, IANA ID, abbreviation or UTC offset"
        onTextChanged: root.query = text
        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
        background: Rectangle { color: Palette.white; border.width: 1; border.color: Palette.black }
    }
    Row {
        spacing: 6
        ActionButton {
            visible: root.offsetSeconds(root.query) !== null
            label: "USE FIXED OFFSET"
            onClicked: { let id = root.query.trim().toUpperCase().replace(/^GMT/, "UTC"); if (!id.startsWith("UTC")) id = "UTC" + id; root.service.send("select", id) }
        }
        Text { text: !root.service || root.service.status === "unavailable" ? "World clock service unavailable" : root.service.status !== "ready" ? "Loading time zones…" : root.resultIds.length + " zones"; font.pixelSize: 10; color: Palette.darkGray; anchors.verticalCenter: parent.verticalCenter }
    }
    SectionHeader { visible: root.service && root.service.data.favorites.length > 0; text: "FAVORITES" }
    Flow {
        width: parent.width; spacing: 5
        Repeater {
            model: root.service ? root.service.data.favorites : []
            ActionButton { required property string modelData; label: modelData; onClicked: root.service.send("select", modelData) }
        }
    }
    SectionHeader { visible: root.service && root.service.data.recent.length > 0; text: "RECENT" }
    Flow {
        width: parent.width; spacing: 5
        Repeater {
            model: root.service ? root.service.data.recent : []
            ActionButton { required property string modelData; label: modelData; onClicked: root.service.send("select", modelData) }
        }
    }
    ListView {
        id: resultList
        width: parent.width; height: root.resultIds.length ? 350 : 0; visible: root.resultIds.length > 0; clip: true
        model: root.resultIds
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
        delegate: Rectangle {
            id: row
            objectName: "timezoneRow"
            required property string modelData
            readonly property var zoneData: root.service.zone(modelData) || ({ id: modelData, label: modelData, country: "", time24: "", date: "", dayShift: 0, time12: "", abbr: "", offset: "", deltaSeconds: 0 })
            width: ListView.view.width; height: 70
            color: row.zoneData.id === root.service.data.reference ? Palette.lightViolet : Palette.white
            border.color: Palette.gray; border.width: 0
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Palette.gray }
            Column {
                anchors.left: parent.left; anchors.leftMargin: 6; anchors.verticalCenter: parent.verticalCenter
                width: Math.max(0, parent.width - 52); spacing: 1
                Row {
                    width: parent.width; spacing: 4
                    Text { width: Math.max(0, parent.width - timeValue.width - parent.spacing); elide: Text.ElideRight; text: row.zoneData.label + (row.zoneData.country ? " · " + row.zoneData.country : ""); font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.bold: true; color: Palette.black }
                    Text { id: timeValue; text: row.zoneData.time24; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.bold: true; color: Palette.black }
                }
                Text { width: parent.width; elide: Text.ElideRight; text: row.zoneData.date + " · " + root.shift(row.zoneData.dayShift) + " · " + row.zoneData.time12; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; color: Palette.black }
                Text { width: parent.width; elide: Text.ElideRight; text: row.zoneData.abbr + " · UTC" + row.zoneData.offset + " / GMT" + row.zoneData.offset + " · " + root.delta(row.zoneData.deltaSeconds); font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9; color: Palette.darkGray }
                Text { width: parent.width; elide: Text.ElideRight; text: row.zoneData.id; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9; color: Palette.darkGray }
            }
            MouseArea { anchors.fill: parent; anchors.rightMargin: 48; onClicked: root.service.send("select", row.zoneData.id) }
            ActionButton { anchors.right: parent.right; anchors.rightMargin: 5; anchors.verticalCenter: parent.verticalCenter; label: root.service.favorite(row.zoneData.id) ? "★" : "☆"; onClicked: root.service.send("favorite", row.zoneData.id) }
        }
    }
}
