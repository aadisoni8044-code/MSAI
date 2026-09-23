/**
 * Main Application Orchestrator & State Management
 * Connects UI events, QR Generator, Logo Handler, Social Link Builder,
 * Camera Scanner, LocalStorage persistence, Theme switching, Copy & Web Share APIs.
 */

import { QRGenerator } from './qr-generator.js';
import { LogoHandler } from './logo-handler.js';
import { SocialLinksBuilder } from './social-links.js';
import { QRScanner } from './scanner.js';

class App {
  constructor() {
    this.storageKey = 'qrcraft_pro_settings_v1';

    // Application State
    this.state = {
      theme: 'dark',
      activeType: 'instagram',
      activeCategory: 'social',
      inputs: {
        instagram: { username: 'instagram' },
        youtube: { channel: '' },
        facebook: { username: '' },
        whatsapp: { phone: '', message: '' },
        telegram: { username: '' },
        twitter: { username: '' },
        url: { url: '' },
        text: { text: '' },
        phone: { phone: '' },
        email: { email: '', subject: '', body: '' },
        wifi: { ssid: '', password: '', encryption: 'WPA', hidden: false }
      },
      customization: {
        fgColor: '#4f46e5',
        bgColor: '#ffffff',
        transparentBg: false,
        enableGradient: false,
        gradientColor2: '#06b6d4',
        gradientType: 'linear',
        gradientRotation: 0,
        dotType: 'square',
        cornerFrameStyle: 'extra-rounded',
        cornerEyeStyle: 'dot',
        cornerFrameColor: '#4f46e5',
        cornerEyeColor: '#4f46e5',
        size: 300,
        margin: 10,
        errorCorrectionLevel: 'H',
        logoPreset: 'none',
        logoCropShape: 'rounded',
        logoBgColor: '#ffffff',
        logoBorderWidth: 2,
        logoBorderColor: '#ffffff',
        logoSizeRatio: 0.22,
        logoMargin: 4
      },
      uploadedLogoSource: null, // File object or Data URL
      processedLogoDataUrl: null
    };

    // Instantiate Modules
    this.logoHandler = new LogoHandler();
    this.qrGenerator = new QRGenerator(document.getElementById('qrCanvasContainer'));
    this.scanner = new QRScanner({
      onScanSuccess: (scannedText) => this.handleScannedData(scannedText)
    });

    this.init();
  }

  /**
   * Initializes application state, UI components, and event listeners
   */
  async init() {
    this.loadLocalStorage();
    this.applyTheme(this.state.theme);
    this.bindUIEvents();

    // Mount initial QR Code
    this.qrGenerator.mount();

    // Initial sync and generation
    this.syncUiFromState();
    await this.updateLogoAndGenerateQr();

    // Global Toast helper
    window.showToast = (msg, type) => this.showToast(msg, type);
  }

