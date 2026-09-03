import { conversationManager } from './conversations.js';

export function searchConversations(query) {
  if (!query || !query.trim()) return [];

  const q = query.toLowerCase().trim();
  const allConvs = conversationManager.getConversations();

  return allConvs.filter(conv => {
    const titleMatch = conv.title.toLowerCase().includes(q);
    const msgMatch = conv.messages.some(m => m.content.toLowerCase().includes(q));
    return titleMatch || msgMatch;
  });
}