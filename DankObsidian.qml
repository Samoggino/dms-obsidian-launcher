import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

QtObject {
    id: root

    property var pluginService: null
    property string trigger: "obs"
    signal itemsChanged

    property bool isFlatpak: true
    property var cachedVaults: []
    property string homeDir: Quickshell.env("HOME") || "/home"
    property string rawData: ""
    property bool enabled: true // Add this property

    property bool alwaysActive: false // New property
    property var excludedPaths: [] //

    // Using the Process component as it is the officially supported one
    property var readProcess: Process {
        command: ["cat", root.getStoragePath()]
        running: false

        stdout: SplitParser {
            onRead: data => {
                root.rawData += data;
            }
        }

        onRunningChanged: {
            if (!running) {
                root.parseData();
            }
        }
    }

    function getStoragePath() {
        return root.isFlatpak ? root.homeDir + "/.var/app/md.obsidian.Obsidian/config/obsidian/obsidian.json" : root.homeDir + "/.config/obsidian/obsidian.json";
    }

    function refreshCache() {
        root.rawData = "";
        // Update the command before starting the process
        root.readProcess.command = ["cat", root.getStoragePath()];
        root.readProcess.running = true;
    }

    function parseData() {
        try {
            const data = JSON.parse(root.rawData);
            let vaults = [];
            if (data && data.vaults) {
                for (var key in data.vaults) {
                    let entry = data.vaults[key];
                    if (entry && entry.path) {
                        vaults.push({
                            name: entry.path.split('/').pop(),
                            path: entry.path
                        });
                    }
                }
            }
            root.cachedVaults = vaults;
            root.itemsChanged();
        } catch (e) {
            console.warn("DankObsidian Error: " + e);
        }
    }

    function updateSettings() {
        if (root.pluginService) {
            // Read values from JSON
            const isEnabled = root.pluginService.loadPluginData("dankObsidian", "enabled", true);
            const newIsFlatpak = root.pluginService.loadPluginData("dankObsidian", "isFlatpak", true);

            // Logic for the trigger:
            // If "Always Active" is enabled, the JSON will have "trigger": ""
            const newTrigger = root.pluginService.loadPluginData("dankObsidian", "trigger", "\obs");

            root.enabled = isEnabled;
            root.isFlatpak = newIsFlatpak;
            root.trigger = newTrigger;
            root.excludedPaths = root.pluginService.loadPluginData("dankObsidian", "excludedPaths", []);

            if (!root.enabled) {
                root.cachedVaults = [];
                root.itemsChanged();
            } else {
                root.refreshCache();
            }
        }
    }

    Component.onCompleted: root.updateSettings()

    property var settingsListener: Connections {
        target: root.pluginService
        function onPluginDataChanged(pluginId) {
            if (pluginId === "dankObsidian") {
                root.updateSettings();
            }
        }
    }

    property var initTimer: Timer {
        interval: 500
        running: true
        repeat: false
        onTriggered: root.refreshCache()
    }

    function getItems(query) {
       if (!root.enabled) return [];

        const q = query ? query.trim().toLowerCase() : "";
    
        return root.cachedVaults
            .filter(v => {
                // Filtro 1: Corrispondenza con la query
                const matchesQuery = q === "" || v.name.toLowerCase().includes(q);
                // Filtro 2: Il path NON deve essere nella lista degli esclusi
                const isNotExcluded = !root.excludedPaths.includes(v.path);
                
                return matchesQuery && isNotExcluded;
            })
            .map(v => ({
                name: v.name,
                icon: "obsidian",
                comment: v.path,
                action: "open:" + v.path
            }));
    }

    function executeItem(item) {
        if (!item?.action)
            return;
        const vPath = item.action.replace("open:", "");
        const uri = "obsidian://open?path=" + encodeURIComponent(vPath);

        // Using execDetached for execution as it is universal
        if (root.isFlatpak) {
            Quickshell.execDetached(["flatpak", "run", "md.obsidian.Obsidian", uri]);
        } else {
            Quickshell.execDetached(["xdg-open", uri]);
        }
    }
}