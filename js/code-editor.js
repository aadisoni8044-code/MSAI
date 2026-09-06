/**
 * MSAI Code Editor Controller
 * Pure Vanilla JS Web Playground supporting HTML, CSS, and JavaScript
 */

import { storage } from './storage.js';
import { notifications } from './notifications.js';
import { copyToClipboard } from './utils.js';

const DEFAULT_PROJECT = {
  name: 'My Website Project',
  html: `<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>MSAI Playground</title>
</head>
<body>
    <div class="card">
        <h1 id="title">Hello MSAI!</h1>
        <p>Interactive HTML, CSS, and JavaScript Web Code Editor.</p>
        <button id="btnClick">Click Me ▶</button>
    </div>
</body>
</html>`,
  css: `body {
    margin: 0;
    padding: 0;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #09090b;
    color: #f4f4f5;
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100vh;
}

.card {
    background: #121215;
    padding: 30px;
    border-radius: 16px;
    border: 1px solid rgba(255, 255, 255, 0.15);
    text-align: center;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
    max-width: 400px;
}

h1 {
    margin-top: 0;
    color: #ffffff;
}

p {
    color: #a1a1aa;
}

button {
    background: #6366f1;
    color: white;
    border: none;
    padding: 10px 20px;
    border-radius: 9999px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s ease;
}

button:hover {
    background: #4f46e5;
}`,
  js: `// JavaScript Code
console.log("Welcome to MSAI Code Playground!");

document.getElementById("btnClick").addEventListener("click", function() {
    const title = document.getElementById("title");
    title.textContent = "MSAI Code Works!";
    title.style.color = "#10b981";
    console.log("Button clicked, title updated!");
});`
};

class CodeEditorController {
  constructor() {
    this.view = null;
    this.activeTab = 'html'; // 'html', 'css', 'js'
    this.project = { ...DEFAULT_PROJECT };
    this.autoSaveTimer = null;
    this.isSaved = true;

    // DOM Elements
    this.projectNameInput = null;
    this.saveStatusEl = null;
    this.textarea = null;
    this.lineNumbersEl = null;
    this.iframe = null;
    this.consoleLogsEl = null;
  }

  init() {
    this.view = document.getElementById('codeEditorView');
    this.projectNameInput = document.getElementById('ceProjectName');
    this.saveStatusEl = document.getElementById('ceSaveStatus');
    this.textarea = document.getElementById('ceTextarea');
    this.lineNumbersEl = document.getElementById('ceLineNumbers');
    this.iframe = document.getElementById('cePreviewIframe');
    this.consoleLogsEl = document.getElementById('ceConsoleLogs');

    this.loadProject();
    this.setupEventListeners();
  }

  setupEventListeners() {
    // Back to MSAI Chat
    const btnBack = document.getElementById('btnBackFromCode');
    if (btnBack) {
      btnBack.addEventListener('click', () => this.closeCodeEditorView());
    }

    // Tab switching
    document.querySelectorAll('.ce-tab, .ce-file-item').forEach(el => {
      el.addEventListener('click', (e) => {
        const fileType = el.getAttribute('data-tab') || el.getAttribute('data-file');
        if (fileType) this.switchTab(fileType);
      });
    });

    // Code input & Line numbers update
    if (this.textarea) {
      this.textarea.addEventListener('input', () => {
        this.project[this.activeTab] = this.textarea.value;
        this.updateLineNumbers();
        this.markUnsaved();
        this.triggerAutoSave();
      });

      this.textarea.addEventListener('scroll', () => {
        if (this.lineNumbersEl) {
          this.lineNumbersEl.scrollTop = this.textarea.scrollTop;
        }
      });

      // Handle Tab key indentation
      this.textarea.addEventListener('keydown', (e) => {
        if (e.key === 'Tab') {
          e.preventDefault();
          const start = this.textarea.selectionStart;
          const end = this.textarea.selectionEnd;
          this.textarea.value = this.textarea.value.substring(0, start) + "    " + this.textarea.value.substring(end);
          this.textarea.selectionStart = this.textarea.selectionEnd = start + 4;
          this.project[this.activeTab] = this.textarea.value;
          this.updateLineNumbers();
          this.markUnsaved();
          this.triggerAutoSave();
        } else if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
          e.preventDefault();
          this.runCode();
        }
      });
    }

