/**
 * MSAI Code Editor Controller
 * Multi-project Vanilla JS Web Playground supporting HTML, CSS, and JavaScript
 */

import { storage } from './storage.js';
import { notifications } from './notifications.js';
import { copyToClipboard } from './utils.js';

const DEFAULT_PROJECT_TEMPLATE = {
  id: 'proj_default',
  name: 'My Website Project',
  createdAt: Date.now(),
  updatedAt: Date.now(),
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
    this.projects = [];
    this.activeProjectId = null;
    this.autoSaveTimer = null;

    // DOM Elements
    this.projectNameInput = null;
    this.saveStatusEl = null;
    this.textarea = null;
    this.lineNumbersEl = null;
    this.iframe = null;
    this.consoleLogsEl = null;
    this.projectListEl = null;
  }

  init() {
    this.view = document.getElementById('codeEditorView');
    this.projectNameInput = document.getElementById('ceProjectName');
    this.saveStatusEl = document.getElementById('ceSaveStatus');
    this.textarea = document.getElementById('ceTextarea');
    this.lineNumbersEl = document.getElementById('ceLineNumbers');
    this.iframe = document.getElementById('cePreviewIframe');
    this.consoleLogsEl = document.getElementById('ceConsoleLogs');
    this.projectListEl = document.getElementById('ceProjectList');

    this.loadProjects();
    this.setupEventListeners();
  }

  get activeProject() {
    return this.projects.find(p => p.id === this.activeProjectId) || this.projects[0];
  }

  setupEventListeners() {
    // Back to MSAI Chat
    const btnBack = document.getElementById('btnBackFromCode');
    if (btnBack) {
      btnBack.addEventListener('click', () => this.closeCodeEditorView());
    }

    // Tab switching
    document.querySelectorAll('.ce-tab, .ce-file-item').forEach(el => {
      el.addEventListener('click', () => {
        const fileType = el.getAttribute('data-tab') || el.getAttribute('data-file');
        if (fileType) this.switchTab(fileType);
      });
    });

    // Code input & Line numbers update
    if (this.textarea) {
      this.textarea.addEventListener('input', () => {
        if (this.activeProject) {
          this.activeProject[this.activeTab] = this.textarea.value;
          this.activeProject.updatedAt = Date.now();
        }
        this.updateLineNumbers();
        this.markUnsaved();
        this.triggerAutoSave();
      });

      this.textarea.addEventListener('scroll', () => {
        if (this.lineNumbersEl) {
          this.lineNumbersEl.scrollTop = this.textarea.scrollTop;
        }
      });

      // Handle Tab key indentation & Ctrl+Enter to Run
      this.textarea.addEventListener('keydown', (e) => {
        if (e.key === 'Tab') {
          e.preventDefault();
          const start = this.textarea.selectionStart;
          const end = this.textarea.selectionEnd;
          this.textarea.value = this.textarea.value.substring(0, start) + "    " + this.textarea.value.substring(end);
          this.textarea.selectionStart = this.textarea.selectionEnd = start + 4;
          if (this.activeProject) {
            this.activeProject[this.activeTab] = this.textarea.value;
            this.activeProject.updatedAt = Date.now();
          }
          this.updateLineNumbers();
          this.markUnsaved();
          this.triggerAutoSave();
        } else if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
          e.preventDefault();
          this.runCode();
        } else if ((e.ctrlKey || e.metaKey) && e.key === 's') {
          e.preventDefault();
          this.saveProjects();
        }
      });
    }

    // Project Name change
    if (this.projectNameInput) {
      this.projectNameInput.addEventListener('input', () => {
        if (this.activeProject) {
          this.activeProject.name = this.projectNameInput.value.trim() || 'Untitled Project';
          this.renderProjectList();
          this.markUnsaved();
          this.triggerAutoSave();
        }
      });
    }

    // Action buttons
    const btnRun = document.getElementById('btnCeRun');
    if (btnRun) btnRun.addEventListener('click', () => this.runCode());

    const btnSave = document.getElementById('btnCeSave');
    if (btnSave) btnSave.addEventListener('click', () => this.saveProjects());

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
    this.renderProjectList();
    this.runCode();
  }

  closeCodeEditorView() {
    if (!this.view) return;

    this.saveProjects(true);
    this.view.classList.add('hidden');
    const mainChat = document.querySelector('.chat-container');
    const composer = document.querySelector('.composer-wrapper');

    if (mainChat) mainChat.classList.remove('hidden');
    if (composer) composer.classList.remove('hidden');
  }

  switchTab(tab) {
    if (!['html', 'css', 'js'].includes(tab)) return;
    this.activeTab = tab;

    document.querySelectorAll('.ce-tab').forEach(t => {
      t.classList.toggle('active', t.getAttribute('data-tab') === tab);
    });

    document.querySelectorAll('.ce-file-item').forEach(f => {
      f.classList.toggle('active', f.getAttribute('data-file') === tab);
    });

    this.renderCurrentTab();
  }

  renderCurrentTab() {
    if (!this.textarea || !this.activeProject) return;
    this.textarea.value = this.activeProject[this.activeTab] || '';
    if (this.projectNameInput) {
      this.projectNameInput.value = this.activeProject.name;
    }
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
    if (!this.iframe || !this.activeProject) return;

    this.clearConsole();
    this.logConsole('info', '✓ Compiling and running code preview...');

    const html = this.activeProject.html || '';
    const css = `<style>\n${this.activeProject.css || ''}\n</style>`;

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

    const js = `<script>\n${this.activeProject.js || ''}\n</script>`;

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
    if (this.saveStatusEl) {
      this.saveStatusEl.textContent = 'Unsaved •';
      this.saveStatusEl.style.color = '#f59e0b';
    }
  }

  triggerAutoSave() {
    if (this.autoSaveTimer) clearTimeout(this.autoSaveTimer);
    this.autoSaveTimer = setTimeout(() => {
      this.saveProjects(true);
    }, 1500);
  }

  saveProjects(isSilent = false) {
    storage.set('msai_code_projects', this.projects);
    storage.set('msai_active_project_id', this.activeProjectId);
    if (this.saveStatusEl) {
      this.saveStatusEl.textContent = 'Saved ✓';
      this.saveStatusEl.style.color = '#10b981';
    }
    if (!isSilent) {
      notifications.success('Project saved locally.');
    }
  }

  loadProjects() {
    const savedList = storage.get('msai_code_projects');
    const savedActiveId = storage.get('msai_active_project_id');

    if (Array.isArray(savedList) && savedList.length > 0) {
      this.projects = savedList;
      this.activeProjectId = savedActiveId && this.projects.some(p => p.id === savedActiveId)
        ? savedActiveId
        : this.projects[0].id;
    } else {
      // Migrate old single-project storage if present
      const oldSingle = storage.get('msai_code_project');
      if (oldSingle && oldSingle.html) {
        const migrated = { ...DEFAULT_PROJECT_TEMPLATE, ...oldSingle, id: 'proj_' + Date.now() };
        this.projects = [migrated];
      } else {
        this.projects = [JSON.parse(JSON.stringify(DEFAULT_PROJECT_TEMPLATE))];
      }
      this.activeProjectId = this.projects[0].id;
      this.saveProjects(true);
    }

    this.renderCurrentTab();
  }

  renderProjectList() {
    if (!this.projectListEl) return;
    this.projectListEl.innerHTML = '';

    this.projects.forEach(p => {
      const item = document.createElement('div');
      item.className = `ce-project-list-item ${p.id === this.activeProjectId ? 'active' : ''}`;
      item.innerHTML = `
        <span class="ce-proj-title">${p.name}</span>
        <div class="ce-proj-actions">
          <button class="btn-proj-dup" title="Duplicate Project">📋</button>
          ${this.projects.length > 1 ? '<button class="btn-proj-del" title="Delete Project">&times;</button>' : ''}
        </div>
      `;

      item.addEventListener('click', (e) => {
        if (e.target.closest('.ce-proj-actions')) return;
        this.switchProject(p.id);
      });

      const btnDup = item.querySelector('.btn-proj-dup');
      if (btnDup) {
        btnDup.addEventListener('click', (e) => {
          e.stopPropagation();
          this.duplicateProject(p.id);
        });
      }

      const btnDel = item.querySelector('.btn-proj-del');
      if (btnDel) {
        btnDel.addEventListener('click', (e) => {
          e.stopPropagation();
          this.deleteProject(p.id);
        });
      }

      this.projectListEl.appendChild(item);
    });
  }

  switchProject(projectId) {
    if (this.activeProjectId === projectId) return;
    this.saveProjects(true);
    this.activeProjectId = projectId;
    this.renderCurrentTab();
    this.renderProjectList();
    this.runCode();
  }

  createNewProject() {
    this.saveProjects(true);
    const newProj = {
      id: 'proj_' + Date.now(),
      name: 'Project ' + (this.projects.length + 1),
      createdAt: Date.now(),
      updatedAt: Date.now(),
      html: `<!DOCTYPE html>\n<html>\n<head>\n    <title>New Project</title>\n</head>\n<body>\n    <h1>Hello World</h1>\n</body>\n</html>`,
      css: `body { font-family: sans-serif; padding: 20px; background: #111; color: #fff; }`,
      js: `console.log("New project initialized!");`
    };

    this.projects.push(newProj);
    this.activeProjectId = newProj.id;
    this.saveProjects(true);
    this.renderCurrentTab();
    this.renderProjectList();
    this.runCode();
    notifications.success('New coding project created!');
  }

  duplicateProject(projectId) {
    const source = this.projects.find(p => p.id === projectId);
    if (!source) return;

    const dup = {
      ...JSON.parse(JSON.stringify(source)),
      id: 'proj_' + Date.now(),
      name: `${source.name} (Copy)`,
      createdAt: Date.now(),
      updatedAt: Date.now()
    };

    this.projects.push(dup);
    this.activeProjectId = dup.id;
    this.saveProjects(true);
    this.renderCurrentTab();
    this.renderProjectList();
    this.runCode();
    notifications.info('Project duplicated!');
  }

  deleteProject(projectId) {
    if (this.projects.length <= 1) {
      notifications.warn('Cannot delete the only remaining project.');
      return;
    }

    if (confirm('Delete this coding project permanently?')) {
      this.projects = this.projects.filter(p => p.id !== projectId);
      if (this.activeProjectId === projectId) {
        this.activeProjectId = this.projects[0].id;
      }
      this.saveProjects(true);
      this.renderCurrentTab();
      this.renderProjectList();
      this.runCode();
      notifications.info('Project deleted.');
    }
  }

  resetProject() {
    if (confirm('Reset this project to its last saved state?')) {
      this.loadProjects();
      this.runCode();
      notifications.info('Project restored to last saved state.');
    }
  }

  async copyCode() {
    if (!this.activeProject) return;
    const text = this.activeProject[this.activeTab] || '';
    const ok = await copyToClipboard(text);
    if (ok) {
      notifications.success(`Copied ${this.activeTab.toUpperCase()} code to clipboard`);
    }
  }

  clearCode() {
    if (confirm(`Clear all ${this.activeTab.toUpperCase()} code in this file?`)) {
      if (this.activeProject) {
        this.activeProject[this.activeTab] = '';
      }
      this.renderCurrentTab();
      this.markUnsaved();
      this.triggerAutoSave();
    }
  }

  downloadProject() {
    if (!this.activeProject) return;
    this.downloadFile('index.html', this.activeProject.html, 'text/html');
    setTimeout(() => this.downloadFile('style.css', this.activeProject.css, 'text/css'), 200);
    setTimeout(() => this.downloadFile('script.js', this.activeProject.js, 'text/javascript'), 400);
    notifications.success('Exported project files (index.html, style.css, script.js)');
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
