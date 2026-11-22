import QtQuick
import Quickshell
import "../Palette.js" as Palette

Rectangle {
	id: root

    readonly property string applicationName: {
        const id = String(appId || "").trim()
        if (!id) return "Desktop"
        if (/(^|[.\-])firefox($|[.\-])/i.test(id)) return "Firefox"
        if (desktopEntry && desktopEntry.name) return desktopEntry.name
        const part = id.split(".").pop().replace(/[-_]+/g, " ").trim()
        return part || "Unknown application"
    }
	property string appId: ""
    readonly property var desktopEntry: {
        if (!appId) return null
        const direct = DesktopEntries.byId(appId) || DesktopEntries.byId(appId + ".desktop")
        if (direct) return direct
        const matches = DesktopEntries.applications.values.filter(e => e.startupClass && e.startupClass.toLowerCase() === appId.toLowerCase())
        return matches.length === 1 ? matches[0] : null
    }
    readonly property string iconSource: desktopEntry && desktopEntry.icon ? Quickshell.iconPath(desktopEntry.icon, true) : ""
	signal activated(string moduleId, Item sourceItem)

	implicitHeight: 30
	height: 30
    implicitWidth: Math.min(220, 7 + 18 + 6 + titleMeasure.implicitWidth + 7)
	width: implicitWidth
    Text { id: titleMeasure; visible: false; text: root.applicationName; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
	color: Palette.white
	border.width: 1
	border.color: Palette.black
	radius: 0

	Row {
		anchors.fill: parent
		anchors.leftMargin: 7
		anchors.rightMargin: 7
		spacing: 6
		visible: root.width > 30

        Item {
            width: 18; height: 18; anchors.verticalCenter: parent.verticalCenter
            Image { id: appIcon; anchors.fill: parent; source: root.iconSource; visible: status === Image.Ready; fillMode: Image.PreserveAspectFit }
            Text { anchors.centerIn: parent; visible: appIcon.status !== Image.Ready; text: "󰣆"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; color: Palette.black }
        }

		Text {
			visible: root.width > 50
			width: Math.max(0, parent.width - 24)
			text: root.applicationName
			font.family: "JetBrainsMono Nerd Font"
			font.pixelSize: 12
			color: Palette.black
			elide: Text.ElideRight
			verticalAlignment: Text.AlignVCenter
			anchors.verticalCenter: parent.verticalCenter
		}
	}

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		onClicked: root.activated("window", root)
	}
}
