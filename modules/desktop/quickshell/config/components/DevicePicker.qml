import QtQuick
import QtQuick.Controls
import "../Palette.js" as Palette

FocusScope {
    id: root
    property var model: []
    property var stableModel: []
    readonly property int displayedCount: choiceList.count
    function syncModel() {
        const incoming = model || []
        if (stableModel.length === incoming.length && stableModel.every((value, index) => value === incoming[index])) return
        stableModel = Array.from(incoming)
    }
    onModelChanged: syncModel()
    Component.onCompleted: syncModel()
    property int currentIndex: -1
    property Item overlayHost: null
    readonly property int count: model ? model.length : 0
    property bool expanded: false
    readonly property alias overlayPopup: overlay
    signal activated(int index)
    width: parent ? Math.min(parent.width, 380) : 300
    implicitHeight: 30
    height: implicitHeight
    onVisibleChanged: if (!visible) expanded = false
    Keys.onEscapePressed: expanded = false
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Space) { expanded = !expanded; event.accepted = true }
    }
    Rectangle {
        id: header
        width: parent.width; height: 30
        color: Palette.white; border.width: 1; border.color: Palette.black
        Text {
            anchors.left: parent.left; anchors.leftMargin: 9; anchors.right: arrow.left; anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            text: root.currentIndex >= 0 && root.currentIndex < root.count ? String(root.model[root.currentIndex]) : "Unavailable"
            elide: Text.ElideRight; color: Palette.black
            font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
        }
        Text { id: arrow; anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: root.expanded ? "▴" : "▾"; color: Palette.black; font.pixelSize: 13 }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.forceActiveFocus(); root.expanded = !root.expanded } }
    }
    // An ordinary top-level item inside the existing PanelWindow, not a
    // Qt Popup or Wayland surface. It draws above the scroll view without
    // changing the layout, and catches clicks outside to dismiss the menu.
    Item {
        id: overlay
        parent: root.overlayHost || root
        anchors.fill: parent
        z: 1000
        visible: root.expanded && !!root.overlayHost
        MouseArea { anchors.fill: parent; onClicked: root.expanded = false }
        Rectangle {
            id: choices
            width: Math.min(root.width, overlay.width)
            height: Math.min(210, Math.max(32, root.count * 30 + 2), Math.max(32, overlay.height - 8))
            x: { const point = root.mapToItem(overlay, 0, 0); return Math.max(0, Math.min(overlay.width - width, point.x)) }
            y: { const point = root.mapToItem(overlay, 0, 0); return point.y + root.height + height <= overlay.height ? point.y + root.height : Math.max(0, point.y - height) }
            color: Palette.white; border.width: 1; border.color: Palette.black
            ListView {
                id: choiceList
                anchors.fill: parent; anchors.margins: 1; clip: true
                model: root.stableModel
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                delegate: Rectangle {
                    required property int index
                    required property var modelData
                    width: choiceList.width; height: 30
                    color: optionMouse.containsMouse || index === root.currentIndex ? Palette.lightViolet : Palette.white
                    Text { anchors.fill: parent; anchors.leftMargin: 9; anchors.rightMargin: 8; verticalAlignment: Text.AlignVCenter; text: String(parent.modelData); color: Palette.black; elide: Text.ElideRight; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
                    MouseArea { id: optionMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.expanded = false; root.activated(parent.index) } }
                }
            }
        }
    }
}
