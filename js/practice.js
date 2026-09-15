/**
 * DevSyntax Practice & Interactive Quiz Engine
 */

const PracticeSystem = {
    currentLanguage: "python",

    quizzes: {
        python: [
            {
                id: "py-q1",
                question: "Which function is used in Python to display output to the terminal?",
                options: ["console.log()", "print()", "System.out.println()", "echo"],
                correct: 1,
                explanation: "`print()` is Python's built-in function to display text or variable outputs."
            },
            {
                id: "py-q2",
                question: "Which keyword is used to declare a function in Python?",
                options: ["function", "def", "func", "declare"],
                correct: 1,
                explanation: "`def` is short for definition and declares a reusable function in Python."
            }
        ],
        javascript: [
            {
                id: "js-q1",
                question: "Which method logs messages to the developer console in JavaScript?",
                options: ["print()", "console.log()", "System.out.println()", "Write-Host"],
                correct: 1,
                explanation: "`console.log()` outputs data directly to the browser or Node.js console."
            }
        ],
        dart: [
            {
                id: "dart-q1",
                question: "What is the mandatory top-level entry point function for any Flutter/Dart application?",
                options: ["start()", "init()", "main()", "runApp()"],
                correct: 2,
                explanation: "Every Dart application requires a `main()` function as its execution starting point."
            }
        ]
    },

    init() {
        const selectElem = document.getElementById('practice-lang-dropdown');
        if (selectElem) {
            this.populateLanguageOptions(selectElem);
            selectElem.addEventListener('change', (e) => {
                this.currentLanguage = e.target.value;
                this.renderQuiz();
            });
        }
        this.renderQuiz();
    },

    populateLanguageOptions(selectElem) {
        if (typeof LANGUAGES_DATA === 'undefined') return;
        let html = '';
        Object.values(LANGUAGES_DATA).forEach(lang => {
            html += `<option value="${lang.id}" ${lang.id === this.currentLanguage ? 'selected' : ''}>${lang.name}</option>`;
        });
        selectElem.innerHTML = html;
    },

    renderQuiz() {
        const container = document.getElementById('practice-quiz-container');
        if (!container) return;

        const langQuizzes = this.quizzes[this.currentLanguage] || this.quizzes.python;
        const quiz = langQuizzes[0]; // Active question

        if (!quiz) {
            container.innerHTML = `<p style="text-align: center; color: var(--text-muted);">No quiz questions available for this language yet.</p>`;
            return;
        }

        let optionsHtml = '';
        quiz.options.forEach((opt, idx) => {
            optionsHtml += `
                <button class="quiz-option-btn" onclick="PracticeSystem.checkAnswer(this, ${idx}, ${quiz.correct}, '${quiz.id}')">
                    <span>${opt}</span>
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/></svg>
                </button>
            `;
        });

        container.innerHTML = `
            <div style="margin-bottom: 12px; font-size: 0.8rem; font-weight: 700; color: var(--accent-indigo); text-transform: uppercase;">Question 1 of 1</div>
            <h3 class="quiz-question-title">${quiz.question}</h3>
            <div class="quiz-options-list" id="quiz-options-${quiz.id}">
                ${optionsHtml}
            </div>
            <div id="quiz-feedback-${quiz.id}" style="display: none; padding: 16px; border-radius: var(--radius-md); margin-top: 16px; font-size: 0.92rem; font-weight: 500;"></div>
        `;
    },

    checkAnswer(btnElem, selectedIdx, correctIdx, quizId) {
        const optionsList = document.getElementById(`quiz-options-${quizId}`);
        const feedbackElem = document.getElementById(`quiz-feedback-${quizId}`);
        if (!optionsList || !feedbackElem) return;

        const buttons = optionsList.querySelectorAll('.quiz-option-btn');
        buttons.forEach(b => b.disabled = true);

        if (selectedIdx === correctIdx) {
            btnElem.classList.add('correct');
            feedbackElem.style.display = 'block';
            feedbackElem.style.background = 'rgba(16, 185, 129, 0.15)';
            feedbackElem.style.color = 'var(--accent-emerald)';
            feedbackElem.style.border = '1px solid var(--accent-emerald)';
            feedbackElem.innerHTML = `✓ Correct! Excellent work.`;

            if (window.ProgressSystem) ProgressSystem.recordQuizScore(this.currentLanguage, 10);
        } else {
            btnElem.classList.add('wrong');
            buttons[correctIdx].classList.add('correct');
            feedbackElem.style.display = 'block';
            feedbackElem.style.background = 'rgba(244, 63, 94, 0.15)';
            feedbackElem.style.color = 'var(--accent-rose)';
            feedbackElem.style.border = '1px solid var(--accent-rose)';
            feedbackElem.innerHTML = `✕ Incorrect. The correct answer is highlighted in green above.`;
        }
    }
};