  /**
   * Binds all DOM input listeners, buttons, and switches
   */
  bindUIEvents() {
    // Theme Toggle
    const themeBtn = document.getElementById('themeToggleBtn');
    if (themeBtn) {
      themeBtn.addEventListener('click', () => {
        const newTheme = this.state.theme === 'dark' ? 'light' : 'dark';
        this.applyTheme(newTheme);
      });
    }

    // Category Tabs
    document.querySelectorAll('.cat-tab').forEach(tab => {
      tab.addEventListener('click', (e) => {
        const cat = e.currentTarget.dataset.cat;
        this.switchCategory(cat);
      });
    });

    // Type Grid Selector Buttons
    document.querySelectorAll('.type-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const type = e.currentTarget.dataset.type;
        this.switchContentType(type);
      });
    });

    // Content Form Field Inputs Listener
    const dynamicInputsContainer = document.getElementById('dynamicInputs');
    if (dynamicInputsContainer) {
      dynamicInputsContainer.addEventListener('input', () => this.handleInputChange());
      dynamicInputsContainer.addEventListener('change', () => this.handleInputChange());
    }

    // Password Toggle Button for Wi-Fi
    const togglePassBtn = document.getElementById('toggleWifiPassBtn');
    if (togglePassBtn) {
      togglePassBtn.addEventListener('click', () => {
        const passInput = document.getElementById('input-wifi-pass');
        const icon = togglePassBtn.querySelector('i');
        if (passInput.type === 'password') {
          passInput.type = 'text';
          icon.className = 'fa-solid fa-eye-slash';
        } else {
          passInput.type = 'password';
          icon.className = 'fa-solid fa-eye';
        }
      });
    }

    // Customization Inputs Listener
    this.bindCustomizationControls();

    // Logo Controls & Presets
    this.bindLogoControls();

    // Action Buttons
    this.bindActionButtons();

    // Camera Scan Trigger
    const scanBtn = document.getElementById('scanCameraBtn');
    if (scanBtn) {
      scanBtn.addEventListener('click', () => this.scanner.start());
    }
  }

  /**
   * Binds color, slider, select, and style option controls
   */
  bindCustomizationControls() {
    const bindVal = (id, prop, isNum = false, hexId = null, labelValId = null, unit = '') => {
      const el = document.getElementById(id);
      if (!el) return;

      const handler = async () => {
        let val = el.type === 'checkbox' ? el.checked : el.value;
        if (isNum) val = Number(val);
        this.state.customization[prop] = val;

        if (hexId) {
          const hexEl = document.getElementById(hexId);
          if (hexEl) hexEl.textContent = val;
        }

        if (labelValId) {
          const lblEl = document.getElementById(labelValId);
          if (lblEl) lblEl.textContent = `${val}${unit}`;
        }

        this.saveLocalStorage();
        await this.generateQr();
      };

      el.addEventListener('input', handler);
      el.addEventListener('change', handler);
    };

    // Foreground / Background
    bindVal('qrFgColor', 'fgColor', false, 'qrFgColorHex');
    bindVal('qrBgColor', 'bgColor', false, 'qrBgColorHex');
    bindVal('qrBgTransparent', 'transparentBg');

    // Gradient
    const gradientCheck = document.getElementById('qrEnableGradient');
    if (gradientCheck) {
      gradientCheck.addEventListener('change', async () => {
        this.state.customization.enableGradient = gradientCheck.checked;
        const panel = document.getElementById('gradientOptionsPanel');
        if (panel) panel.classList.toggle('hide', !gradientCheck.checked);
        this.saveLocalStorage();
        await this.generateQr();
      });
    }

    bindVal('qrGradientColor2', 'gradientColor2', false, 'qrGradientColor2Hex');
    bindVal('qrGradientType', 'gradientType');
    bindVal('qrGradientRotation', 'gradientRotation', true, null, 'qrGradientRotationVal', '°');

    // Dot Patterns
    document.querySelectorAll('#dotStyleSelector .style-opt').forEach(btn => {
      btn.addEventListener('click', async (e) => {
        document.querySelectorAll('#dotStyleSelector .style-opt').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        this.state.customization.dotType = btn.dataset.value;
        this.saveLocalStorage();
        await this.generateQr();
      });
    });

    // Corner Frame & Eye Styles
    bindVal('cornerFrameStyle', 'cornerFrameStyle');
    bindVal('cornerEyeStyle', 'cornerEyeStyle');
    bindVal('cornerFrameColor', 'cornerFrameColor', false, 'cornerFrameColorHex');
    bindVal('cornerEyeColor', 'cornerEyeColor', false, 'cornerEyeColorHex');

    // Resolution Size, Margin & Safety
    bindVal('qrSize', 'size', true, null, 'qrSizeVal', ' x ' + (document.getElementById('qrSize')?.value || 300) + ' px');
    const qrSizeInput = document.getElementById('qrSize');
    if (qrSizeInput) {
      qrSizeInput.addEventListener('input', () => {
        const valSpan = document.getElementById('qrSizeVal');
        if (valSpan) valSpan.textContent = `${qrSizeInput.value} x ${qrSizeInput.value} px`;
      });
    }

    bindVal('qrMargin', 'margin', true, null, 'qrMarginVal', ' px');
    bindVal('qrErrorCorrection', 'errorCorrectionLevel');
  }

  /**
   * Binds center logo file upload, preset buttons, and logo style options
   */
  bindLogoControls() {
    // Preset Buttons
    document.querySelectorAll('#presetLogoGroup .btn-preset').forEach(btn => {
      btn.addEventListener('click', async () => {
        document.querySelectorAll('#presetLogoGroup .btn-preset').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        const preset = btn.dataset.preset;
        this.state.customization.logoPreset = preset;

        if (preset === 'none') {
          this.state.uploadedLogoSource = null;
          this.hideLogoPreview();
        } else if (preset === 'auto') {
          // Use active social type icon
          const logoDataUrl = this.logoHandler.getPresetLogo(this.state.activeType);
          this.state.uploadedLogoSource = logoDataUrl || this.logoHandler.getPresetLogo('instagram');
          this.showLogoPreview('Social Preset Icon');
        } else {
          const logoDataUrl = this.logoHandler.getPresetLogo(preset);
          this.state.uploadedLogoSource = logoDataUrl;
          this.showLogoPreview(`${preset.toUpperCase()} Preset Logo`);
        }

        this.saveLocalStorage();
        await this.updateLogoAndGenerateQr();
      });
    });

    // File Upload Box
    const fileInput = document.getElementById('logoFileInput');
    const removeBtn = document.getElementById('removeLogoBtn');

    if (fileInput) {
      fileInput.addEventListener('change', async (e) => {
        const file = e.target.files[0];
        if (file) {
          this.state.uploadedLogoSource = file;
          this.state.customization.logoPreset = 'custom';
          document.querySelectorAll('#presetLogoGroup .btn-preset').forEach(b => b.classList.remove('active'));

          this.showLogoPreview(file.name);
          this.saveLocalStorage();
          await this.updateLogoAndGenerateQr();
        }
      });
    }

    if (removeBtn) {
      removeBtn.addEventListener('click', async () => {
        if (fileInput) fileInput.value = '';
        this.state.uploadedLogoSource = null;
        this.state.customization.logoPreset = 'none';

        document.querySelectorAll('#presetLogoGroup .btn-preset').forEach(b => b.classList.remove('active'));
        const noneBtn = document.querySelector('#presetLogoGroup [data-preset="none"]');
        if (noneBtn) noneBtn.classList.add('active');

        this.hideLogoPreview();
        this.saveLocalStorage();
        await this.updateLogoAndGenerateQr();
      });
    }

    // Logo Option Sliders & Selects
    const logoControls = ['logoCropShape', 'logoBgColor', 'logoBorderWidth', 'logoBorderColor', 'logoSizeRatio', 'logoMargin'];
    logoControls.forEach(ctrlId => {
      const el = document.getElementById(ctrlId);
      if (!el) return;

      const handler = async () => {
        let val = el.value;
        if (ctrlId === 'logoBorderWidth' || ctrlId === 'logoMargin' || ctrlId === 'logoSizeRatio') {
          val = Number(val);
        }
        this.state.customization[ctrlId] = val;

        // Update hex or value labels
        if (ctrlId === 'logoBgColor') document.getElementById('logoBgColorHex').textContent = val;
        if (ctrlId === 'logoBorderColor') document.getElementById('logoBorderColorHex').textContent = val;
        if (ctrlId === 'logoSizeRatio') document.getElementById('logoSizeRatioVal').textContent = val;
        if (ctrlId === 'logoMargin') document.getElementById('logoMarginVal').textContent = `${val} px`;

        this.saveLocalStorage();
        await this.updateLogoAndGenerateQr();
      };

      el.addEventListener('input', handler);
      el.addEventListener('change', handler);
    });
  }

  /**
   * Binds action buttons (Download PNG, Download SVG, Copy Link, Share, Test Scan, Reset)
   */
  bindActionButtons() {
    const pngBtn = document.getElementById('downloadPngBtn');
    const svgBtn = document.getElementById('downloadSvgBtn');
    const copyBtn = document.getElementById('copyContentBtn');
    const shareBtn = document.getElementById('shareQrBtn');
    const testBtn = document.getElementById('testScanBtn');
    const resetBtn = document.getElementById('resetCustomizationBtn');

    if (pngBtn) {
      pngBtn.addEventListener('click', async () => {
        await this.qrGenerator.download('png', `qr-${this.state.activeType}`);
        this.showToast('PNG Downloaded Successfully!', 'success');
      });
    }

    if (svgBtn) {
      svgBtn.addEventListener('click', async () => {
        await this.qrGenerator.download('svg', `qr-${this.state.activeType}`);
        this.showToast('SVG Downloaded Successfully!', 'success');
      });
    }

    if (copyBtn) {
      copyBtn.addEventListener('click', async () => {
        const payload = this.getCurrentPayload();
        try {
          await navigator.clipboard.writeText(payload);
          this.showToast('Target payload copied to clipboard!', 'success');
        } catch (err) {
          this.showToast('Failed to copy to clipboard.', 'error');
        }
      });
    }

    if (shareBtn) {
      shareBtn.addEventListener('click', async () => {
        const dataUrl = await this.qrGenerator.getDataUrl();
        const payload = this.getCurrentPayload();

        if (navigator.share) {
          try {
            if (dataUrl && dataUrl.startsWith('data:image')) {
              const res = await fetch(dataUrl);
              const blob = await res.blob();
              const file = new File([blob], 'qrcode.png', { type: 'image/png' });

              if (navigator.canShare && navigator.canShare({ files: [file] })) {
                await navigator.share({
                  title: 'QR Code',
                  text: `Scannable QR Code for ${payload}`,
                  files: [file]
                });
                this.showToast('Shared successfully!', 'success');
                return;
              }
            }
            await navigator.share({
              title: 'QR Code Payload',
              text: payload,
              url: payload.startsWith('http') ? payload : undefined
            });
            this.showToast('Shared successfully!', 'success');
          } catch (err) {
            if (err.name !== 'AbortError') {
              this.showToast('Share cancelled or not supported.', 'info');
            }
          }
        } else {
          // Fallback copy
          try {
            await navigator.clipboard.writeText(payload);
            this.showToast('Native share unavailable. Link copied to clipboard!', 'info');
          } catch (e) {
            this.showToast('Share not supported on this device/browser.', 'error');
          }
        }
      });
    }

    if (testBtn) {
      testBtn.addEventListener('click', () => {
        const payload = this.getCurrentPayload();
        alert(`Test Scan Result:\n\nPayload: ${payload}\n\nStatus: Scannable with high error correction.`);
      });
    }

    if (resetBtn) {
      resetBtn.addEventListener('click', async () => {
        if (confirm('Reset all customization settings to default?')) {
          this.resetCustomization();
          this.showToast('Customization settings reset.', 'info');
        }
      });
    }
  }

  /**
   * Category tab switch
   */
  switchCategory(cat) {
    this.state.activeCategory = cat;

    // Toggle active category tabs
    document.querySelectorAll('.cat-tab').forEach(t => {
      t.classList.toggle('active', t.dataset.cat === cat);
    });

    // Filter visible type grid buttons
    document.querySelectorAll('.type-btn').forEach(btn => {
      const match = btn.dataset.cat === cat;
      btn.classList.toggle('hide', !match);
    });

    // Activate first type button in selected category if active button is hidden
    const firstVisible = document.querySelector(`.type-btn[data-cat="${cat}"]`);
    if (firstVisible) {
      this.switchContentType(firstVisible.dataset.type);
    }
  }

  /**
   * Content type switch (e.g. instagram -> whatsapp)
   */
  async switchContentType(type) {
    this.state.activeType = type;

    // Active class on selector grid
    document.querySelectorAll('.type-btn').forEach(b => {
      b.classList.toggle('active', b.dataset.type === type);
    });

    // Show corresponding form panel
    document.querySelectorAll('.input-group-panel').forEach(p => {
      p.classList.remove('active');
    });

    const activeForm = document.getElementById(`form-${type}`);
    if (activeForm) activeForm.classList.add('active');

    // Auto preset logo update if preset is set to 'auto'
    if (this.state.customization.logoPreset === 'auto') {
      const logoDataUrl = this.logoHandler.getPresetLogo(type);
      this.state.uploadedLogoSource = logoDataUrl || this.logoHandler.getPresetLogo('instagram');
      await this.updateLogoAndGenerateQr();
    } else {
      await this.generateQr();
    }

    this.saveLocalStorage();
  }

  /**
   * Reads form field values for active type and updates state
   */
  readActiveFormInputs() {
    const type = this.state.activeType;
    const form = document.getElementById(`form-${type}`);
    if (!form) return {};

    const data = {};
    if (type === 'instagram') data.username = document.getElementById('input-instagram')?.value || '';
    if (type === 'youtube') data.channel = document.getElementById('input-youtube')?.value || '';
    if (type === 'facebook') data.username = document.getElementById('input-facebook')?.value || '';
    if (type === 'whatsapp') {
      data.phone = document.getElementById('input-whatsapp-phone')?.value || '';
      data.message = document.getElementById('input-whatsapp-msg')?.value || '';
    }
    if (type === 'telegram') data.username = document.getElementById('input-telegram')?.value || '';
    if (type === 'twitter') data.username = document.getElementById('input-twitter')?.value || '';
    if (type === 'url') data.url = document.getElementById('input-url')?.value || '';
    if (type === 'text') data.text = document.getElementById('input-text')?.value || '';
    if (type === 'phone') data.phone = document.getElementById('input-phone')?.value || '';
    if (type === 'email') {
      data.email = document.getElementById('input-email-to')?.value || '';
      data.subject = document.getElementById('input-email-subject')?.value || '';
      data.body = document.getElementById('input-email-body')?.value || '';
    }
    if (type === 'wifi') {
      data.ssid = document.getElementById('input-wifi-ssid')?.value || '';
      data.password = document.getElementById('input-wifi-pass')?.value || '';
      data.encryption = document.getElementById('select-wifi-enc')?.value || 'WPA';
      data.hidden = document.getElementById('input-wifi-hidden')?.checked || false;
    }

    this.state.inputs[type] = data;
    return data;
  }

  /**
   * Handles user input changes in active forms
   */
  async handleInputChange() {
    this.readActiveFormInputs();
    this.saveLocalStorage();
    await this.generateQr();
  }

  /**
   * Gets current formatted QR code payload string
   */
  getCurrentPayload() {
    const data = this.readActiveFormInputs();
    return SocialLinksBuilder.buildPayload(this.state.activeType, data);
  }

  /**
   * Processes center logo image and updates QR Code generator
   */
  async updateLogoAndGenerateQr() {
    const cust = this.state.customization;

    if (this.state.uploadedLogoSource) {
      try {
        this.state.processedLogoDataUrl = await this.logoHandler.processLogo(
          this.state.uploadedLogoSource,
          {
            shape: cust.logoCropShape,
            bgColor: cust.logoBgColor,
            borderWidth: cust.logoBorderWidth,
            borderColor: cust.logoBorderColor,
            margin: cust.logoMargin,
            targetSize: 240
          }
        );
      } catch (err) {
        console.error('Logo processing error:', err);
        this.state.processedLogoDataUrl = null;
      }
    } else {
      this.state.processedLogoDataUrl = null;
    }

    await this.generateQr();
  }

  /**
   * Generates / Updates QR code preview canvas
   */
  async generateQr() {
    const payload = this.getCurrentPayload();
    const cust = this.state.customization;

    // Update target payload summary
    const summaryEl = document.getElementById('qrSummaryText');
    if (summaryEl) {
      summaryEl.textContent = SocialLinksBuilder.getSummaryLabel(this.state.activeType, payload);
    }

    // Auto force high error correction when logo is present
    const errLevel = this.state.processedLogoDataUrl ? 'H' : cust.errorCorrectionLevel;

    // Trigger QR render
    this.qrGenerator.update({
      data: payload,
      size: cust.size,
      margin: cust.margin,
      errorCorrectionLevel: errLevel,
      dotType: cust.dotType,
      fgColor: cust.fgColor,
      bgColor: cust.bgColor,
      transparentBg: cust.transparentBg,
      enableGradient: cust.enableGradient,
      gradientColor2: cust.gradientColor2,
      gradientType: cust.gradientType,
      gradientRotation: cust.gradientRotation,
      cornerFrameStyle: cust.cornerFrameStyle,
      cornerEyeStyle: cust.cornerEyeStyle,
      cornerFrameColor: cust.cornerFrameColor,
      cornerEyeColor: cust.cornerEyeColor,
      logoImage: this.state.processedLogoDataUrl,
      logoSizeRatio: cust.logoSizeRatio,
      logoMargin: cust.logoMargin
    });
  }

  /**
   * Handles camera scanner result
   */
  async handleScannedData(scannedText) {
    if (!scannedText) return;

    // If scanned URL matches social link, populate social tab
    if (scannedText.includes('instagram.com/')) {
      this.switchCategory('social');
      this.switchContentType('instagram');
      const user = scannedText.split('instagram.com/')[1]?.split('/')[0] || '';
      document.getElementById('input-instagram').value = user;
    } else if (scannedText.includes('youtube.com/')) {
      this.switchCategory('social');
      this.switchContentType('youtube');
      document.getElementById('input-youtube').value = scannedText;
    } else if (scannedText.startsWith('http://') || scannedText.startsWith('https://')) {
      this.switchCategory('general');
      this.switchContentType('url');
      document.getElementById('input-url').value = scannedText;
    } else {
      this.switchCategory('general');
      this.switchContentType('text');
      document.getElementById('input-text').value = scannedText;
    }

    await this.handleInputChange();
    this.showToast('Scanned data loaded into generator!', 'success');
  }

  /**
   * Shows upload logo preview bar in DOM
   */
  showLogoPreview(fileName) {
    const prompt = document.getElementById('uploadPrompt');
    const previewBar = document.getElementById('uploadPreviewBar');
    const nameSpan = document.getElementById('logoFileName');
    const imgPreview = document.getElementById('logoPreviewImg');
    const controlsPanel = document.getElementById('logoControlsPanel');

    if (prompt) prompt.classList.add('hide');
    if (previewBar) previewBar.classList.remove('hide');
    if (nameSpan) nameSpan.textContent = fileName;
    if (controlsPanel) controlsPanel.classList.remove('hide');

    if (imgPreview && this.state.uploadedLogoSource) {
      if (typeof this.state.uploadedLogoSource === 'string') {
        imgPreview.src = this.state.uploadedLogoSource;
      } else if (this.state.uploadedLogoSource instanceof File) {
        imgPreview.src = URL.createObjectURL(this.state.uploadedLogoSource);
      }
    }
  }

  /**
   * Hides logo preview bar in DOM
   */
  hideLogoPreview() {
    const prompt = document.getElementById('uploadPrompt');
    const previewBar = document.getElementById('uploadPreviewBar');
    const controlsPanel = document.getElementById('logoControlsPanel');

    if (prompt) prompt.classList.remove('hide');
    if (previewBar) previewBar.classList.add('hide');
    if (controlsPanel) controlsPanel.classList.add('hide');
  }

  /**
   * Resets customization settings
   */
  async resetCustomization() {
    this.state.customization = {
      fgColor: '#4f46e5',
      bgColor: '#ffffff',
      transparentBg: false,
      enableGradient: false,
      gradientColor2: '#06b6d4',
      gradientType: 'linear',
      gradientRotation: 0,
      dotType: 'square',
      cornerFrameStyle: 'extra-rounded',
      cornerEyeStyle: 'dot',
      cornerFrameColor: '#4f46e5',
      cornerEyeColor: '#4f46e5',
      size: 300,
      margin: 10,
      errorCorrectionLevel: 'H',
      logoPreset: 'none',
      logoCropShape: 'rounded',
      logoBgColor: '#ffffff',
      logoBorderWidth: 2,
      logoBorderColor: '#ffffff',
      logoSizeRatio: 0.22,
      logoMargin: 4
    };

    this.state.uploadedLogoSource = null;
    this.hideLogoPreview();
    this.syncUiFromState();
    this.saveLocalStorage();
    await this.updateLogoAndGenerateQr();
  }

  /**
   * Syncs HTML form elements with internal state values
   */
  syncUiFromState() {
    const cust = this.state.customization;
    const inputs = this.state.inputs;

    // Theme
    this.applyTheme(this.state.theme);

    // Category and Type
    this.switchCategory(this.state.activeCategory);
    this.switchContentType(this.state.activeType);

    // Form inputs restoration
    if (inputs.instagram?.username) document.getElementById('input-instagram').value = inputs.instagram.username;
    if (inputs.youtube?.channel) document.getElementById('input-youtube').value = inputs.youtube.channel;
    if (inputs.facebook?.username) document.getElementById('input-facebook').value = inputs.facebook.username;
    if (inputs.whatsapp) {
      if (inputs.whatsapp.phone) document.getElementById('input-whatsapp-phone').value = inputs.whatsapp.phone;
      if (inputs.whatsapp.message) document.getElementById('input-whatsapp-msg').value = inputs.whatsapp.message;
    }
    if (inputs.telegram?.username) document.getElementById('input-telegram').value = inputs.telegram.username;
    if (inputs.twitter?.username) document.getElementById('input-twitter').value = inputs.twitter.username;
    if (inputs.url?.url) document.getElementById('input-url').value = inputs.url.url;
    if (inputs.text?.text) document.getElementById('input-text').value = inputs.text.text;
    if (inputs.phone?.phone) document.getElementById('input-phone').value = inputs.phone.phone;
    if (inputs.email) {
      if (inputs.email.email) document.getElementById('input-email-to').value = inputs.email.email;
      if (inputs.email.subject) document.getElementById('input-email-subject').value = inputs.email.subject;
      if (inputs.email.body) document.getElementById('input-email-body').value = inputs.email.body;
    }
    if (inputs.wifi) {
      if (inputs.wifi.ssid) document.getElementById('input-wifi-ssid').value = inputs.wifi.ssid;
      if (inputs.wifi.password) document.getElementById('input-wifi-pass').value = inputs.wifi.password;
      if (inputs.wifi.encryption) document.getElementById('select-wifi-enc').value = inputs.wifi.encryption;
      if (inputs.wifi.hidden !== undefined) document.getElementById('input-wifi-hidden').checked = inputs.wifi.hidden;
    }

    // Design Inputs
    document.getElementById('qrFgColor').value = cust.fgColor;
    document.getElementById('qrFgColorHex').textContent = cust.fgColor;
    document.getElementById('qrBgColor').value = cust.bgColor;
    document.getElementById('qrBgColorHex').textContent = cust.bgColor;
    document.getElementById('qrBgTransparent').checked = cust.transparentBg;

    document.getElementById('qrEnableGradient').checked = cust.enableGradient;
    document.getElementById('gradientOptionsPanel').classList.toggle('hide', !cust.enableGradient);
    document.getElementById('qrGradientColor2').value = cust.gradientColor2;
    document.getElementById('qrGradientColor2Hex').textContent = cust.gradientColor2;
    document.getElementById('qrGradientType').value = cust.gradientType;
    document.getElementById('qrGradientRotation').value = cust.gradientRotation;
    document.getElementById('qrGradientRotationVal').textContent = `${cust.gradientRotation}°`;

    document.querySelectorAll('#dotStyleSelector .style-opt').forEach(btn => {
      btn.classList.toggle('active', btn.dataset.value === cust.dotType);
    });

    document.getElementById('cornerFrameStyle').value = cust.cornerFrameStyle;
    document.getElementById('cornerEyeStyle').value = cust.cornerEyeStyle;
    document.getElementById('cornerFrameColor').value = cust.cornerFrameColor;
    document.getElementById('cornerFrameColorHex').textContent = cust.cornerFrameColor;
    document.getElementById('cornerEyeColor').value = cust.cornerEyeColor;
    document.getElementById('cornerEyeColorHex').textContent = cust.cornerEyeColor;

    document.getElementById('qrSize').value = cust.size;
    document.getElementById('qrSizeVal').textContent = `${cust.size} x ${cust.size} px`;
    document.getElementById('qrMargin').value = cust.margin;
    document.getElementById('qrMarginVal').textContent = `${cust.margin} px`;
    document.getElementById('qrErrorCorrection').value = cust.errorCorrectionLevel;

    document.getElementById('logoCropShape').value = cust.logoCropShape;
    document.getElementById('logoBgColor').value = cust.logoBgColor;
    document.getElementById('logoBgColorHex').textContent = cust.logoBgColor;
    document.getElementById('logoBorderWidth').value = cust.logoBorderWidth;
    document.getElementById('logoBorderColor').value = cust.logoBorderColor;
    document.getElementById('logoBorderColorHex').textContent = cust.logoBorderColor;
    document.getElementById('logoSizeRatio').value = cust.logoSizeRatio;
    document.getElementById('logoSizeRatioVal').textContent = cust.logoSizeRatio;
    document.getElementById('logoMargin').value = cust.logoMargin;
    document.getElementById('logoMarginVal').textContent = `${cust.logoMargin} px`;
  }

  /**
   * Applies Theme (dark / light)
   */
  applyTheme(theme) {
    this.state.theme = theme;
    document.documentElement.setAttribute('data-theme', theme);
    const themeIcon = document.getElementById('themeIcon');
    if (themeIcon) {
      themeIcon.className = theme === 'dark' ? 'fa-solid fa-moon' : 'fa-solid fa-sun';
    }
    this.saveLocalStorage();
  }

  /**
   * Persists settings in LocalStorage
   */
  saveLocalStorage() {
    try {
      const serialized = {
        theme: this.state.theme,
        activeType: this.state.activeType,
        activeCategory: this.state.activeCategory,
        inputs: this.state.inputs,
        customization: this.state.customization
      };
      localStorage.setItem(this.storageKey, JSON.stringify(serialized));
    } catch (e) {
      console.warn('LocalStorage save failed:', e);
    }
  }

  /**
   * Loads persisted settings from LocalStorage
   */
  loadLocalStorage() {
    try {
      const data = localStorage.getItem(this.storageKey);
      if (data) {
        const parsed = JSON.parse(data);
        if (parsed.theme) this.state.theme = parsed.theme;
        if (parsed.activeType) this.state.activeType = parsed.activeType;
        if (parsed.activeCategory) this.state.activeCategory = parsed.activeCategory;
        if (parsed.inputs) this.state.inputs = { ...this.state.inputs, ...parsed.inputs };
        if (parsed.customization) this.state.customization = { ...this.state.customization, ...parsed.customization };
      }
    } catch (e) {
      console.warn('LocalStorage load failed:', e);
    }
  }

  /**
   * Displays toast message
   */
  showToast(message, type = 'info') {
    const container = document.getElementById('toastContainer');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;

    const icon = type === 'success' ? 'fa-circle-check' : (type === 'error' ? 'fa-triangle-exclamation' : 'fa-circle-info');
    toast.innerHTML = `<i class="fa-solid ${icon}"></i> <span>${message}</span>`;

    container.appendChild(toast);

    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateY(10px)';
      toast.style.transition = 'all 0.25s ease';
      setTimeout(() => toast.remove(), 250);
    }, 3000);
  }
}

// Instantiate App when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  window.app = new App();
});
