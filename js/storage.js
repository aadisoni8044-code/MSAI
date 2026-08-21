/**
 * IndexedDB and LocalStorage persistent storage manager for MSAI
 */

const DB_NAME = 'msai_db';
const DB_VERSION = 1;
const STORE_CONVERSATIONS = 'conversations';
const STORE_SETTINGS = 'settings';

class StorageManager {
    constructor() {
        this.db = null;
        this.initPromise = this.initDB();
    }

    async initDB() {
        return new Promise((resolve, reject) => {
            if (!window.indexedDB) {
                console.warn('IndexedDB not supported, fallback to localStorage');
                resolve(null);
                return;
            }

            const request = indexedDB.open(DB_NAME, DB_VERSION);

            request.onerror = (event) => {
                console.error('IndexedDB open error:', event.target.error);
                resolve(null); // Fallback gracefully
            };

            request.onsuccess = (event) => {
                this.db = event.target.result;
                resolve(this.db);
            };

            request.onupgradeneeded = (event) => {
                const db = event.target.result;

                if (!db.objectStoreNames.contains(STORE_CONVERSATIONS)) {
                    const convStore = db.createObjectStore(STORE_CONVERSATIONS, { keyPath: 'id' });
                    convStore.createIndex('updatedAt', 'updatedAt', { unique: false });
                }

                if (!db.objectStoreNames.contains(STORE_SETTINGS)) {
                    db.createObjectStore(STORE_SETTINGS, { keyPath: 'key' });
                }
            };
        });
    }

    // Conversations Storage
    async saveConversation(conversation) {
        await this.initPromise;
        if (this.db) {
            return new Promise((resolve, reject) => {
                const tx = this.db.transaction([STORE_CONVERSATIONS], 'readwrite');
                const store = tx.objectStore(STORE_CONVERSATIONS);
                const req = store.put(conversation);
                req.onsuccess = () => resolve(true);
                req.onerror = () => reject(req.error);
            });
        } else {
            // LocalStorage Fallback
            const chats = this.getLocalStorageChats();
            chats[conversation.id] = conversation;
            localStorage.setItem('msai_chats', JSON.stringify(chats));
            return true;
        }
    }

    async getConversation(id) {
        await this.initPromise;
        if (this.db) {
            return new Promise((resolve, reject) => {
                const tx = this.db.transaction([STORE_CONVERSATIONS], 'readonly');
                const store = tx.objectStore(STORE_CONVERSATIONS);
                const req = store.get(id);
                req.onsuccess = () => resolve(req.result || null);
                req.onerror = () => reject(req.error);
            });
        } else {
            const chats = this.getLocalStorageChats();
            return chats[id] || null;
        }
    }

    async getAllConversations() {
        await this.initPromise;
        if (this.db) {
            return new Promise((resolve, reject) => {
                const tx = this.db.transaction([STORE_CONVERSATIONS], 'readonly');
                const store = tx.objectStore(STORE_CONVERSATIONS);
                const index = store.index('updatedAt');
                const req = index.openCursor(null, 'prev'); // Newest first
                const list = [];

                req.onsuccess = (event) => {
                    const cursor = event.target.result;
                    if (cursor) {
                        list.push(cursor.value);
                        cursor.continue();
                    } else {
                        resolve(list);
                    }
                };
                req.onerror = () => reject(req.error);
            });
        } else {
            const chats = this.getLocalStorageChats();
            const list = Object.values(chats);
            list.sort((a, b) => b.updatedAt - a.updatedAt);
            return list;
        }
    }

    async deleteConversation(id) {
        await this.initPromise;
        if (this.db) {
            return new Promise((resolve, reject) => {
                const tx = this.db.transaction([STORE_CONVERSATIONS], 'readwrite');
                const store = tx.objectStore(STORE_CONVERSATIONS);
                const req = store.delete(id);
                req.onsuccess = () => resolve(true);
                req.onerror = () => reject(req.error);
            });
        } else {
            const chats = this.getLocalStorageChats();
            delete chats[id];
            localStorage.setItem('msai_chats', JSON.stringify(chats));
            return true;
        }
    }

    async clearAllConversations() {
        await this.initPromise;
        if (this.db) {
            return new Promise((resolve, reject) => {
                const tx = this.db.transaction([STORE_CONVERSATIONS], 'readwrite');
                const store = tx.objectStore(STORE_CONVERSATIONS);
                const req = store.clear();
                req.onsuccess = () => resolve(true);
                req.onerror = () => reject(req.error);
            });
        } else {
            localStorage.removeItem('msai_chats');
            return true;
        }
    }

    // Helper for LocalStorage
    getLocalStorageChats() {
        try {
            return JSON.parse(localStorage.getItem('msai_chats')) || {};
        } catch (e) {
            return {};
        }
    }

    // Settings Storage
    getSetting(key, defaultValue = null) {
        const stored = localStorage.getItem(`msai_setting_${key}`);
        if (stored === null) return defaultValue;
        try {
            return JSON.parse(stored);
        } catch {
            return stored;
        }
    }

    setSetting(key, value) {
        localStorage.setItem(`msai_setting_${key}`, JSON.stringify(value));
    }
}

export const storage = new StorageManager();
