import QtQuick
import "../Palette.js" as Palette

// A device and its controls share one line; this is connection management,
// not a claim to physically power off the adapter.
Item {
    id: root
    property string deviceName: ""
    property string deviceType: ""
    property string secondary: ""
    property bool connected: false
    property bool wifi: false
    property bool wired: false
    property bool wiredCanConnect: false
    property bool wiredHasLink: false
    property bool scanning: false
    readonly property string stateText: connected ? "CONNECTED" : "DISCONNECTED"
    readonly property real actionStart: actions.x
    readonly property real actionEnd: actions.x + actions.width
    signal connectWired()
    signal disconnectDevice()
    signal chooseNetwork()
    signal toggleScan()
    implicitHeight: 30
    height: implicitHeight

    Row {
        id: summary
        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
        width: Math.max(0, actions.x - 8); spacing: 6; clip: true
        Text {
            id: nameText
            width: Math.max(0, Math.min(implicitWidth, summary.width - stateLabel.width - summary.spacing))
            text: root.deviceName || "Unknown"
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.DemiBold
            color: Palette.black; elide: Text.ElideRight; anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            id: stateLabel
            text: root.stateText
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
            color: Palette.black; anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            visible: width > 12
            width: Math.max(0, summary.width - nameText.width - stateLabel.width - summary.spacing * 2)
            text: root.deviceType + (root.secondary ? " · " + root.secondary : "")
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
            color: Palette.black; elide: Text.ElideRight; anchors.verticalCenter: parent.verticalCenter
        }
    }
    Row {
        id: actions
        objectName: "networkActions"
        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        spacing: 5
        ActionButton {
            objectName: "connectWiredButton"
            visible: !root.connected && root.wired
            label: root.wiredCanConnect ? "CONNECT" : root.wiredHasLink ? "UNAVAILABLE" : "NO LINK"
            enabled: root.wiredCanConnect
            opacity: enabled ? 1 : 0.55
            onClicked: root.connectWired()
        }
        ActionButton {
            objectName: "chooseWifiButton"
            visible: !root.connected && root.wifi
            label: "CHOOSE WI-FI"
            onClicked: root.chooseNetwork()
        }
        ActionButton {
            objectName: "scanWifiButton"
            visible: root.wifi
            label: root.scanning ? "STOP" : "SCAN"
            onClicked: root.toggleScan()
        }
        ActionButton {
            objectName: "disconnectButton"
            visible: root.connected
            label: "DISCONNECT"
            onClicked: root.disconnectDevice()
        }
        Text {
            visible: !root.wifi && !root.wired && !root.connected
            text: "NO CONTROL"; color: Palette.darkGray
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
