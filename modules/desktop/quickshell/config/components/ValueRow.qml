import QtQuick
import "../Palette.js" as Palette

Row {
	id: root

	property string label: ""
	property string value: "—"
	property color valueColor: Palette.black

	height: Math.max(labelText.implicitHeight, valueLabel.height)
	spacing: 12
	width: parent ? parent.width : 400

	Text {
		id: labelText

		color: Palette.black
		elide: Text.ElideRight
		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 12
		text: root.label
		width: Math.max(0, parent.width - valueLabel.width - parent.spacing)
	}
	TextEdit {
		id: valueLabel

		color: root.valueColor
		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 12
		font.weight: Font.DemiBold
		horizontalAlignment: TextEdit.AlignRight
		persistentSelection: true
		readOnly: true
		selectByMouse: true
		text: root.value
		width: Math.min(implicitWidth, Math.max(0, parent.width * 0.65))
		wrapMode: TextEdit.Wrap
	}
}
