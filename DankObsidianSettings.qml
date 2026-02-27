import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets
import "logic.js" as Logic

PluginSettings {
    id: root
    pluginId: "dankObsidian"

    // --- PROPRIETÀ ---
    property var excludedPaths: []
    property color colorCard: "#211e29"
        property color colorAccent: "#cdbdff"
            property color colorText: "#e6e0ef"

                // --- INIZIALIZZAZIONE ---
                Component.onCompleted: {
                    loadMatugenColors();
                    let saved = root.getValue("excludedPaths", []);
                    // Inizializziamo il singleton JS e aggiorniamo la proprietà locale
                    root.excludedPaths = Logic.init(saved);
                }

                // --- LOGICA TOGGLE ---
                function handleToggle(targetPath)
                {
                    // Aggiorniamo tramite il tuo logic.js intatto
                    let updatedList = Logic.toggle(targetPath);

                    // RIASSEGNAZIONE: Questo scatena la notifica a tutti i VaultRow
                    root.excludedPaths = updatedList;

                    // Salvataggio
                    root.saveValue("excludedPaths", updatedList);
                }

                // --- CARICAMENTO COLORI MATUGEN ---
                function loadMatugenColors()
                {
                    var xhr = new XMLHttpRequest();
                    xhr.open("GET", "file:///home/samoggino/VSC/dotfiles/config/gtk-4.0/dank-colors.css", true);
                    xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE && (xhr.status === 200 || xhr.status === 0))
                    {
                        let css = xhr.responseText;
                        let getHex = (name) => {
                        let m = css.match(new RegExp(name + "\\s+(#[A-Fa-f0-9]+)"));
                        return m ? m[1] : "";
                    };
                    let c_card = getHex("card_bg_color");
                    let c_accent = getHex("accent_bg_color");
                    let c_text = getHex("window_fg_color");

                    if (c_card) root.colorCard = c_card;
                    if (c_accent) root.colorAccent = c_accent;
                    if (c_text) root.colorText = c_text;
                }
            };
            xhr.send();
        }

        property var mockVaults: [
        { "name": "Personal", "path": "/home/user/Personal" },
        { "name": "Work", "path": "/home/user/Work" }
        ]

        // --- UI ---
        StyledText {
            width: parent.width
            text: "Obsidian Settings"
            font.pixelSize: Theme.fontSizeLarge
            font.weight: Font.Bold
            color: Theme.surfaceText
        }

        ToggleSetting {
            settingKey: "enabled"
            label: "Enable Plugin"
            defaultValue: true
        }

        StringSetting {
            id: triggerSetting
            settingKey: "trigger"
            label: "Search Trigger"
            defaultValue: "\\obs"
        }

        Item { width: parent.width; height: 20 }

        StyledText {
            text: "Vault Visibility"
            font.weight: Font.Bold
            color: Theme.surfaceText
        }

        Column {
            width: parent.width
            spacing: 8

            Repeater {
                id: vaultRepeater
                model: root.mockVaults

                delegate: VaultRow {
                    name: modelData.name
                    path: modelData.path

                    // Binding pulito: si aggiorna ogni volta che root.excludedPaths cambia
                    isExcluded: root.excludedPaths.indexOf(modelData.path) !== -1

                    rowColor: root.colorCard
                    accentColor: root.colorAccent
                    textColor: root.colorText

                    // Chiamiamo la funzione del padre
                    onToggled: root.handleToggle(modelData.path)
                }
            }

            // Repeater per verificare il funzionamento del toggle (rimuovere in produzione)

            VaultRow {
                name: "Test Frontend"
                path: "/solo/visuale"

                // Usiamo una proprietà interna per gestire lo stato locale
                property bool localState: false
                    isExcluded: localState

                    // Passiamo i colori caricati (se XHR ha funzionato) o fallback
                    rowColor: root.colorCard
                    accentColor: root.colorAccent
                    textColor: root.colorText

                    onToggled: {
                        // Qui cambiamo SOLO lo stato locale
                        localState = !localState;
                        console.log("Toggle test cliccato: nuovo stato " + localState);
                    }
                }

            }

        }