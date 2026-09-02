/**
 * MSAI LocalStorage Wrapper
 */
window.MSAI = window.MSAI || {};

window.MSAI.Storage = {
  get(key, defaultValue = null) {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : defaultValue;
    } catch (e) {
      console.error(`Storage error getting ${key}`, e);
      return defaultValue;
    }
  },

  set(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value));
    } catch (e) {
      console.error(`Storage error setting ${key}`, e);
    }
  },

  remove(key) {
    try {
      localStorage.removeItem(key);
    } catch (e) {
      console.error(`Storage error removing ${key}`, e);
    }
  }
};
