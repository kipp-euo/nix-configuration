import QtQuick
import "../Palette.js" as Palette

Rectangle {
	id: root

	property string moduleId: ""
	property string glyph: ""
	property string valueText: ""
	property string tooltipText: moduleId
	property int horizontalPadding: 7
	property int maxWidth: 180

	signal activated(string moduleId, Item sourceItem)
	signal refreshRequested(string moduleId)

    // Measure text rather than reserving a fixed width for every tile.
    implicitWidth: glyphText.implicitWidth + (root.valueText.length ? content.spacing + valueMeasure.implicitWidth : 0) + horizontalPadding * 2 + 2
    readonly property bool textFits: !valueLabel.truncated
	implicitHeight: 30
	height: 30
	width: Math.min(maxWidth, implicitWidth)
	color: Palette.white
	border.width: 1
	border.color: Palette.black
	radius: 0

    // Measure with an unconstrained Text: the displayed label is elided and
    // its implicit width can be affected by its current allocated width.
    Text { id: valueMeasure; visible: false; text: root.valueText; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.Light }

	Row {
		id: content
		anchors.centerIn: parent
		width: Math.max(0, root.width - root.horizontalPadding * 2)
		spacing: 5

		Text {
			id: glyphText
			text: root.glyph
			font.family: "JetBrainsMono Nerd Font"
			font.pixelSize: 14
			color: Palette.black
			anchors.verticalCenter: parent.verticalCenter
		}

		Text {
            id: valueLabel
			width: Math.max(0, parent.width - glyphText.implicitWidth - parent.spacing)
			text: root.valueText
			font.family: "JetBrainsMono Nerd Font"
			font.pixelSize: 12
            font.weight: Font.Light
			color: Palette.black
			anchors.verticalCenter: parent.verticalCenter
			elide: Text.ElideRight
		}
	}

	MouseArea {
		anchors.fill: parent
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		cursorShape: Qt.PointingHandCursor

		onClicked: mouse => {
			if (mouse.button === Qt.LeftButton) root.activated(root.moduleId, root)
			else if (mouse.button === Qt.RightButton) root.refreshRequested(root.moduleId)
		}
	}
}
