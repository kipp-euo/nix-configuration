import QtQuick
import QtQuick.Controls
import "../Palette.js" as Palette
Column {
    id: root
    property string label: ""
    property string value: ""
    width: parent ? parent.width : 400
    spacing: 3
    Text { text: root.label; color: Palette.black; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11 }
    TextEdit {
        id: textValue
        width: parent.width; text: root.value; readOnly: true; selectByMouse: true; persistentSelection: true
        wrapMode: TextEdit.NoWrap; clip: true
        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.DemiBold; color: Palette.black
        HoverHandler { id: hover }
        ToolTip.visible: hover.hovered && textValue.contentWidth > textValue.width
        ToolTip.text: root.value
    }
}
