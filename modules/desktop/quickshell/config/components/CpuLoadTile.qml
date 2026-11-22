import QtQuick
import "../Palette.js" as Palette

Rectangle {
    id: root
    property int cpuId: 0
    property var usage: null
    property bool selected: false
    readonly property alias loadFill: loadFill
    readonly property bool available: usage !== null && usage !== undefined && Number.isFinite(Number(usage))
    readonly property real fraction: available ? Math.max(0, Math.min(1, Number(usage) / 100)) : 0
    signal activated()

    implicitWidth: 160
    implicitHeight: 46
    height: implicitHeight
    color: selected ? Palette.lightViolet : Palette.white
    border.width: 1
    border.color: selected ? Palette.violet : Palette.gray

    Text {
        id: name
        anchors.left: parent.left; anchors.leftMargin: 8
        anchors.top: parent.top; anchors.topMargin: 6
        text: "CPU " + root.cpuId
        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
        color: Palette.darkGray
    }
    Text {
        anchors.right: parent.right; anchors.rightMargin: 8
        anchors.top: parent.top; anchors.topMargin: 6
        text: root.available ? Number(root.usage).toFixed(1) + "%" : "N/A"
        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.DemiBold
        color: Palette.black
    }
    Rectangle {
        id: track
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
        anchors.margins: 8
        height: 7; color: Palette.lightGray
        Rectangle {
            id: loadFill
            objectName: "cpuFill"
            width: Math.round(parent.width * root.fraction); height: parent.height; color: Palette.violet
            Behavior on width { enabled: root.available; NumberAnimation { duration: 650; easing.type: Easing.OutCubic } }
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
