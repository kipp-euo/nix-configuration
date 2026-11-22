//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import "services"
import "."

ShellRoot {
	id: shell

	TelemetryService {
		id: telemetryService
	}

	ClockService {
		id: sharedClockService
	}

	WorldClockService { id: sharedWorldClock }
    AudioMeterService { id: sharedAudioMeter }

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
				screen: modelData
				anchors {
					top: true
					left: true
					right: true
				}
				margins {
					top: 12
					left: 12
					right: 12
				}
				implicitHeight: 30
				color: "transparent"
				focusable: false
				exclusiveZone: 30

				MainPanel {
					anchors.fill: parent
					screen: modelData
					panelWindow: panelWindowRoot
					telemetry: telemetryService
					clockTime: sharedClockService.currentTime
					worldClock: sharedWorldClock
                    audioMeter: sharedAudioMeter
					batteryHistory: sharedBatteryHistory.history
				}
			}
		}
	}
}
