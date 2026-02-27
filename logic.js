// logic.js
.pragma library // Fondamentale: rende lo script un singleton (mantiene lo stato)

let internalBlacklist = [];

function init(savedData) {
    if (Array.isArray(savedData)) {
        internalBlacklist = savedData;
    } else {
        internalBlacklist = [];
    }
    return internalBlacklist;
}

function toggle(path) {
    let index = internalBlacklist.indexOf(path);
    if (index === -1) {
        internalBlacklist.push(path);
    } else {
        internalBlacklist.splice(index, 1);
    }
    // Restituiamo una copia per forzare l'aggiornamento QML
    return Array.from(internalBlacklist);
}

function getList() {
    return internalBlacklist;
}