/**
 * MSAI - Conversation Search Engine
 * Dynamic instant searching across conversation titles & message content
 */

import { storage } from "./storage.js";
import { escapeHtml } from "./sanitizer.js";

export class SearchEngine {
  constructor() {
    this.conversationsCache = [];
  }

  async updateIndex() {
    this.conversationsCache = await storage.getAllConversations();
  }

  async search(query) {
    if (!query || !query.trim()) {
      return [];
    }

    await this.updateIndex();
    const cleanQuery = query.trim().toLowerCase();
    const results = [];

    for (const conv of this.conversationsCache) {
      let titleMatch = false;
      let matchedSnippet = "";
      let score = 0;

      // 1. Check title match
      if (conv.title && conv.title.toLowerCase().includes(cleanQuery)) {
        titleMatch = true;
        score += 10;
      }

      // 2. Check message content match
      if (conv.messages && Array.isArray(conv.messages)) {
        for (const msg of conv.messages) {
          const contentLower = (msg.content || "").toLowerCase();
          const matchIndex = contentLower.indexOf(cleanQuery);
          if (matchIndex !== -1) {
            score += 5;
            if (!matchedSnippet) {
              // Extract snippet context
              const start = Math.max(0, matchIndex - 35);
              const end = Math.min(msg.content.length, matchIndex + cleanQuery.length + 45);
              let snippet = msg.content.substring(start, end);
              if (start > 0) snippet = "..." + snippet;
              if (end < msg.content.length) snippet = snippet + "...";
              matchedSnippet = snippet;
            }
          }
        }
      }

      if (score > 0) {
        results.push({
          conversation: conv,
          titleMatch,
          matchedSnippet,
          score,
          query: cleanQuery,
        });
      }
    }

    // Sort highest score first
    results.sort((a, b) => b.score - a.score);
    return results;
  }

  highlightMatch(text, query) {
    if (!text || !query) return escapeHtml(text);
    const escapedText = escapeHtml(text);
    const escapedQuery = escapeHtml(query);
    const regexSafeQuery = escapedQuery.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    try {
      const regex = new RegExp(`(${regexSafeQuery})`, "gi");
      return escapedText.replace(regex, "<mark class='search-highlight'>$1</mark>");
    } catch {
      return escapedText;
    }
  }
}

export const searchEngine = new SearchEngine();
