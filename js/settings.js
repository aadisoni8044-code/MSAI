/* SYLVAN WHISPERS - SETTINGS MANAGER */
window.SettingsManager = (function() {
    const SETTINGS_KEY = 'sylvan_whispers_settings';

    const defaultSettings = {
        musicVolume: 70,
        sfxVolume: 80,
        touchControls: false,
        graphicsQuality: 'high', // 'high', 'medium', 'low'
        fullscreen: false
    };

    function loadSettings() {
        try {
            const raw = localStorage.getItem(SETTINGS_KEY);
            if (!raw) {
                // Auto-detect mobile touch environment default
                const isMobile = 'ontouchstart' in window || navigator.maxTouchPoints > 0;
                return { ...defaultSettings, touchControls: isMobile };
            }
            return { ...defaultSettings, ...JSON.parse(raw) };
        } catch (e) {
            console.warn('Failed to load settings from LocalStorage:', e);
            return { ...defaultSettings };
        }
    }

    function saveSettings(settings) {
        try {
            const current = loadSettings();
            const updated = { ...current, ...settings };
            localStorage.setItem(SETTINGS_KEY, JSON.stringify(updated));
            return updated;
        } catch (e) {
            console.error('Failed to save settings:', e);
            return defaultSettings;
        }
    }

    return {
        load: loadSettings,
        save: saveSettings
    };
})();
