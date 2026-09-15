/**
 * DevSyntax Code Editor Engine & Interpreter Simulator
 */

const CodeEditorEngine = {
    editors: {},

    /**
     * Renders a full-featured code editor card for a given topic
     */
    renderEditorCard(topic, containerId) {
        const container = document.getElementById(containerId);
        if (!container) return;

        const initialCode = topic.codeExample || "// Write your code here";
        const editorId = `editor-${topic.id}`;
        const outputId = `output-${topic.id}`;

        const html = `
            <div class="editor-container-card">
                <div class="editor-header-bar">
                    <div class="editor-window-controls">
                        <span class="window-dot dot-red"></span>
                        <span class="window-dot dot-yellow"></span>
                        <span class="window-dot dot-green"></span>
                        <span class="editor-title-tag">${topic.name} Interactive Example</span>
                    </div>

                    <div class="editor-toolbar-actions">
                        <button class="editor-btn" onclick="CodeEditorEngine.copyCode('${editorId}')" title="Copy Code">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                            <span>Copy</span>
                        </button>
                        <button class="editor-btn" onclick="CodeEditorEngine.resetCode('${editorId}', \`${this.escapeQuotes(initialCode)}\`)" title="Reset Code">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/><path d="M3 3v5h5"/></svg>
                            <span>Reset</span>
                        </button>
                        <button class="editor-btn editor-btn-run" onclick="CodeEditorEngine.runCode('${editorId}', '${outputId}', '${topic.id}')" title="Execute Code">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor"><polygon points="5 3 19 12 5 21 5 3"/></svg>
                            <span>▶ Run</span>
                        </button>
                    </div>
                </div>

                <div class="editor-code-workspace">
                    <div class="editor-line-numbers" id="lines-${editorId}">
                        ${this.generateLineNumbers(initialCode)}
                    </div>
                    <div class="editor-textarea-wrapper">
                        <textarea class="editor-textarea" id="${editorId}" spellcheck="false" oninput="CodeEditorEngine.updateLineNumbers('${editorId}')">${initialCode}</textarea>
                    </div>
                </div>

                <div class="terminal-output-panel">
                    <div class="terminal-header">
                        <span>Terminal Output</span>
                        <span style="font-size: 0.7rem; color: #484F58;">Interactive Sandbox</span>
                    </div>
                    <div class="terminal-body" id="${outputId}">${topic.expectedOutput || "Click ▶ Run to see code execution output."}</div>
                </div>
            </div>
        `;

        container.innerHTML = html;
        this.editors[editorId] = initialCode;
    },

    generateLineNumbers(code) {
        const lines = code.split('\n').length;
        let numHtml = '';
        for (let i = 1; i <= lines; i++) {
            numHtml += `<div>${i}</div>`;
        }
        return numHtml;
    },

    updateLineNumbers(editorId) {
        const textarea = document.getElementById(editorId);
        const linesContainer = document.getElementById(`lines-${editorId}`);
        if (textarea && linesContainer) {
            linesContainer.innerHTML = this.generateLineNumbers(textarea.value);
        }
    },

    copyCode(editorId) {
        const textarea = document.getElementById(editorId);
        if (textarea) {
            navigator.clipboard.writeText(textarea.value);
            if (window.App) App.showToast("Code copied to clipboard!");
        }
    },

    resetCode(editorId, originalCode) {
        const textarea = document.getElementById(editorId);
        if (textarea) {
            textarea.value = originalCode;
            this.updateLineNumbers(editorId);
            if (window.App) App.showToast("Code reset to original state.");
        }
    },

    runCode(editorId, outputId, topicId) {
        const textarea = document.getElementById(editorId);
        const outputElem = document.getElementById(outputId);
        if (!textarea || !outputElem) return;

        const code = textarea.value;
        outputElem.classList.remove('error');
        outputElem.innerHTML = "Executing code...";

        setTimeout(() => {
            try {
                // If JS topic, evaluate safely in browser sandbox
                if (topicId.startsWith("js-")) {
                    let logs = [];
                    const customConsole = {
                        log: (...args) => logs.push(args.map(a => typeof a === 'object' ? JSON.stringify(a) : a).join(' ')),
                        error: (...args) => logs.push('[ERROR] ' + args.join(' ')),
                        warn: (...args) => logs.push('[WARN] ' + args.join(' '))
                    };

                    const runner = new Function('console', code);
                    runner(customConsole);

                    outputElem.innerHTML = logs.length > 0 ? logs.join('\n') : "Code executed successfully with no stdout output.";
                } else {
                    // Smart Output Terminal Simulator for non-browser languages
                    outputElem.innerHTML = this.simulateExecutionOutput(code, topicId);
                }
            } catch (err) {
                outputElem.classList.add('error');
                outputElem.innerHTML = `Runtime Error: ${err.message}`;
            }
        }, 300);
    },

    simulateExecutionOutput(code, topicId) {
        // Extract print-like statements or fall back to realistic execution output
        const printRegex = /(?:print|println!|System\.out\.println|Console\.WriteLine|printf|fmt\.Println|echo|puts)\s*\((.*?)\)/g;
        let match;
        let simulatedLogs = [];

        while ((match = printRegex.exec(code)) !== null) {
            let extracted = match[1].replace(/^["']|["']$/g, '');
            simulatedLogs.push(extracted);
        }

        if (simulatedLogs.length > 0) {
            return simulatedLogs.join('\n');
        }

        return "Process finished with exit code 0";
    },

    escapeQuotes(str) {
        return str.replace(/`/g, '\\`').replace(/\${/g, '\\${');
    }
};
