/**
 * Android Hardware Back Button Handler for MSAI
 * Uses Capacitor App plugin when available in Android environment
 */

import { App } from '@capacitor/app';
import { sidebarController } from './sidebar.js';
import { subscriptionsController } from './subscriptions.js';
import { codeEditorController } from './code-editor.js';

export function setupAndroidBack() {
  if (typeof window === 'undefined') return;

  try {
    App.addListener('backButton', () => {
      // 1. Close active modals if open
      const openModal = document.querySelector('.modal-backdrop.open, .subscription-modal-backdrop.open');
      if (openModal) {
        openModal.classList.remove('open');
        return;
      }

      // 2. Close mobile sidebar drawer if open
      const sidebar = document.getElementById('sidebar');
      if (sidebar && sidebar.classList.contains('mobile-open')) {
        sidebarController.closeMobileSidebar();
        return;
      }

      // 3. Close Code Editor view if open
      const codeView = document.getElementById('codeEditorView');
      if (codeView && !codeView.classList.contains('hidden')) {
        codeEditorController.closeCodeEditorView();
        return;
      }

      // 4. Close Subscriptions view if open
      const subView = document.getElementById('subscriptionsView');
      if (subView && !subView.classList.contains('hidden')) {
        subscriptionsController.closeSubscriptionsView();
        return;
      }

      // 5. Exit app if at root chat view
      App.exitApp();
    });
  } catch (e) {
    // Web fallback - App listener ignored in normal web browsers
  }
}
