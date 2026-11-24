import QtQuick
import Quickshell
import "../Palette.js" as Palette

Rectangle {
	id: root

	property string appId: ""
	readonly property string applicationName: {
		const id = String(appId || "").trim();
		if (!id)
			return "Desktop";
		if (/(^|[.\-])firefox($|[.\-])/i.test(id))
			return "Firefox";
		if (desktopEntry && desktopEntry.name)
			return desktopEntry.name;
		const part = id.split(".").pop().replace(/[-_]+/g, " ").trim();
		return part || "Unknown application";
	}
	readonly property var desktopEntry: {
		if (!appId)
			return null;
		const direct = DesktopEntries.byId(appId) || DesktopEntries.byId(appId + ".desktop");
		if (direct)
			return direct;
		const matches = DesktopEntries.applications.values.filter(e => e.startupClass && e.startupClass.toLowerCase() === appId.toLowerCase());
		return matches.length === 1 ? matches[0] : null;
	}
	readonly property string iconSource: desktopEntry && desktopEntry.icon ? Quickshell.iconPath(desktopEntry.icon, true) : ""

	signal activated(string moduleId, Item sourceItem)

	border.color: Palette.black
	border.width: 1
	color: Palette.white
	height: 30
	implicitHeight: 30
	implicitWidth: Math.min(220, 10 + 18 + 6 + titleMeasure.implicitWidth + 10)
	radius: 0
	width: implicitWidth

	Text {
		id: titleMeasure

		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 12
		text: root.applicationName
		visible: false
	}
	Row {
		anchors.fill: parent
		anchors.leftMargin: 10
		anchors.rightMargin: 10
		spacing: 6
		visible: root.width > 30

		Item {
			anchors.verticalCenter: parent.verticalCenter
			height: 18
			width: 18

			Image {
				id: appIcon

				anchors.fill: parent
				fillMode: Image.PreserveAspectFit
				source: root.iconSource
				visible: status === Image.Ready
			}
			Text {
				anchors.centerIn: parent
				color: Palette.black
				font.family: "JetBrainsMono Nerd Font"
				font.pixelSize: 13
				text: "󰣆"
				visible: appIcon.status !== Image.Ready
			}
		}
		Text {
			anchors.verticalCenter: parent.verticalCenter
			color: Palette.black
			elide: Text.ElideRight
			font.family: "JetBrainsMono Nerd Font"
			font.pixelSize: 12
			text: root.applicationName
			verticalAlignment: Text.AlignVCenter
			visible: root.width > 50
			width: Math.max(0, parent.width - 24)
		}
	}
	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor

		onClicked: root.activated("window", root)
	}
}
