pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia.Config
import Caelestia.Models
import qs.services
import qs.utils

Searcher {
    id: root

    readonly property string currentNamePath: `${Paths.state}/wallpaper/path.txt`
    readonly property list<string> smartArg: GlobalConfig.services.smartScheme ? [] : ["--no-smart"]

    property bool showPreview: false
    readonly property string current: showPreview ? previewPath : actualCurrent
    property string previewPath
    property string actualCurrent
    property bool previewColourLock

    FileView {
        id: previewWriter
        path: `${Paths.state}/wallpaper/preview.txt`
        watchChanges: false
    }

    function setWallpaper(path: string): void {
        actualCurrent = path;
        setWallpaperProc.command = ["caelestia", "wallpaper", "-f", path, ...smartArg];
        setWallpaperProc.running = true;
    }

    function preview(path: string): void {
        previewPath = path;
        showPreview = true;
        console.log("preview called:", path, "scheme:", Colours.scheme);
        Quickshell.execDetached(["bash", "-c", `echo -n '${path}' > ${Paths.state}/wallpaper/preview.txt`]);
        getPreviewColoursProc.running = false;
        restartPreviewTimer.restart();
    }

    function stopPreview(): void {
        showPreview = false;
        getPreviewColoursProc.running = false;
        Quickshell.execDetached(["bash", "-c", `echo -n '${actualCurrent}' > ${Paths.state}/wallpaper/preview.txt`]);
        if (!previewColourLock)
            Colours.showPreview = false;
    }

    list: wallpapers.entries
    key: "relativePath"
    useFuzzy: GlobalConfig.launcher.useFuzzy.wallpapers
    extraOpts: useFuzzy ? ({}) : ({
            forward: false
        })

    IpcHandler {
        function get(): string {
            return root.actualCurrent;
        }

        function set(path: string): void {
            root.setWallpaper(path);
        }

        function list(): string {
            return root.list.map(w => w.path).join("\n");
        }

        target: "wallpaper"
    }

    FileView {
        path: root.currentNamePath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.actualCurrent = text().trim();
            root.previewColourLock = false;
        }
    }

    FileSystemModel {
        id: wallpapers

        recursive: true
        path: Paths.wallsdir
        filter: FileSystemModel.Images
    }

    Process {
        id: getPreviewColoursProc

        command: ["caelestia", "wallpaper", "-p", root.previewPath, ...root.smartArg]
        stdout: StdioCollector {
            onStreamFinished: {
                Colours.load(text, true);
                Colours.showPreview = true;
            }
        }
    }


    Timer {
        id: restartPreviewTimer
        interval: 50
        onTriggered: getPreviewColoursProc.running = true
    }

    Process {
        id: setWallpaperProc
        onRunningChanged: {
            if (!running)
                Quickshell.execDetached(["caelestia", "scheme", "set", "-n", "dynamic", "-v", "vibrant"]);
        }
    }
}
