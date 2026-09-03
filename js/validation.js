export function validatePrompt(prompt) {
  if (!prompt || typeof prompt !== 'string') return { valid: false, message: 'Message cannot be empty' };
  const trimmed = prompt.trim();
  if (trimmed.length === 0) return { valid: false, message: 'Message cannot be empty' };
  if (trimmed.length > 20000) return { valid: false, message: 'Message is too long' };
  return { valid: true, value: trimmed };
}