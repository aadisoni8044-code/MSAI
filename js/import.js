import { storage } from './storage.js';
import { showNotification } from './notifications.js';

export function importData(file, callback) {
  const reader = new FileReader();
  reader.onload = (e) => {
    try {
      const data = JSON.parse(e.target.result);
      if (data.conversations && Array.isArray(data.conversations)) {
        storage.set('conversations', data.conversations);
        showNotification('Conversations imported successfully', 'success');
        if (callback) callback();
      } else {
        showNotification('Invalid backup file format', 'error');
      }
    } catch (err) {
      showNotification('Failed to parse backup JSON file', 'error');
    }
  };
  reader.readAsText(file);
}