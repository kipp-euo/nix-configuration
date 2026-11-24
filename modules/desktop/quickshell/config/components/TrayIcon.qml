import QtQuick
import Quickshell
import "../Palette.js" as Palette

Item {
	id: root

	readonly property bool fallbackShown: fallback.visible
	property var hostWindow
	readonly property bool iconReady: icon.status === Image.Ready
	// The icon provider substitutes a magenta checkerboard but reports Ready
	// for unknown theme names. Preserve pixmaps and explicit IconThemePath;
	// only replace a plain theme name that Qt confirms is absent.
	readonly property string iconSource: {
		if (!trayItem || !trayItem.icon)
			return "";
		const source = String(trayItem.icon);
		const prefix = "image://icon/";
		if (!source.startsWith(prefix))
			return source;
		// Some GPU Screen Recorder builds publish /usr/share/... paths that
		// do not exist on NixOS. Resolve its actual state icon by theme name,
		// then use the upstream state-specific icon bundled with this config.
		const rawName = source.slice(prefix.length).split("?")[0];
		const baseName = rawName.slice(rawName.lastIndexOf("/") + 1);
		const gsr = /^com\.dec05eba\.gpu_screen_recorder\.tray-(idle|paused|recording)(?:\.png)?$/.exec(baseName);
		if (gsr) {
			const themeIcon = Quickshell.iconPath("com.dec05eba.gpu_screen_recorder.tray-" + gsr[1], true);
			return themeIcon || Qt.resolvedUrl("../icons/gpu-screen-recorder/" + gsr[1] + ".png");
		}
		if (source.indexOf("?") !== -1)
			return source;
		const name = source.slice(prefix.length);
		if (name.indexOf("/") !== -1)
			return source;
		if (Quickshell.iconPath(name, true))
			return source;
		const id = String(trayItem.id || "");
		const candidates = [id, id.toLowerCase(), id.toLowerCase().replace(/[^a-z0-9_-]/g, "")];
		for (const candidate of candidates) {
			if (!candidate)
				continue;
			const entry = DesktopEntries.byId(candidate) || DesktopEntries.byId(candidate + ".desktop");
			const alternative = entry && entry.icon ? Quickshell.iconPath(entry.icon, true) : Quickshell.iconPath(candidate, true);
			if (alternative)
				return alternative;
		}
		return "";
	}
	property var menuStack: []
	readonly property string tooltipText: trayItem ? ((trayItem.tooltipTitle || trayItem.title || trayItem.id || "") + (trayItem.tooltipDescription ? "\n" + trayItem.tooltipDescription : "")) : ""
	readonly property bool tooltipVisible: tooltip.visible
	property var trayItem

	function dispatchClick(button, x, y) {
		if (!trayItem)
			return;
		if (button === Qt.LeftButton) {
			if (!trayItem.onlyMenu)
				trayItem.activate();
			else if (trayItem.hasMenu)
				showMenu({
					x: x,
					y: y
				});
		} else if (button === Qt.RightButton && trayItem.hasMenu)
			showMenu({
				x: x,
				y: y
			});
		else if (button === Qt.MiddleButton)
			trayItem.secondaryActivate();
	}
	function dispatchScroll(horizontal, vertical) {
		if (!trayItem)
			return;
		if (vertical)
			trayItem.scroll(vertical, false);
		if (horizontal)
			trayItem.scroll(horizontal, true);
	}
	function showMenu(mouse) {
		if (!root.trayItem || !root.trayItem.menu)
			return;
		if (trayMenu.visible) {
			trayMenu.visible = false;
			return;
		}
		root.menuStack = [root.trayItem.menu];
		trayMenu.visible = true;
	}

	height: 26
	width: 26

	Image {
		id: icon

		anchors.centerIn: parent
		fillMode: Image.PreserveAspectFit
		height: 20
		smooth: false
		source: root.iconSource
		sourceSize.height: 20
		sourceSize.width: 20
		width: 20
	}
	Text {
		id: fallback

		anchors.centerIn: parent
		color: Palette.darkGray
		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 16
		text: "󰣆"
		visible: String(icon.source).length === 0 || icon.status === Image.Error
	}
	Timer {
		id: hoverDelay

		interval: 500

		onTriggered: tooltip.visible = pointer.containsMouse && root.tooltipText.length > 0
	}
	PopupWindow {
		id: tooltip

		anchor.edges: Edges.Bottom | Edges.Left
		anchor.gravity: Edges.Bottom | Edges.Right
		anchor.item: root
		color: "transparent"
		grabFocus: false
		implicitHeight: Math.ceil(tooltipLabel.implicitHeight) + 12
		implicitWidth: Math.min(320, Math.ceil(tooltipLabel.implicitWidth) + 16)
		visible: false

		mask: Region {
		}

		Rectangle {
			anchors.fill: parent
			border.color: Palette.black
			border.width: 1
			color: Palette.white

			Text {
				id: tooltipLabel

				anchors.fill: parent
				anchors.margins: 8
				color: Palette.black
				elide: Text.ElideRight
				font.family: "JetBrainsMono Nerd Font"
				font.pixelSize: 11
				text: root.tooltipText
			}
		}
	}
	MouseArea {
		id: pointer

		acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		hoverEnabled: true

		onClicked: mouse => root.dispatchClick(mouse.button, mouse.x, mouse.y)
		onEntered: {
			if (root.tooltipText.length)
				hoverDelay.restart();
		}
		onExited: {
			hoverDelay.stop();
			tooltip.visible = false;
		}
		onPressed: {
			hoverDelay.stop();
			tooltip.visible = false;
		}
		onWheel: wheel => root.dispatchScroll(wheel.angleDelta.x, wheel.angleDelta.y)
	}
	QsMenuOpener {
		id: menuOpener

		menu: trayMenu.visible && root.menuStack.length ? root.menuStack[root.menuStack.length - 1] : null
	}
	PopupWindow {
		id: trayMenu

		anchor.edges: Edges.Bottom | Edges.Left
		anchor.gravity: Edges.Bottom | Edges.Right
		anchor.item: root
		color: "transparent"
		implicitHeight: Math.min(450, menuColumn.implicitHeight + 10)
		implicitWidth: 240
		visible: false

		Rectangle {
			anchors.fill: parent
			border.color: Palette.black
			border.width: 1
			color: Palette.white

			Flickable {
				anchors.fill: parent
				anchors.margins: 5
				clip: true
				contentHeight: menuColumn.implicitHeight

				Column {
					id: menuColumn

					width: parent.width

					Rectangle {
						color: backMouse.containsMouse ? Palette.lightViolet : Palette.white
						height: 26
						visible: root.menuStack.length > 1
						width: parent.width

						Text {
							anchors.verticalCenter: parent.verticalCenter
							color: Palette.black
							font.family: "JetBrainsMono Nerd Font"
							font.pixelSize: 11
							text: "‹  Back"
							x: 7
						}
						MouseArea {
							id: backMouse

							anchors.fill: parent
							hoverEnabled: true

							onClicked: root.menuStack = root.menuStack.slice(0, -1)
						}
					}
					Repeater {
						model: menuOpener.children

						delegate: Rectangle {
							readonly property var entry: modelData
							required property var modelData

							color: hover.containsMouse && entry.enabled && !entry.isSeparator ? Palette.lightViolet : Palette.white
							height: entry.isSeparator ? 8 : 27
							width: menuColumn.width

							Rectangle {
								anchors.centerIn: parent
								color: Palette.darkGray
								height: 1
								visible: parent.entry.isSeparator
								width: parent.width - 12
							}
							Text {
								anchors.verticalCenter: parent.verticalCenter
								color: Palette.black
								font.pixelSize: 11
								text: parent.entry.buttonType === QsMenuButtonType.None ? "" : (parent.entry.checkState === Qt.Checked ? (parent.entry.buttonType === QsMenuButtonType.RadioButton ? "●" : "✓") : (parent.entry.buttonType === QsMenuButtonType.RadioButton ? "○" : "□"))
								visible: !parent.entry.isSeparator
								x: 5
							}
							Image {
								anchors.verticalCenter: parent.verticalCenter
								height: 16
								source: parent.entry.icon
								sourceSize.height: 16
								sourceSize.width: 16
								visible: !parent.entry.isSeparator && source.toString().length > 0
								width: 16
								x: 22
							}
							Text {
								anchors.verticalCenter: parent.verticalCenter
								color: parent.entry.enabled ? Palette.black : Palette.darkGray
								elide: Text.ElideRight
								font.family: "JetBrainsMono Nerd Font"
								font.pixelSize: 11
								text: parent.entry.text.replace(/&/g, "")
								visible: !parent.entry.isSeparator
								width: parent.width - 62
								x: 42
							}
							Text {
								anchors.right: parent.right
								anchors.rightMargin: 5
								anchors.verticalCenter: parent.verticalCenter
								color: Palette.black
								font.pixelSize: 13
								text: "›"
								visible: parent.entry.hasChildren
							}
							MouseArea {
								id: hover

								anchors.fill: parent
								enabled: parent.entry.enabled && !parent.entry.isSeparator
								hoverEnabled: true

								onClicked: {
									if (parent.entry.hasChildren)
										root.menuStack = root.menuStack.concat([parent.entry]);
									else {
										parent.entry.triggered();
										trayMenu.visible = false;
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
