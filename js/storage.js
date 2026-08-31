/**
 * MSAI - Storage Manager (LocalStorage & IndexedDB Hybrid)
 */

import { CONFIG } from "./config.js";

const DB_NAME = "msai_database";
const DB_VERSION = 1;
const STORE_CONVERSATIONS = "conversations";
const STORE_SETTINGS = "settings";

class StorageManager {
  constructor() {
    this.db = null;
    this.isIndexedDBAvailable = false;
    this.initPromise = this.initDB();
  }

  async initDB() {
    if (typeof indexedDB === "undefined") {
      this.isIndexedDBAvailable = false;
      return;
    }

    return new Promise((resolve) => {
      try {
        const request = indexedDB.open(DB_NAME, DB_VERSION);

        request.onerror = () => {
          console.warn("IndexedDB failed to open, falling back to localStorage");
          this.isIndexedDBAvailable = false;
          resolve();
        };

        request.onsuccess = async (event) => {
          this.db = event.target.result;
          this.isIndexedDBAvailable = true;
          // Synchronize/migrate data if needed
          await this.syncStoresOnStartup();
          resolve();
        };

        request.onupgradeneeded = (event) => {
          const db = event.target.result;
          if (!db.objectStoreNames.contains(STORE_CONVERSATIONS)) {
            const convStore = db.createObjectStore(STORE_CONVERSATIONS, { keyPath: "id" });
            convStore.createIndex("updatedAt", "updatedAt", { unique: false });
          }
          if (!db.objectStoreNames.contains(STORE_SETTINGS)) {
            db.createObjectStore(STORE_SETTINGS, { keyPath: "key" });
          }
        };
      } catch (err) {
        console.warn("Error initializing IndexedDB:", err);
        this.isIndexedDBAvailable = false;
        resolve();
      }
    });
  }

  async syncStoresOnStartup() {
    if (!this.isIndexedDBAvailable || !this.db) return;
    try {
      const idbList = await new Promise((resolve) => {
        const transaction = this.db.transaction([STORE_CONVERSATIONS], "readonly");
        const store = transaction.objectStore(STORE_CONVERSATIONS);
        const request = store.getAll();
        request.onsuccess = () => resolve(request.result || []);
        request.onerror = () => resolve([]);
      });

      const localList = this.getFallbackConversations();

      // If IndexedDB is empty but localStorage has data, migrate into IndexedDB
      if (idbList.length === 0 && localList.length > 0) {
        const tx = this.db.transaction([STORE_CONVERSATIONS], "readwrite");
        const store = tx.objectStore(STORE_CONVERSATIONS);
        for (const item of localList) {
          store.put(item);
        }
      } else if (idbList.length > 0 && localList.length === 0) {
        // If IndexedDB has data but localStorage is empty, cache in localStorage
        try {
          localStorage.setItem(CONFIG.STORAGE_KEYS.CONVERSATIONS, JSON.stringify(idbList));
        } catch {
          // Ignore quota errors
        }
      }
    } catch (e) {
      console.warn("Storage sync on startup failed:", e);
    }
  }

  // --- Conversations ---

  async getAllConversations() {
    await this.initPromise;

    if (this.isIndexedDBAvailable && this.db) {
      return new Promise((resolve) => {
        try {
          const transaction = this.db.transaction([STORE_CONVERSATIONS], "readonly");
          const store = transaction.objectStore(STORE_CONVERSATIONS);
          const request = store.getAll();

          request.onsuccess = () => {
            const list = request.result || [];
            // Sort by updatedAt descending
            list.sort((a, b) => new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime());
            resolve(list);
          };

          request.onerror = () => {
            resolve(this.getFallbackConversations());
          };
        } catch {
          resolve(this.getFallbackConversations());
        }
      });
    }

    return this.getFallbackConversations();
  }

