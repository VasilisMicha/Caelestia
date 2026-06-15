import QtQuick
import Quickshell
import qs.components
Item {
    id: root

    required property ShellScreen screen
    required property DrawerVisibilities visibilities
    required property Item sidebarPanel
    property alias osdPanel: content.osdPanel
    property alias sessionPanel: content.sessionPanel
    visible: height > 0
    anchors.topMargin: -5
    implicitWidth: Math.max(sidebarPanel.width, content.implicitWidth)
    implicitHeight: content.implicitHeight

    Content {
        id: content
        screen: root.screen
        visibilities: root.visibilities
    }
}
