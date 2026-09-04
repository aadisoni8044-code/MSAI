/**
 * Input & Data Validation Module
 */

export function validateMessage(text) {
  if (!text || typeof text !== 'string') {
    return { valid: false, error: 'Message cannot be empty.' };
  }
  const trimmed = text.trim();
  if (trimmed.length === 0) {
    return { valid: false, error: 'Message cannot be empty.' };
  }
  return { valid: true, text: trimmed };
}

export function validateApiKey(key) {
  if (!key || typeof key !== 'string') return false;
  return key.trim().length > 10;
}

export function validateImportData(data) {
  if (!data || typeof data !== 'object') {
    return { valid: false, error: 'Invalid data format.' };
  }
  if (!Array.isArray(data.conversations)) {
    return { valid: false, error: 'Missing conversations array.' };
  }
  return { valid: true, conversations: data.conversations };
}