  getFallbackConversations() {
    try {
      const raw = localStorage.getItem(CONFIG.STORAGE_KEYS.CONVERSATIONS);
      const list = raw ? JSON.parse(raw) : [];
      list.sort((a, b) => new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime());
      return list;
    } catch {
      return [];
    }
  }

  async getConversationById(id) {
    await this.initPromise;
    if (!id) return null;

    if (this.isIndexedDBAvailable && this.db) {
      return new Promise((resolve) => {
        try {
          const transaction = this.db.transaction([STORE_CONVERSATIONS], "readonly");
          const store = transaction.objectStore(STORE_CONVERSATIONS);
          const request = store.get(id);

          request.onsuccess = () => resolve(request.result || null);
          request.onerror = () => resolve(this.getFallbackConversationById(id));
        } catch {
          resolve(this.getFallbackConversationById(id));
        }
      });
    }

    return this.getFallbackConversationById(id);
  }

  getFallbackConversationById(id) {
    const list = this.getFallbackConversations();
    return list.find((c) => c.id === id) || null;
  }

  async saveConversation(conversation) {
    await this.initPromise;
    if (!conversation || !conversation.id) return;

    conversation.updatedAt = new Date().toISOString();

    // Mirror to localStorage as quick fallback & sync
    const list = this.getFallbackConversations();
    const existingIndex = list.findIndex((c) => c.id === conversation.id);
    if (existingIndex >= 0) {
      list[existingIndex] = conversation;
    } else {
      list.unshift(conversation);
    }
    try {
      localStorage.setItem(CONFIG.STORAGE_KEYS.CONVERSATIONS, JSON.stringify(list));
    } catch (e) {
      console.warn("LocalStorage full, continuing with IndexedDB:", e);
    }

    if (this.isIndexedDBAvailable && this.db) {
      return new Promise((resolve) => {
        try {
          const transaction = this.db.transaction([STORE_CONVERSATIONS], "readwrite");
          const store = transaction.objectStore(STORE_CONVERSATIONS);
          const request = store.put(conversation);
          request.onsuccess = () => resolve(conversation);
          request.onerror = () => resolve(conversation);
        } catch {
          resolve(conversation);
        }
      });
    }

    return conversation;
  }

  async deleteConversation(id) {
    await this.initPromise;
    if (!id) return true;

    // Clear active pointer if deleted
    if (this.getActiveChatId() === id) {
      this.setActiveChatId(null);
    }

    // Remove from localStorage
    const list = this.getFallbackConversations().filter((c) => c.id !== id);
    try {
      localStorage.setItem(CONFIG.STORAGE_KEYS.CONVERSATIONS, JSON.stringify(list));
    } catch (e) {
      console.warn("Could not update localStorage on delete:", e);
    }

    if (this.isIndexedDBAvailable && this.db) {
      return new Promise((resolve) => {
        try {
          const transaction = this.db.transaction([STORE_CONVERSATIONS], "readwrite");
          const store = transaction.objectStore(STORE_CONVERSATIONS);
          const request = store.delete(id);
          request.onsuccess = () => resolve(true);
          request.onerror = (e) => {
            console.warn("IndexedDB delete error:", e);
            resolve(true);
          };
        } catch (err) {
          console.warn("IndexedDB transaction error on delete:", err);
          resolve(true);
        }
      });
    }

    return true;
  }

  async deleteAllConversations() {
    await this.initPromise;
    localStorage.removeItem(CONFIG.STORAGE_KEYS.CONVERSATIONS);
    localStorage.removeItem(CONFIG.STORAGE_KEYS.ACTIVE_CHAT_ID);

    if (this.isIndexedDBAvailable && this.db) {
      return new Promise((resolve) => {
        try {
          const transaction = this.db.transaction([STORE_CONVERSATIONS], "readwrite");
          const store = transaction.objectStore(STORE_CONVERSATIONS);
          const request = store.clear();
          request.onsuccess = () => resolve(true);
          request.onerror = () => resolve(true);
        } catch {
          resolve(true);
        }
      });
    }
  }

