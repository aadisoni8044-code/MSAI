/**
 * Conversation Search Module
 * Instant filtering of conversations by title or message contents.
 */

export class SearchManager {
    constructor() {
        this.query = "";
    }

    /**
     * Filters list of conversations by search query
     */
    filterConversations(conversations, query) {
        if (!query || !query.trim()) return conversations;

        const q = query.toLowerCase().trim();

        return conversations.filter(conv => {
            // Match title
            if (conv.title && conv.title.toLowerCase().includes(q)) {
                return true;
            }
            // Match any message content
            if (conv.messages && Array.isArray(conv.messages)) {
                return conv.messages.some(msg =>
                    msg.content && msg.content.toLowerCase().includes(q)
                );
            }
            return false;
        });
    }
}

export const search = new SearchManager();
