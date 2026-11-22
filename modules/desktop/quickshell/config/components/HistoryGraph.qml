import QtQuick
import "../Palette.js" as Palette

Canvas {
	id: root

	property var points: []
	property var series: []
	property string valueKey: "value"
	property color lineColor: Palette.violet
	property real minimum: 0
	property real maximum: 100
	property bool autoRange: false
    property real valueDivisor: 1
    property string unit: ""
    property int valuePrecision: 2
	property real windowSeconds: 60
	property real minWindowSeconds: 5
	property real maxWindowSeconds: 3600
	property bool live: true
	property real frozenEndMs: Date.now()
	property real dragStartX: 0
	property real dragStartEndMs: 0
    property real dragStartY: 0
    property real dragStartWindow: 60
    property real dragStartScale: 1
    property real yScale: 1
	property real cursorX: -1
    readonly property real plotLeft: 45
    readonly property real plotWidth: Math.max(1, width - plotLeft)
	property var hoveredSample: {
		if (cursorX < 0 || width <= 0 || !points || points.length === 0) return null
		const end = viewEndMs()
		const start = end - windowSeconds * 1000
		const target = start + (Math.max(0, Math.min(1, (cursorX - plotLeft) / plotWidth))) * windowSeconds * 1000
		let nearest = null
		let distance = Number.MAX_VALUE
		for (const point of points) {
			if (point.time < start || point.time > end) continue
			const nextDistance = Math.abs(point.time - target)
			if (nextDistance < distance) { distance = nextDistance; nearest = point }
		}
		return nearest
	}

	implicitHeight: 132
	height: implicitHeight

    function formatTime(milliseconds) {
        const value = new Date(milliseconds)
        const two = n => String(n).padStart(2, "0")
        return two(value.getHours()) + ":" + two(value.getMinutes()) + ":" + two(value.getSeconds())
    }
    function formatDuration(seconds) {
        const total = Math.max(0, Math.round(seconds))
        const h = Math.floor(total / 3600), m = Math.floor((total % 3600) / 60), s = total % 60
        if (h) return h + " h" + (m ? " " + m + " min" : "") + (s ? " " + s + " s" : "")
        if (m) return m + " min" + (s ? " " + s + " s" : "")
        return s + " s"
    }
    function latestTime() { return points && points.length ? points[points.length - 1].time : Date.now() }
	function viewEndMs() {
		return live ? latestTime() : frozenEndMs
	}

	function effectiveSeries() {
		return series && series.length > 0
			? series
			: [{ key: valueKey, color: lineColor, label: valueKey }]
	}

	function visibleSamples() {
		if (!points || points.length === 0) return []
		const end = viewEndMs()
		const start = end - windowSeconds * 1000
		return points.filter(point => point.time >= start && point.time <= end)
	}

    function displayNumber(raw) {
        if (raw === null || raw === undefined || !Number.isFinite(Number(raw)) || !(valueDivisor > 0)) return "N/A"
        return (Number(raw) / valueDivisor).toFixed(valuePrecision) + (unit ? " " + unit : "")
    }
    function hasVisibleData() {
        for (const point of visibleSamples()) for (const definition of effectiveSeries()) {
            const raw = point[definition.key]
            if (raw !== null && raw !== undefined && Number.isFinite(Number(raw))) return true
        }
        return false
    }

	function goLive() {
		live = true
		frozenEndMs = latestTime()
		requestPaint()
	}

	function clampHistoryEnd(value) {
		if (!points || points.length === 0) return value
		const oldest = points[0].time
		return Math.min(latestTime(), Math.max(value, oldest + windowSeconds * 1000))
	}

	function zoomAt(direction, pointerX) {
		const oldWindow = windowSeconds
		const factor = direction > 0 ? 0.8 : 1.25
		const nextWindow = Math.max(minWindowSeconds, Math.min(maxWindowSeconds, oldWindow * factor))
		if (Math.abs(nextWindow - oldWindow) < 0.001) return

		if (!live) {
			const ratio = Math.max(0, Math.min(1, (pointerX - plotLeft) / plotWidth))
			const anchorTime = frozenEndMs - oldWindow * 1000 * (1 - ratio)
			windowSeconds = nextWindow
			frozenEndMs = clampHistoryEnd(anchorTime + nextWindow * 1000 * (1 - ratio))
		} else {
			windowSeconds = nextWindow
		}
		requestPaint()
	}

    function resizeAxes(dx, dy) {
        const oldWindow = dragStartWindow
        const newWindow = Math.max(minWindowSeconds, Math.min(maxWindowSeconds, oldWindow * Math.exp(-dx / 200)))
        if (!live) {
            const ratio = Math.max(0, Math.min(1, (dragStartX - plotLeft) / plotWidth))
            const anchorTime = dragStartEndMs - oldWindow * 1000 * (1 - ratio)
            windowSeconds = newWindow
            frozenEndMs = clampHistoryEnd(anchorTime + newWindow * 1000 * (1 - ratio))
        } else windowSeconds = newWindow
        yScale = Math.max(0.05, Math.min(20, dragStartScale * Math.exp(dy / 120)))
        requestPaint()
    }

    onPointsChanged: {
        if (!live && points && points.length > 0) frozenEndMs = clampHistoryEnd(frozenEndMs)
        requestPaint()
    }
	onSeriesChanged: requestPaint()
    onValueDivisorChanged: requestPaint()
    onMinimumChanged: requestPaint()
    onMaximumChanged: requestPaint()
    onAutoRangeChanged: requestPaint()
    onYScaleChanged: requestPaint()
	onWidthChanged: requestPaint()
	onHeightChanged: requestPaint()
	onWindowSecondsChanged: requestPaint()
	onFrozenEndMsChanged: requestPaint()
	onLiveChanged: requestPaint()

	onPaint: {
		const ctx = getContext("2d")
		ctx.clearRect(0, 0, width, height)

		const chartTop = 22
		const chartBottom = height - 24
		const chartHeight = chartBottom - chartTop
		const samples = visibleSamples()
		const definitions = effectiveSeries()
		const end = viewEndMs()
		const start = end - windowSeconds * 1000


		let low = minimum / Math.max(valueDivisor, 0.0000001)
		let high = maximum / Math.max(valueDivisor, 0.0000001)
		if (autoRange && samples.length > 0) {
			low = Number.MAX_VALUE
			high = -Number.MAX_VALUE
			for (const point of samples) {
				for (const definition of definitions) {
					const raw = point[definition.key]
					if (raw === null || raw === undefined) continue
					const value = Number(raw) / Math.max(valueDivisor, 0.0000001)
					if (!Number.isFinite(value)) continue
					low = Math.min(low, value)
					high = Math.max(high, value)
				}
			}
			if (low === Number.MAX_VALUE || high === -Number.MAX_VALUE) { low = 0; high = 1 }
			if (Math.abs(high - low) < 0.000001) { const delta = Math.max(Math.abs(high) * 0.1, valueDivisor > 1 ? 0.001 : 1); low -= delta; high += delta }
			const padding = (high - low) * 0.08
			low -= padding
			high += padding
            if (minimum >= 0) low = Math.max(0, low)
		} else if (!(high > low)) {
			high = low + 1
		}

        if (yScale !== 1) {
            const scaled = (high - low) * yScale
            if (minimum >= 0 && low >= 0) high = low + scaled
            else { const middle = (low + high) / 2; low = middle - scaled / 2; high = middle + scaled / 2 }
        }
        ctx.strokeStyle = String(Palette.gray)
        ctx.fillStyle = String(Palette.darkGray)
        ctx.font = "9px 'JetBrainsMono Nerd Font'"
        ctx.textAlign = "right"
        ctx.lineWidth = 1
        for (let line = 0; line <= 4; line++) {
            const y = Math.round(chartTop + chartHeight * line / 4) + 0.5
            const tick = high - (high - low) * line / 4
            const span = high - low
            // Precision follows the tick interval, not the magnitude: otherwise
            // low-rate graphs show multiple identical 0.000 / 0.001 labels.
            const step = span / 4
            const digits = Math.max(0, Math.min(6, Math.ceil(-Math.log10(step)) + 1))
            const label = Math.abs(tick) >= 100000 ? tick.toExponential(1) : tick.toFixed(digits)
            ctx.fillText(label, plotLeft - 5, Math.max(9, Math.min(height - 1, y + 3)))
            ctx.beginPath(); ctx.moveTo(plotLeft, y); ctx.lineTo(width, y); ctx.stroke()
        }

		if (samples.length >= 2) {
			for (const definition of definitions) {
				ctx.strokeStyle = String(definition.color || lineColor)
				ctx.lineWidth = 1.7
				ctx.beginPath()
				let started = false
				for (const point of samples) {
					const raw = point[definition.key]
					if (raw === null || raw === undefined) { started = false; continue }
					const value = Number(raw) / Math.max(valueDivisor, 0.0000001)
					if (!Number.isFinite(value)) { started = false; continue }
					const x = plotLeft + ((point.time - start) / (windowSeconds * 1000)) * plotWidth
					const normalized = Math.max(0, Math.min(1, (value - low) / (high - low)))
					const y = chartBottom - normalized * chartHeight
					if (!started) { ctx.moveTo(x, y); started = true }
					else ctx.lineTo(x, y)
				}
                // The path may contain earlier segments even when the last
                // sample is missing. Stroke accumulated subpaths regardless.
                ctx.stroke()
			}
		}

		if (cursorX >= 0 && hoveredSample) {
			ctx.strokeStyle = String(Palette.darkGray)
			ctx.lineWidth = 1
			ctx.setLineDash([3, 3])
			ctx.beginPath()
			ctx.moveTo(Math.max(plotLeft, cursorX), chartTop)
			ctx.lineTo(Math.max(plotLeft, cursorX), chartBottom)
			ctx.stroke()
			ctx.setLineDash([])
		}
	}

	MouseArea {
		anchors.fill: parent
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		hoverEnabled: true
		preventStealing: true

		onPressed: mouse => {
            root.dragStartX = mouse.x
            root.dragStartEndMs = root.viewEndMs()
            root.dragStartY = mouse.y
            root.dragStartWindow = root.windowSeconds
            root.dragStartScale = root.yScale
		}

		onPositionChanged: mouse => {
			root.cursorX = mouse.x
            if (pressed && (pressedButtons & Qt.RightButton)) {
                root.resizeAxes(mouse.x - root.dragStartX, mouse.y - root.dragStartY)
            } else if (pressed && (pressedButtons & Qt.LeftButton) && root.points && root.points.length > 0) {
                const delta = mouse.x - root.dragStartX
                if (Math.abs(delta) > 2 || !root.live) {
                    root.frozenEndMs = root.clampHistoryEnd(root.dragStartEndMs - delta / root.plotWidth * root.windowSeconds * 1000)
                    root.live = false
                }
            }
			root.requestPaint()
		}

		onReleased: root.requestPaint()
		onExited: { root.cursorX = -1; root.requestPaint() }
        // Propagate wheel input to the enclosing ScrollView; never zoom here.
        onWheel: wheel => { wheel.accepted = false }
	}

	Text {
        objectName: "graphTime"
		anchors.left: parent.left
		anchors.top: parent.top
		text: (root.hoveredSample ? root.formatTime(root.hoveredSample.time) : root.formatDuration(root.windowSeconds)) + (root.unit ? " · " + root.unit : "")
		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 9
		color: Palette.darkGray
	}

    Text {
        anchors.centerIn: parent
        visible: !root.hasVisibleData()
        text: "NO DATA"
        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
        color: Palette.darkGray
    }
    Row {
        objectName: "graphLegend"
        anchors.left: parent.left; anchors.leftMargin: 130
        anchors.top: parent.top; anchors.right: parent.right; anchors.rightMargin: 55
        spacing: 10; clip: true
        Repeater {
            model: root.effectiveSeries()
            delegate: Row {
                required property var modelData
                spacing: 3
                Rectangle { width: 8; height: 3; anchors.verticalCenter: parent.verticalCenter; color: modelData.color || root.lineColor }
                Text { text: modelData.label || modelData.key; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9; color: Palette.darkGray }
            }
        }
    }

	Rectangle {
		anchors.right: parent.right
		anchors.top: parent.top
		width: 46
		height: 18
		color: root.live ? Palette.lightViolet : Palette.white
		border.width: 1
		border.color: Palette.black
		Text {
			anchors.centerIn: parent
			text: "LIVE"
			font.family: "JetBrainsMono Nerd Font"
			font.pixelSize: 9
			font.weight: Font.DemiBold
			color: Palette.black
		}
		MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: root.goLive()
		}
	}

	Text {
        objectName: "graphHoverValue"
		anchors.left: parent.left
		anchors.bottom: parent.bottom
		text: root.hoveredSample && root.effectiveSeries().length > 0
			? root.effectiveSeries().map(entry => entry.label + ": " + root.displayNumber(root.hoveredSample[entry.key])).join("  ·  ")
			: ""
		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 9
		color: Palette.black
		elide: Text.ElideRight
		width: parent.width - 60
	}

}
