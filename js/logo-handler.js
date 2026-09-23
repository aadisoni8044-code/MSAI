/**
 * Center Logo Image Processor
 * Processes user-uploaded photos and social icons locally via HTML5 Canvas.
 * Supports shape cropping (circle, rounded square, square), padding, border, and background fills.
 */

export class LogoHandler {
  constructor() {
    this.presetSvgMap = {
      instagram: this.createSocialSvgDataUrl('instagram', '#e1306c'),
      youtube: this.createSocialSvgDataUrl('youtube', '#ff0000'),
      facebook: this.createSocialSvgDataUrl('facebook', '#1877f2'),
      whatsapp: this.createSocialSvgDataUrl('whatsapp', '#25d366'),
      telegram: this.createSocialSvgDataUrl('telegram', '#229ed9'),
      twitter: this.createSocialSvgDataUrl('x-twitter', '#000000')
    };
  }

  /**
   * Processes input image file or data URL into a styled composite logo Data URL
   * @param {File|string} source - Image File object or Data URL string
   * @param {Object} options - Customization options
   * @returns {Promise<string>} Processed Image Data URL
   */
  async processLogo(source, options = {}) {
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
    return this.renderStyledLogo(img, options);
  }

  /**
   * Renders image onto offscreen canvas with crop shape, background, border, and padding
   */
  renderStyledLogo(img, options = {}) {
    const shape = options.shape || 'rounded'; // 'circle', 'rounded', 'square'
    const bgColor = options.bgColor || '#ffffff';
    const borderWidth = options.borderWidth !== undefined ? Number(options.borderWidth) : 2;
    const borderColor = options.borderColor || '#ffffff';
    const margin = options.margin !== undefined ? Number(options.margin) : 4;
    const targetSize = options.targetSize || 200;

    const canvas = document.createElement('canvas');
    canvas.width = targetSize;
    canvas.height = targetSize;
    const ctx = canvas.getContext('2d');

    ctx.clearRect(0, 0, targetSize, targetSize);

    const outerRadius = shape === 'circle' ? targetSize / 2 : (shape === 'rounded' ? targetSize * 0.22 : 0);

    // Draw Background Shape
    ctx.save();
    ctx.beginPath();
    this.drawRoundedRectPath(ctx, 0, 0, targetSize, targetSize, outerRadius);
    ctx.fillStyle = bgColor;
    ctx.fill();

    // Draw Border
    if (borderWidth > 0) {
      ctx.lineWidth = borderWidth * 2; // Outer stroke
      ctx.strokeStyle = borderColor;
      ctx.stroke();
    }
    ctx.restore();

    // Draw Content Image (Clipped inside margin)
    const contentOffset = borderWidth + margin;
    const contentSize = targetSize - (contentOffset * 2);

    if (contentSize > 0) {
      ctx.save();
      const innerRadius = shape === 'circle' ? contentSize / 2 : (shape === 'rounded' ? contentSize * 0.18 : 0);

      ctx.beginPath();
      this.drawRoundedRectPath(ctx, contentOffset, contentOffset, contentSize, contentSize, innerRadius);
      ctx.clip();

      // Object fit contain image scaling
      const aspect = img.width / img.height;
      let drawW = contentSize;
      let drawH = contentSize;
      let drawX = contentOffset;
      let drawY = contentOffset;

      if (aspect > 1) {
        drawH = contentSize / aspect;
        drawY = contentOffset + (contentSize - drawH) / 2;
      } else if (aspect < 1) {
        drawW = contentSize * aspect;
        drawX = contentOffset + (contentSize - drawW) / 2;
      }

      ctx.drawImage(img, drawX, drawY, drawW, drawH);
      ctx.restore();
    }

    return canvas.toDataURL('image/png');
  }

