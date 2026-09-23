/**
 * Photo Pixel QR Controller Module
 * Manages state, artistic presets, debounced input sliders, requestAnimationFrame rendering,
 * and PNG/SVG export downloads for the Photo Pixel QR mode.
 */

import { PhotoProcessor } from './photo-processor.js';
import { CanvasRenderer } from './canvas-renderer.js';

export class PhotoPixelQR {
  constructor(canvasElement) {
    this.canvas = canvasElement;

    // Default Resolution Map
    this.resolutions = {
      low: 60,
      medium: 100,
      high: 160,
      ultra: 220
    };

    // Auto-detect mobile device to recommend MEDIUM resolution
    const isMobile = window.innerWidth < 768;
    this.currentResolutionKey = isMobile ? 'medium' : 'medium';

    this.state = {
      photoSource: null,
      photoData: null,
      payload: 'https://instagram.com/instagram',
      preset: 'classic',
      dotSize: 0.85,
      dotSpacing: 0,
      brightness: 0,
      contrast: 1.0,
      sharpness: 1.0,
      photoStrength: 0.75,
      dotShape: 'circle',
      colorMode: 'color',
      dotColor: '#000000',
      bgColor: '#ffffff'
    };

    this.renderDebounceTimer = null;
    this.bindEvents();
  }

  bindEvents() {
    // Photo File Input Dropzone
    const fileInput = document.getElementById('pixelPhotoFileInput');
    const removeBtn = document.getElementById('removePixelPhotoBtn');

    if (fileInput) {
      fileInput.addEventListener('change', async (e) => {
        const file = e.target.files[0];
        if (file) {
          await this.loadPhoto(file, file.name);
        }
      });
    }

    if (removeBtn) {
      removeBtn.addEventListener('click', async () => {
        if (fileInput) fileInput.value = '';
        this.state.photoSource = null;
        this.state.photoData = null;
        this.hidePhotoPreview();
        this.scheduleRender();
      });
    }

    // QR Payload Target Input
    const payloadInput = document.getElementById('ppQrPayloadInput');
    if (payloadInput) {
      payloadInput.addEventListener('input', () => {
        this.state.payload = payloadInput.value.trim() || 'https://instagram.com/instagram';
        const summary = document.getElementById('ppSummaryText');
        if (summary) summary.textContent = this.state.payload;
        this.scheduleRender();
      });
    }

    // Resolution Selector Pills
    document.querySelectorAll('.res-pill').forEach(pill => {
      pill.addEventListener('click', async () => {
        document.querySelectorAll('.res-pill').forEach(p => p.classList.remove('active'));
        pill.classList.add('active');
        this.currentResolutionKey = pill.dataset.res;

        if (this.state.photoSource) {
          await this.reprocessPhoto();
        }
        this.scheduleRender();
      });
    });

    // Helper for preset card click listener
    const bindPresetClick = (card, cb) => {
      card.addEventListener('click', () => cb(card.dataset.preset));
    };

    // Artistic Presets Grid
    document.querySelectorAll('.artistic-preset-grid .preset-card').forEach(card => {
      bindPresetClick(card, async (presetKey) => {
        document.querySelectorAll('.artistic-preset-grid .preset-card').forEach(c => c.classList.remove('active'));
        card.classList.add('active');
        await this.applyPreset(presetKey);
      });
    });

    // Sliders & Select Controls
    this.bindSlider('ppDotSize', 'dotSize', true, 'ppDotSizeVal');
    this.bindSlider('ppDotSpacing', 'dotSpacing', true, 'ppDotSpacingVal', ' px');
    this.bindSlider('ppBrightness', 'brightness', true, 'ppBrightnessVal');
    this.bindSlider('ppContrast', 'contrast', true, 'ppContrastVal');
    this.bindSlider('ppSharpness', 'sharpness', true, 'ppSharpnessVal');
    this.bindSlider('ppPhotoStrength', 'photoStrength', true, 'ppPhotoStrengthVal');

    this.bindSelect('ppDotShape', 'dotShape');
    this.bindSelect('ppColorMode', 'colorMode');
    this.bindColor('ppDotColor', 'dotColor', 'ppDotColorHex');
    this.bindColor('ppBgColor', 'bgColor', 'ppBgColorHex');

    // Action Buttons
    const pngBtn = document.getElementById('ppDownloadPngBtn');
    const svgBtn = document.getElementById('ppDownloadSvgBtn');
    const regenBtn = document.getElementById('ppRegenerateBtn');
    const copyBtn = document.getElementById('ppCopyContentBtn');
    const shareBtn = document.getElementById('ppShareBtn');
    const resetBtn = document.getElementById('ppResetBtn');

    if (pngBtn) pngBtn.addEventListener('click', () => this.downloadPng());
    if (svgBtn) svgBtn.addEventListener('click', () => this.downloadSvg());
    if (regenBtn) regenBtn.addEventListener('click', () => this.scheduleRender());
    if (copyBtn) {
      copyBtn.addEventListener('click', async () => {
        try {
          await navigator.clipboard.writeText(this.state.payload);
          if (window.showToast) window.showToast('Copied payload to clipboard!', 'success');
        } catch (e) {
          if (window.showToast) window.showToast('Failed to copy text.', 'error');
        }
      });
    }
    if (shareBtn) {
      shareBtn.addEventListener('click', async () => {
        if (navigator.share && this.canvas) {
          try {
            const dataUrl = this.canvas.toDataURL('image/png');
            const res = await fetch(dataUrl);
            const blob = await res.blob();
            const file = new File([blob], 'photo-pixel-qr.png', { type: 'image/png' });
            if (navigator.canShare && navigator.canShare({ files: [file] })) {
              await navigator.share({
                title: 'Photo Pixel QR Code',
                text: `Artistic QR Code for ${this.state.payload}`,
                files: [file]
              });
              return;
            }
          } catch (e) { /* fallback copy */ }
        }
        await navigator.clipboard.writeText(this.state.payload);
        if (window.showToast) window.showToast('Payload copied to clipboard!', 'info');
      });
    }
    if (resetBtn) resetBtn.addEventListener('click', () => this.reset());
  }

