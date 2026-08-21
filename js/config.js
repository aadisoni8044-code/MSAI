/**
 * Central Configuration for MSAI Application
 */
export const CONFIG = {
    // Default Google Gemini API Key - Editable via UI or here
    GEMINI_API_KEY: "YOUR_GOOGLE_GEMINI_API_KEY",

    // Default Gemini Model
    // Options: "gemini-2.5-flash", "gemini-2.5-pro"
    DEFAULT_MODEL: "gemini-2.5-flash",

    // App Metadata
    APP_NAME: "MSAI",
    VERSION: "1.0.0",

    // Default Preferences
    ENTER_TO_SEND: true,
    AUTO_SCROLL: true,
    TEMPERATURE: 0.7,

    // API Request Limits
    MAX_ATTACHMENT_SIZE_MB: 10,
    SUPPORTED_MIME_TYPES: [
        "image/png",
        "image/jpeg",
        "image/webp",
        "image/heic",
        "image/heif",
        "text/plain",
        "text/markdown",
        "text/csv",
        "application/pdf"
    ]
};