  // --- Active Chat Pointer ---

  getActiveChatId() {
    return localStorage.getItem(CONFIG.STORAGE_KEYS.ACTIVE_CHAT_ID) || null;
  }

  setActiveChatId(id) {
    if (id) {
      localStorage.setItem(CONFIG.STORAGE_KEYS.ACTIVE_CHAT_ID, id);
    } else {
      localStorage.removeItem(CONFIG.STORAGE_KEYS.ACTIVE_CHAT_ID);
    }
  }

  // --- Settings ---

  getSettings() {
    const defaultSettings = {
      model: CONFIG.DEFAULT_MODEL,
      systemPrompt: CONFIG.DEFAULT_SYSTEM_PROMPT,
      temperature: CONFIG.DEFAULT_TEMPERATURE,
      streaming: CONFIG.DEFAULT_STREAMING,
      theme: "dark", // dark mode default as requested
      enterToSend: true,
      autoScroll: true,
      soundEffects: true,
      readAloudVoice: "default",
      speechSpeed: 1.0,
      apiKey: "",
      avatarStyle: "default",
    };

    try {
      const raw = localStorage.getItem(CONFIG.STORAGE_KEYS.SETTINGS);
      if (raw) {
        const parsed = { ...defaultSettings, ...JSON.parse(raw) };
        // Migrate legacy/deprecated model names
        if (parsed.model === "gemini-2.5-pro" || parsed.model === "gemini-2.0-pro" || parsed.model === "gemini-1.5-pro") {
          parsed.model = "gemini-3.1-pro-preview";
        } else if (parsed.model === "gemini-2.5-flash-lite" || parsed.model === "gemini-2.0-flash-lite") {
          parsed.model = "gemini-3.1-flash-lite";
        } else if (parsed.model === "gemini-2.5-flash" || parsed.model === "gemini-2.0-flash" || parsed.model === "gemini-1.5-flash") {
          parsed.model = "gemini-3.7-flash";
        }
        return parsed;
      }
    } catch (e) {
      console.warn("Could not read settings from storage:", e);
    }
    return defaultSettings;
  }

  saveSettings(settings) {
    try {
      localStorage.setItem(CONFIG.STORAGE_KEYS.SETTINGS, JSON.stringify(settings));
    } catch (e) {
      console.error("Failed to save settings:", e);
    }
  }

  // --- Export / Import ---

  async exportAllData() {
    const conversations = await this.getAllConversations();
    const settings = this.getSettings();
    return {
      version: CONFIG.VERSION,
      appName: CONFIG.APP_NAME,
      exportedAt: new Date().toISOString(),
      settings,
      conversations,
    };
  }

  async importData(data) {
    if (!data || !Array.isArray(data.conversations)) {
      throw new Error("Invalid import file format.");
    }

    for (const conv of data.conversations) {
      if (conv.id && conv.messages) {
        await this.saveConversation(conv);
      }
    }

    if (data.settings) {
      this.saveSettings({ ...this.getSettings(), ...data.settings });
    }

    return true;
  }

  exportConversationAsMarkdown(conversation) {
    if (!conversation) return "";
    let md = `# ${conversation.title || "MSAI Chat"}\n\n`;
    md += `*Generated with ${CONFIG.APP_NAME} (${conversation.model || CONFIG.DEFAULT_MODEL}) on ${new Date(conversation.createdAt).toLocaleString()}*\n\n---\n\n`;

    conversation.messages.forEach((msg) => {
      const speaker = msg.role === "user" ? "### 👤 User" : "### 🤖 MSAI";
      md += `${speaker} *(${new Date(msg.timestamp).toLocaleTimeString()})*\n\n`;
      if (msg.attachments && msg.attachments.length > 0) {
        md += `*Attachments: ${msg.attachments.map((a) => a.name).join(", ")}*\n\n`;
      }
      md += `${msg.content}\n\n---\n\n`;
    });

    return md;
  }
}

export const storage = new StorageManager();