  bindSlider(id, prop, isNum, valSpanId, unit = '') {
    const el = document.getElementById(id);
    if (!el) return;
    el.addEventListener('input', async () => {
      const val = isNum ? Number(el.value) : el.value;
      this.state[prop] = val;
      const span = document.getElementById(valSpanId);
      if (span) span.textContent = `${val}${unit}`;

      if (prop === 'brightness' || prop === 'contrast' || prop === 'sharpness') {
        await this.reprocessPhoto();
      }
      this.scheduleRender();
    });
  }

  bindSelect(id, prop) {
    const el = document.getElementById(id);
    if (!el) return;
    el.addEventListener('change', () => {
      this.state[prop] = el.value;
      this.scheduleRender();
    });
  }

  bindColor(id, prop, hexSpanId) {
    const el = document.getElementById(id);
    if (!el) return;
    el.addEventListener('input', () => {
      this.state[prop] = el.value;
      const hexSpan = document.getElementById(hexSpanId);
      if (hexSpan) hexSpan.textContent = el.value;
      this.scheduleRender();
    });
  }

  /**
   * Loads a photo file and extracts pixel matrix
   */
  async loadPhoto(source, fileName) {
    this.state.photoSource = source;
    this.showPhotoPreview(fileName, source);
    await this.reprocessPhoto();
    this.scheduleRender();
  }

  /**
   * Reprocesses pixel matrix with active resolution and filters
   */
  async reprocessPhoto() {
    if (!this.state.photoSource) {
      this.state.photoData = null;
      return;
    }

    const gridRes = this.resolutions[this.currentResolutionKey] || 100;
    try {
      this.state.photoData = await PhotoProcessor.processPhoto(this.state.photoSource, gridRes, {
        brightness: this.state.brightness,
        contrast: this.state.contrast,
        sharpness: this.state.sharpness
      });
    } catch (err) {
      console.error('Error processing photo pixels:', err);
      if (window.showToast) window.showToast('Failed to process image pixels.', 'error');
    }
  }

