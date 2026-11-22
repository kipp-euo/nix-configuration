import QtQuick
import "../Palette.js" as Palette

Item {
    id: root
    property string networkName: ""
    property string details: ""
    property bool connected: false
    property bool known: false
    property bool supportsPassword: false
    property bool askingPassword: false
    property bool confirmingForget: false
    signal connectRequested()
    signal disconnectRequested()
    signal passwordRequested()
    signal forgetRequested()
    signal confirmForgetRequested()
    signal cancelForgetRequested()
    readonly property real actionStart: actions.x
    readonly property real actionEnd: actions.x + actions.width
    height: 30

    Row {
        id: actions
        objectName: "networkConnectionActions"
        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        spacing: 5
        ActionButton { objectName: "connect"; visible: !root.connected && !root.confirmingForget; label: "CONNECT"; onClicked: root.connectRequested() }
        ActionButton { objectName: "password"; visible: !root.connected && root.supportsPassword && !root.askingPassword && !root.confirmingForget; label: "PASSWORD"; onClicked: root.passwordRequested() }
        ActionButton { objectName: "forget"; visible: root.known && !root.confirmingForget; label: "FORGET"; onClicked: root.forgetRequested() }
        ActionButton { objectName: "disconnect"; visible: root.connected && !root.confirmingForget; label: "DISCONNECT"; onClicked: root.disconnectRequested() }
        ActionButton { objectName: "confirm"; visible: root.confirmingForget; label: "CONFIRM FORGET"; danger: true; onClicked: root.confirmForgetRequested() }
        ActionButton { objectName: "cancel"; visible: root.confirmingForget; label: "CANCEL"; onClicked: root.cancelForgetRequested() }
    }
    Row {
        anchors.left: parent.left; anchors.right: actions.left; anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter; spacing: 6
        Text {
            id: nameText
            width: Math.min(implicitWidth, Math.max(0, parent.width * 0.55))
            text: root.networkName || "(hidden network)"; elide: Text.ElideRight
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.weight: Font.DemiBold; color: Palette.black
        }
        Text {
            width: Math.max(0, parent.width - nameText.width - parent.spacing)
            text: root.details; elide: Text.ElideRight
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: Palette.black
        }
    }
}
