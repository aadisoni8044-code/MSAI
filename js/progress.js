/**
 * DevSyntax User Progress & Theme State Persistence Manager
 */

const ProgressSystem = {
    storageKey: "devsyntax_progress_v1",
    themeKey: "devsyntax_theme_v1",

    data: {
        completedTopics: {},
        quizScores: {},
        lastActiveLanguage: "python",
        lastActiveTopic: "py-print"
    },

    init() {
        this.loadProgress();
        this.applyTheme();
        this.bindEvents();
    },

    loadProgress() {
        try {
            const saved = localStorage.getItem(this.storageKey);
            if (saved) {
                this.data = Object.assign(this.data, JSON.parse(saved));
            }
        } catch (e) {
            console.warn("Could not load DevSyntax progress from localStorage:", e);
        }
    },

    saveProgress() {
        try {
            localStorage.setItem(this.storageKey, JSON.stringify(this.data));
        } catch (e) {
            console.warn("Could not save DevSyntax progress to localStorage:", e);
        }
    },

    isTopicCompleted(topicId) {
        return !!this.data.completedTopics[topicId];
    },

    toggleTopicCompletion(topicId) {
        if (this.data.completedTopics[topicId]) {
            delete this.data.completedTopics[topicId];
        } else {
            this.data.completedTopics[topicId] = true;
        }
        this.saveProgress();
        return this.isTopicCompleted(topicId);
    },

    getLanguageProgress(langId) {
        if (typeof LANGUAGES_DATA === 'undefined' || !LANGUAGES_DATA[langId]) {
            return { total: 0, completed: 0, percent: 0 };
        }

        const lang = LANGUAGES_DATA[langId];
        let total = 0;
        let completed = 0;

        lang.categories.forEach(cat => {
            cat.topics.forEach(topic => {
                total++;
                if (this.isTopicCompleted(topic.id)) {
                    completed++;
                }
            });
        });

        const percent = total > 0 ? Math.round((completed / total) * 100) : 0;
        return { total, completed, percent };
    },

    recordQuizScore(langId, score) {
        this.data.quizScores[langId] = (this.data.quizScores[langId] || 0) + score;
        this.saveProgress();
    },

    bindEvents() {
        const themeBtn = document.getElementById('theme-toggle-btn');
        if (themeBtn) {
            themeBtn.addEventListener('click', () => this.toggleTheme());
        }

        const profileBtn = document.getElementById('profile-btn');
        const profileModal = document.getElementById('profile-modal-overlay');
        const profileClose = document.getElementById('profile-modal-close');

        if (profileBtn && profileModal) {
            profileBtn.addEventListener('click', () => {
                this.renderProfileModal();
                profileModal.classList.add('active');
            });
        }

        if (profileClose && profileModal) {
            profileClose.addEventListener('click', () => {
                profileModal.classList.remove('active');
            });
        }
    },

    toggleTheme() {
        const currentTheme = document.documentElement.getAttribute('data-theme') || 'dark';
        const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
        document.documentElement.setAttribute('data-theme', newTheme);
        try {
            localStorage.setItem(this.themeKey, newTheme);
        } catch (e) {}
    },

    applyTheme() {
        try {
            const savedTheme = localStorage.getItem(this.themeKey) || 'dark';
            document.documentElement.setAttribute('data-theme', savedTheme);
        } catch (e) {
            document.documentElement.setAttribute('data-theme', 'dark');
        }
    },

    renderProfileModal() {
        const contentElem = document.getElementById('profile-modal-content');
        if (!contentElem) return;

        let totalMastered = Object.keys(this.data.completedTopics).length;

        let langBreakdownHtml = '';
        if (typeof LANGUAGES_DATA !== 'undefined') {
            Object.values(LANGUAGES_DATA).forEach(lang => {
                const prog = this.getLanguageProgress(lang.id);
                langBreakdownHtml += `
                    <div style="margin-bottom: 14px;">
                        <div style="display: flex; justify-content: space-between; font-size: 0.88rem; font-weight: 600; margin-bottom: 4px;">
                            <span>${lang.name}</span>
                            <span style="color: var(--accent-indigo);">${prog.completed} / ${prog.total} (${prog.percent}%)</span>
                        </div>
                        <div class="progress-bar-container">
                            <div class="progress-bar-fill" style="width: ${prog.percent}%;"></div>
                        </div>
                    </div>
                `;
            });
        }

        contentElem.innerHTML = `
            <div style="text-align: center; margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid var(--border-subtle);">
                <div class="avatar-ring" style="width: 56px; height: 56px; font-size: 1.2rem; margin: 0 auto 12px;">DS</div>
                <h4 style="font-size: 1.2rem; font-weight: 700;">Developer Student</h4>
                <p style="font-size: 0.85rem; color: var(--text-muted);">${totalMastered} Topics Mastered across 16 Languages</p>
            </div>

            <div style="max-height: 300px; overflow-y: auto; padding-right: 6px;">
                <h5 style="font-size: 0.8rem; font-weight: 700; color: var(--text-muted); text-transform: uppercase; margin-bottom: 12px;">Language Breakdown</h5>
                ${langBreakdownHtml}
            </div>
        `;
    }
};
