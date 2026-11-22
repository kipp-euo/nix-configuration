import QtQuick
import QtQuick.Controls
import "../Palette.js" as Palette

Grid {
    id: root
    property var metrics: []
    property real labelFraction: 0.54
    width: parent ? parent.width : 400
    columns: width >= 380 ? 2 : 1
    columnSpacing: 18
    rowSpacing: 8
    Repeater {
        model: root.metrics
        delegate: Item {
            required property var modelData
            width: (root.width - root.columnSpacing * (root.columns - 1)) / root.columns
            height: Math.max(labelText.implicitHeight, valueText.implicitHeight)
            Text {
                id: labelText
                width: parent.width * root.labelFraction - 4
                text: modelData.label; elide: Text.ElideRight
                HoverHandler { id: labelHover }
                ToolTip.visible: labelHover.hovered && labelText.truncated
                ToolTip.text: modelData.label
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: Palette.black
            }
            TextEdit {
                id: valueText
                anchors.right: parent.right; width: parent.width * (1 - root.labelFraction) - 4
                text: String(modelData.value); readOnly: true
                selectByMouse: true; persistentSelection: true; wrapMode: TextEdit.NoWrap; clip: true
                HoverHandler { id: valueHover }
                ToolTip.visible: valueHover.hovered && valueText.contentWidth > valueText.width
                ToolTip.text: String(modelData.value)
                horizontalAlignment: TextEdit.AlignRight
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                font.weight: Font.DemiBold; color: Palette.black
            }
        }
    }
}
