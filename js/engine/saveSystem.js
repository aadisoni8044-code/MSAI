/* LocalStorage Save System */
class SaveSystem {
    constructor() {
        this.STORAGE_KEY = 'sylvan_veil_save_data';
        this.defaultData = {
            unlockedLevel: 1,
            currentLevel: 1,
            checkpointId: null,
            coins: 0,
            crystals: 0,
            keys: 0,
            settings: {
                musicVolume: 70,
                sfxVolume: 80,
                forceMobileControls: false,
                graphicsQuality: 'high'
            }
        };
        this.data = this.loadData();
    }

    loadData() {
        try {
            const raw = localStorage.getItem(this.STORAGE_KEY);
            if (raw) {
                return Object.assign({}, this.defaultData, JSON.parse(raw));
            }
        } catch (e) {
            console.warn('Failed to load save data:', e);
        }
        return Object.assign({}, this.defaultData);
    }

    saveData() {
        try {
            localStorage.setItem(this.STORAGE_KEY, JSON.stringify(this.data));
        } catch (e) {
            console.warn('Failed to save data:', e);
        }
    }

    resetProgress() {
        this.data = Object.assign({}, this.defaultData);
        this.saveData();
    }

    unlockLevel(levelNum) {
        if (levelNum > this.data.unlockedLevel) {
            this.data.unlockedLevel = levelNum;
            this.saveData();
        }
    }

    setCurrentLevel(levelNum) {
        this.data.currentLevel = levelNum;
        this.saveData();
    }

    saveCheckpoint(checkpointId) {
        this.data.checkpointId = checkpointId;
        this.saveData();
    }

    addCollectibles(coins = 0, crystals = 0, keys = 0) {
        this.data.coins += coins;
        this.data.crystals += crystals;
        this.data.keys += keys;
        this.saveData();
    }

    updateSettings(settings) {
        this.data.settings = Object.assign({}, this.data.settings, settings);
        this.saveData();
    }
}

window.saveSystem = new SaveSystem();
