import QtQuick
import QtQuick.Controls
import Quickshell.Networking
import "../Palette.js" as Palette

// NetworkManager actions are intentionally independent of telemetry collection.
// Scanner and radio are backend-global: do not disable them when another
// monitor closes its panel. The user can explicitly stop scanning.
Column {
    id: root
    spacing: 8
    readonly property bool hasWifiDevice: Networking.devices.values.some(d => d && d.type === DeviceType.Wifi)
    SectionHeader { text: "NETWORKMANAGER" }
    Text {
        width: parent.width; wrapMode: Text.Wrap
        text: Networking.devices.values.length ? "Manage connections below. Disconnect prevents automatic reconnection until manually activated." : "No NetworkManager devices available. Check that NetworkManager is running and access is permitted."
        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; color: Palette.darkGray
    }
    ActionButton {
        visible: root.hasWifiDevice
        label: Networking.wifiEnabled ? "WI-FI RADIO: ON" : "WI-FI RADIO: OFF"
        onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
    }
    Text { visible: root.hasWifiDevice && !Networking.wifiHardwareEnabled; width: parent.width; wrapMode: Text.Wrap; text: "Wi-Fi is hardware-blocked."; color: Palette.darkGray; font.pixelSize: 10 }
    Repeater {
        id: deviceRepeater
        model: Networking.devices
        delegate: Column {
            id: deviceRow
            required property var modelData
            property var device: modelData
            property bool wifi: device.type === DeviceType.Wifi
            property bool wired: device.type === DeviceType.Wired
            readonly property alias header: deviceHeader
            readonly property alias networkRepeater: networkRepeater
            width: root.width; spacing: 5
            Rectangle { width: parent.width; height: 1; color: Palette.gray }
            NetworkDeviceHeader {
                id: deviceHeader
                width: parent.width
                deviceName: deviceRow.device.name || "Unknown"
                deviceType: deviceRow.wifi ? "Wi-Fi" : deviceRow.wired ? "Ethernet" : DeviceType.toString(deviceRow.device.type)
                connected: deviceRow.device.connected
                wifi: deviceRow.wifi; wired: deviceRow.wired
                wiredCanConnect: deviceRow.wired && !!deviceRow.device.network
                wiredHasLink: deviceRow.wired && deviceRow.device.hasLink
                scanning: deviceRow.wifi && deviceRow.device.scannerEnabled
                secondary: deviceRow.wired ? (deviceRow.device.hasLink ? "Cable · " + deviceRow.device.linkSpeed + " Mbit/s" : "No cable") : (deviceRow.device.address || "")
                onConnectWired: { if (deviceRow.wired && deviceRow.device.network) deviceRow.device.network.connect() }
                onDisconnectDevice: deviceRow.device.disconnect()
                onChooseNetwork: { if (deviceRow.wifi) deviceRow.device.scannerEnabled = true }
                onToggleScan: { if (deviceRow.wifi) deviceRow.device.scannerEnabled = !deviceRow.device.scannerEnabled }
            }
            Repeater {
                id: networkRepeater
                model: deviceRow.device.networks
                delegate: Column {
                    id: networkRow
                    required property var modelData
                    property var net: modelData
                    readonly property alias header: connectionHeader
                    property bool askPassword: false
                    property bool confirmForget: false
                    property string failure: ""
                    property bool supportsPsk: deviceRow.wifi && (net.security === WifiSecurityType.WpaPsk || net.security === WifiSecurityType.Wpa2Psk || net.security === WifiSecurityType.Sae)
                    width: deviceRow.width; spacing: 4
                    Connections {
                        target: networkRow.net
                        function onConnectionFailed(reason) {
                            networkRow.failure = ConnectionFailReason.toString(reason)
                            if (reason === ConnectionFailReason.NoSecrets && networkRow.supportsPsk) networkRow.askPassword = true
                        }
                    }
                    NetworkConnectionHeader {
                        id: connectionHeader
                        width: parent.width
                        networkName: networkRow.net.name || "(hidden network)"
                        details: (networkRow.net.connected ? "CONNECTED · " : "") + (networkRow.net.known ? "SAVED · " : "") + (deviceRow.wifi ? Math.round(networkRow.net.signalStrength * 100) + "% · " + WifiSecurityType.toString(networkRow.net.security) : "")
                        connected: networkRow.net.connected
                        known: networkRow.net.known
                        supportsPassword: networkRow.supportsPsk
                        askingPassword: networkRow.askPassword
                        confirmingForget: networkRow.confirmForget
                        onConnectRequested: { networkRow.failure = ""; networkRow.net.connect() }
                        onPasswordRequested: networkRow.askPassword = true
                        onDisconnectRequested: networkRow.net.disconnect()
                        onForgetRequested: networkRow.confirmForget = true
                        onConfirmForgetRequested: { networkRow.confirmForget = false; networkRow.net.forget() }
                        onCancelForgetRequested: networkRow.confirmForget = false
                    }
                    Text { visible: networkRow.failure !== ""; text: "Connection failed: " + networkRow.failure; width: parent.width; wrapMode: Text.Wrap; color: Palette.darkGray; font.pixelSize: 10 }
                    Row {
                        visible: networkRow.askPassword; spacing: 5
                        TextField { id: password; width: Math.max(0, Math.min(220, root.width - 180)); placeholderText: "Wi-Fi password"; echoMode: TextInput.Password; onAccepted: { if (text.length) { networkRow.net.connectWithPsk(text); clear(); networkRow.askPassword = false } } }
                        ActionButton { label: "CONNECT"; onClicked: { if (password.text.length) { networkRow.net.connectWithPsk(password.text); password.clear(); networkRow.askPassword = false } } }
                        ActionButton { label: "CANCEL"; onClicked: { password.clear(); networkRow.askPassword = false } }
                    }
                }
            }
        }
    }
}
