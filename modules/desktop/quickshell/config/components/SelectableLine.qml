import QtQuick
import QtQuick.Controls
import "../Palette.js" as Palette

Column {
	id: root

	property string label: ""
	property string value: ""

	spacing: 3
	width: parent ? parent.width : 400

	Text {
		color: Palette.black
		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 11
		text: root.label
	}
	TextEdit {
		id: textValue

		ToolTip.text: root.value
		ToolTip.visible: hover.hovered && textValue.contentWidth > textValue.width
		clip: true
		color: Palette.black
		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 12
		font.weight: Font.DemiBold
		persistentSelection: true
		readOnly: true
		selectByMouse: true
		text: root.value
		width: parent.width
		wrapMode: TextEdit.NoWrap

		HoverHandler {
			id: hover
		}
	}
}
