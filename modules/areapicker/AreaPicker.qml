pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.components.containers
import qs.components.misc
import qs.services

Scope {
    LazyLoader {
        id: root
        property bool freeze
        property bool closing
        property bool clipboardOnly
        property var savedVisibilities: ({})

        function openPicker(): void {
            Visibilities.pickerActive = true; 
            const v = Visibilities.getForActive();
            if (v) {
                root.savedVisibilities = {
                    dashboard: v.dashboard,
                    osd: v.osd,
                    utilities: v.utilities,
                    sidebar: v.sidebar,
                    launcher: v.launcher,
                    session: v.session
                };
            }
        }

        function restorePicker(): void {
            const v = Visibilities.getForActive();
            if (v && Object.keys(root.savedVisibilities).length > 0) {
                v.dashboard = root.savedVisibilities.dashboard;
                v.osd = root.savedVisibilities.osd;
                v.utilities = root.savedVisibilities.utilities;
                v.sidebar = root.savedVisibilities.sidebar;
                v.launcher = root.savedVisibilities.launcher;
                v.session = root.savedVisibilities.session;
                root.savedVisibilities = {};
            }
            Visibilities.pickerActive = false; 
        }

        onActiveAsyncChanged: {
            if (!activeAsync) {
                restoreTimer.start();
            }
        }

        Timer {
            id: restoreTimer
            interval: 300
            repeat: false
            onTriggered: root.restorePicker()
        }

        Variants {
            model: Screens.screens

            StyledWindow {
                id: win

                required property ShellScreen modelData

                screen: modelData
                name: "area-picker"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: root.closing ? WlrKeyboardFocus.None : WlrKeyboardFocus.Exclusive
                mask: root.closing ? empty : null

                anchors.top: true
                anchors.bottom: true
                anchors.left: true
                anchors.right: true

                Region {
                    id: empty
                }

                Picker {
                    loader: root
                    screen: win.modelData
                }
            }
        }
    }

    IpcHandler {
        function open(): void {
            root.freeze = false;
            root.closing = false;
            root.clipboardOnly = false;
            root.openPicker();
            root.activeAsync = true;
        }

        function openFreeze(): void {
            root.freeze = true;
            root.closing = false;
            root.clipboardOnly = false;
            root.openPicker();
            root.activeAsync = true;
        }

        function openClip(): void {
            root.freeze = false;
            root.closing = false;
            root.clipboardOnly = true;
            root.openPicker();
            root.activeAsync = true;
        }

        function openFreezeClip(): void {
            root.freeze = true;
            root.closing = false;
            root.clipboardOnly = true;
            root.openPicker();
            root.activeAsync = true;
        }

        target: "picker"
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "screenshot"
        description: "Open screenshot tool"
        onPressed: {
            root.freeze = false;
            root.closing = false;
            root.clipboardOnly = false;
            root.openPicker();
            root.activeAsync = true;
        }
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "screenshotFreeze"
        description: "Open screenshot tool (freeze mode)"
        onPressed: {
            root.freeze = true;
            root.closing = false;
            root.clipboardOnly = false;
            root.openPicker();
            root.activeAsync = true;
        }
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "screenshotClip"
        description: "Open screenshot tool (clipboard)"
        onPressed: {
            root.freeze = false;
            root.closing = false;
            root.clipboardOnly = true;
            root.openPicker();
            root.activeAsync = true;
        }
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "screenshotFreezeClip"
        description: "Open screenshot tool (freeze mode, clipboard)"
        onPressed: {
            root.freeze = true;
            root.closing = false;
            root.clipboardOnly = true;
            root.openPicker();
            root.activeAsync = true;
        }
    }
}
