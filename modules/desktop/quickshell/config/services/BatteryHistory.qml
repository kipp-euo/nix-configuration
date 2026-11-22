import QtQuick
import Quickshell.Services.UPower

QtObject {
	id: root

    property var telemetry
	property var history: []
	property int capacity: 3600

	function sample() {
		const device = UPower.displayDevice
		if (!device || !device.ready || !device.isLaptopBattery) return

        const batteries = telemetry && telemetry.snapshot.powerDetails ? telemetry.snapshot.powerDetails.batteries : []
        const sysfsAvailable = batteries.length > 0 && batteries.every(b => b.powerW !== null && b.powerW !== undefined && Number.isFinite(Number(b.powerW)))
        const rate = sysfsAvailable ? batteries.reduce((sum, b) => sum + Number(b.powerW), 0) : Number(device.changeRate)
		const next = history.slice(0)
		next.push({
			time: Date.now(),
			powerW: rate,
            source: sysfsAvailable ? "sysfs" : "UPower",
			energyWh: Number(device.energy),
			percentage: Number(device.percentage) * 100
		})
		if (next.length > capacity) next.splice(0, next.length - capacity)
		history = next
	}

	property Timer sampleTimer: Timer {
		interval: 1000
		repeat: true
		running: true
		onTriggered: root.sample()
	}
}
