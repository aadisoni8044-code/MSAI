/**
 * MSAI Application Configuration
 * Centralized API configuration and default app settings.
 */

export const CONFIG = {
    // Default Gemini API Key - Replace with your key or configure via Settings UI
    GEMINI_API_KEY: "YOUR_GOOGLE_GEMINI_API_KEY",

    // Default model to use for Gemini API
    MODEL: "gemini-2.5-flash",

    // API endpoint base URL for Google Generative AI
    API_BASE_URL: "https://generativelanguage.googleapis.com/v1beta",

    // Default generation parameters
    TEMPERATURE: 0.7,
    MAX_OUTPUT_TOKENS: 4096,

    // UI Defaults
    ENTER_TO_SEND: true,
    AUTO_SCROLL: true,
    THEME: "dark",

    // Version
    APP_VERSION: "1.0.0"
};

/**
 * Gets effective configuration taking into account user overrides in localStorage
 */
export function getAppConfig() {
    const savedApiKey = localStorage.getItem("msai_api_key");
    const savedModel = localStorage.getItem("msai_model");
    const savedTemp = localStorage.getItem("msai_temperature");
    const savedEnterToSend = localStorage.getItem("msai_enter_to_send");

    return {
        ...CONFIG,
        GEMINI_API_KEY: savedApiKey || CONFIG.GEMINI_API_KEY,
        MODEL: savedModel || CONFIG.MODEL,
        TEMPERATURE: savedTemp ? parseFloat(savedTemp) : CONFIG.TEMPERATURE,
        ENTER_TO_SEND: savedEnterToSend !== null ? savedEnterToSend === "true" : CONFIG.ENTER_TO_SEND
    };
}

/**
 * Saves updated config overrides to localStorage
 */
export function updateAppConfig(newConfig) {
    if (newConfig.GEMINI_API_KEY !== undefined) {
        localStorage.setItem("msai_api_key", newConfig.GEMINI_API_KEY);
    }
    if (newConfig.MODEL) {
        localStorage.setItem("msai_model", newConfig.MODEL);
    }
    if (newConfig.TEMPERATURE !== undefined) {
        localStorage.setItem("msai_temperature", newConfig.TEMPERATURE.toString());
    }
    if (newConfig.ENTER_TO_SEND !== undefined) {
        localStorage.setItem("msai_enter_to_send", newConfig.ENTER_TO_SEND.toString());
    }
}
