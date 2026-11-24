import QtQuick
import "../Palette.js" as Palette

Rectangle {
	id: root

	property color backgroundColor: Palette.white
	property bool danger: false
	property string label: ""

	signal clicked

	border.color: Palette.black
	border.width: 1
	color: danger ? Palette.pink : root.backgroundColor
	height: 30
	implicitHeight: 30
	implicitWidth: labelText.implicitWidth + 24
	radius: 0
	width: implicitWidth

	Text {
		id: labelText

		anchors.centerIn: parent
		color: Palette.black
		elide: Text.ElideRight
		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 12
		font.weight: Font.DemiBold
		horizontalAlignment: Text.AlignHCenter
		text: root.label
		width: Math.max(0, parent.width - 16)
	}
	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor

		onClicked: root.clicked()
	}
}
