export function setupKeyboardShortcuts(actions) {
  document.addEventListener('keydown', (e) => {
    if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
      e.preventDefault();
      if (actions.openSearch) actions.openSearch();
    }
    if ((e.ctrlKey || e.metaKey) && e.key === 'n') {
      e.preventDefault();
      if (actions.newChat) actions.newChat();
    }
    if (e.key === 'Escape') {
      if (actions.closeModals) actions.closeModals();
    }
  });
}