  /**
   * Helper path generator for rounded rectangles
   */
  drawRoundedRectPath(ctx, x, y, width, height, radius) {
    if (radius <= 0) {
      ctx.rect(x, y, width, height);
      return;
    }
    const r = Math.min(radius, width / 2, height / 2);
    ctx.moveTo(x + r, y);
    ctx.arcTo(x + width, y, x + width, y + height, r);
    ctx.arcTo(x + width, y + height, x, y + height, r);
    ctx.arcTo(x, y + height, x, y, r);
    ctx.arcTo(x, y, x + width, y, r);
    ctx.closePath();
  }

  /**
   * Helper to load Image element from Data URL asynchronously
   */
  loadImage(dataUrl) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.crossOrigin = 'anonymous';
      img.onload = () => resolve(img);
      img.onerror = (err) => reject(new Error('Failed to load image file.'));
      img.src = dataUrl;
    });
  }

  /**
   * Helper to read File object as Data URL
   */
  readFileAsDataURL(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result);
      reader.onerror = (err) => reject(new Error('Failed to read image file.'));
      reader.readAsDataURL(file);
    });
  }

  /**
   * Gets preset SVG Data URL for platform icons
   */
  getPresetLogo(presetName) {
    return this.presetSvgMap[presetName] || null;
  }

  /**
   * Generates inline SVG vector Data URL for social icons
   */
  createSocialSvgDataUrl(platform, color) {
    const paths = {
      instagram: 'M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z',
      youtube: 'M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z',
      facebook: 'M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z',
      whatsapp: 'M.057 24l1.687-6.163c-1.041-1.804-1.588-3.849-1.587-5.946.003-6.556 5.338-11.891 11.893-11.891 3.181.001 6.167 1.24 8.413 3.488 2.245 2.248 3.481 5.236 3.48 8.414-.003 6.557-5.338 11.892-11.893 11.892-1.99-.001-3.951-.5-5.688-1.448l-6.305 1.654zm6.597-3.807c1.676.995 3.276 1.591 5.392 1.592 5.448 0 9.886-4.434 9.889-9.885.002-5.462-4.415-9.89-9.881-9.892-5.452 0-9.887 4.434-9.889 9.884-.001 2.225.651 3.891 1.746 5.634l-.999 3.648 3.742-.981zm11.387-5.464c-.074-.124-.272-.198-.57-.347-.297-.149-1.758-.868-2.031-.967-.272-.099-.47-.149-.669.149-.198.297-.768.967-.941 1.165-.173.198-.347.223-.644.074-.297-.149-1.255-.462-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.297-.347.446-.521.151-.172.2-.296.3-.495.099-.198.05-.372-.025-.521-.075-.148-.669-1.611-.916-2.206-.242-.579-.487-.501-.669-.51l-.57-.01c-.198 0-.52.074-.792.372s-1.04 1.016-1.04 2.479 1.065 2.876 1.213 3.074c.149.198 2.095 3.2 5.076 4.487.709.306 1.263.489 1.694.626.712.226 1.36.194 1.872.118.571-.085 1.758-.719 2.006-1.413.248-.695.248-1.29.173-1.414z',
      telegram: 'M12 0C5.37 0 0 5.37 0 12s5.37 12 12 12 12-5.37 12-12S18.63 0 12 0zm5.562 8.161c-.18.717-.962 4.084-1.362 5.421-.169.565-.378.753-.58.771-.439.041-.772-.29-.1196-.569-.666-.436-2.83-1.866-3.144-2.078-.441-.297-.078-.461.096-.641.046-.046.844-.813 1.583-1.503.337-.315.674-.63.674-.821 0-.112-.047-.168-.14-.168-.112 0-.281.047-1.125.619-1.2.812-2.316 1.57-2.316 1.57l-2.044-.641c-.445-.14-.455-.445.094-.661 2.148-.934 3.582-1.552 4.303-1.854 2.046-.856 2.472-1.005 2.75-.101.061.014.198.047.286.117.075.061.127.145.141.229.014.085.028.263.014.423z',
      'x-twitter': 'M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z'
    };

    const pathData = paths[platform] || paths['instagram'];
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="200" height="200"><path fill="${color}" d="${pathData}"/></svg>`;
    return `data:image/svg+xml;utf8,${encodeURIComponent(svg)}`;
  }
}
