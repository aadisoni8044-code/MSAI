import { storage } from './storage.js';
import { showNotification } from './notifications.js';

export function exportData() {
  const conversations = storage.get('conversations', []);
  const settings = storage.get('settings', {});
  const data = { conversations, settings, exported_at: new Date().toISOString() };

  const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `msai_backup_${Date.now()}.json`;
  a.click();
  URL.revokeObjectURL(url);

  showNotification('Conversations exported successfully', 'success');
}