  /**
   * Applies an artistic preset
   */
  async applyPreset(presetKey) {
    this.state.preset = presetKey;

    switch (presetKey) {
      case 'classic':
        this.state.dotShape = 'circle';
        this.state.colorMode = 'color';
        this.state.dotSize = 0.85;
        this.state.photoStrength = 0.75;
        this.currentResolutionKey = 'medium';
        break;

      case 'micro':
        this.state.dotShape = 'circle';
        this.state.colorMode = 'color';
        this.state.dotSize = 0.60;
        this.state.photoStrength = 0.85;
        this.currentResolutionKey = 'high';
        break;

      case 'qrdots':
        this.state.dotShape = 'qrmodule';
        this.state.colorMode = 'grayscale';
        this.state.dotSize = 0.90;
        this.state.photoStrength = 0.65;
        this.currentResolutionKey = 'medium';
        break;

      case 'pixel':
        this.state.dotShape = 'square';
        this.state.colorMode = 'color';
        this.state.dotSize = 1.0;
        this.state.photoStrength = 0.80;
        this.currentResolutionKey = 'medium';
        break;

      case 'mono':
        this.state.dotShape = 'circle';
        this.state.colorMode = 'grayscale';
        this.state.dotSize = 0.85;
        this.state.photoStrength = 0.80;
        this.currentResolutionKey = 'medium';
        break;

      case 'color':
        this.state.dotShape = 'rounded';
        this.state.colorMode = 'color';
        this.state.dotSize = 0.90;
        this.state.photoStrength = 0.85;
        this.currentResolutionKey = 'medium';
        break;

      case 'contrast':
        this.state.dotShape = 'diamond';
        this.state.colorMode = 'custom';
        this.state.dotColor = '#000000';
        this.state.dotSize = 0.95;
        this.state.contrast = 1.5;
        this.state.photoStrength = 0.90;
        this.currentResolutionKey = 'medium';
        break;

      case 'ultradense':
        this.state.dotShape = 'circle';
        this.state.colorMode = 'color';
        this.state.dotSize = 0.75;
        this.state.photoStrength = 0.90;
        this.currentResolutionKey = 'ultra';
        break;
    }

    this.syncControlsUi();
    if (this.state.photoSource) {
      await this.reprocessPhoto();
    }
    this.scheduleRender();
  }

  /**
   * Syncs control elements in DOM with internal state
   */
  syncControlsUi() {
    // Resolution pills
    document.querySelectorAll('.res-pill').forEach(pill => {
      pill.classList.toggle('active', pill.dataset.res === this.currentResolutionKey);
    });

    const setVal = (id, val) => {
      const el = document.getElementById(id);
      if (el) el.value = val;
    };
    const setTxt = (id, txt) => {
      const el = document.getElementById(id);
      if (el) el.textContent = txt;
    };

    setVal('ppDotSize', this.state.dotSize);
    setTxt('ppDotSizeVal', this.state.dotSize);

    setVal('ppDotSpacing', this.state.dotSpacing);
    setTxt('ppDotSpacingVal', `${this.state.dotSpacing} px`);

    setVal('ppBrightness', this.state.brightness);
    setTxt('ppBrightnessVal', this.state.brightness);

    setVal('ppContrast', this.state.contrast);
    setTxt('ppContrastVal', this.state.contrast);

    setVal('ppSharpness', this.state.sharpness);
    setTxt('ppSharpnessVal', this.state.sharpness);

    setVal('ppPhotoStrength', this.state.photoStrength);
    setTxt('ppPhotoStrengthVal', this.state.photoStrength);

    setVal('ppDotShape', this.state.dotShape);
    setVal('ppColorMode', this.state.colorMode);

    setVal('ppDotColor', this.state.dotColor);
    setTxt('ppDotColorHex', this.state.dotColor);

    setVal('ppBgColor', this.state.bgColor);
    setTxt('ppBgColorHex', this.state.bgColor);
  }