    // Project Name change
    if (this.projectNameInput) {
      this.projectNameInput.addEventListener('input', () => {
        this.project.name = this.projectNameInput.value.trim() || 'Untitled Project';
        this.markUnsaved();
        this.triggerAutoSave();
      });
    }

    // Action buttons
    const btnRun = document.getElementById('btnCeRun');
    if (btnRun) btnRun.addEventListener('click', () => this.runCode());

    const btnSave = document.getElementById('btnCeSave');
    if (btnSave) btnSave.addEventListener('click', () => this.saveProject());

    const btnReset = document.getElementById('btnCeReset');
    if (btnReset) btnReset.addEventListener('click', () => this.resetProject());

    const btnNewProject = document.getElementById('btnCeNewProject');
    if (btnNewProject) btnNewProject.addEventListener('click', () => this.createNewProject());

    const btnDownload = document.getElementById('btnCeDownload');
    if (btnDownload) btnDownload.addEventListener('click', () => this.downloadProject());

    const btnCopy = document.getElementById('btnCeCopyCode');
    if (btnCopy) btnCopy.addEventListener('click', () => this.copyCode());

    const btnClear = document.getElementById('btnCeClearCode');
    if (btnClear) btnClear.addEventListener('click', () => this.clearCode());

    const btnRefreshPreview = document.getElementById('btnCeRefreshPreview');
    if (btnRefreshPreview) btnRefreshPreview.addEventListener('click', () => this.runCode());

    const btnClearConsole = document.getElementById('btnCeClearConsole');
    if (btnClearConsole) btnClearConsole.addEventListener('click', () => this.clearConsole());

