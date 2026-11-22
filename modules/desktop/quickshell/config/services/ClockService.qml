import QtQuick

QtObject {
	id: root

	property var currentTime: new Date()

	property Timer tickTimer: Timer {
		interval: 1000
		repeat: true
		running: true
		onTriggered: root.currentTime = new Date()
	}
}
