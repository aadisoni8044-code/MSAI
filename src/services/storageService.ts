import { Conversation, Settings } from '../types/chat';
import config from '../data/config.json';

const STORAGE_KEYS = {
  CONVERSATIONS: 'msai_conversations_v1',
  ACTIVE_CONVERSATION_ID: 'msai_active_conv_id_v1',
  SETTINGS: 'msai_settings_v1',
  SIDEBAR_COLLAPSED: 'msai_sidebar_collapsed_v1',
};

export const storageService = {
  // Save conversations list
  saveConversations(conversations: Conversation[]): void {
    try {
      localStorage.setItem(STORAGE_KEYS.CONVERSATIONS, JSON.stringify(conversations));
    } catch (e) {
      console.error('Failed to save conversations to localStorage:', e);
    }
  },

  // Load conversations list
  loadConversations(): Conversation[] {
    try {
      const data = localStorage.getItem(STORAGE_KEYS.CONVERSATIONS);
      if (data) {
        return JSON.parse(data);
      }
    } catch (e) {
      console.error('Failed to load conversations from localStorage:', e);
    }
    return [];
  },

  // Save active conversation ID
  saveActiveConversationId(id: string | null): void {
    try {
      if (id) {
        localStorage.setItem(STORAGE_KEYS.ACTIVE_CONVERSATION_ID, id);
      } else {
        localStorage.removeItem(STORAGE_KEYS.ACTIVE_CONVERSATION_ID);
      }
    } catch (e) {
      console.error('Failed to save active conversation id:', e);
    }
  },

  // Load active conversation ID
  loadActiveConversationId(): string | null {
    try {
      return localStorage.getItem(STORAGE_KEYS.ACTIVE_CONVERSATION_ID);
    } catch (e) {
      console.error('Failed to load active conversation id:', e);
      return null;
    }
  },

  // Save Settings
  saveSettings(settings: Settings): void {
    try {
      localStorage.setItem(STORAGE_KEYS.SETTINGS, JSON.stringify(settings));
    } catch (e) {
      console.error('Failed to save settings to localStorage:', e);
    }
  },

  // Load Settings
  loadSettings(): Settings {
    try {
      const data = localStorage.getItem(STORAGE_KEYS.SETTINGS);
      if (data) {
        return { ...config.defaultSettings, ...JSON.parse(data) } as Settings;
      }
    } catch (e) {
      console.error('Failed to load settings from localStorage:', e);
    }
    return config.defaultSettings as Settings;
  },

  // Save Sidebar Collapsed state
  saveSidebarCollapsed(collapsed: boolean): void {
    try {
      localStorage.setItem(STORAGE_KEYS.SIDEBAR_COLLAPSED, JSON.stringify(collapsed));
    } catch (e) {
      console.error('Failed to save sidebar state:', e);
    }
  },

  // Load Sidebar Collapsed state
  loadSidebarCollapsed(): boolean {
    try {
      const data = localStorage.getItem(STORAGE_KEYS.SIDEBAR_COLLAPSED);
      if (data !== null) {
        return JSON.parse(data);
      }
    } catch (e) {
      console.error('Failed to load sidebar state:', e);
    }
    return false;
  },

  // Clear storage
  clearAllData(): void {
    try {
      localStorage.removeItem(STORAGE_KEYS.CONVERSATIONS);
      localStorage.removeItem(STORAGE_KEYS.ACTIVE_CONVERSATION_ID);
    } catch (e) {
      console.error('Failed to clear storage:', e);
    }
  },
};
