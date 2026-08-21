/**
 * Storage Layer for MSAI
 * Primary storage: IndexedDB with localStorage fallback.
 */

const DB_NAME = "msai_db";
const DB_VERSION = 1;
const STORE_CONVERSATIONS = "conversations";
const STORE_SETTINGS = "settings";

class StorageService {
    constructor() {
        this.db = null;
        this.isIndexedDBSupported = "indexedDB" in window;
    }

    /**
     * Initializes the IndexedDB storage instance
     */
    async init() {
        if (!this.isIndexedDBSupported) {
            console.warn("IndexedDB not supported, using localStorage fallback.");
            return;
        }

        return new Promise((resolve, reject) => {
            const request = indexedDB.open(DB_NAME, DB_VERSION);

            request.onupgradeneeded = (event) => {
                const db = event.target.result;

                // Create conversations store
                if (!db.objectStoreNames.contains(STORE_CONVERSATIONS)) {
                    const convStore = db.createObjectStore(STORE_CONVERSATIONS, { keyPath: "id" });
                    convStore.createIndex("updatedAt", "updatedAt", { unique: false });
                }

                // Create settings store
                if (!db.objectStoreNames.contains(STORE_SETTINGS)) {
                    db.createObjectStore(STORE_SETTINGS, { keyPath: "key" });
                }
            };

            request.onsuccess = (event) => {
                this.db = event.target.result;
                resolve();
            };

            request.onerror = (event) => {
                console.error("IndexedDB initialization error:", event.target.error);
                resolve(); // Fallback gracefully to localStorage
            };
        });
    }

    /**
     * Retrieves all saved conversations ordered by updatedAt descending
     */
    async getAllConversations() {
        if (this.db) {
            return new Promise((resolve) => {
                const transaction = this.db.transaction([STORE_CONVERSATIONS], "readonly");
                const store = transaction.objectStore(STORE_CONVERSATIONS);
                const request = store.getAll();

                request.onsuccess = () => {
                    const result = request.result || [];
                    result.sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt));
                    resolve(result);
                };

                request.onerror = () => {
                    resolve(this._getLocalStorageConversations());
                };
            });
        }
        return this._getLocalStorageConversations();
    }

    /**
     * Saves or updates a conversation object
     */
    async saveConversation(conversation) {
        if (this.db) {
            return new Promise((resolve) => {
                const transaction = this.db.transaction([STORE_CONVERSATIONS], "readwrite");
                const store = transaction.objectStore(STORE_CONVERSATIONS);
                const request = store.put(conversation);

                request.onsuccess = () => resolve(true);
                request.onerror = () => {
                    this._saveLocalStorageConversation(conversation);
                    resolve(false);
                };
            });
        }
        this._saveLocalStorageConversation(conversation);
        return true;
    }

    /**
     * Deletes a conversation by ID
     */
    async deleteConversation(id) {
        if (this.db) {
            return new Promise((resolve) => {
                const transaction = this.db.transaction([STORE_CONVERSATIONS], "readwrite");
                const store = transaction.objectStore(STORE_CONVERSATIONS);
                const request = store.delete(id);

                request.onsuccess = () => resolve(true);
                request.onerror = () => resolve(false);
            });
        }
        const convs = this._getLocalStorageConversations().filter(c => c.id !== id);
        localStorage.setItem("msai_conversations", JSON.stringify(convs));
        return true;
    }

    /**
     * Clears all stored conversations
     */
    async clearAllConversations() {
        if (this.db) {
            return new Promise((resolve) => {
                const transaction = this.db.transaction([STORE_CONVERSATIONS], "readwrite");
                const store = transaction.objectStore(STORE_CONVERSATIONS);
                const request = store.clear();

                request.onsuccess = () => resolve(true);
                request.onerror = () => resolve(false);
            });
        }
        localStorage.removeItem("msai_conversations");
        return true;
    }

    /* Fallback LocalStorage Helpers */
    _getLocalStorageConversations() {
        try {
            const data = localStorage.getItem("msai_conversations");
            return data ? JSON.parse(data) : [];
        } catch (e) {
            return [];
        }
    }

    _saveLocalStorageConversation(conversation) {
        try {
            const convs = this._getLocalStorageConversations();
            const index = convs.findIndex(c => c.id === conversation.id);
            if (index >= 0) {
                convs[index] = conversation;
            } else {
                convs.push(conversation);
            }
            localStorage.setItem("msai_conversations", JSON.stringify(convs));
        } catch (e) {
            console.error("LocalStorage write error:", e);
        }
    }
}

export const storage = new StorageService();
