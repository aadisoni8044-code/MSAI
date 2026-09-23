/**
 * QR Code Generator Core Module
 * Wraps qr-code-styling library to provide real-time updates for pattern styling,
 * colors, gradients, error correction, logo overlay, and PNG/SVG downloads.
 */

export class QRGenerator {
  constructor(containerElement) {
    this.container = containerElement;
    this.options = {
      width: 300,
      height: 300,
      type: 'canvas',
      data: 'https://instagram.com/instagram',
      image: '',
      margin: 10,
      qrOptions: {
        typeNumber: 0,
        mode: 'Byte',
        errorCorrectionLevel: 'H'
      },
      imageOptions: {
        hideBackgroundDots: true,
        imageSize: 0.22,
        margin: 4,
        crossOrigin: 'anonymous'
      },
      dotsOptions: {
        color: '#4f46e5',
        type: 'square'
      },
      backgroundOptions: {
        color: '#ffffff'
      },
      cornersSquareOptions: {
        color: '#4f46e5',
        type: 'extra-rounded'
      },
      cornersDotOptions: {
        color: '#4f46e5',
        type: 'dot'
      }
    };

    // Initialize QRCodeStyling library instance
    if (typeof window.QRCodeStyling !== 'undefined') {
      this.qrCodeInstance = new window.QRCodeStyling(this.options);
    } else {
      console.warn('QRCodeStyling library is not yet loaded.');
    }
  }

  /**
   * Mounts QR code into DOM container
   */
  mount() {
    if (this.container && this.qrCodeInstance) {
      this.container.innerHTML = '';
      this.qrCodeInstance.append(this.container);
    }
  }

  /**
   * Updates QR Code options and re-renders canvas
   * @param {Object} newOptions - Map of configuration parameters
   */
  update(newOptions = {}) {
    if (!this.qrCodeInstance) {
      if (typeof window.QRCodeStyling !== 'undefined') {
        this.qrCodeInstance = new window.QRCodeStyling(this.options);
        this.mount();
      } else {
        return;
      }
    }

    // Map parameters into QRCodeStyling structure
    const updated = { ...this.options };

    if (newOptions.data !== undefined) updated.data = newOptions.data;
    if (newOptions.size !== undefined) {
      updated.width = Number(newOptions.size);
      updated.height = Number(newOptions.size);
    }
    if (newOptions.margin !== undefined) updated.margin = Number(newOptions.margin);
    if (newOptions.errorCorrectionLevel !== undefined) {
      updated.qrOptions = {
        ...updated.qrOptions,
        errorCorrectionLevel: newOptions.errorCorrectionLevel
      };
    }

    // Dot / Pattern Styling
    updated.dotsOptions = {
      type: newOptions.dotType || updated.dotsOptions.type
    };

    // Gradient or Solid Colors for Dots
    if (newOptions.enableGradient) {
      updated.dotsOptions.gradient = {
        type: newOptions.gradientType || 'linear',
        rotation: (Number(newOptions.gradientRotation) || 0) * (Math.PI / 180),
        colorStops: [
          { offset: 0, color: newOptions.fgColor || '#4f46e5' },
          { offset: 1, color: newOptions.gradientColor2 || '#06b6d4' }
        ]
      };
      delete updated.dotsOptions.color;
    } else {
      delete updated.dotsOptions.gradient;
      updated.dotsOptions.color = newOptions.fgColor || '#4f46e5';
    }

    // Background Color or Transparency
    updated.backgroundOptions = {
      color: newOptions.transparentBg ? 'transparent' : (newOptions.bgColor || '#ffffff')
    };

    // Corners Square
    updated.cornersSquareOptions = {
      type: newOptions.cornerFrameStyle || 'extra-rounded',
      color: newOptions.cornerFrameColor || newOptions.fgColor || '#4f46e5'
    };

    // Corners Eye
    updated.cornersDotOptions = {
      type: newOptions.cornerEyeStyle || 'dot',
      color: newOptions.cornerEyeColor || newOptions.fgColor || '#4f46e5'
    };

    // Center Logo Image
    if (newOptions.logoImage) {
      updated.image = newOptions.logoImage;
      updated.imageOptions = {
        hideBackgroundDots: true,
        imageSize: Number(newOptions.logoSizeRatio) || 0.22,
        margin: Number(newOptions.logoMargin) || 4,
        crossOrigin: 'anonymous'
      };
    } else {
      updated.image = '';
    }

    this.options = updated;
    this.qrCodeInstance.update(this.options);
  }

  /**
   * Triggers file download in PNG or SVG format
   * @param {string} extension - 'png' or 'svg'
   * @param {string} name - Base filename
   */
  async download(extension = 'png', name = 'qr-code') {
    if (!this.qrCodeInstance) return;
    await this.qrCodeInstance.download({ name, extension });
  }

  /**
   * Acquires raw Data URL string from canvas for copying/sharing
   */
  async getDataUrl() {
    if (!this.container) return null;
    const canvas = this.container.querySelector('canvas');
    if (canvas) {
      return canvas.toDataURL('image/png');
    }
    return null;
  }
}