    // Listen for Console postMessage from iframe
    window.addEventListener('message', (e) => {
      if (e.data && e.data.source === 'msai-preview-console') {
        this.logConsole(e.data.type, e.data.message);
      }
    });
  }

  openCodeEditorView() {
    if (!this.view) this.init();

    const mainChat = document.querySelector('.chat-container');
    const composer = document.querySelector('.composer-wrapper');
    const subView = document.getElementById('subscriptionsView');

    if (mainChat) mainChat.classList.add('hidden');
    if (composer) composer.classList.add('hidden');
    if (subView) subView.classList.add('hidden');

    this.view.classList.remove('hidden');
    this.renderCurrentTab();
    this.runCode();
  }

  closeCodeEditorView() {
    if (!this.view) return;

    this.view.classList.add('hidden');
    const mainChat = document.querySelector('.chat-container');
    const composer = document.querySelector('.composer-wrapper');

    if (mainChat) mainChat.classList.remove('hidden');
    if (composer) composer.classList.remove('hidden');
  }

  switchTab(tab) {
    if (!['html', 'css', 'js'].includes(tab)) return;
    this.activeTab = tab;

    // Update UI tabs & sidebar items
    document.querySelectorAll('.ce-tab').forEach(t => {
      t.classList.toggle('active', t.getAttribute('data-tab') === tab);
    });

    document.querySelectorAll('.ce-file-item').forEach(f => {
      f.classList.toggle('active', f.getAttribute('data-file') === tab);
    });

    this.renderCurrentTab();
  }

  renderCurrentTab() {
    if (!this.textarea) return;
    this.textarea.value = this.project[this.activeTab] || '';
    this.updateLineNumbers();
  }

  updateLineNumbers() {
    if (!this.textarea || !this.lineNumbersEl) return;
    const lines = this.textarea.value.split('\n').length;
    let numbersHtml = '';
    for (let i = 1; i <= lines; i++) {
      numbersHtml += `${i}<br>`;
    }
    this.lineNumbersEl.innerHTML = numbersHtml;
  }

  runCode() {
    if (!this.iframe) return;

    this.clearConsole();
    this.logConsole('info', '✓ Compiling and running code preview...');

    const html = this.project.html || '';
    const css = `<style>\n${this.project.css || ''}\n</style>`;

    // Embedded console capture script
    const consoleCaptureScript = `
      <script>
        (function() {
          function sendLog(type, msg) {
            window.parent.postMessage({
              source: 'msai-preview-console',
              type: type,
              message: String(msg)
            }, '*');
          }
          const origLog = console.log;
          const origError = console.error;
          const origWarn = console.warn;

          console.log = function(...args) {
            sendLog('log', args.join(' '));
            origLog.apply(console, args);
          };
          console.error = function(...args) {
            sendLog('error', args.join(' '));
            origError.apply(console, args);
          };
          console.warn = function(...args) {
            sendLog('warn', args.join(' '));
            origWarn.apply(console, args);
          };

          window.onerror = function(msg, url, line) {
            sendLog('error', 'Uncaught Error: ' + msg + ' (Line ' + line + ')');
            return false;
          };
        })();
      </script>
    `;

    const js = `<script>\n${this.project.js || ''}\n</script>`;

    const combinedDoc = `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          ${consoleCaptureScript}
          ${css}
        </head>
        <body>
          ${html}
          ${js}
        </body>
      </html>
    `;

    this.iframe.srcdoc = combinedDoc;
  }

  logConsole(type, message) {
    if (!this.consoleLogsEl) return;
    const entry = document.createElement('div');
    entry.className = `ce-log-entry ${type}`;
    entry.textContent = message;
    this.consoleLogsEl.appendChild(entry);
    this.consoleLogsEl.scrollTop = this.consoleLogsEl.scrollHeight;
  }

  clearConsole() {
    if (this.consoleLogsEl) {
      this.consoleLogsEl.innerHTML = '';
    }
  }

  markUnsaved() {
    this.isSaved = false;
    if (this.saveStatusEl) {
      this.saveStatusEl.textContent = 'Unsaved •';
      this.saveStatusEl.style.color = '#f59e0b';
    }
  }

  triggerAutoSave() {
    if (this.autoSaveTimer) clearTimeout(this.autoSaveTimer);
    this.autoSaveTimer = setTimeout(() => {
      this.saveProject(true);
    }, 1500);
  }

  saveProject(isSilent = false) {
    storage.set('msai_code_project', this.project);
    this.isSaved = true;
    if (this.saveStatusEl) {
      this.saveStatusEl.textContent = 'Saved ✓';
      this.saveStatusEl.style.color = '#10b981';
    }
    if (!isSilent) {
      notifications.success('Project saved locally.');
    }
  }

  loadProject() {
    const saved = storage.get('msai_code_project');
    if (saved && saved.html !== undefined) {
      this.project = { ...DEFAULT_PROJECT, ...saved };
    } else {
      this.project = { ...DEFAULT_PROJECT };
    }

    if (this.projectNameInput) {
      this.projectNameInput.value = this.project.name || 'My Website Project';
    }
  }

  resetProject() {
    if (confirm('Reset this project to the default code template? Any unsaved edits will be lost.')) {
      this.project = JSON.parse(JSON.stringify(DEFAULT_PROJECT));
      if (this.projectNameInput) this.projectNameInput.value = this.project.name;
      this.renderCurrentTab();
      this.saveProject();
      this.runCode();
      notifications.info('Project reset to default templates.');
    }
  }

  createNewProject() {
    if (confirm('Create a new project? Your current work will be saved.')) {
      this.saveProject(true);
      this.project = {
        name: 'New Project ' + new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        html: `<!DOCTYPE html>\n<html>\n<head>\n    <title>New Project</title>\n</head>\n<body>\n    <h1>Hello World</h1>\n</body>\n</html>`,
        css: `body { font-family: sans-serif; padding: 20px; background: #111; color: #fff; }`,
        js: `console.log("New project initialized!");`
      };
      if (this.projectNameInput) this.projectNameInput.value = this.project.name;
      this.renderCurrentTab();
      this.saveProject();
      this.runCode();
      notifications.success('New project created!');
    }
  }

  async copyCode() {
    const text = this.project[this.activeTab] || '';
    const ok = await copyToClipboard(text);
    if (ok) {
      notifications.success(`Copied ${this.activeTab.toUpperCase()} code to clipboard`);
    }
  }

  clearCode() {
    if (confirm(`Clear all ${this.activeTab.toUpperCase()} code in this file?`)) {
      this.project[this.activeTab] = '';
      this.renderCurrentTab();
      this.markUnsaved();
      this.triggerAutoSave();
    }
  }

  downloadProject() {
    this.downloadFile('index.html', this.project.html, 'text/html');
    setTimeout(() => this.downloadFile('style.css', this.project.css, 'text/css'), 200);
    setTimeout(() => this.downloadFile('script.js', this.project.js, 'text/javascript'), 400);
    notifications.success('Downloaded project files (index.html, style.css, script.js)');
  }

  downloadFile(filename, content, type) {
    const blob = new Blob([content], { type });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  }
}

export const codeEditorController = new CodeEditorController();
