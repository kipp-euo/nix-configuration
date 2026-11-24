//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import "."
import "services"

ShellRoot {
	id: shell

	TelemetryService {
		id: telemetryService
	}
	ClockService {
		id: sharedClockService
	}
	WorldClockService {
		id: sharedWorldClock
	}
	AudioMeterService {
		id: sharedAudioMeter
	}
	BatteryHistory {
		id: sharedBatteryHistory

		telemetry: telemetryService
	}

	// PwNodeAudio volume/mute is available only for tracked PipeWire nodes.
	// This is one shared tracker for the shell, not one tracker per popup.
	PwObjectTracker {
		objects: Pipewire.nodes.values
	}
	Variants {
		model: Quickshell.screens

		delegate: Component {
			PanelWindow {
				id: panelWindowRoot

				required property var modelData

				color: "transparent"
				exclusiveZone: 30
				focusable: false
				implicitHeight: 30
				screen: modelData

				anchors {
					left: true
					right: true
					top: true
				}
				margins {
					left: 12
					right: 12
					top: 12
				}
				MainPanel {
					anchors.fill: parent
					audioMeter: sharedAudioMeter
					batteryHistory: sharedBatteryHistory.history
					clockTime: sharedClockService.currentTime
					panelWindow: panelWindowRoot
					screen: modelData
					telemetry: telemetryService
					worldClock: sharedWorldClock
				}
			}
		}
	}
}
