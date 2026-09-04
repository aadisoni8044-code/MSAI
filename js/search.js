/**
 * Real-time Conversation Search
 */
import { conversations } from './conversations.js';
import { modalManager } from './modal.js';
import { escapeHtml, formatDate } from './utils.js';

class SearchController {
  constructor() {
    this.searchInput = null;
    this.resultsContainer = null;
  }

  init() {
    this.searchInput = document.getElementById('conversationSearchInput');
    this.resultsContainer = document.getElementById('searchResultsList');

    if (this.searchInput) {
      this.searchInput.addEventListener('input', () => {
        this.performSearch(this.searchInput.value.trim());
      });
    }

    // Trigger buttons
    document.querySelectorAll('[data-open-search]').forEach(btn => {
      btn.addEventListener('click', () => {
        modalManager.open('searchModal');
        if (this.searchInput) {
          this.searchInput.value = '';
          this.performSearch('');
        }
      });
    });
  }

  performSearch(query) {
    if (!this.resultsContainer) return;

    const all = conversations.getAll();
    if (!query) {
      // Show recent conversations
      this.renderResults(all.slice(0, 10), '');
      return;
    }

    const lower = query.toLowerCase();
    const matches = [];

    all.forEach(chat => {
      let matchedInTitle = chat.title.toLowerCase().includes(lower);
      let snippet = '';

      if (!matchedInTitle) {
        // Search in messages
        const foundMsg = chat.messages.find(m => m.content.toLowerCase().includes(lower));
        if (foundMsg) {
          const idx = foundMsg.content.toLowerCase().indexOf(lower);
          const start = Math.max(0, idx - 30);
          const end = Math.min(foundMsg.content.length, idx + 60);
          snippet = (start > 0 ? '...' : '') + foundMsg.content.slice(start, end) + (end < foundMsg.content.length ? '...' : '');
        }
      }

      if (matchedInTitle || snippet) {
        matches.push({ chat, snippet, matchedInTitle });
      }
    });

    this.renderResults(matches, query);
  }

  renderResults(results, query) {
    if (!this.resultsContainer) return;
    this.resultsContainer.innerHTML = '';

    if (results.length === 0) {
      this.resultsContainer.innerHTML = `
        <div class="search-empty">No matching conversations found.</div>
      `;
      return;
    }

    results.forEach(item => {
      const chat = item.chat || item;
      const snippet = item.snippet || (chat.messages[0]?.content.slice(0, 80) || 'No messages');

      const el = document.createElement('div');
      el.className = 'search-result-item';

      let highlightedTitle = escapeHtml(chat.title);
      let highlightedSnippet = escapeHtml(snippet);

      if (query) {
        const regex = new RegExp(`(${escapeHtml(query)})`, 'gi');
        highlightedTitle = highlightedTitle.replace(regex, '<mark>$1</mark>');
        highlightedSnippet = highlightedSnippet.replace(regex, '<mark>$1</mark>');
      }

      el.innerHTML = `
        <div class="search-result-title">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
          </svg>
          <span>${highlightedTitle}</span>
        </div>
        <div class="search-result-snippet">${highlightedSnippet}</div>
        <div class="search-result-date">${formatDate(chat.updatedAt)}</div>
      `;

      el.addEventListener('click', () => {
        conversations.setActive(chat.id);
        modalManager.close('searchModal');
      });

      this.resultsContainer.appendChild(el);
    });
  }
}

export const searchController = new SearchController();
