import QtQuick
import Quickshell
import "../Palette.js" as Palette

Item {
	id: root

	property var trayItem
	property var hostWindow
    readonly property bool iconReady: icon.status === Image.Ready
    readonly property bool fallbackShown: fallback.visible
    // The icon provider substitutes a magenta checkerboard but reports Ready
    // for unknown theme names. Preserve pixmaps and explicit IconThemePath;
    // only replace a plain theme name that Qt confirms is absent.
    readonly property string iconSource: {
        if (!trayItem || !trayItem.icon) return ""
        const source = String(trayItem.icon)
        const prefix = "image://icon/"
        if (!source.startsWith(prefix)) return source
        // Some GPU Screen Recorder builds publish /usr/share/... paths that
        // do not exist on NixOS. Resolve its actual state icon by theme name,
        // then use the upstream state-specific icon bundled with this config.
        const rawName = source.slice(prefix.length).split("?")[0]
        const baseName = rawName.slice(rawName.lastIndexOf("/") + 1)
        const gsr = /^com\.dec05eba\.gpu_screen_recorder\.tray-(idle|paused|recording)(?:\.png)?$/.exec(baseName)
        if (gsr) {
            const themeIcon = Quickshell.iconPath("com.dec05eba.gpu_screen_recorder.tray-" + gsr[1], true)
            return themeIcon || Qt.resolvedUrl("../icons/gpu-screen-recorder/" + gsr[1] + ".png")
        }
        if (source.indexOf("?") !== -1) return source
        const name = source.slice(prefix.length)
        if (name.indexOf("/") !== -1) return source
        if (Quickshell.iconPath(name, true)) return source
        const id = String(trayItem.id || "")
        const candidates = [id, id.toLowerCase(), id.toLowerCase().replace(/[^a-z0-9_-]/g, "")]
        for (const candidate of candidates) {
            if (!candidate) continue
            const entry = DesktopEntries.byId(candidate) || DesktopEntries.byId(candidate + ".desktop")
            const alternative = entry && entry.icon ? Quickshell.iconPath(entry.icon, true) : Quickshell.iconPath(candidate, true)
            if (alternative) return alternative
        }
        return ""
    }

	width: 26
	height: 26

	Image {
        id: icon
        anchors.centerIn: parent
        width: 20; height: 20
        sourceSize.width: 20; sourceSize.height: 20
		source: root.iconSource
		fillMode: Image.PreserveAspectFit
		smooth: false
	}

    Text {
        id: fallback
        anchors.centerIn: parent
        visible: String(icon.source).length === 0 || icon.status === Image.Error
        text: "󰣆"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16
        color: Palette.darkGray
    }
    readonly property string tooltipText: trayItem ? ((trayItem.tooltipTitle || trayItem.title || trayItem.id || "") + (trayItem.tooltipDescription ? "\n" + trayItem.tooltipDescription : "")) : ""
    readonly property bool tooltipVisible: tooltip.visible
    Timer { id: hoverDelay; interval: 500; onTriggered: tooltip.visible = pointer.containsMouse && root.tooltipText.length > 0 }
    PopupWindow {
        id: tooltip
        anchor.item: root
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right
        visible: false
        grabFocus: false
        mask: Region { }
        implicitWidth: Math.min(320, Math.ceil(tooltipLabel.implicitWidth) + 16)
        implicitHeight: Math.ceil(tooltipLabel.implicitHeight) + 12
        color: "transparent"
        Rectangle {
            anchors.fill: parent
            color: Palette.white; border.width: 1; border.color: Palette.black
            Text {
                id: tooltipLabel
                anchors.fill: parent; anchors.margins: 8
                text: root.tooltipText; color: Palette.black
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                elide: Text.ElideRight
            }
        }
    }

	MouseArea {
		id: pointer
		anchors.fill: parent
        hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
		cursorShape: Qt.PointingHandCursor

        onEntered: { if (root.tooltipText.length) hoverDelay.restart() }
        onExited: { hoverDelay.stop(); tooltip.visible = false }
        onPressed: { hoverDelay.stop(); tooltip.visible = false }
        onClicked: mouse => root.dispatchClick(mouse.button, mouse.x, mouse.y)
        onWheel: wheel => root.dispatchScroll(wheel.angleDelta.x, wheel.angleDelta.y)

	}

    function dispatchClick(button, x, y) {
        if (!trayItem) return
        if (button === Qt.LeftButton) {
            if (!trayItem.onlyMenu) trayItem.activate()
            else if (trayItem.hasMenu) showMenu({x: x, y: y})
        } else if (button === Qt.RightButton && trayItem.hasMenu) showMenu({x: x, y: y})
        else if (button === Qt.MiddleButton) trayItem.secondaryActivate()
    }
    function dispatchScroll(horizontal, vertical) {
        if (!trayItem) return
        if (vertical) trayItem.scroll(vertical, false)
        if (horizontal) trayItem.scroll(horizontal, true)
    }

    property var menuStack: []
    QsMenuOpener { id: menuOpener; menu: trayMenu.visible && root.menuStack.length ? root.menuStack[root.menuStack.length - 1] : null }
    PopupWindow {
        id: trayMenu
        anchor.item: root
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right
        visible: false
        implicitWidth: 240
        implicitHeight: Math.min(450, menuColumn.implicitHeight + 10)
        color: "transparent"
        Rectangle {
            anchors.fill: parent; color: Palette.white; border.color: Palette.black; border.width: 1
            Flickable {
                anchors.fill: parent; anchors.margins: 5; contentHeight: menuColumn.implicitHeight; clip: true
                Column {
                    id: menuColumn; width: parent.width
                    Rectangle {
                        width: parent.width; height: 26; visible: root.menuStack.length > 1
                        color: backMouse.containsMouse ? Palette.lightViolet : Palette.white
                        Text { anchors.verticalCenter: parent.verticalCenter; x: 7; text: "‹  Back"; color: Palette.black; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11 }
                        MouseArea { id: backMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.menuStack = root.menuStack.slice(0, -1) }
                    }
                    Repeater {
                        model: menuOpener.children
                        delegate: Rectangle {
                            required property var modelData
                            readonly property var entry: modelData
                            width: menuColumn.width; height: entry.isSeparator ? 8 : 27
                            color: hover.containsMouse && entry.enabled && !entry.isSeparator ? Palette.lightViolet : Palette.white
                            Rectangle { visible: parent.entry.isSeparator; anchors.centerIn: parent; width: parent.width - 12; height: 1; color: Palette.darkGray }
                            Text {
                                visible: !parent.entry.isSeparator
                                x: 5; anchors.verticalCenter: parent.verticalCenter
                                text: parent.entry.buttonType === QsMenuButtonType.None ? "" : (parent.entry.checkState === Qt.Checked ? (parent.entry.buttonType === QsMenuButtonType.RadioButton ? "●" : "✓") : (parent.entry.buttonType === QsMenuButtonType.RadioButton ? "○" : "□"))
                                font.pixelSize: 11; color: Palette.black
                            }
                            Image { visible: !parent.entry.isSeparator && source.toString().length > 0; x: 22; width: 16; height: 16; anchors.verticalCenter: parent.verticalCenter; source: parent.entry.icon; sourceSize.width: 16; sourceSize.height: 16 }
                            Text {
                                visible: !parent.entry.isSeparator; x: 42; width: parent.width - 62
                                anchors.verticalCenter: parent.verticalCenter; elide: Text.ElideRight
                                text: parent.entry.text.replace(/&/g, ""); color: parent.entry.enabled ? Palette.black : Palette.darkGray
                                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                            }
                            Text { visible: parent.entry.hasChildren; anchors.right: parent.right; anchors.rightMargin: 5; anchors.verticalCenter: parent.verticalCenter; text: "›"; color: Palette.black; font.pixelSize: 13 }
                            MouseArea {
                                id: hover; anchors.fill: parent; hoverEnabled: true; enabled: parent.entry.enabled && !parent.entry.isSeparator
                                onClicked: { if (parent.entry.hasChildren) root.menuStack = root.menuStack.concat([parent.entry]); else { parent.entry.triggered(); trayMenu.visible = false } }
                            }
                        }
                    }
                }
            }
        }
    }
    function showMenu(mouse) {
        if (!root.trayItem || !root.trayItem.menu) return
        if (trayMenu.visible) { trayMenu.visible = false; return }
        root.menuStack = [root.trayItem.menu]
        trayMenu.visible = true
    }
}
