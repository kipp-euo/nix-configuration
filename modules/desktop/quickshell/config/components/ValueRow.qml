import QtQuick
import "../Palette.js" as Palette

Row {
	id: root

	property string label: ""
	property string value: "—"
	property color valueColor: Palette.black

	width: parent ? parent.width : 400
	height: Math.max(labelText.implicitHeight, valueLabel.height)
	spacing: 12

	Text {
		id: labelText
		width: Math.max(0, parent.width - valueLabel.width - parent.spacing)
		text: root.label
		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 12
		color: Palette.black
		elide: Text.ElideRight
	}

	TextEdit {
		id: valueLabel
        readOnly: true; selectByMouse: true; persistentSelection: true
        horizontalAlignment: TextEdit.AlignRight
        width: Math.min(implicitWidth, Math.max(0, parent.width * 0.65))
        wrapMode: TextEdit.Wrap
		text: root.value
		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 12
		font.weight: Font.DemiBold
		color: root.valueColor
	}
}
