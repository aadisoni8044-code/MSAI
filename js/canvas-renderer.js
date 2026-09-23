/**
 * Canvas Matrix Renderer
 * High-performance 2D Canvas renderer that blends QR matrix modules with photo pixel dot art.
 * Preserves QR quiet zones and the 3 finder patterns to ensure scannability.
 */

export class CanvasRenderer {
  /**
   * Generates a 2D boolean array representing the QR code matrix for a payload
   * @param {string} payload - Target URL or text
   * @returns {Array<Array<boolean>>} 2D boolean matrix
   */
  static getQrMatrix(payload) {
    if (typeof window.qrcode === 'undefined') {
      console.warn('qrcode-generator library not available.');
      return null;
    }

    try {
      // Type 0 auto-calculates version size, 'H' for High error correction
      const qr = window.qrcode(0, 'H');
      qr.addData(payload || 'https://instagram.com/instagram');
      qr.make();

      const count = qr.getModuleCount();
      const matrix = [];
      for (let r = 0; r < count; r++) {
        const row = [];
        for (let c = 0; c < count; c++) {
          row.push(qr.isDark(r, c));
        }
        matrix.push(row);
      }
      return matrix;
    } catch (err) {
      console.error('Error creating QR matrix:', err);
      return null;
    }
  }

  /**
   * Checks if a cell coordinate falls within the protected 3 QR finder patterns or quiet zone
   */
  static isFinderPattern(r, c, qrCount) {
    const margin = 1; // 1 module quiet zone around 7x7 finder squares

    // Top-Left Finder
    if (r >= -margin && r < 7 + margin && c >= -margin && c < 7 + margin) return true;

    // Top-Right Finder
    if (r >= -margin && r < 7 + margin && c >= qrCount - 7 - margin && c < qrCount + margin) return true;

    // Bottom-Left Finder
    if (r >= qrCount - 7 - margin && r < qrCount + margin && c >= -margin && c < 7 + margin) return true;

    return false;
  }

  /**
   * Renders the complete Photo Pixel QR artwork on target canvas
   * @param {HTMLCanvasElement} canvas - Target Canvas DOM element
   * @param {Object} options - Render configuration
   */
  static render(canvas, options = {}) {
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    const width = canvas.width;
    const height = canvas.height;

    const payload = options.payload || 'https://instagram.com/instagram';
    const photoData = options.photoData; // { resolution, pixels }
    const dotShape = options.dotShape || 'circle'; // 'square', 'circle', 'rounded', 'qrmodule', 'diamond'
    const colorMode = options.colorMode || 'color'; // 'color', 'grayscale', 'custom'
    const dotColor = options.dotColor || '#000000';
    const bgColor = options.bgColor || '#ffffff';
    const dotSizeRatio = options.dotSize !== undefined ? Number(options.dotSize) : 0.85;
    const dotSpacing = options.dotSpacing !== undefined ? Number(options.dotSpacing) : 0;
    const photoStrength = options.photoStrength !== undefined ? Number(options.photoStrength) : 0.75;

    // 1. Fill Background
    ctx.fillStyle = bgColor;
    ctx.fillRect(0, 0, width, height);

    // Get QR Matrix
    const qrMatrix = this.getQrMatrix(payload);
    const qrCount = qrMatrix ? qrMatrix.length : 29;

    // Determine grid dimensions (number of cells = photo resolution or scaled to QR matrix)
    const gridRes = photoData ? photoData.resolution : qrCount;
    const cellSize = (width - 30) / gridRes; // 15px outer quiet zone padding
    const padding = 15;

    // Draw cells
    for (let r = 0; r < gridRes; r++) {
      for (let c = 0; c < gridRes; c++) {
        const x = padding + c * cellSize;
        const y = padding + r * cellSize;

        // Map grid cell coordinate (r, c) to QR matrix module coordinate (qrR, qrC)
        const qrR = Math.floor((r / gridRes) * qrCount);
        const qrC = Math.floor((c / gridRes) * qrCount);

        const isDarkQrModule = qrMatrix ? qrMatrix[qrR][qrC] : false;
        const inFinder = this.isFinderPattern(qrR, qrC, qrCount);

        // Get Photo Pixel Cell if photo is available
        const pixel = (photoData && photoData.pixels[r]) ? photoData.pixels[r][c] : null;

        // Calculate Cell Dot Color & Radius
        let fillStyle = dotColor;
        let scale = dotSizeRatio;

        if (inFinder) {
          // PROTECTED FINDER PATTERN: Draw high-contrast clean QR structure
          if (isDarkQrModule) {
            fillStyle = dotColor;
            scale = 1.0;
          } else {
            fillStyle = bgColor;
            scale = 0; // Clear cell
          }
        } else {
          // DATA AREA: Blend Photo Lum & Color with QR Modules
          if (pixel) {
            if (colorMode === 'color') {
              fillStyle = pixel.hex;
            } else if (colorMode === 'grayscale') {
              const v = Math.round((1 - pixel.luminance) * 255);
              fillStyle = `rgb(${v}, ${v}, ${v})`;
            } else {
              fillStyle = dotColor;
            }

            // Darker photo areas yield larger dots
            const photoLumScale = (1 - pixel.luminance) * photoStrength;

            if (isDarkQrModule) {
              scale = Math.min(1.1, dotSizeRatio * (0.6 + photoLumScale));
            } else {
              // Light QR module: reduce dot scale so QR scanner sees background contrast
              scale = dotSizeRatio * photoLumScale * 0.45;
            }
          } else {
            // No Photo uploaded: Standard QR module scale
            if (isDarkQrModule) {
              fillStyle = dotColor;
              scale = dotSizeRatio;
            } else {
              scale = 0;
            }
          }
        }

        if (scale <= 0.05) continue; // Skip practically invisible dots

        // Render Dot Shape inside Cell
        ctx.fillStyle = fillStyle;
        const dSize = Math.max(1, (cellSize - dotSpacing) * scale);
        const dX = x + (cellSize - dSize) / 2;
        const dY = y + (cellSize - dSize) / 2;

        ctx.beginPath();
        if (dotShape === 'circle') {
          ctx.arc(x + cellSize / 2, y + cellSize / 2, dSize / 2, 0, Math.PI * 2);
          ctx.fill();
        } else if (dotShape === 'rounded') {
          this.drawRoundedRect(ctx, dX, dY, dSize, dSize, dSize * 0.25);
          ctx.fill();
        } else if (dotShape === 'diamond') {
          ctx.moveTo(x + cellSize / 2, dY);
          ctx.lineTo(dX + dSize, y + cellSize / 2);
          ctx.lineTo(x + cellSize / 2, dY + dSize);
          ctx.lineTo(dX, y + cellSize / 2);
          ctx.closePath();
          ctx.fill();
        } else {
          // 'square' and 'qrmodule'
          ctx.fillRect(dX, dY, dSize, dSize);
        }
      }
    }
  }

