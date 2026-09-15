/**
 * DevSyntax Global Search Palette System (Cmd+K)
 */

const SearchSystem = {
    modalOverlay: null,
    searchInput: null,
    resultsContainer: null,
    allIndex: [],
    selectedIndex: 0,

    init() {
        this.modalOverlay = document.getElementById('search-modal-overlay');
        this.searchInput = document.getElementById('global-search-input');
        this.resultsContainer = document.getElementById('global-search-results');

        this.buildSearchIndex();
        this.bindEvents();
    },

    buildSearchIndex() {
        this.allIndex = [];
        if (typeof LANGUAGES_DATA === 'undefined') return;

        Object.values(LANGUAGES_DATA).forEach(lang => {
            lang.categories.forEach(cat => {
                cat.topics.forEach(topic => {
                    this.allIndex.push({
                        id: topic.id,
                        langId: lang.id,
                        langName: lang.name,
                        categoryTitle: cat.title,
                        name: topic.name,
                        shortDesc: topic.shortDesc,
                        type: topic.type,
                        difficulty: topic.difficulty,
                        whatIsIt: topic.whatIsIt
                    });
                });
            });
        });
    },

    bindEvents() {
        // Global Keyboard Shortcut (Cmd+K / Ctrl+K or /)
        document.addEventListener('keydown', (e) => {
            if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
                e.preventDefault();
                this.openModal();
            } else if (e.key === 'Escape' && this.modalOverlay && this.modalOverlay.classList.contains('active')) {
                this.closeModal();
            }
        });

        // Trigger buttons
        const triggerBtn = document.getElementById('global-search-trigger');
        if (triggerBtn) triggerBtn.addEventListener('click', () => this.openModal());

        const heroSearchBtn = document.getElementById('hero-quick-search-btn');
        if (heroSearchBtn) heroSearchBtn.addEventListener('click', () => this.openModal());

        const footerSearchBtn = document.getElementById('footer-search-trigger');
        if (footerSearchBtn) footerSearchBtn.addEventListener('click', (e) => {
            e.preventDefault();
            this.openModal();
        });

        const closeBtn = document.getElementById('search-modal-close');
        if (closeBtn) closeBtn.addEventListener('click', () => this.closeModal());

        if (this.modalOverlay) {
            this.modalOverlay.addEventListener('click', (e) => {
                if (e.target === this.modalOverlay) this.closeModal();
            });
        }

        if (this.searchInput) {
            this.searchInput.addEventListener('input', () => this.handleSearchInput());
            this.searchInput.addEventListener('keydown', (e) => this.handleKeyNavigation(e));
        }
    },

    openModal() {
        if (!this.modalOverlay) return;
        this.modalOverlay.classList.add('active');
        if (this.searchInput) {
            this.searchInput.value = '';
            this.searchInput.focus();
            this.handleSearchInput();
        }
    },

    closeModal() {
        if (this.modalOverlay) {
            this.modalOverlay.classList.remove('active');
        }
    },

    handleSearchInput() {
        const query = (this.searchInput ? this.searchInput.value : '').trim().toLowerCase();

        let filtered = [];
        if (!query) {
            filtered = this.allIndex.slice(0, 8); // Top featured suggestions
        } else {
            filtered = this.allIndex.filter(item => {
                return item.name.toLowerCase().includes(query) ||
                       item.langName.toLowerCase().includes(query) ||
                       item.shortDesc.toLowerCase().includes(query) ||
                       item.categoryTitle.toLowerCase().includes(query);
            }).slice(0, 12);
        }

        this.selectedIndex = 0;
        this.renderResults(filtered, query);
    },

    renderResults(items, query) {
        if (!this.resultsContainer) return;

        if (items.length === 0) {
            this.resultsContainer.innerHTML = `
                <div style="padding: 32px; text-align: center; color: var(--text-muted);">
                    <p style="font-size: 1.1rem; font-weight: 600; margin-bottom: 6px;">No functions or keywords found</p>
                    <p style="font-size: 0.88rem;">Try searching for "print", "def", "fetch", or "SELECT"</p>
                </div>
            `;
            return;
        }

        let html = '';
        items.forEach((item, index) => {
            const isSelected = index === this.selectedIndex ? 'selected' : '';
            html += `
                <div class="search-result-item ${isSelected}" data-index="${index}" onclick="SearchSystem.selectItem('${item.langId}', '${item.id}')">
                    <div>
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <span class="search-result-title">${item.name}</span>
                            <span style="font-size: 0.72rem; padding: 2px 6px; border-radius: 4px; background: var(--bg-surface-hover); color: var(--text-muted); font-weight: 600;">${item.langName}</span>
                        </div>
                        <div class="search-result-desc">${item.shortDesc}</div>
                    </div>
                    <div style="font-size: 0.75rem; color: var(--text-muted); font-weight: 600;">${item.categoryTitle}</div>
                </div>
            `;
        });

        this.resultsContainer.innerHTML = html;
    },

    handleKeyNavigation(e) {
        const items = this.resultsContainer ? this.resultsContainer.querySelectorAll('.search-result-item') : [];
        if (items.length === 0) return;

        if (e.key === 'ArrowDown') {
            e.preventDefault();
            this.selectedIndex = (this.selectedIndex + 1) % items.length;
            this.updateSelectedState(items);
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            this.selectedIndex = (this.selectedIndex - 1 + items.length) % items.length;
            this.updateSelectedState(items);
        } else if (e.key === 'Enter') {
            e.preventDefault();
            const selectedElem = items[this.selectedIndex];
            if (selectedElem) selectedElem.click();
        }
    },

    updateSelectedState(items) {
        items.forEach((item, idx) => {
            if (idx === this.selectedIndex) {
                item.classList.add('selected');
                item.scrollIntoView({ block: 'nearest' });
            } else {
                item.classList.remove('selected');
            }
        });
    },

    selectItem(langId, topicId) {
        this.closeModal();
        if (window.App) {
            App.switchLanguageAndTopic(langId, topicId);
        }
    }
};
