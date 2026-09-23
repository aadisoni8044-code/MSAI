/**
 * Client-Side Photo Image Processor
 * Loads, resizes, and extracts pixel luminance and color data for the Photo Pixel QR renderer.
 * All image processing occurs strictly in the browser using HTML5 Canvas.
 */

export class PhotoProcessor {
  /**
   * Loads an image file or Data URL and processes its pixel data
   * @param {File|string} source - Image File object or Data URL
   * @param {number} gridResolution - Target dot grid resolution size (e.g. 60, 100, 160, 220)
   * @param {Object} filters - Brightness, contrast, and sharpness parameters
   * @returns {Promise<Object>} Matrix of cell pixel colors, brightness, and dimensions
   */
  static async processPhoto(source, gridResolution = 100, filters = {}) {
    if (!source) return null;

    let dataUrl = '';
    if (source instanceof File) {
      dataUrl = await this.readFileAsDataURL(source);
    } else if (typeof source === 'string') {
      dataUrl = source;
    } else {
      return null;
    }

    const img = await this.loadImage(dataUrl);

    // Render image to square canvas at target grid resolution
    const canvas = document.createElement('canvas');
    canvas.width = gridResolution;
    canvas.height = gridResolution;
    const ctx = canvas.getContext('2d');

    // Crop center square (object-fit cover)
    const aspect = img.width / img.height;
    let srcX = 0, srcY = 0, srcW = img.width, srcH = img.height;

    if (aspect > 1) {
      srcW = img.height;
      srcX = (img.width - img.height) / 2;
    } else if (aspect < 1) {
      srcH = img.width;
      srcY = (img.height - img.width) / 2;
    }

    ctx.drawImage(img, srcX, srcY, srcW, srcH, 0, 0, gridResolution, gridResolution);

    // Read pixel data
    const imgData = ctx.getImageData(0, 0, gridResolution, gridResolution);
    const data = imgData.data;

    const brightness = filters.brightness !== undefined ? Number(filters.brightness) : 0;
    const contrast = filters.contrast !== undefined ? Number(filters.contrast) : 1.0;
    const sharpness = filters.sharpness !== undefined ? Number(filters.sharpness) : 1.0;

    const pixels = []; // 2D array [row][col]

    for (let y = 0; y < gridResolution; y++) {
      const row = [];
      for (let x = 0; y < gridResolution && x < gridResolution; x++) {
        const idx = (y * gridResolution + x) * 4;
        let r = data[idx];
        let g = data[idx + 1];
        let b = data[idx + 2];
        const a = data[idx + 3] / 255;

        // Apply contrast
        r = Math.min(255, Math.max(0, (r - 128) * contrast + 128));
        g = Math.min(255, Math.max(0, (g - 128) * contrast + 128));
        b = Math.min(255, Math.max(0, (b - 128) * contrast + 128));

        // Apply brightness
        r = Math.min(255, Math.max(0, r + brightness));
        g = Math.min(255, Math.max(0, g + brightness));
        b = Math.min(255, Math.max(0, b + brightness));

        // Calculate luminance (0 to 1)
        let lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255;

        // Apply sharpness emphasis (curve)
        if (sharpness !== 1.0) {
          lum = Math.pow(lum, sharpness);
        }

        row.push({
          r: Math.round(r),
          g: Math.round(g),
          b: Math.round(b),
          a: a,
          luminance: lum, // 0 = pitch black, 1 = pure white
          hex: `#${((1 << 24) + (Math.round(r) << 16) + (Math.round(g) << 8) + Math.round(b)).toString(16).slice(1)}`
        });
      }
      pixels.push(row);
    }

    return {
      resolution: gridResolution,
      pixels: pixels
    };
  }

  static loadImage(dataUrl) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.crossOrigin = 'anonymous';
      img.onload = () => resolve(img);
      img.onerror = () => reject(new Error('Failed to load image for photo pixel processing.'));
      img.src = dataUrl;
    });
  }

  static readFileAsDataURL(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result);
      reader.onerror = () => reject(new Error('Failed to read image file.'));
      reader.readAsDataURL(file);
    });
  }
}
