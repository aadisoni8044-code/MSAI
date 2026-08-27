/**
 * MSAI Configuration
 */
const CONFIG = {
  APP_NAME: 'MSAI',
  VERSION: '1.0.0',
  DEFAULT_MODEL: 'gemini-2.0-flash',
  API_PROXY_ENDPOINT: '/api/chat',
  API_STATUS_ENDPOINT: '/api/status',
  STORAGE_KEYS: {
    CONVERSATIONS: 'msai_conversations_v1',
    ACTIVE_CONV_ID: 'msai_active_conv_id_v1',
    SETTINGS: 'msai_settings_v1',
    THEME: 'msai_theme_v1',
    SIDEBAR_COLLAPSED: 'msai_sidebar_collapsed_v1'
  },
  DEFAULT_SETTINGS: {
    theme: 'dark',
    userApiKey: '',
    useProxy: true,
    model: 'gemini-2.0-flash',
    sendOnEnter: true,
    streamResponses: true,
    soundEffects: false
  },
  SYSTEM_INSTRUCTION: {
    parts: [
      {
        text: "You are MSAI, an advanced, highly intelligent AI assistant. You provide concise, insightful, precise, and helpful responses with clear Markdown formatting where applicable."
      }
    ]
  }
};

if (typeof module !== 'undefined' && module.exports) {
  module.exports = CONFIG;
}
