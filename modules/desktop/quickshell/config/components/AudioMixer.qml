import QtQuick
import "../Palette.js" as Palette
import Quickshell
import Quickshell.Services.Pipewire

Column {
	id: root

	property var applicationGroups: buildApplicationGroups(Pipewire.nodes.values)
	spacing: 8

	function buildApplicationGroups(nodes) {
		const groups = ({})
		for (const node of nodes) {
			if (!node || !node.isStream || !node.audio || !node.ready) continue
			const properties = node.properties || ({})
			const applicationName = properties["application.name"]
				|| properties["application.process.binary"]
				|| node.description
				|| node.name
				|| "Unknown application"
            if (applicationName === "Quickshell Signal Meter") continue
			if (!groups[applicationName]) groups[applicationName] = []
			groups[applicationName].push(node)
		}

		const result = []
		for (const name of Object.keys(groups).sort()) {
			result.push({ key: name, name: name, streams: groups[name] })
		}
		return result
	}

	Text {
		text: "APPLICATIONS"
		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 11
		font.weight: Font.DemiBold
		color: Palette.midViolet
	}

	Repeater {
		model: ScriptModel {
			values: root.applicationGroups
			objectProp: "key"
		}

		delegate: AudioApplicationRow {
			required property var modelData
			applicationName: modelData.name
			streams: modelData.streams
		}
	}

	Text {
		visible: root.applicationGroups.length === 0
		text: "No active application audio streams."
		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 11
		color: Palette.darkGray
	}
}
