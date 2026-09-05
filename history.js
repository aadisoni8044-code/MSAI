/**
 * Nv Translate - History & Favorites Layer
 * Manages translation history and saved favorite translations using LocalStorage.
 */

const STORAGE_KEY_HISTORY = 'nv_translate_history';
const STORAGE_KEY_FAVORITES = 'nv_translate_favorites';
const MAX_HISTORY_ITEMS = 50;

/**
 * Get all history items sorted by timestamp descending.
 * @returns {Array<Object>}
 */
export function getHistory() {
  try {
    const data = localStorage.getItem(STORAGE_KEY_HISTORY);
    return data ? JSON.parse(data) : [];
  } catch (e) {
    console.error('Failed to parse history:', e);
    return [];
  }
}

/**
 * Get all favorite items sorted by timestamp descending.
 * @returns {Array<Object>}
 */
export function getFavorites() {
  try {
    const data = localStorage.getItem(STORAGE_KEY_FAVORITES);
    return data ? JSON.parse(data) : [];
  } catch (e) {
    console.error('Failed to parse favorites:', e);
    return [];
  }
}

/**
 * Save a new translation to history.
 * @param {Object} item - { sourceLang, targetLang, sourceText, translatedText, detectedSourceLang }
 * @returns {Object} Saved item with id and timestamp
 */
export function saveTranslation(item) {
  if (!item || !item.sourceText || !item.translatedText) {
    return null;
  }

  const history = getHistory();

  // Deduplicate if identical to top item
  if (
    history.length > 0 &&
    history[0].sourceText.trim() === item.sourceText.trim() &&
    history[0].translatedText.trim() === item.translatedText.trim() &&
    history[0].sourceLang === item.sourceLang &&
    history[0].targetLang === item.targetLang
  ) {
    return history[0];
  }

  const newItem = {
    id: 'hist_' + Date.now() + '_' + Math.random().toString(36).substr(2, 5),
    sourceLang: item.sourceLang,
    targetLang: item.targetLang,
    sourceText: item.sourceText,
    translatedText: item.translatedText,
    detectedSourceLang: item.detectedSourceLang || null,
    timestamp: Date.now(),
    isFavorite: false
  };

  // Check if it's already in favorites
  const favorites = getFavorites();
  if (favorites.some(f => f.sourceText === newItem.sourceText && f.translatedText === newItem.translatedText && f.targetLang === newItem.targetLang)) {
    newItem.isFavorite = true;
  }

  history.unshift(newItem);

  if (history.length > MAX_HISTORY_ITEMS) {
    history.pop();
  }

  try {
    localStorage.setItem(STORAGE_KEY_HISTORY, JSON.stringify(history));
  } catch (e) {
    console.error('Failed to save translation history:', e);
  }

  return newItem;
}

/**
 * Remove an item from history by ID.
 * @param {string} id
 */
export function deleteHistoryItem(id) {
  const history = getHistory().filter(item => item.id !== id);
  try {
    localStorage.setItem(STORAGE_KEY_HISTORY, JSON.stringify(history));
  } catch (e) {
    console.error('Failed to delete history item:', e);
  }
}

/**
 * Clear all translation history.
 */
export function clearHistory() {
  try {
    localStorage.removeItem(STORAGE_KEY_HISTORY);
  } catch (e) {
    console.error('Failed to clear history:', e);
  }
}

/**
 * Toggle favorite status of a translation.
 * @param {Object} translation - Translation object with sourceText, translatedText, sourceLang, targetLang
 * @returns {boolean} New favorite state (true if favorited, false if unfavorited)
 */
export function toggleFavorite(translation) {
  if (!translation || !translation.sourceText || !translation.translatedText) {
    return false;
  }

  let favorites = getFavorites();
  const existingIndex = favorites.findIndex(
    f => f.sourceText.trim() === translation.sourceText.trim() &&
         f.translatedText.trim() === translation.translatedText.trim() &&
         f.targetLang === translation.targetLang
  );

  let isFav = false;

  if (existingIndex >= 0) {
    // Remove from favorites
    favorites.splice(existingIndex, 1);
    isFav = false;
  } else {
    // Add to favorites
    const favItem = {
      id: translation.id || ('fav_' + Date.now() + '_' + Math.random().toString(36).substr(2, 5)),
      sourceLang: translation.sourceLang,
      targetLang: translation.targetLang,
      sourceText: translation.sourceText,
      translatedText: translation.translatedText,
      timestamp: Date.now(),
      isFavorite: true
    };
    favorites.unshift(favItem);
    isFav = true;
  }

  try {
    localStorage.setItem(STORAGE_KEY_FAVORITES, JSON.stringify(favorites));

    // Update favorite flag in history if present
    const history = getHistory();
    let historyChanged = false;
    history.forEach(item => {
      if (
        item.sourceText.trim() === translation.sourceText.trim() &&
        item.translatedText.trim() === translation.translatedText.trim() &&
        item.targetLang === translation.targetLang
      ) {
        item.isFavorite = isFav;
        historyChanged = true;
      }
    });

    if (historyChanged) {
      localStorage.setItem(STORAGE_KEY_HISTORY, JSON.stringify(history));
    }
  } catch (e) {
    console.error('Failed to toggle favorite:', e);
  }

  return isFav;
}

/**
 * Check if a translation is currently in favorites.
 * @param {string} sourceText
 * @param {string} translatedText
 * @param {string} targetLang
 * @returns {boolean}
 */
export function isFavorite(sourceText, translatedText, targetLang) {
  if (!sourceText || !translatedText) return false;
  const favorites = getFavorites();
  return favorites.some(
    f => f.sourceText.trim() === sourceText.trim() &&
         f.translatedText.trim() === translatedText.trim() &&
         f.targetLang === targetLang
  );
}

/**
 * Remove a specific favorite item by ID.
 * @param {string} id
 */
export function deleteFavoriteItem(id) {
  const favorites = getFavorites();
  const itemToRemove = favorites.find(f => f.id === id);
  const updated = favorites.filter(f => f.id !== id);

  try {
    localStorage.setItem(STORAGE_KEY_FAVORITES, JSON.stringify(updated));

    if (itemToRemove) {
      // Also sync history state
      const history = getHistory();
      let changed = false;
      history.forEach(item => {
        if (
          item.sourceText.trim() === itemToRemove.sourceText.trim() &&
          item.translatedText.trim() === itemToRemove.translatedText.trim() &&
          item.targetLang === itemToRemove.targetLang
        ) {
          item.isFavorite = false;
          changed = true;
        }
      });
      if (changed) {
        localStorage.setItem(STORAGE_KEY_HISTORY, JSON.stringify(history));
      }
    }
  } catch (e) {
    console.error('Failed to delete favorite item:', e);
  }
}