  /**
   * Debounces render trigger using requestAnimationFrame
   */
  scheduleRender() {
    if (this.renderDebounceTimer) cancelAnimationFrame(this.renderDebounceTimer);
    this.renderDebounceTimer = requestAnimationFrame(() => {
      this.render();
    });
  }

  /**
   * Triggers canvas render
   */
  render() {
    if (!this.canvas) return;
    CanvasRenderer.render(this.canvas, {
      payload: this.state.payload,
      photoData: this.state.photoData,
      dotShape: this.state.dotShape,
      colorMode: this.state.colorMode,
      dotColor: this.state.dotColor,
      bgColor: this.state.bgColor,
      dotSize: this.state.dotSize,
      dotSpacing: this.state.dotSpacing,
      photoStrength: this.state.photoStrength
    });
  }

  /**
   * Downloads PNG artwork at high resolution
   */
  downloadPng() {
    if (!this.canvas) return;

    // Render offscreen canvas at high res (1200x1200)
    const exportCanvas = document.createElement('canvas');
    exportCanvas.width = 1200;
    exportCanvas.height = 1200;

    CanvasRenderer.render(exportCanvas, {
      payload: this.state.payload,
      photoData: this.state.photoData,
      dotShape: this.state.dotShape,
      colorMode: this.state.colorMode,
      dotColor: this.state.dotColor,
      bgColor: this.state.bgColor,
      dotSize: this.state.dotSize,
      dotSpacing: this.state.dotSpacing,
      photoStrength: this.state.photoStrength
    });

    const link = document.createElement('a');
    link.download = `photo-pixel-qr-${Date.now()}.png`;
    link.href = exportCanvas.toDataURL('image/png');
    link.click();

    if (window.showToast) window.showToast('Downloaded High-Res PNG Artwork!', 'success');
  }

  /**
   * Downloads SVG vector file
   */
  downloadSvg() {
    const svgContent = CanvasRenderer.exportSvg({
      payload: this.state.payload,
      photoData: this.state.photoData,
      dotShape: this.state.dotShape,
      colorMode: this.state.colorMode,
      dotColor: this.state.dotColor,
      bgColor: this.state.bgColor,
      dotSize: this.state.dotSize,
      photoStrength: this.state.photoStrength
    });

    const blob = new Blob([svgContent], { type: 'image/svg+xml;charset=utf-8' });
    const link = document.createElement('a');
    link.download = `photo-pixel-qr-${Date.now()}.svg`;
    link.href = URL.createObjectURL(blob);
    link.click();

    if (window.showToast) window.showToast('Downloaded SVG Vector!', 'success');
  }

  showPhotoPreview(fileName, source) {
    const prompt = document.getElementById('pixelUploadPrompt');
    const previewBar = document.getElementById('pixelUploadPreviewBar');
    const nameSpan = document.getElementById('pixelPhotoFileName');
    const imgPreview = document.getElementById('pixelPhotoPreviewImg');

    if (prompt) prompt.classList.add('hide');
    if (previewBar) previewBar.classList.remove('hide');
    if (nameSpan) nameSpan.textContent = fileName;

    if (imgPreview && source) {
      if (typeof source === 'string') {
        imgPreview.src = source;
      } else if (source instanceof File) {
        imgPreview.src = URL.createObjectURL(source);
      }
    }
  }

  hidePhotoPreview() {
    const prompt = document.getElementById('pixelUploadPrompt');
    const previewBar = document.getElementById('pixelUploadPreviewBar');
    if (prompt) prompt.classList.remove('hide');
    if (previewBar) previewBar.classList.add('hide');
  }

  reset() {
    this.state.photoSource = null;
    this.state.photoData = null;
    this.hidePhotoPreview();
    this.applyPreset('classic');
  }
}
