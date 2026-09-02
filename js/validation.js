/**
 * MSAI Input Validation Helper
 */
window.MSAI = window.MSAI || {};

window.MSAI.Validation = {
  isValidPrompt(text) {
    return typeof text === 'string' && text.trim().length > 0 && text.length <= 10000;
  }
};
