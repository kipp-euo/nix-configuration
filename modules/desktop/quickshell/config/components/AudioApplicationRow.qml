import QtQuick
import "../Palette.js" as Palette
import QtQuick.Controls

Rectangle {
	id: root

	property string applicationName: "Unknown application"
	property var streams: []
	property real sharedVolume: {
		if (!streams || streams.length === 0) return 0
		let total = 0
		let count = 0
		for (const stream of streams) {
			if (stream.audio && stream.ready) {
				total += stream.audio.volume
				count += 1
			}
		}
		return count > 0 ? total / count : 0
	}
	property bool allMuted: {
		if (!streams || streams.length === 0) return false
		for (const stream of streams) if (stream.audio && stream.ready && !stream.audio.muted) return false
		return true
	}

	implicitHeight: 62
	height: 62
	width: parent ? parent.width : 420
	color: "transparent"

	function setSharedVolume(value) {
		for (const stream of streams) {
			if (stream.audio && stream.ready) stream.audio.volume = value
		}
	}

	function setSharedMute(value) {
		for (const stream of streams) {
			if (stream.audio && stream.ready) stream.audio.muted = value
		}
	}

	Column {
		anchors.fill: parent
		spacing: 5

		Row {
			width: parent.width
			height: 22
			spacing: 8

			Text {
				width: parent.width - muteButton.width - 12
				text: root.applicationName
				font.family: "JetBrainsMono Nerd Font"
				font.pixelSize: 12
				font.weight: Font.DemiBold
				color: Palette.black
				elide: Text.ElideRight
				anchors.verticalCenter: parent.verticalCenter
			}

			Rectangle {
				id: muteButton
				width: 58
				height: 22
				color: root.allMuted ? Palette.violet : Palette.white
				border.width: 1
				border.color: Palette.black
				Text {
					anchors.centerIn: parent
					text: root.allMuted ? "MUTED" : "MUTE"
					font.family: "JetBrainsMono Nerd Font"
					font.pixelSize: 10
					color: root.allMuted ? Palette.white : Palette.black
				}
				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					onClicked: root.setSharedMute(!root.allMuted)
				}
			}
		}

		Slider {
			id: volumeSlider
			width: parent.width
			height: 24
			from: 0
			to: 1.5
			value: root.sharedVolume
			onMoved: root.setSharedVolume(value)

			background: Rectangle {
				x: volumeSlider.leftPadding
				y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
				width: volumeSlider.availableWidth
				height: 5
				color: Palette.gray

				Rectangle {
					width: volumeSlider.visualPosition * parent.width
					height: parent.height
					color: Palette.violet
				}
			}

			handle: Rectangle {
				x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
				y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
				width: 10
				height: 16
				color: Palette.white
				border.width: 1
				border.color: Palette.black
				radius: 0
			}
		}
	}
}
