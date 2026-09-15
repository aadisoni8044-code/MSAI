/**
 * NV ZIP — Global Search Engine
 * Supports quick search across all 12 AI topics, keyboard shortcut (Cmd/Ctrl + K),
 * matching results display, and instant smooth jumping to matching sections.
 */

class SearchEngine {
  constructor() {
    this.triggerBtn = document.getElementById('search-trigger-btn');
    this.searchModal = document.getElementById('search-modal');
    this.closeBtn = document.getElementById('search-modal-close');
    this.searchInput = document.getElementById('global-search-input');
    this.resultsList = document.getElementById('search-results-list');

    this.init();
  }

  init() {
    if (!this.searchModal || !this.searchInput) return;

    // Trigger search modal on button click
    if (this.triggerBtn) {
      this.triggerBtn.addEventListener('click', () => this.openSearch());
    }

    // Close button
    if (this.closeBtn) {
      this.closeBtn.addEventListener('click', () => this.closeSearch());
    }

    // Close modal on click outside content
    this.searchModal.addEventListener('click', (e) => {
      if (e.target === this.searchModal) {
        this.closeSearch();
      }
    });

    // Keyboard shortcuts (Cmd/Ctrl + K and ESC)
    document.addEventListener('keydown', (e) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault();
        this.openSearch();
      } else if (e.key === 'Escape' && !this.searchModal.classList.contains('hidden')) {
        this.closeSearch();
      }
    });

    // Real-time input search event
    this.searchInput.addEventListener('input', () => {
      this.performSearch(this.searchInput.value.trim());
    });
  }

  openSearch() {
    this.searchModal.classList.remove('hidden');
    this.searchModal.setAttribute('aria-hidden', 'false');
    this.searchInput.value = '';
    this.performSearch('');
    setTimeout(() => this.searchInput.focus(), 50);
  }

  closeSearch() {
    this.searchModal.classList.add('hidden');
    this.searchModal.setAttribute('aria-hidden', 'true');
  }

  performSearch(query) {
    if (!this.resultsList) return;
    this.resultsList.innerHTML = '';

    const concepts = window.NV_DATA ? window.NV_DATA.concepts : {};
    const keys = Object.keys(concepts);

    const matches = keys.filter(key => {
      const item = concepts[key];
      if (!query) return true; // Show all if query empty
      const q = query.toLowerCase();
      return (
        item.title.toLowerCase().includes(q) ||
        item.category.toLowerCase().includes(q) ||
        item.shortDesc.toLowerCase().includes(q) ||
        key.toLowerCase().includes(q)
      );
    });

    if (matches.length === 0) {
      this.resultsList.innerHTML = `
        <div style="padding: 20px; text-align: center; color: var(--text-muted); font-size: 0.9rem;">
          No matching AI concepts found for "${query}"
        </div>
      `;
      return;
    }

    matches.forEach(key => {
      const item = concepts[key];
      const resultEl = document.createElement('a');
      resultEl.className = 'search-result-item';
      resultEl.href = '#explorer';
      resultEl.innerHTML = `
        <div>
          <div class="result-title">${item.icon} ${item.title}</div>
          <div style="font-size: 0.75rem; color: var(--text-secondary); margin-top: 2px;">${item.shortDesc}</div>
        </div>
        <span class="result-cat">${item.category}</span>
      `;

      resultEl.addEventListener('click', (e) => {
        e.preventDefault();
        this.closeSearch();

        // Open concept modal via Explorer module if available
        if (window.explorerCards && window.explorerCards.openModal) {
          window.explorerCards.openModal(key);
        } else {
          const target = document.getElementById('explorer');
          if (target) target.scrollIntoView({ behavior: 'smooth' });
        }
      });

      this.resultsList.appendChild(resultEl);
    });
  }
}

document.addEventListener('DOMContentLoaded', () => {
  window.searchEngine = new SearchEngine();
});
