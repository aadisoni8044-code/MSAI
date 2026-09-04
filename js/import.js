/**
 * Import Conversations Module
 */
import { conversations } from './conversations.js';
import { validateImportData } from './validation.js';

export async function importConversationsJSON(file) {
  try {
    const text = await file.text();
    const parsed = JSON.parse(text);

    const validation = validateImportData(parsed);
    if (!validation.valid) {
      console.error('Validation failed:', validation.error);
      return false;
    }

    const importedChats = validation.conversations;
    const existingChats = conversations.getAll();

    // Merge by id or append
    importedChats.forEach(newChat => {
      const existingIdx = existingChats.findIndex(c => c.id === newChat.id);
      if (existingIdx !== -1) {
        existingChats[existingIdx] = newChat;
      } else {
        existingChats.push(newChat);
      }
    });

    conversations.save();
    return true;
  } catch (err) {
    console.error('Import error:', err);
    return false;
  }
}
