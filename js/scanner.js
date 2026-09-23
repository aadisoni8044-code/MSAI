/**
 * Camera QR Scanner Module
 * Integrates html5-qrcode library for real-time camera QR scanning.
 * Manages device camera stream, permissions, device enumeration, and modal UI.
 */

export class QRScanner {
  constructor(options = {}) {
    this.modalEl = document.getElementById('scannerModal');
    this.closeBtn = document.getElementById('closeScannerModalBtn');
    this.viewportEl = document.getElementById('reader');
    this.cameraSelect = document.getElementById('cameraSourceSelect');
    this.resultBox = document.getElementById('scannerResultBox');
    this.resultText = document.getElementById('scannerResultText');
    this.useScannedBtn = document.getElementById('useScannedDataBtn');
    this.copyScannedBtn = document.getElementById('copyScannedTextBtn');

    this.onScanSuccessCallback = options.onScanSuccess || null;
    this.html5Qrcode = null;
    this.isScanning = false;
    this.lastScannedText = '';

    this.bindEvents();
  }

  bindEvents() {
    if (this.closeBtn) {
      this.closeBtn.addEventListener('click', () => this.stopAndClose());
    }

    if (this.modalEl) {
      this.modalEl.addEventListener('click', (e) => {
        if (e.target === this.modalEl) this.stopAndClose();
      });
    }

    if (this.cameraSelect) {
      this.cameraSelect.addEventListener('change', () => {
        if (this.isScanning && this.cameraSelect.value) {
          this.switchCamera(this.cameraSelect.value);
        }
      });
    }

    if (this.copyScannedBtn) {
      this.copyScannedBtn.addEventListener('click', async () => {
        if (this.lastScannedText) {
          try {
            await navigator.clipboard.writeText(this.lastScannedText);
            if (window.showToast) window.showToast('Scanned result copied to clipboard!', 'success');
          } catch (err) {
            console.error('Copy failed:', err);
          }
        }
      });
    }

    if (this.useScannedBtn) {
      this.useScannedBtn.addEventListener('click', () => {
        if (this.lastScannedText && this.onScanSuccessCallback) {
          this.onScanSuccessCallback(this.lastScannedText);
          this.stopAndClose();
        }
      });
    }
  }

  /**
   * Opens scanner modal and starts camera stream
   */
  async start() {
    if (typeof window.Html5Qrcode === 'undefined') {
      if (window.showToast) window.showToast('Camera scanner library is not loaded.', 'error');
      return;
    }

    if (this.modalEl) this.modalEl.classList.remove('hide');
    if (this.resultBox) this.resultBox.classList.add('hide');

    try {
      this.html5Qrcode = new window.Html5Qrcode('reader');
      const devices = await window.Html5Qrcode.getCameras();

      if (devices && devices.length > 0) {
        this.populateCameraOptions(devices);
        const backCamera = devices.find(d => d.label.toLowerCase().includes('back') || d.label.toLowerCase().includes('rear')) || devices[0];
        const cameraId = backCamera ? backCamera.id : devices[0].id;

        if (this.cameraSelect) this.cameraSelect.value = cameraId;
        await this.startCameraWithId(cameraId);
      } else {
        if (window.showToast) window.showToast('No camera devices found on this device.', 'error');
      }
    } catch (err) {
      console.error('Camera permission or initialization error:', err);
      if (window.showToast) window.showToast('Unable to access camera. Please allow camera permissions.', 'error');
    }
  }

  /**
   * Starts camera scanning feed with given camera device ID
   */
  async startCameraWithId(cameraId) {
    if (!this.html5Qrcode) return;

    try {
      this.isScanning = true;
      await this.html5Qrcode.start(
        cameraId,
        {
          fps: 10,
          qrbox: { width: 220, height: 220 }
        },
        (decodedText) => this.handleScanSuccess(decodedText),
        () => { /* Ignore frame scan noise */ }
      );
    } catch (err) {
      console.error('Failed to start camera feed:', err);
      if (window.showToast) window.showToast('Failed to start camera feed.', 'error');
    }
  }

  /**
   * Switches active camera stream
   */
  async switchCamera(cameraId) {
    if (this.html5Qrcode && this.isScanning) {
      await this.html5Qrcode.stop();
      await this.startCameraWithId(cameraId);
    }
  }

  /**
   * Scan success handler
   */
  handleScanSuccess(decodedText) {
    this.lastScannedText = decodedText;
    if (this.resultText) this.resultText.textContent = decodedText;
    if (this.resultBox) this.resultBox.classList.remove('hide');
    if (window.showToast) window.showToast('QR Code Scanned Successfully!', 'success');
  }

  /**
   * Populates camera select options dropdown
   */
  populateCameraOptions(devices) {
    if (!this.cameraSelect) return;
    this.cameraSelect.innerHTML = '';
    devices.forEach((dev, idx) => {
      const opt = document.createElement('option');
      opt.value = dev.id;
      opt.textContent = dev.label || `Camera ${idx + 1}`;
      this.cameraSelect.appendChild(opt);
    });
  }

  /**
   * Stops camera stream and hides modal
   */
  async stopAndClose() {
    if (this.html5Qrcode && this.isScanning) {
      try {
        await this.html5Qrcode.stop();
      } catch (err) {
        console.warn('Error stopping scanner:', err);
      }
      this.isScanning = false;
    }
    if (this.modalEl) this.modalEl.classList.add('hide');
  }
}
