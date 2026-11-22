import QtQuick
import "../Palette.js" as Palette

Rectangle {
	id: root

	property string label: ""
	property bool danger: false
	property color backgroundColor: Palette.white
	signal clicked()

	implicitWidth: labelText.implicitWidth + 24
	implicitHeight: 30
	width: implicitWidth
	height: 30
	color: danger ? Palette.pink : root.backgroundColor
	border.width: 1
	border.color: Palette.black
	radius: 0

	Text {
		id: labelText
		anchors.centerIn: parent
        width: Math.max(0, parent.width - 16)
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
		text: root.label
		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 12
		font.weight: Font.DemiBold
		color: Palette.black
	}

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		onClicked: root.clicked()
	}
}
