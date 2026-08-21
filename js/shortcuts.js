/**
 * Global Keyboard Shortcuts Manager
 */

export function setupKeyboardShortcuts({ onNewChat, onSearchFocus, onCloseModals, onToggleSidebar }) {
    document.addEventListener('keydown', (e) => {
        // Ctrl+K or Cmd+K: Search chats
        if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
            e.preventDefault();
            if (onSearchFocus) onSearchFocus();
        }

        // Ctrl+N or Cmd+N: New chat
        if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'n') {
            e.preventDefault();
            if (onNewChat) onNewChat();
        }

        // Ctrl+B or Cmd+B: Toggle sidebar
        if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'b') {
            e.preventDefault();
            if (onToggleSidebar) onToggleSidebar();
        }

        // Escape: Close active modals or drawers
        if (e.key === 'Escape') {
            if (onCloseModals) onCloseModals();
        }
    });
}
