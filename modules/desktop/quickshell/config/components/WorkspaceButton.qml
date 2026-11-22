import QtQuick
import "../Palette.js" as Palette

Rectangle {
	id: root

	property string label: ""
	property bool active: false
	property bool urgent: false
	signal activated()

	implicitWidth: 30
	implicitHeight: 30
	width: 30
	height: width
	color: active ? Palette.violet : Palette.white
	border.width: 1
	border.color: Palette.black
	radius: 0

	Text {
		anchors.centerIn: parent
		text: root.label
		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 12
		font.weight: root.active ? Font.DemiBold : Font.Normal
		color: root.active ? Palette.white : Palette.black
	}

	Rectangle {
		visible: root.urgent && !root.active
		anchors.right: parent.right
		anchors.top: parent.top
		width: 5
		height: 5
		color: Palette.pink
	}

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		onClicked: root.activated()
	}
}
