/**
 * AssetManager - Asynchronous resource loader for Images, Audio, and JSON data.
 * Features progress tracking, fallback synthetic asset generation, and web audio synthesis.
 */
export class AssetManager {
  constructor() {
    this.images = new Map();
    this.audio = new Map();
    this.jsons = new Map();

    this.totalAssets = 0;
    this.loadedAssets = 0;
    this.failedAssets = 0;

    // Optional Web Audio API context for procedural SFX generation
    this.audioCtx = null;
  }

  /**
   * Returns loading progress as a normalized float (0.0 to 1.0).
   * @returns {number}
   */
  get progress() {
    if (this.totalAssets === 0) return 1.0;
    return (this.loadedAssets + this.failedAssets) / this.totalAssets;
  }

  /**
   * Checks if all assets have finished loading.
   * @returns {boolean}
   */
  get isDone() {
    if (this.totalAssets === 0) return true;
    return this.loadedAssets + this.failedAssets >= this.totalAssets;
  }

  /**
   * Load an Image asset asynchronously.
   * @param {string} key - Unique identifier
   * @param {string} src - URL or Data URI
   * @returns {Promise<HTMLImageElement>}
   */
  loadImage(key, src) {
    this.totalAssets++;
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = () => {
        this.images.set(key, img);
        this.loadedAssets++;
        resolve(img);
      };
      img.onerror = (err) => {
        console.warn(`[AssetManager] Failed to load image: ${key} (${src})`);
        this.failedAssets++;
        // Fallback placeholder canvas image
        const fallback = this._createFallbackCanvasImage(key);
        this.images.set(key, fallback);
        resolve(fallback);
      };
      img.src = src;
    });
  }

  /**
   * Load an Audio asset asynchronously.
   * @param {string} key - Unique identifier
   * @param {string} src - URL or Data URI
   * @returns {Promise<HTMLAudioElement>}
   */
  loadAudio(key, src) {
    this.totalAssets++;
    return new Promise((resolve) => {
      const audio = new Audio();
      audio.oncanplaythrough = () => {
        this.audio.set(key, audio);
        this.loadedAssets++;
        resolve(audio);
      };
      audio.onerror = () => {
        console.warn(`[AssetManager] Failed to load audio: ${key} (${src})`);
        this.failedAssets++;
        resolve(null);
      };
      audio.src = src;
    });
  }

  /**
   * Load a JSON asset asynchronously.
   * @param {string} key - Unique identifier
   * @param {string} url - Asset URL
   * @returns {Promise<Object>}
   */
  async loadJSON(key, url) {
    this.totalAssets++;
    try {
      const res = await fetch(url);
      if (!res.ok) throw new Error(`HTTP error ${res.status}`);
      const data = await res.json();
      this.jsons.set(key, data);
      this.loadedAssets++;
      return data;
    } catch (err) {
      console.warn(`[AssetManager] Failed to load JSON: ${key} (${url})`);
      this.failedAssets++;
      return null;
    }
  }

  /**
   * Retrieve an image asset by key.
   */
  getImage(key) {
    return this.images.get(key) || null;
  }

  /**
   * Retrieve an audio asset by key.
   */
  getAudio(key) {
    return this.audio.get(key) || null;
  }

  /**
   * Retrieve a JSON asset by key.
   */
  getJSON(key) {
    return this.jsons.get(key) || null;
  }

  /**
   * Plays sound effect using Web Audio API procedural sound synthesis (no external files needed!).
   * @param {string} type - 'coin', 'dash', 'hit', 'pickup', 'win'
   */
  playSynthesizedSound(type) {
    try {
      if (!this.audioCtx) {
        const AudioContextClass = window.AudioContext || window.webkitAudioContext;
        if (AudioContextClass) {
          this.audioCtx = new AudioContextClass();
        }
      }

      if (!this.audioCtx) return;
      if (this.audioCtx.state === 'suspended') {
        this.audioCtx.resume();
      }

      const ctx = this.audioCtx;
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.connect(gain);
      gain.connect(ctx.destination);

      const now = ctx.currentTime;

      if (type === 'coin' || type === 'pickup') {
        osc.type = 'sine';
        osc.frequency.setValueAtTime(587.33, now); // D5
        osc.frequency.exponentialRampToValueAtTime(880, now + 0.12); // A5
        gain.gain.setValueAtTime(0.3, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.15);
        osc.start(now);
        osc.stop(now + 0.15);
      } else if (type === 'dash') {
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(200, now);
        osc.frequency.exponentialRampToValueAtTime(600, now + 0.08);
        gain.gain.setValueAtTime(0.2, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.1);
        osc.start(now);
        osc.stop(now + 0.1);
      } else if (type === 'hit') {
        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(150, now);
        osc.frequency.linearRampToValueAtTime(40, now + 0.15);
        gain.gain.setValueAtTime(0.4, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.15);
        osc.start(now);
        osc.stop(now + 0.15);
      } else if (type === 'win') {
        osc.type = 'square';
        osc.frequency.setValueAtTime(440, now);
        osc.frequency.setValueAtTime(554.37, now + 0.1);
        osc.frequency.setValueAtTime(659.25, now + 0.2);
        gain.gain.setValueAtTime(0.2, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.4);
        osc.start(now);
        osc.stop(now + 0.4);
      }
    } catch (e) {
      // Audio Context play muted or restricted
    }
  }

  /**
   * Helper to generate dynamic procedural texture Data URI for game sprites.
   */
  createColoredTexture(key, width, height, drawCallback) {
    const canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;
    const ctx = canvas.getContext('2d');
    drawCallback(ctx, width, height);

    const img = new Image();
    img.src = canvas.toDataURL();
    this.images.set(key, img);
    return img;
  }

  _createFallbackCanvasImage(key) {
    const canvas = document.createElement('canvas');
    canvas.width = 32;
    canvas.height = 32;
    const ctx = canvas.getContext('2d');
    ctx.fillStyle = '#ff0055';
    ctx.fillRect(0, 0, 32, 32);
    ctx.fillStyle = '#ffffff';
    ctx.font = '10px sans-serif';
    ctx.fillText(key.slice(0, 4), 2, 18);
    const img = new Image();
    img.src = canvas.toDataURL();
    return img;
  }
}
