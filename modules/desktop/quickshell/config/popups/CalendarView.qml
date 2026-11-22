import QtQuick
import "../Palette.js" as Palette
import QtQuick.Controls
import "../components"

Column {
	id: root

	property int viewYear: new Date().getFullYear()
	property int viewMonth: new Date().getMonth() + 1
	property int viewDay: new Date().getDate()
	property int preferredDay: new Date().getDate()
	property string activeField: ""
	property string draftValue: ""
    property var wheelRemainder: ({ year: 0, month: 0, day: 0 })
	property int page: 0
	property var currentTime: new Date()
	property var worldClock
	readonly property var referenceZone: worldClock ? worldClock.zone(worldClock.data.reference) : null
	property var monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

	spacing: 14

	function makeDate(year, monthIndex, day, hour) {
		const date = new Date(0)
		date.setHours(hour === undefined ? 12 : hour, 0, 0, 0)
		date.setFullYear(year, monthIndex, day)
		return date
	}

	function makeUtcDate(year, monthIndex, day) {
		const date = new Date(0)
		date.setUTCHours(0, 0, 0, 0)
		date.setUTCFullYear(year, monthIndex, day)
		return date
	}

	function daysInMonth(year, month) {
		return makeDate(year, month, 0).getDate()
	}

	function dateObject() {
		return makeDate(viewYear, viewMonth - 1, viewDay)
	}

	function pad2(value) {
		const text = String(value)
		return text.length < 2 ? "0" + text : text
	}

	function formatLocalTime24(value) {
		return pad2(value.getHours()) + ":" + pad2(value.getMinutes()) + ":" + pad2(value.getSeconds())
	}

	function formatLocalTime12(value) {
		let hours = value.getHours() % 12
		if (hours === 0) hours = 12
		return pad2(hours) + ":" + pad2(value.getMinutes()) + ":" + pad2(value.getSeconds())
			+ (value.getHours() < 12 ? " AM" : " PM")
	}

	function formatLocalDate(value) {
		return value.getFullYear() + "-" + pad2(value.getMonth() + 1) + "-" + pad2(value.getDate())
	}

	function formatUtcTime24(value) {
		return pad2(value.getUTCHours()) + ":" + pad2(value.getUTCMinutes()) + ":" + pad2(value.getUTCSeconds())
	}

	function formatUtcDate(value) {
		return value.getUTCFullYear() + "-" + pad2(value.getUTCMonth() + 1) + "-" + pad2(value.getUTCDate())
	}

	function beginEdit(field, fieldItem) {
		activeField = field
		draftValue = field === "year" ? String(viewYear) : field === "month" ? String(viewMonth) : String(viewDay)
		fieldItem.text = draftValue
		fieldItem.selectAll()
	}

	function cancelEdit(fieldItem) {
		activeField = ""
		draftValue = ""
		fieldItem.text = fieldItem.displayValue
	}

	function cancelAnyEdit() {
		const field = activeField
		activeField = ""
		draftValue = ""
		if (field === "year") { yearField.text = yearField.displayValue; yearField.focus = false }
		else if (field === "month") { monthField.text = monthField.displayValue; monthField.focus = false }
		else if (field === "day") { dayField.text = dayField.displayValue; dayField.focus = false }
	}

	function commitEdit(field, fieldItem) {
		if (activeField !== field) return
		const parsed = Number(draftValue)
		if (!/^[0-9]+$/.test(draftValue) || !Number.isInteger(parsed)) {
			cancelEdit(fieldItem)
			return
		}

		if (field === "year") {
			if (parsed < 1 || parsed > 9999 || viewDay > daysInMonth(parsed, viewMonth)) { cancelEdit(fieldItem); return }
			viewYear = parsed
		} else if (field === "month") {
			if (parsed < 1 || parsed > 12 || viewDay > daysInMonth(viewYear, parsed)) { cancelEdit(fieldItem); return }
			viewMonth = parsed
		} else {
			if (parsed < 1 || parsed > daysInMonth(viewYear, viewMonth)) { cancelEdit(fieldItem); return }
			viewDay = parsed
			preferredDay = parsed
		}

		activeField = ""
		draftValue = ""
		fieldItem.text = fieldItem.displayValue
	}

    function scrollField(field, angleDelta, pixelDelta) {
        if (activeField !== "") return
        // Angle deltas are eighths of a degree (120 per detent); pixel events
        // use a separate practical threshold and must not be treated as detents.
        const delta = angleDelta !== 0 ? angleDelta / 120 : pixelDelta / 40
        if (!Number.isFinite(delta) || delta === 0) return
        const next = Object.assign({}, wheelRemainder)
        let amount = (next[field] || 0) + delta
        const steps = amount < 0 ? Math.ceil(amount) : Math.floor(amount)
        amount -= steps; next[field] = amount; wheelRemainder = next
        const bounded = Math.max(-24, Math.min(24, steps))
        for (let i = 0; i < Math.abs(bounded); ++i) stepField(field, bounded > 0 ? 1 : -1)
    }

	function stepField(field, direction) {
		if (activeField !== "") return
		if (field === "year") {
			viewYear = Math.max(1, Math.min(9999, viewYear + direction))
			viewDay = Math.min(preferredDay, daysInMonth(viewYear, viewMonth))
		} else if (field === "month") {
			let nextMonth = viewMonth + direction
			if ((viewYear === 1 && nextMonth < 1) || (viewYear === 9999 && nextMonth > 12)) return
			if (nextMonth < 1) { nextMonth = 12; viewYear = Math.max(1, viewYear - 1) }
			else if (nextMonth > 12) { nextMonth = 1; viewYear = Math.min(9999, viewYear + 1) }
			viewMonth = nextMonth
			viewDay = Math.min(preferredDay, daysInMonth(viewYear, viewMonth))
		} else {
			const next = makeDate(viewYear, viewMonth - 1, viewDay + direction)
			const nextYear = next.getFullYear()
			if (nextYear < 1) {
				viewYear = 1; viewMonth = 1; viewDay = 1
			} else if (nextYear > 9999) {
				viewYear = 9999; viewMonth = 12; viewDay = 31
			} else {
				viewYear = nextYear
				viewMonth = next.getMonth() + 1
				viewDay = next.getDate()
			}
			preferredDay = viewDay
		}
	}

	function dayOfYear(date) {
		const year = date.getFullYear()
		const start = makeUtcDate(year, 0, 1)
		const current = makeUtcDate(year, date.getMonth(), date.getDate())
		return Math.floor((current - start) / 86400000) + 1
	}

	function isoWeek(date) {
		const value = makeUtcDate(date.getFullYear(), date.getMonth(), date.getDate())
		const weekday = value.getUTCDay() || 7
		value.setUTCDate(value.getUTCDate() + 4 - weekday)
		const yearStart = makeUtcDate(value.getUTCFullYear(), 0, 1)
		return Math.ceil((((value - yearStart) / 86400000) + 1) / 7)
	}

    function isoWeekYear(date) {
        const value = makeUtcDate(date.getFullYear(), date.getMonth(), date.getDate())
        const weekday = value.getUTCDay() || 7
        value.setUTCDate(value.getUTCDate() + 4 - weekday)
        return value.getUTCFullYear()
    }

	function isoWeeksInYear(year) {
		return isoWeek(makeDate(year, 11, 28))
	}


    Column {
        width: parent.width; spacing: 8
        Row {
            width: parent.width; spacing: 18
            Column {
                width: Math.max(0, (parent.width - parent.spacing) / 2); spacing: 4
                SectionHeader { text: "LOCAL TIME · 24H" }
                TextEdit { width: parent.width; readOnly: true; selectByMouse: true; persistentSelection: true; clip: true; text: root.formatLocalTime24(root.currentTime); font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 26; font.weight: Font.DemiBold; color: Palette.black }
                Text { width: parent.width; elide: Text.ElideRight; text: root.formatLocalDate(root.currentTime); font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; color: Palette.black }
                Text { width: parent.width; elide: Text.ElideRight; text: root.worldClock ? root.worldClock.data.localZone + " · UTC" + root.worldClock.data.localOffset : ""; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; color: Palette.black }
                Text { text: root.formatLocalTime12(root.currentTime); font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; color: Palette.black }
            }
            Column {
                width: Math.max(0, (parent.width - parent.spacing) / 2); spacing: 4
                SectionHeader { text: "REFERENCE · 24H" }
                TextEdit { width: parent.width; readOnly: true; selectByMouse: true; persistentSelection: true; clip: true; text: root.referenceZone ? root.referenceZone.time24 : root.formatUtcTime24(root.currentTime); font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 26; font.weight: Font.DemiBold; color: Palette.black }
                Text { width: parent.width; elide: Text.ElideRight; text: root.referenceZone ? root.referenceZone.date : ""; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; color: Palette.black }
                Text { width: parent.width; elide: Text.ElideRight; text: root.referenceZone ? root.referenceZone.id + " · UTC" + root.referenceZone.offset : "UTC"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; color: Palette.black }
                Text { text: root.referenceZone ? root.referenceZone.time12 : ""; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; color: Palette.black }
            }
        }
        ValueRow { label: "UNIX EPOCH"; value: Math.floor(root.currentTime.getTime() / 1000).toString() }
    }

	Row {
		width: parent.width
		spacing: 10
		Text {
			text: "CALENDAR"
			font.family: "JetBrainsMono Nerd Font"
			font.pixelSize: 11
			font.weight: Font.DemiBold
			color: Palette.midViolet
			anchors.verticalCenter: parent.verticalCenter
		}
		Item { width: 1; height: 1 }
		ActionButton {
			label: "TODAY"
			onClicked: {
				const now = new Date()
				root.cancelAnyEdit()
				root.viewYear = now.getFullYear()
				root.viewMonth = now.getMonth() + 1
				root.viewDay = now.getDate()
				root.preferredDay = now.getDate()
			}
		}
	}

	Row {
		width: parent.width
		spacing: 7

		Column {
            width: Math.max(0, (parent.width - 17) / 3)
            spacing: 3
            Text { text: "YEAR"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: Palette.black }
		TextField {
			id: yearField
			property string displayValue: String(root.viewYear)
			width: parent.width
			height: 34
			Component.onCompleted: text = displayValue
			onDisplayValueChanged: if (!activeFocus) text = displayValue
			font.family: "JetBrainsMono Nerd Font"
			font.pixelSize: 16
			font.weight: Font.DemiBold
			color: Palette.black
			selectedTextColor: Palette.black
			selectionColor: Palette.lightViolet
			background: Rectangle { color: Palette.white; border.width: 1; border.color: Palette.black; radius: 0 }
			validator: RegularExpressionValidator { regularExpression: /^[0-9]{0,4}$/ }
			inputMethodHints: Qt.ImhDigitsOnly
			onActiveFocusChanged: { if (activeFocus) root.beginEdit("year", yearField); else root.commitEdit("year", yearField) }
			onTextEdited: root.draftValue = text
			onAccepted: { root.commitEdit("year", yearField); yearField.focus = false }
			Keys.onEscapePressed: event => { event.accepted = true; root.cancelEdit(yearField); yearField.focus = false }
            MouseArea {
                anchors.fill: parent; acceptedButtons: Qt.NoButton
                onWheel: wheel => { root.scrollField("year", wheel.angleDelta.y, wheel.pixelDelta.y); wheel.accepted = true }
            }
		}
        }

		Column {
            width: Math.max(0, (parent.width - 17) / 3)
            spacing: 3
            Text { text: "MONTH"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: Palette.black }
		TextField {
			id: monthField
			property string displayValue: root.monthNames[root.viewMonth - 1] + "/" + String(root.viewMonth).padStart(2, "0")
			width: parent.width
			height: 34
			Component.onCompleted: text = displayValue
			onDisplayValueChanged: if (!activeFocus) text = displayValue
			font.family: "JetBrainsMono Nerd Font"
			font.pixelSize: 16
			font.weight: Font.DemiBold
			color: Palette.black
			selectedTextColor: Palette.black
			selectionColor: Palette.lightViolet
			background: Rectangle { color: Palette.white; border.width: 1; border.color: Palette.black; radius: 0 }
			validator: RegularExpressionValidator { regularExpression: /^[0-9]{0,2}$/ }
			inputMethodHints: Qt.ImhDigitsOnly
			onActiveFocusChanged: { if (activeFocus) root.beginEdit("month", monthField); else root.commitEdit("month", monthField) }
			onTextEdited: root.draftValue = text
			onAccepted: { root.commitEdit("month", monthField); monthField.focus = false }
			Keys.onEscapePressed: event => { event.accepted = true; root.cancelEdit(monthField); monthField.focus = false }
            MouseArea {
                anchors.fill: parent; acceptedButtons: Qt.NoButton
                onWheel: wheel => { root.scrollField("month", wheel.angleDelta.y, wheel.pixelDelta.y); wheel.accepted = true }
            }
		}
        }

		Column {
            width: Math.max(0, (parent.width - 17) / 3)
            spacing: 3
            Text { text: "DAY"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: Palette.black }
		TextField {
			id: dayField
			property string displayValue: String(root.viewDay).padStart(2, "0")
			width: parent.width
			height: 34
			Component.onCompleted: text = displayValue
			onDisplayValueChanged: if (!activeFocus) text = displayValue
			font.family: "JetBrainsMono Nerd Font"
			font.pixelSize: 16
			font.weight: Font.DemiBold
			color: Palette.black
			selectedTextColor: Palette.black
			selectionColor: Palette.lightViolet
			background: Rectangle { color: Palette.white; border.width: 1; border.color: Palette.black; radius: 0 }
			validator: RegularExpressionValidator { regularExpression: /^[0-9]{0,2}$/ }
			inputMethodHints: Qt.ImhDigitsOnly
			onActiveFocusChanged: { if (activeFocus) root.beginEdit("day", dayField); else root.commitEdit("day", dayField) }
			onTextEdited: root.draftValue = text
			onAccepted: { root.commitEdit("day", dayField); dayField.focus = false }
			Keys.onEscapePressed: event => { event.accepted = true; root.cancelEdit(dayField); dayField.focus = false }
            MouseArea {
                anchors.fill: parent; acceptedButtons: Qt.NoButton
                onWheel: wheel => { root.scrollField("day", wheel.angleDelta.y, wheel.pixelDelta.y); wheel.accepted = true }
            }
		}
        }
	}

	Grid {
        anchors.horizontalCenter: parent.horizontalCenter
		width: Math.min(parent.width, 490)
		columns: 7
		spacing: 4
		Repeater {
			model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
			delegate: Text {
				required property string modelData
				width: (parent.width - 24) / 7
				height: 20
				text: modelData
				horizontalAlignment: Text.AlignHCenter
				font.family: "JetBrainsMono Nerd Font"
				font.pixelSize: 12
				color: Palette.black
			}
		}
	}

	Grid {
        anchors.horizontalCenter: parent.horizontalCenter
		width: Math.min(parent.width, 490)
		columns: 7
		spacing: 4
		Repeater {
			model: {
				const first = root.makeDate(root.viewYear, root.viewMonth - 1, 1)
				const offset = (first.getDay() + 6) % 7
				const count = root.daysInMonth(root.viewYear, root.viewMonth)
				const values = []
				for (let i = 0; i < 42; i++) values.push(i - offset + 1)
				return values
			}
			delegate: Rectangle {
				required property int modelData
				property bool inMonth: modelData >= 1 && modelData <= root.daysInMonth(root.viewYear, root.viewMonth)
				property bool selected: inMonth && modelData === root.viewDay
                property bool today: inMonth && modelData === root.currentTime.getDate() && root.viewMonth === root.currentTime.getMonth() + 1 && root.viewYear === root.currentTime.getFullYear()
				width: (parent.width - 24) / 7
				height: 30
				color: selected ? Palette.violet : Palette.white
				border.width: selected || today ? 1 : 0
				border.color: today && !selected ? Palette.violet : Palette.black
				Text {
					anchors.centerIn: parent
					text: parent.inMonth ? parent.modelData : ""
					font.family: "JetBrainsMono Nerd Font"
					font.pixelSize: 13
					color: parent.selected ? Palette.white : Palette.black
				}
				MouseArea {
					anchors.fill: parent
					visible: parent.inMonth
					cursorShape: Qt.PointingHandCursor
					onClicked: { root.viewDay = parent.modelData; root.preferredDay = parent.modelData }
				}
			}
		}
	}

	Row {
		width: parent.width
		spacing: 24
		ValueRow { width: Math.max(0, (parent.width - parent.spacing) / 2); label: "DAY OF YEAR"; value: root.dayOfYear(root.dateObject()) + " / " + (root.daysInMonth(root.viewYear, 2) === 29 ? 366 : 365) }
		ValueRow { width: Math.max(0, (parent.width - parent.spacing) / 2); label: "ISO WEEK"; value: root.isoWeek(root.dateObject()) + " / " + root.isoWeeksInYear(root.isoWeekYear(root.dateObject())) + " · " + root.isoWeekYear(root.dateObject()) }
	}

    Column {
        width: parent.width
        spacing: 4
        visible: !!root.worldClock && root.worldClock.data.favorites.length > 0
        SectionHeader { text: "FAVORITE TIME ZONES" }
        Flow {
            id: favoriteFlow
            width: parent.width; spacing: 8
            Repeater {
                model: root.worldClock ? root.worldClock.data.favorites : []
                delegate: Rectangle {
                    required property string modelData
                    property var entry: root.worldClock.zone(modelData)
                    width: Math.max(1, (favoriteFlow.width - 8) / 2); height: 54
                    color: Palette.white; border.color: Palette.gray
                    Column {
                        anchors.fill: parent; anchors.margins: 5; spacing: 1
                        Text { width: parent.width; elide: Text.ElideRight; text: entry ? entry.label : modelData; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.bold: true; color: Palette.black }
                        Text { width: parent.width; elide: Text.ElideRight; text: entry ? entry.time24 + " · " + entry.date : ""; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: Palette.black }
                        Text { text: entry ? (entry.dayShift === 0 ? "same day" : (entry.dayShift > 0 ? "+" : "") + entry.dayShift + (Math.abs(entry.dayShift) === 1 ? " day" : " days")) : ""; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; color: Palette.black }
                    }
                }
            }
        }
    }

}
