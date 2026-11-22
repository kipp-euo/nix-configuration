import QtQuick
import "../Palette.js" as Palette
import QtQuick.Controls

Column {
	id: root

	property string label: "DEVICE"
	property var deviceNode
    property real signalLevel: -1
    readonly property alias signalOverlay: signalOverlay

	width: parent ? parent.width : 400
	spacing: 5
	visible: deviceNode && deviceNode.audio && deviceNode.ready

	Row {
		width: parent.width
		spacing: 8

		Text {
			width: parent.width - muteButton.width - parent.spacing
			text: root.deviceNode ? (root.deviceNode.description || root.deviceNode.name || root.label) : root.label
			font.family: "JetBrainsMono Nerd Font"
			font.pixelSize: 11
			font.weight: Font.DemiBold
			color: Palette.black
			elide: Text.ElideRight
			anchors.verticalCenter: parent.verticalCenter
		}

		Rectangle {
			id: muteButton
			width: 58
			height: 22
			color: root.deviceNode && root.deviceNode.audio && root.deviceNode.audio.muted ? Palette.violet : Palette.white
			border.width: 1
			border.color: Palette.black
			Text {
				anchors.centerIn: parent
				text: root.deviceNode && root.deviceNode.audio && root.deviceNode.audio.muted ? "MUTED" : "MUTE"
				font.family: "JetBrainsMono Nerd Font"
				font.pixelSize: 10
				color: root.deviceNode && root.deviceNode.audio && root.deviceNode.audio.muted ? Palette.white : Palette.black
			}
			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: if (root.deviceNode && root.deviceNode.audio) root.deviceNode.audio.muted = !root.deviceNode.audio.muted
			}
		}
	}

	Row {
		width: parent.width
		spacing: 8

		Text {
			text: root.label
			font.family: "JetBrainsMono Nerd Font"
			font.pixelSize: 10
			color: Palette.darkGray
			anchors.verticalCenter: parent.verticalCenter
		}

		Slider {
			id: deviceSlider
			width: parent.width - 98
			height: 24
			from: 0
			to: 1.5
			value: root.deviceNode && root.deviceNode.audio ? root.deviceNode.audio.volume : 0
			onMoved: if (root.deviceNode && root.deviceNode.audio) root.deviceNode.audio.volume = value

			background: Rectangle {
				x: deviceSlider.leftPadding
				y: deviceSlider.topPadding + deviceSlider.availableHeight / 2 - height / 2
				width: deviceSlider.availableWidth
				height: 8
				color: Palette.gray
				Rectangle {
					width: deviceSlider.visualPosition * parent.width
					height: parent.height
					color: Palette.violet
				}
                Rectangle {
                    id: signalOverlay
                    objectName: "signalOverlay"
                    visible: root.signalLevel >= 0 && !(root.deviceNode && root.deviceNode.audio && root.deviceNode.audio.muted)
                    anchors.left: parent.left; anchors.bottom: parent.bottom
                    width: Math.max(0, Math.min(1, root.signalLevel)) * parent.width
                    height: 2; color: Palette.green
                    Behavior on width { enabled: signalOverlay.visible; NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                }
			}

			handle: Rectangle {
				x: deviceSlider.leftPadding + deviceSlider.visualPosition * (deviceSlider.availableWidth - width)
				y: deviceSlider.topPadding + deviceSlider.availableHeight / 2 - height / 2
				width: 10
				height: 16
				color: Palette.white
				border.width: 1
				border.color: Palette.black
				radius: 0
			}
		}

		Text {
			text: root.deviceNode && root.deviceNode.audio ? Math.round(root.deviceNode.audio.volume * 100) + "%" : "N/A"
			font.family: "JetBrainsMono Nerd Font"
			font.pixelSize: 10
			color: Palette.black
			anchors.verticalCenter: parent.verticalCenter
		}
	}
}
