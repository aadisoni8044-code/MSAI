/**
 * MSAI - Keyboard Shortcuts Handler
 */

class ShortcutsManager {
  constructor() {
    this.handlers = new Map();
  }

  init(bindings = {}) {
    this.bindings = bindings;
    document.addEventListener("keydown", (e) => this.handleKeyDown(e));
  }

  handleKeyDown(e) {
    const isMac = navigator.platform.toUpperCase().indexOf("MAC") >= 0;
    const modifier = isMac ? e.metaKey : e.ctrlKey;
    const target = e.target;
    const isInput = target.tagName === "INPUT" || target.tagName === "TEXTAREA" || target.isContentEditable;

    // 1. Escape key (always active to close modals/search)
    if (e.key === "Escape") {
      if (this.bindings.onEscape) {
        this.bindings.onEscape();
      }
      return;
    }

    // 2. Ctrl/Cmd + K: Search
    if (modifier && (e.key.toLowerCase() === "k")) {
      e.preventDefault();
      if (this.bindings.onSearch) this.bindings.onSearch();
      return;
    }

    // 3. Ctrl/Cmd + N: New Chat
    if (modifier && (e.key.toLowerCase() === "n") && !e.shiftKey) {
      e.preventDefault();
      if (this.bindings.onNewChat) this.bindings.onNewChat();
      return;
    }

    // 4. Ctrl/Cmd + B: Toggle Sidebar
    if (modifier && (e.key.toLowerCase() === "b")) {
      e.preventDefault();
      if (this.bindings.onToggleSidebar) this.bindings.onToggleSidebar();
      return;
    }

    // 5. Ctrl/Cmd + ,: Settings
    if (modifier && (e.key === ",")) {
      e.preventDefault();
      if (this.bindings.onOpenSettings) this.bindings.onOpenSettings();
      return;
    }

    // 6. Ctrl/Cmd + /: Shortcuts Help
    if (modifier && (e.key === "/")) {
      e.preventDefault();
      if (this.bindings.onOpenShortcuts) this.bindings.onOpenShortcuts();
      return;
    }
  }
}

export const shortcutsManager = new ShortcutsManager();
