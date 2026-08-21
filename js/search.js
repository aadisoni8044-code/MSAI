import { conversationManager } from './conversations.js';
import { debounce } from './utils.js';

/**
 * Dynamic Conversations Search Filter Module
 */
export class SearchManager {
    constructor() {
        this.searchInput = null;
        this.onSearchResultsCallback = null;
    }

    init({ onSearchResults }) {
        this.onSearchResultsCallback = onSearchResults;
        this.searchInput = document.getElementById('search-chats-input');

        if (this.searchInput) {
            this.searchInput.addEventListener('input', debounce((e) => {
                this.performSearch(e.target.value);
            }, 250));
        }
    }

    focusInput() {
        if (this.searchInput) {
            this.searchInput.focus();
            this.searchInput.select();
        }
    }

    async performSearch(query) {
        const trimmed = query.trim().toLowerCase();
        const allConversations = await conversationManager.getConversations();

        if (!trimmed) {
            if (this.onSearchResultsCallback) {
                this.onSearchResultsCallback(allConversations);
            }
            return;
        }

        const filtered = allConversations.filter(c => {
            const titleMatch = c.title.toLowerCase().includes(trimmed);
            const contentMatch = c.messages.some(m => m.content.toLowerCase().includes(trimmed));
            return titleMatch || contentMatch;
        });

        if (this.onSearchResultsCallback) {
            this.onSearchResultsCallback(filtered);
        }
    }
}

export const searchManager = new SearchManager();