  static drawRoundedRect(ctx, x, y, width, height, radius) {
    ctx.beginPath();
    ctx.moveTo(x + radius, y);
    ctx.arcTo(x + width, y, x + width, y + height, radius);
    ctx.arcTo(x + width, y + height, x, y + height, radius);
    ctx.arcTo(x, y + height, x, y, radius);
    ctx.arcTo(x, y, x + width, y, radius);
    ctx.closePath();
  }

  /**
   * Generates vector SVG representation of Photo Pixel QR
   */
  static exportSvg(options = {}) {
    const payload = options.payload || 'https://instagram.com/instagram';
    const photoData = options.photoData;
    const dotShape = options.dotShape || 'circle';
    const colorMode = options.colorMode || 'color';
    const dotColor = options.dotColor || '#000000';
    const bgColor = options.bgColor || '#ffffff';
    const dotSizeRatio = options.dotSize !== undefined ? Number(options.dotSize) : 0.85;
    const photoStrength = options.photoStrength !== undefined ? Number(options.photoStrength) : 0.75;

    const qrMatrix = this.getQrMatrix(payload);
    const qrCount = qrMatrix ? qrMatrix.length : 29;
    const gridRes = photoData ? photoData.resolution : qrCount;
    const width = 800;
    const padding = 20;
    const cellSize = (width - padding * 2) / gridRes;

    let svgElements = `<rect width="${width}" height="${width}" fill="${bgColor}"/>`;

    for (let r = 0; r < gridRes; r++) {
      for (let c = 0; c < gridRes; c++) {
        const x = padding + c * cellSize;
        const y = padding + r * cellSize;

        const qrR = Math.floor((r / gridRes) * qrCount);
        const qrC = Math.floor((c / gridRes) * qrCount);

        const isDarkQrModule = qrMatrix ? qrMatrix[qrR][qrC] : false;
        const inFinder = this.isFinderPattern(qrR, qrC, qrCount);
        const pixel = (photoData && photoData.pixels[r]) ? photoData.pixels[r][c] : null;

        let fillStyle = dotColor;
        let scale = dotSizeRatio;

        if (inFinder) {
          if (isDarkQrModule) {
            fillStyle = dotColor;
            scale = 1.0;
          } else {
            scale = 0;
          }
        } else {
          if (pixel) {
            if (colorMode === 'color') fillStyle = pixel.hex;
            else if (colorMode === 'grayscale') {
              const v = Math.round((1 - pixel.luminance) * 255);
              fillStyle = `rgb(${v},${v},${v})`;
            }
            const photoLumScale = (1 - pixel.luminance) * photoStrength;
            scale = isDarkQrModule ? Math.min(1.1, dotSizeRatio * (0.6 + photoLumScale)) : dotSizeRatio * photoLumScale * 0.45;
          } else {
            if (!isDarkQrModule) scale = 0;
          }
        }

        if (scale <= 0.05) continue;

        const dSize = Math.max(1, cellSize * scale);
        const cx = x + cellSize / 2;
        const cy = y + cellSize / 2;

        if (dotShape === 'circle') {
          svgElements += `<circle cx="${cx.toFixed(1)}" cy="${cy.toFixed(1)}" r="${(dSize / 2).toFixed(1)}" fill="${fillStyle}"/>`;
        } else {
          svgElements += `<rect x="${(cx - dSize / 2).toFixed(1)}" y="${(cy - dSize / 2).toFixed(1)}" width="${dSize.toFixed(1)}" height="${dSize.toFixed(1)}" rx="2" fill="${fillStyle}"/>`;
        }
      }
    }

    return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${width}" width="${width}" height="${width}">${svgElements}</svg>`;
  }
}
