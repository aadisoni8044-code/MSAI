/**
 * Global Keyboard Shortcuts Manager
 * Handles Ctrl+K (Search), Ctrl+N (New Chat), and Esc (Close Modal/Drawer).
 */

import { conversations } from './conversations.js';
import { modal } from './modal.js';
import { sidebar } from './sidebar.js';

export class ShortcutManager {
    init() {
        document.addEventListener("keydown", (e) => {
            // Ctrl+K / Cmd+K : Focus Search Input
            if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
                e.preventDefault();
                const searchInput = document.getElementById("search-chats-input");
                if (searchInput) {
                    searchInput.focus();
                    searchInput.select();
                }
            }

            // Ctrl+N / Cmd+N : Start New Chat
            if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'n') {
                e.preventDefault();
                conversations.createNewConversation();
            }

            // Escape : Close modals or mobile drawer
            if (e.key === "Escape") {
                modal.closeActiveModal();
                sidebar.closeMobileSidebar();
            }
        });
    }
}

export const shortcuts = new ShortcutManager();
