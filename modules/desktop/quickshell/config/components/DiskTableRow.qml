import QtQuick
import "../Palette.js" as Palette

Row {
    id: root
    readonly property alias cellContainer: cellsRow
    property var cells: []
    property var columnWidths: []
    property bool header: false
    property bool compactFirst: false
    property bool selected: false
    property int actionIndex: -1
    signal action()
    function rowHeight() {
        let h = 30
        for (const cell of cellsRow.children) if (cell.naturalHeight !== undefined) h = Math.max(h, cell.naturalHeight)
        return h
    }
    height: rowHeight()
    width: parent ? parent.width : 800

    // A nested Row allows variable-height wrapping without truncating names,
    // mount paths, numbers or units. Column widths are shared by all rows.
    Row {
        id: cellsRow
        Repeater {
            model: root.cells
            delegate: Rectangle {
                required property var modelData
                required property int index
                width: root.columnWidths[index] || 80
                property real naturalHeight: root.compactFirst && index === 0 ? 30 : textItem.implicitHeight + 8
                height: root.height
                color: root.header ? Palette.lightGray : root.selected ? Palette.lightViolet : Palette.white
                border.width: 1; border.color: Palette.gray
                TextEdit {
                    id: textItem
                    visible: !(root.compactFirst && index === 0)
                    anchors.verticalCenter: parent.verticalCenter
                    x: 3; width: parent.width - 6
                    text: String(modelData); readOnly: true; selectByMouse: root.actionIndex !== index; persistentSelection: true
                    wrapMode: TextEdit.Wrap
                    horizontalAlignment: TextEdit.AlignHCenter
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                    font.weight: root.header || root.actionIndex === index ? Font.DemiBold : Font.Normal
                    color: root.actionIndex === index ? Palette.violet : Palette.black
                }
                Text {
                    visible: root.compactFirst && index === 0
                    anchors.fill: parent; anchors.leftMargin: 5; anchors.rightMargin: 5
                    verticalAlignment: Text.AlignVCenter; elide: Text.ElideMiddle
                    text: String(modelData); font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                    color: Palette.black
                }
                MouseArea {
                    anchors.fill: parent; enabled: root.actionIndex === index
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: root.action()
                }
            }
        }
    }
}
