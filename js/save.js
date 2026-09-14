/* SYLVAN WHISPERS - SAVE SYSTEM MANAGER */
window.SaveManager = (function() {
    const SAVE_KEY = 'sylvan_whispers_save';

    const defaultSave = {
        currentSectionIndex: 0,
        checkpointSection: 0,
        checkpointX: 120,
        checkpointY: 450,
        collectibles: 0,
        collectedOrbs: [], // array of orb IDs collected
        health: 100,
        unlockedSections: [0],
        timestamp: null
    };

    function loadSave() {
        try {
            const raw = localStorage.getItem(SAVE_KEY);
            if (!raw) return { ...defaultSave };
            const parsed = JSON.parse(raw);
            return { ...defaultSave, ...parsed };
        } catch (e) {
            console.warn('Failed to parse save data from LocalStorage:', e);
            return { ...defaultSave };
        }
    }

    function saveProgress(data) {
        try {
            const current = loadSave();
            const updated = {
                ...current,
                ...data,
                timestamp: Date.now()
            };
            localStorage.setItem(SAVE_KEY, JSON.stringify(updated));
            return true;
        } catch (e) {
            console.error('Failed to save game state:', e);
            return false;
        }
    }

    function resetSave() {
        try {
            localStorage.removeItem(SAVE_KEY);
            return { ...defaultSave };
        } catch (e) {
            console.error('Failed to reset save state:', e);
            return { ...defaultSave };
        }
    }

    function hasSaveData() {
        const save = loadSave();
        return save.timestamp !== null || save.collectibles > 0 || save.checkpointSection > 0;
    }

    return {
        load: loadSave,
        save: saveProgress,
        reset: resetSave,
        hasSave: hasSaveData
    };
})();
