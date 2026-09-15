/**
 * DevSyntax Main Application Controller
 */

const App = {
    activeView: "welcome",
    activeLanguageId: "python",
    activeTopicId: "py-print",

    init() {
        ProgressSystem.init();
        SearchSystem.init();
        PracticeSystem.init();

        this.bindGlobalNavigation();
        this.renderLanguagesGrid('all');
        this.bindFilterTabs();
        this.bindMobileMenu();

        // Restore active state if saved
        if (ProgressSystem.data.lastActiveLanguage && LANGUAGES_DATA[ProgressSystem.data.lastActiveLanguage]) {
            this.activeLanguageId = ProgressSystem.data.lastActiveLanguage;
        }
        if (ProgressSystem.data.lastActiveTopic) {
            this.activeTopicId = ProgressSystem.data.lastActiveTopic;
        }

        this.renderDashboardSidebar();
        this.renderTopicDetail();
    },

    bindGlobalNavigation() {
        // Nav Links
        document.querySelectorAll('.nav-link, .nav-switch').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const targetView = link.getAttribute('data-view');
                if (targetView) this.switchView(targetView);
            });
        });

        // Brand logo link to welcome view
        const logoLink = document.getElementById('logo-link');
        if (logoLink) {
            logoLink.addEventListener('click', (e) => {
                e.preventDefault();
                this.switchView('welcome');
            });
        }

        // Footer language selectors
        document.querySelectorAll('.lang-select-footer').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const langId = link.getAttribute('data-lang');
                if (langId && LANGUAGES_DATA[langId]) {
                    this.switchLanguage(langId);
                    this.switchView('dashboard');
                }
            });
        });
    },

    switchView(viewId) {
        this.activeView = viewId;

        document.querySelectorAll('.view-section').forEach(sec => sec.classList.remove('active'));
        const targetSec = document.getElementById(`${viewId}-view`);
        if (targetSec) targetSec.classList.add('active');

        document.querySelectorAll('.nav-link').forEach(link => {
            if (link.getAttribute('data-view') === viewId) {
                link.classList.add('active');
            } else {
                link.classList.remove('active');
            }
        });

        window.scrollTo({ top: 0, behavior: 'smooth' });
    },

    renderLanguagesGrid(filter = 'all') {
        const grid = document.getElementById('languages-grid');
        if (!grid || typeof LANGUAGES_DATA === 'undefined') return;

        let html = '';
        Object.values(LANGUAGES_DATA).forEach(lang => {
            if (filter !== 'all' && lang.category !== filter && filter !== 'popular') return;
            if (filter === 'popular' && lang.badge !== 'Popular' && lang.badge !== 'Essential') return;

            let topicCount = 0;
            lang.categories.forEach(cat => topicCount += cat.topics.length);

            html += `
                <div class="language-card" style="--accent-color: ${lang.color};" onclick="App.selectLanguageFromCard('${lang.id}')">
                    <div class="card-top">
                        <div class="card-icon-box">${lang.iconSvg}</div>
                        <span class="card-badge">${lang.badge}</span>
                    </div>

                    <h3 class="card-title">${lang.name}</h3>
                    <p class="card-desc">${lang.tagline} • ${lang.description.substring(0, 75)}...</p>

                    <div class="card-footer">
                        <span class="card-topics-count">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                            ${topicCount} Topics
                        </span>
                        <span class="card-action-arrow">Explore →</span>
                    </div>
                </div>
            `;
        });

        grid.innerHTML = html;
    },

    bindFilterTabs() {
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                const filter = btn.getAttribute('data-filter');
                this.renderLanguagesGrid(filter);
            });
        });
    },

    selectLanguageFromCard(langId) {
        if (!LANGUAGES_DATA[langId]) return;
        this.switchLanguage(langId);
        this.switchView('dashboard');
    },

    switchLanguage(langId) {
        if (!LANGUAGES_DATA[langId]) return;
        this.activeLanguageId = langId;

        // Pick first topic of this language
        const firstCat = LANGUAGES_DATA[langId].categories[0];
        if (firstCat && firstCat.topics[0]) {
            this.activeTopicId = firstCat.topics[0].id;
        }

        ProgressSystem.data.lastActiveLanguage = this.activeLanguageId;
        ProgressSystem.data.lastActiveTopic = this.activeTopicId;
        ProgressSystem.saveProgress();

        this.renderDashboardSidebar();
        this.renderTopicDetail();
    },

    switchLanguageAndTopic(langId, topicId) {
        if (!LANGUAGES_DATA[langId]) return;
        this.activeLanguageId = langId;
        this.activeTopicId = topicId;

        ProgressSystem.data.lastActiveLanguage = langId;
        ProgressSystem.data.lastActiveTopic = topicId;
        ProgressSystem.saveProgress();

        this.renderDashboardSidebar();
        this.renderTopicDetail();
        this.switchView('dashboard');
    },

    renderDashboardSidebar() {
        const lang = LANGUAGES_DATA[this.activeLanguageId];
        if (!lang) return;

        // Active Language Header Badge
        const iconContainer = document.getElementById('sidebar-active-lang-icon');
        const nameElem = document.getElementById('sidebar-active-lang-name');
        const metaElem = document.getElementById('sidebar-active-lang-meta');

        if (iconContainer) iconContainer.innerHTML = lang.iconSvg;
        if (nameElem) nameElem.textContent = lang.name;

        let totalTopics = 0;
        lang.categories.forEach(c => totalTopics += c.topics.length);
        if (metaElem) metaElem.textContent = `${lang.categories.length} Categories • ${totalTopics} Topics`;

        // Render Language Dropdown Menu Items
        const dropdownList = document.getElementById('lang-dropdown-list');
        if (dropdownList) {
            let dropHtml = '';
            Object.values(LANGUAGES_DATA).forEach(l => {
                dropHtml += `
                    <div class="lang-dropdown-item" onclick="App.switchLanguage('${l.id}')">
                        <div style="width: 20px; height: 20px; color: ${l.color}; display: flex;">${l.iconSvg}</div>
                        <span style="font-weight: 600;">${l.name}</span>
                    </div>
                `;
            });
            dropdownList.innerHTML = dropHtml;
        }

        // Dropdown toggle
        const selectorBtn = document.getElementById('sidebar-lang-selector-btn');
        const dropdownMenu = document.getElementById('lang-dropdown-menu');
        if (selectorBtn && dropdownMenu) {
            selectorBtn.onclick = (e) => {
                e.stopPropagation();
                dropdownMenu.classList.toggle('open');
            };
            document.onclick = () => dropdownMenu.classList.remove('open');
        }

        // Filter input
        const filterInput = document.getElementById('sidebar-filter-input');
        if (filterInput) {
            filterInput.oninput = () => this.renderCategoryTree(filterInput.value.trim().toLowerCase());
        }

        this.renderCategoryTree();
        this.updateSidebarProgress();
    },

    renderCategoryTree(filter = '') {
        const treeContainer = document.getElementById('sidebar-category-tree');
        const lang = LANGUAGES_DATA[this.activeLanguageId];
        if (!treeContainer || !lang) return;

        let html = '';
        lang.categories.forEach(cat => {
            const matchingTopics = cat.topics.filter(t => !filter || t.name.toLowerCase().includes(filter) || t.shortDesc.toLowerCase().includes(filter));
            if (matchingTopics.length === 0) return;

            let topicItemsHtml = '';
            matchingTopics.forEach(topic => {
                const isActive = topic.id === this.activeTopicId ? 'active' : '';
                const isCompleted = ProgressSystem.isTopicCompleted(topic.id) ? 'completed' : '';

                topicItemsHtml += `
                    <button class="topic-item-btn ${isActive} ${isCompleted}" onclick="App.selectTopic('${topic.id}')">
                        <span class="font-mono">${topic.name}</span>
                        <svg class="topic-check-icon" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                    </button>
                `;
            });

            html += `
                <div class="category-group">
                    <div class="category-title-btn">
                        <span>${cat.title}</span>
                    </div>
                    <div class="topic-item-list">
                        ${topicItemsHtml}
                    </div>
                </div>
            `;
        });

        treeContainer.innerHTML = html;
    },

    selectTopic(topicId) {
        this.activeTopicId = topicId;
        ProgressSystem.data.lastActiveTopic = topicId;
        ProgressSystem.saveProgress();

        this.renderCategoryTree();
        this.renderTopicDetail();
    },

    renderTopicDetail() {
        const lang = LANGUAGES_DATA[this.activeLanguageId];
        if (!lang) return;

        let currentCat = null;
        let currentTopic = null;

        for (const cat of lang.categories) {
            for (const t of cat.topics) {
                if (t.id === this.activeTopicId) {
                    currentCat = cat;
                    currentTopic = t;
                    break;
                }
            }
            if (currentTopic) break;
        }

        if (!currentTopic) return;

        // Update Breadcrumbs
        const crumbLang = document.getElementById('breadcrumb-lang');
        const crumbCat = document.getElementById('breadcrumb-cat');
        const crumbTopic = document.getElementById('breadcrumb-topic');
        if (crumbLang) crumbLang.textContent = lang.name;
        if (crumbCat) crumbCat.textContent = currentCat.title;
        if (crumbTopic) crumbTopic.textContent = currentTopic.name;

        // Completion Button State
        const completedBtn = document.getElementById('mark-completed-btn');
        const completedText = document.getElementById('mark-completed-text');
        if (completedBtn && completedText) {
            const isComp = ProgressSystem.isTopicCompleted(currentTopic.id);
            if (isComp) {
                completedBtn.classList.add('completed');
                completedText.textContent = "Completed ✓";
            } else {
                completedBtn.classList.remove('completed');
                completedText.textContent = "Mark as Completed";
            }

            completedBtn.onclick = () => {
                const newState = ProgressSystem.toggleTopicCompletion(currentTopic.id);
                if (newState) {
                    completedBtn.classList.add('completed');
                    completedText.textContent = "Completed ✓";
                    this.showToast("Topic marked as completed!");
                } else {
                    completedBtn.classList.remove('completed');
                    completedText.textContent = "Mark as Completed";
                }
                this.renderCategoryTree();
                this.updateSidebarProgress();
            };
        }

        // Render Detail Content
        const detailContainer = document.getElementById('topic-detail-content');
        if (detailContainer) {
            let stepsHtml = '';
            if (currentTopic.howItWorks) {
                currentTopic.howItWorks.forEach((step, idx) => {
                    stepsHtml += `
                        <div class="step-item">
                            <div class="step-number">${idx + 1}</div>
                            <div class="step-text">${step}</div>
                        </div>
                    `;
                });
            }

            let paramsHtml = '';
            if (currentTopic.parameters && currentTopic.parameters.length > 0) {
                let rowsHtml = '';
                currentTopic.parameters.forEach(p => {
                    rowsHtml += `<tr><td><strong>${p.name}</strong></td><td><code>${p.type}</code></td><td>${p.desc}</td></tr>`;
                });
                paramsHtml = `
                    <div class="learning-card" id="parameters">
                        <h3 class="card-heading">Parameters & Return Value</h3>
                        <table class="params-table">
                            <thead><tr><th>Name</th><th>Type</th><th>Description</th></tr></thead>
                            <tbody>${rowsHtml}</tbody>
                        </table>
                        <div style="margin-top: 16px; font-size: 0.9rem;"><strong>Return Value:</strong> <code>${currentTopic.returnValue || 'None'}</code></div>
                    </div>
                `;
            }

            detailContainer.innerHTML = `
                <div class="topic-title-section">
                    <div class="topic-meta-tags">
                        <span class="tag-badge badge-easy">${currentTopic.difficulty || 'Beginner'}</span>
                        <span style="font-size: 0.8rem; color: var(--text-muted); font-weight: 600;">Type: ${currentTopic.type}</span>
                    </div>
                    <h1 class="topic-main-title">${currentTopic.name}</h1>
                    <p class="topic-short-desc">${currentTopic.shortDesc}</p>
                </div>

                <div class="learning-card" id="overview">
                    <h3 class="card-heading">What is ${currentTopic.name}?</h3>
                    <p class="concept-explanation-text">${currentTopic.whatIsIt}</p>
                </div>

                <div class="learning-card" id="syntax">
                    <h3 class="card-heading">Syntax</h3>
                    <div class="syntax-box">${currentTopic.syntax}</div>
                </div>

                <div id="code-example"></div>

                <div class="learning-card" id="how-it-works">
                    <h3 class="card-heading">How It Works</h3>
                    <div class="how-it-works-list">${stepsHtml}</div>
                </div>

                ${paramsHtml}

                <div class="learning-card" id="gotchas">
                    <h3 class="card-heading" style="color: var(--accent-rose);">Common Mistakes & Gotchas</h3>
                    <div class="gotcha-box">${currentTopic.commonMistakes || 'Be careful with proper syntax formatting and indentation.'}</div>
                </div>

                <div class="learning-card" id="real-world">
                    <h3 class="card-heading" style="color: var(--accent-emerald);">Real-World Use Cases</h3>
                    <p class="concept-explanation-text">${currentTopic.realWorldUse || 'Widely used in software architecture.'}</p>
                </div>
            `;

            CodeEditorEngine.renderEditorCard(currentTopic, 'code-example');
        }

        this.updateTocPane(lang, currentCat, currentTopic);
        this.updatePrevNextButtons(lang, currentTopic);
    },

    updateTocPane(lang, currentCat, currentTopic) {
        const tocLang = document.getElementById('toc-info-lang');
        const tocCat = document.getElementById('toc-info-category');
        const tocDiff = document.getElementById('toc-info-difficulty');
        const relatedList = document.getElementById('toc-related-list');

        if (tocLang) tocLang.textContent = lang.name;
        if (tocCat) tocCat.textContent = currentCat.title;
        if (tocDiff) tocDiff.textContent = currentTopic.difficulty || 'Beginner';

        if (relatedList && currentTopic.relatedTopics) {
            let relHtml = '';
            currentTopic.relatedTopics.forEach(relId => {
                relHtml += `<div class="related-topic-tag" onclick="App.selectTopic('${relId}')">→ ${relId}</div>`;
            });
            relatedList.innerHTML = relHtml || '<span style="font-size:0.8rem; color:var(--text-muted);">No related items</span>';
        }
    },

    updatePrevNextButtons(lang, currentTopic) {
        let allTopics = [];
        lang.categories.forEach(c => allTopics.push(...c.topics));

        const currentIndex = allTopics.findIndex(t => t.id === currentTopic.id);
        const prevBtn = document.getElementById('prev-topic-btn');
        const nextBtn = document.getElementById('next-topic-btn');

        const prevTitle = document.getElementById('prev-topic-title');
        const nextTitle = document.getElementById('next-topic-title');

        if (currentIndex > 0) {
            const prev = allTopics[currentIndex - 1];
            if (prevTitle) prevTitle.textContent = prev.name;
            if (prevBtn) {
                prevBtn.style.visibility = 'visible';
                prevBtn.onclick = () => this.selectTopic(prev.id);
            }
        } else if (prevBtn) {
            prevBtn.style.visibility = 'hidden';
        }

        if (currentIndex < allTopics.length - 1) {
            const next = allTopics[currentIndex + 1];
            if (nextTitle) nextTitle.textContent = next.name;
            if (nextBtn) {
                nextBtn.style.visibility = 'visible';
                nextBtn.onclick = () => this.selectTopic(next.id);
            }
        } else if (nextBtn) {
            nextBtn.style.visibility = 'hidden';
        }
    },

    updateSidebarProgress() {
        const prog = ProgressSystem.getLanguageProgress(this.activeLanguageId);
        const bar = document.getElementById('sidebar-progress-bar');
        const percent = document.getElementById('sidebar-progress-percentage');
        const text = document.getElementById('sidebar-progress-text');

        if (bar) bar.style.width = `${prog.percent}%`;
        if (percent) percent.textContent = `${prog.percent}%`;
        if (text) text.textContent = `${prog.completed} of ${prog.total} topics completed`;
    },

    bindMobileMenu() {
        const toggleBtn = document.getElementById('mobile-menu-toggle');
        const sidebar = document.getElementById('dashboard-sidebar');
        if (toggleBtn && sidebar) {
            toggleBtn.addEventListener('click', () => sidebar.classList.toggle('open'));
        }
    },

    showToast(msg) {
        const container = document.getElementById('toast-container');
        if (!container) return;

        const toast = document.createElement('div');
        toast.className = 'toast-msg';
        toast.textContent = msg;
        container.appendChild(toast);

        setTimeout(() => {
            toast.remove();
        }, 3000);
    }
};

document.addEventListener('DOMContentLoaded', () => {
    App.init();
});
