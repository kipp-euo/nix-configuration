import QtQuick
import "../Palette.js" as Palette

Rectangle {
	id: root

	property bool active: false
	property string label: ""
	property bool urgent: false

	signal activated

	border.color: Palette.black
	border.width: 1
	border.pixelAligned: true
	color: active ? Palette.violet : hoverHandler.hovered ? Palette.black : Palette.white 
	height: width
	implicitHeight: 30
	implicitWidth: 30
	radius: 0
	width: 30

	Text {
		anchors.centerIn: parent
		color: (root.active || hoverHandler.hovered) ? Palette.white : Palette.black
		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 12
		font.weight: root.active ? Font.DemiBold : Font.Normal
		text: root.label
	}
	Rectangle {
		anchors.right: parent.right
		anchors.top: parent.top
		color: Palette.pink
		height: 5
		visible: root.urgent && !root.active
		width: 5
	}
	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor

		onClicked: root.activated()
	}
	HoverHandler {
		id: hoverHandler
	}
}
