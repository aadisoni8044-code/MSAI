/**
 * MSstudio UI Panels & Drawer Controller
 */

window.MSstudioPanels = (function() {

  // Helper: Get active fabric canvas
  function getCanvas() {
    return window.MSstudio && window.MSstudio.state ? window.MSstudio.state.canvas : null;
  }

  // Helper: Get random position near canvas center
  function getCenterPos() {
    const state = window.MSstudio ? window.MSstudio.state : { canvasWidth: 1080, canvasHeight: 1080 };
    const jitter = (Math.random() - 0.5) * 40;
    return {
      x: state.canvasWidth / 2 + jitter,
      y: state.canvasHeight / 2 + jitter
    };
  }

  // Sidebar Tab Switching Engine
  function initSidebarTabs() {
    const tabs = document.querySelectorAll('.sidebar-tab');
    const drawer = document.getElementById('drawer-panel');
    const drawerTitle = document.getElementById('drawer-title');
    const panelSections = document.querySelectorAll('.panel-section');
    const btnCloseDrawer = document.getElementById('btn-close-drawer');

    tabs.forEach(tab => {
      tab.addEventListener('click', () => {
        const targetTab = tab.getAttribute('data-tab');

        // Activate Tab Icon
        tabs.forEach(t => t.classList.remove('active'));
        tab.classList.add('active');

        // Show Drawer if collapsed
        if (drawer.classList.contains('collapsed')) {
          drawer.classList.remove('collapsed');
        }

        // Show matching Panel Section
        panelSections.forEach(section => {
          section.classList.remove('active');
        });

        const activeSection = document.getElementById(`panel-${targetTab}`);
        if (activeSection) {
          activeSection.classList.add('active');
        }

        // Update Drawer Header Title
        if (drawerTitle) {
          const tabNames = {
            'templates': 'Templates',
            'text': 'Text & Typography',
            'elements': 'Elements & Shapes',
            'uploads': 'Uploads',
            'layers': 'Layers',
            'settings': 'Canvas Settings'
          };
          drawerTitle.textContent = tabNames[targetTab] || 'Tool Panel';
        }

        if (window.MSstudio) {
          window.MSstudio.state.activeTab = targetTab;
        }

        // Render layers list if opening layers tab
        if (targetTab === 'layers') {
          renderLayersList();
        }
      });
    });

    // Close/Collapse Drawer Button
    if (btnCloseDrawer) {
      btnCloseDrawer.addEventListener('click', () => {
        drawer.classList.add('collapsed');
        tabs.forEach(t => t.classList.remove('active'));
      });
    }
  }

  // TEXT PANEL HANDLERS
  function initTextPanel() {
    const btnAddHeading = document.getElementById('btn-add-heading');
    const btnAddSubheading = document.getElementById('btn-add-subheading');
    const btnAddBody = document.getElementById('btn-add-body');
    const presetCards = document.querySelectorAll('.text-presets-grid .preset-card');

    if (btnAddHeading) {
      btnAddHeading.addEventListener('click', () => {
        addText('Heading Text', {
          fontSize: 56,
          fontWeight: '700',
          fontFamily: 'Inter',
          fill: getThemeTextColor()
        });
      });
    }

    if (btnAddSubheading) {
      btnAddSubheading.addEventListener('click', () => {
        addText('Subheading Text', {
          fontSize: 36,
          fontWeight: '600',
          fontFamily: 'Inter',
          fill: getThemeTextColor()
        });
      });
    }

    if (btnAddBody) {
      btnAddBody.addEventListener('click', () => {
        addText('Click to write body text...', {
          fontSize: 24,
          fontWeight: '400',
          fontFamily: 'Inter',
          fill: getThemeTextColor()
        });
      });
    }

    // Text Presets
    presetCards.forEach(card => {
      card.addEventListener('click', () => {
        const preset = card.getAttribute('data-preset');
        applyTextPreset(preset);
      });
    });
  }

  function getThemeTextColor() {
    const isDark = document.documentElement.getAttribute('data-theme') !== 'light';
    return isDark ? '#ffffff' : '#0f172a';
  }

  function addText(content, options = {}) {
    const canvas = getCanvas();
    if (!canvas) return;

    const pos = getCenterPos();
    const text = new fabric.IText(content, {
      left: pos.x,
      top: pos.y,
      originX: 'center',
      originY: 'center',
      fontSize: options.fontSize || 32,
      fontFamily: options.fontFamily || 'Inter',
      fontWeight: options.fontWeight || '400',
      fontStyle: options.fontStyle || 'normal',
      fill: options.fill || '#0f172a',
      shadow: options.shadow || null
    });

    canvas.add(text);
    canvas.setActiveObject(text);
    canvas.renderAll();
  }

  function applyTextPreset(preset) {
    const canvas = getCanvas();
    if (!canvas) return;

    const pos = getCenterPos();
    let textObj;

    switch (preset) {
      case 'glow':
        textObj = new fabric.IText('GLOW MAG', {
          left: pos.x,
          top: pos.y,
          originX: 'center',
          originY: 'center',
          fontSize: 52,
          fontFamily: 'Playfair Display',
          fontWeight: '700',
          fill: '#f43f5e',
          shadow: new fabric.Shadow({
            color: 'rgba(244, 63, 94, 0.6)',
            blur: 15,
            offsetX: 0,
            offsetY: 4
          })
        });
        break;

      case 'handwriting':
        textObj = new fabric.IText('Handcrafted', {
          left: pos.x,
          top: pos.y,
          originX: 'center',
          originY: 'center',
          fontSize: 60,
          fontFamily: 'Caveat',
          fontWeight: '600',
          fill: '#06b6d4'
        });
        break;

      case 'bold-headline':
        textObj = new fabric.IText('NEON NIGHTS', {
          left: pos.x,
          top: pos.y,
          originX: 'center',
          originY: 'center',
          fontSize: 56,
          fontFamily: 'Oswald',
          fontWeight: '700',
          fill: '#6366f1',
          shadow: new fabric.Shadow({
            color: 'rgba(99, 102, 241, 0.5)',
            blur: 20,
            offsetX: 2,
            offsetY: 4
          })
        });
        break;

      case 'playful':
        textObj = new fabric.IText('Sweet Summer', {
          left: pos.x,
          top: pos.y,
          originX: 'center',
          originY: 'center',
          fontSize: 48,
          fontFamily: 'Pacifico',
          fill: '#f59e0b'
        });
        break;

      default:
        textObj = new fabric.IText('Preset Text', {
          left: pos.x,
          top: pos.y,
          originX: 'center',
          originY: 'center',
          fontSize: 40,
          fontFamily: 'Poppins',
          fill: '#10b981'
        });
    }

    if (textObj) {
      canvas.add(textObj);
      canvas.setActiveObject(textObj);
      canvas.renderAll();
    }
  }

  // Dynamic Layer List Stub (will be detailed in step 7)
  function renderLayersList() {
    const layersList = document.getElementById('layers-list');
    const layersCount = document.getElementById('layers-count');
    const canvas = getCanvas();

    if (!layersList || !canvas) return;

    const objects = canvas.getObjects();
    if (layersCount) layersCount.textContent = `${objects.length} Objects`;

    if (objects.length === 0) {
      layersList.innerHTML = `<li class="empty-layers-msg">Canvas is empty. Add elements to view layers.</li>`;
      return;
    }

    layersList.innerHTML = '';
    // Display layers top-to-bottom (reversed order of Fabric stack)
    [...objects].reverse().forEach((obj, index) => {
      const realIndex = objects.indexOf(obj);
      const li = document.createElement('li');
      li.className = `layer-item ${canvas.getActiveObject() === obj ? 'active' : ''}`;

      let iconClass = 'fa-shapes';
      let name = 'Object';

      if (obj.type === 'i-text' || obj.type === 'text') {
        iconClass = 'fa-font';
        name = obj.text ? `"${obj.text.substring(0, 15)}"` : 'Text';
      } else if (obj.type === 'rect') {
        iconClass = 'fa-square';
        name = 'Rectangle';
      } else if (obj.type === 'circle') {
        iconClass = 'fa-circle';
        name = 'Circle';
      } else if (obj.type === 'triangle') {
        iconClass = 'fa-play fa-rotate-270';
        name = 'Triangle';
      } else if (obj.type === 'polygon' || obj.type === 'path') {
        iconClass = 'fa-star';
        name = 'Star/Icon';
      } else if (obj.type === 'line') {
        iconClass = 'fa-minus';
        name = 'Line';
      } else if (obj.type === 'image') {
        iconClass = 'fa-image';
        name = 'Image Asset';
      }

      li.innerHTML = `
        <div class="layer-info">
          <i class="fa-solid ${iconClass} layer-icon"></i>
          <span class="layer-name">${name}</span>
        </div>
        <div class="layer-controls">
          <button class="layer-btn btn-visibility" title="Toggle Visibility">
            <i class="fa-solid ${obj.visible !== false ? 'fa-eye' : 'fa-eye-slash'}"></i>
          </button>
          <button class="layer-btn btn-lock" title="Lock Layer">
            <i class="fa-solid ${obj.selectable !== false ? 'fa-unlock' : 'fa-lock'}"></i>
          </button>
          <button class="layer-btn btn-delete text-danger" title="Delete Layer">
            <i class="fa-solid fa-trash-can"></i>
          </button>
        </div>
      `;

      // Select object on layer click
      li.addEventListener('click', (e) => {
        if (e.target.closest('.layer-btn')) return; // Ignore control buttons
        canvas.setActiveObject(obj);
        canvas.renderAll();
        highlightActiveLayer();
      });

      // Visibility Toggle
      li.querySelector('.btn-visibility')?.addEventListener('click', (e) => {
        e.stopPropagation();
        obj.visible = obj.visible === false ? true : false;
        canvas.renderAll();
        renderLayersList();
        if (window.MSstudio) window.MSstudio.saveState();
      });

      // Lock Toggle
      li.querySelector('.btn-lock')?.addEventListener('click', (e) => {
        e.stopPropagation();
        const isLocked = obj.selectable === false;
        obj.set({
          selectable: isLocked,
          hasControls: isLocked,
          lockMovementX: !isLocked,
          lockMovementY: !isLocked
        });
        canvas.renderAll();
        renderLayersList();
        if (window.MSstudio) window.MSstudio.saveState();
      });

      // Delete Layer
      li.querySelector('.btn-delete')?.addEventListener('click', (e) => {
        e.stopPropagation();
        canvas.remove(obj);
        canvas.discardActiveObject();
        canvas.renderAll();
        renderLayersList();
      });

      layersList.appendChild(li);
    });
  }

  function highlightActiveLayer() {
    const canvas = getCanvas();
    if (!canvas) return;
    const activeObj = canvas.getActiveObject();
    const items = document.querySelectorAll('.layers-list .layer-item');

    // Simple refresh or class toggle
    renderLayersList();
  }

  // SHAPES & ELEMENTS PANEL HANDLERS
  function initElementsPanel() {
    const shapeBtns = document.querySelectorAll('.shapes-grid .shape-btn');
    const elementCards = document.querySelectorAll('.elements-presets-grid .element-preset-card');

    shapeBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        const shapeType = btn.getAttribute('data-shape');
        addShape(shapeType);
      });
    });

    elementCards.forEach(card => {
      card.addEventListener('click', () => {
        const elementType = card.getAttribute('data-element');
        addDecorativeElement(elementType);
      });
    });
  }

  function addShape(shapeType) {
    const canvas = getCanvas();
    if (!canvas) return;

    const pos = getCenterPos();
    let shapeObj;

    const defaultFill = '#6366f1';
    const defaultStroke = '#4338ca';

    switch (shapeType) {
      case 'rectangle':
        shapeObj = new fabric.Rect({
          left: pos.x,
          top: pos.y,
          originX: 'center',
          originY: 'center',
          width: 180,
          height: 140,
          fill: defaultFill,
          stroke: defaultStroke,
          strokeWidth: 0,
          rx: 8,
          ry: 8
        });
        break;

      case 'circle':
        shapeObj = new fabric.Circle({
          left: pos.x,
          top: pos.y,
          originX: 'center',
          originY: 'center',
          radius: 80,
          fill: '#06b6d4',
          stroke: '#0891b2',
          strokeWidth: 0
        });
        break;

      case 'triangle':
        shapeObj = new fabric.Triangle({
          left: pos.x,
          top: pos.y,
          originX: 'center',
          originY: 'center',
          width: 160,
          height: 150,
          fill: '#f59e0b',
          stroke: '#d97706',
          strokeWidth: 0
        });
        break;

      case 'star':
        shapeObj = createStarPoly(pos.x, pos.y, 5, 80, 40, {
          fill: '#ec4899',
          stroke: '#db2777',
          strokeWidth: 0
        });
        break;

      case 'line':
        shapeObj = new fabric.Line([pos.x - 100, pos.y, pos.x + 100, pos.y], {
          stroke: defaultFill,
          strokeWidth: 6,
          strokeLineCap: 'round'
        });
        break;

      case 'arrow':
        shapeObj = createArrowGroup(pos.x, pos.y);
        break;

      default:
        shapeObj = new fabric.Rect({
          left: pos.x,
          top: pos.y,
          originX: 'center',
          originY: 'center',
          width: 150,
          height: 150,
          fill: defaultFill
        });
    }

    if (shapeObj) {
      canvas.add(shapeObj);
      canvas.setActiveObject(shapeObj);
      canvas.renderAll();
    }
  }

  function createStarPoly(centerX, centerY, points, outerRadius, innerRadius, options) {
    const results = [];
    const step = Math.PI / points;

    for (let i = 0; i < 2 * points; i++) {
      const r = (i % 2 === 0) ? outerRadius : innerRadius;
      const x = centerX + r * Math.sin(i * step);
      const y = centerY - r * Math.cos(i * step);
      results.push({ x, y });
    }

    return new fabric.Polygon(results, {
      left: centerX,
      top: centerY,
      originX: 'center',
      originY: 'center',
      ...options
    });
  }

  function createArrowGroup(x, y) {
    const line = new fabric.Line([-80, 0, 60, 0], {
      stroke: '#6366f1',
      strokeWidth: 8,
      strokeLineCap: 'round',
      originX: 'center',
      originY: 'center'
    });

    const head = new fabric.Triangle({
      width: 30,
      height: 30,
      fill: '#6366f1',
      left: 60,
      top: 0,
      angle: 90,
      originX: 'center',
      originY: 'center'
    });

    return new fabric.Group([line, head], {
      left: x,
      top: y,
      originX: 'center',
      originY: 'center'
    });
  }

  function addDecorativeElement(elementType) {
    const canvas = getCanvas();
    if (!canvas) return;

    const pos = getCenterPos();
    let elem;

    switch (elementType) {
      case 'badge-circle':
        elem = createStarPoly(pos.x, pos.y, 12, 90, 75, {
          fill: '#10b981',
          strokeWidth: 0
        });
        break;

      case 'heart':
        const pathData = "M 272.70141,238.71731 C 206.46141,173.53731 101.46141,228.53731 101.46141,313.53731 C 101.46141,398.53731 272.70141,523.53731 272.70141,523.53731 C 272.70141,523.53731 443.94141,398.53731 443.94141,313.53731 C 443.94141,228.53731 338.94141,173.53731 272.70141,238.71731 Z";
        elem = new fabric.Path(pathData, {
          left: pos.x,
          top: pos.y,
          originX: 'center',
          originY: 'center',
          fill: '#ef4444',
          scaleX: 0.4,
          scaleY: 0.4
        });
        break;

      case 'cloud':
        const cloudPath = "M 120 160 a 40 40 0 0 1 70 -20 a 50 50 0 0 1 90 10 a 40 40 0 0 1 30 70 l -190 0 a 40 40 0 0 1 0 -60 z";
        elem = new fabric.Path(cloudPath, {
          left: pos.x,
          top: pos.y,
          originX: 'center',
          originY: 'center',
          fill: '#38bdf8',
          scaleX: 1.2,
          scaleY: 1.2
        });
        break;

      case 'lightning':
        const boltPath = "M 10 0 L 0 14 L 7 14 L 3 24 L 16 8 L 8 8 Z";
        elem = new fabric.Path(boltPath, {
          left: pos.x,
          top: pos.y,
          originX: 'center',
          originY: 'center',
          fill: '#f59e0b',
          scaleX: 6,
          scaleY: 6
        });
        break;
    }

    if (elem) {
      canvas.add(elem);
      canvas.setActiveObject(elem);
      canvas.renderAll();
    }
  }

  // UPLOADS PANEL HANDLERS
  function initUploadsPanel() {
    const dropzone = document.getElementById('upload-dropzone');
    const fileInput = document.getElementById('file-input');
    const gallery = document.getElementById('uploads-gallery');

    if (!dropzone || !fileInput) return;

    // Trigger file chooser
    dropzone.addEventListener('click', () => {
      fileInput.click();
    });

    fileInput.addEventListener('change', (e) => {
      const files = e.target.files;
      if (files && files.length > 0) {
        handleImageFiles(files);
      }
    });

    // Drag and Drop Events
    dropzone.addEventListener('dragover', (e) => {
      e.preventDefault();
      dropzone.classList.add('dragover');
    });

    dropzone.addEventListener('dragleave', () => {
      dropzone.classList.remove('dragover');
    });

    dropzone.addEventListener('drop', (e) => {
      e.preventDefault();
      dropzone.classList.remove('dragover');
      const files = e.dataTransfer.files;
      if (files && files.length > 0) {
        handleImageFiles(files);
      }
    });
  }

  function handleImageFiles(files) {
    const gallery = document.getElementById('uploads-gallery');
    const emptyMsg = gallery ? gallery.querySelector('.empty-gallery-msg') : null;

    Array.from(files).forEach(file => {
      if (!file.type.startsWith('image/')) return;

      const reader = new FileReader();
      reader.onload = function(event) {
        const imgSrc = event.target.result;

        if (emptyMsg) emptyMsg.style.display = 'none';

        // Add thumbnail to gallery
        const item = document.createElement('div');
        item.className = 'gallery-item';
        item.innerHTML = `<img src="${imgSrc}" alt="Uploaded image">`;

        item.addEventListener('click', () => {
          addImageToCanvas(imgSrc);
        });

        if (gallery) {
          gallery.prepend(item);
        }

        // Auto insert into canvas
        addImageToCanvas(imgSrc);
      };
      reader.readAsDataURL(file);
    });
  }

  function addImageToCanvas(url) {
    const canvas = getCanvas();
    if (!canvas) return;

    fabric.Image.fromURL(url, (img) => {
      const pos = getCenterPos();

      // Auto-scale large images to fit reasonably on canvas
      const maxDim = 400;
      let scale = 1.0;
      if (img.width > maxDim || img.height > maxDim) {
        scale = Math.min(maxDim / img.width, maxDim / img.height);
      }

      img.set({
        left: pos.x,
        top: pos.y,
        originX: 'center',
        originY: 'center',
        scaleX: scale,
        scaleY: scale
      });

      canvas.add(img);
      canvas.setActiveObject(img);
      canvas.renderAll();
    });
  }

  // LAYERS ORDERING CONTROLS HANDLERS
  function initLayersPanelControls() {
    const btnUp = document.getElementById('btn-layer-up');
    const btnDown = document.getElementById('btn-layer-down');
    const btnTop = document.getElementById('btn-layer-top');
    const btnBottom = document.getElementById('btn-layer-bottom');

    btnUp?.addEventListener('click', () => {
      const canvas = getCanvas();
      const obj = canvas?.getActiveObject();
      if (canvas && obj) {
        canvas.bringForward(obj);
        canvas.renderAll();
        renderLayersList();
        if (window.MSstudio) window.MSstudio.saveState();
      }
    });

    btnDown?.addEventListener('click', () => {
      const canvas = getCanvas();
      const obj = canvas?.getActiveObject();
      if (canvas && obj) {
        canvas.sendBackwards(obj);
        canvas.renderAll();
        renderLayersList();
        if (window.MSstudio) window.MSstudio.saveState();
      }
    });

    btnTop?.addEventListener('click', () => {
      const canvas = getCanvas();
      const obj = canvas?.getActiveObject();
      if (canvas && obj) {
        canvas.bringToFront(obj);
        canvas.renderAll();
        renderLayersList();
        if (window.MSstudio) window.MSstudio.saveState();
      }
    });

    btnBottom?.addEventListener('click', () => {
      const canvas = getCanvas();
      const obj = canvas?.getActiveObject();
      if (canvas && obj) {
        canvas.sendToBack(obj);
        canvas.renderAll();
        renderLayersList();
        if (window.MSstudio) window.MSstudio.saveState();
      }
    });
  }

  // CANVAS SETTINGS PANEL HANDLERS
  function initSettingsPanel() {
    const presetBtns = document.querySelectorAll('.preset-size-btn');
    const widthInput = document.getElementById('canvas-width-input');
    const heightInput = document.getElementById('canvas-height-input');
    const btnApplyDim = document.getElementById('btn-apply-dimensions');
    const bgColorPicker = document.getElementById('bg-color-picker');
    const colorSwatches = document.querySelectorAll('.color-presets .color-swatch');

    // Size Presets
    presetBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        presetBtns.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        const w = parseInt(btn.getAttribute('data-width'), 10);
        const h = parseInt(btn.getAttribute('data-height'), 10);

        if (widthInput) widthInput.value = w;
        if (heightInput) heightInput.value = h;

        resizeCanvas(w, h);
      });
    });

    // Custom Dimensions
    btnApplyDim?.addEventListener('click', () => {
      const w = parseInt(widthInput.value, 10);
      const h = parseInt(heightInput.value, 10);

      if (w >= 100 && w <= 4000 && h >= 100 && h <= 4000) {
        presetBtns.forEach(b => b.classList.remove('active'));
        resizeCanvas(w, h);
      } else {
        alert('Dimensions must be between 100px and 4000px.');
      }
    });

    // Background Color Swatches
    colorSwatches.forEach(swatch => {
      swatch.addEventListener('click', () => {
        colorSwatches.forEach(s => s.classList.remove('active'));
        swatch.classList.add('active');

        const color = swatch.getAttribute('data-color');
        if (bgColorPicker) bgColorPicker.value = color;
        setCanvasBackgroundColor(color);
      });
    });

    // Custom BG Color Picker
    bgColorPicker?.addEventListener('input', (e) => {
      colorSwatches.forEach(s => s.classList.remove('active'));
      setCanvasBackgroundColor(e.target.value);
    });
  }

  function resizeCanvas(w, h) {
    if (!window.MSstudio || !window.MSstudio.state) return;
    const state = window.MSstudio.state;

    state.canvasWidth = w;
    state.canvasHeight = h;

    if (window.MSstudio.fitCanvasToViewport) {
      window.MSstudio.fitCanvasToViewport();
    }
  }

  function setCanvasBackgroundColor(color) {
    const canvas = getCanvas();
    if (!canvas) return;

    canvas.setBackgroundColor(color, () => {
      canvas.renderAll();
      if (window.MSstudio) window.MSstudio.saveState();
    });
  }

  // TEMPLATES PANEL HANDLERS
  function initTemplatesPanel() {
    const templateCards = document.querySelectorAll('.templates-grid .template-card');

    templateCards.forEach(card => {
      card.addEventListener('click', () => {
        const templateType = card.getAttribute('data-template');
        loadTemplate(templateType);
      });
    });
  }

  function loadTemplate(type) {
    const canvas = getCanvas();
    if (!canvas) return;

    if (canvas.getObjects().length > 0) {
      if (!confirm('Loading a template will clear your current canvas objects. Continue?')) {
        return;
      }
    }

    canvas.clear();

    const w = 1080;
    const h = 1080;
    resizeCanvas(w, h);

    switch (type) {
      case 'quote':
        canvas.setBackgroundColor('#0f172a', canvas.renderAll.bind(canvas));

        const accentRect = new fabric.Rect({
          left: w / 2,
          top: h / 2,
          originX: 'center',
          originY: 'center',
          width: 900,
          height: 900,
          fill: 'transparent',
          stroke: '#f43f5e',
          strokeWidth: 4,
          rx: 16,
          ry: 16
        });

        const quoteMark = new fabric.IText('“', {
          left: w / 2,
          top: 260,
          originX: 'center',
          originY: 'center',
          fontSize: 160,
          fontFamily: 'Playfair Display',
          fill: '#fb923c'
        });

        const quoteText = new fabric.IText('Creativity is intelligence having fun.', {
          left: w / 2,
          top: 480,
          originX: 'center',
          originY: 'center',
          fontSize: 48,
          fontFamily: 'Playfair Display',
          fontStyle: 'italic',
          fill: '#f8fafc',
          textAlign: 'center',
          width: 750
        });

        const authorText = new fabric.IText('- ALBERT EINSTEIN -', {
          left: w / 2,
          top: 720,
          originX: 'center',
          originY: 'center',
          fontSize: 28,
          fontFamily: 'Oswald',
          fill: '#f43f5e',
          charSpacing: 200
        });

        canvas.add(accentRect, quoteMark, quoteText, authorText);
        break;

      case 'social':
        canvas.setBackgroundColor('#1e1b4b', canvas.renderAll.bind(canvas));

        const bgCircle = new fabric.Circle({
          left: w / 2,
          top: h / 2 - 50,
          originX: 'center',
          originY: 'center',
          radius: 320,
          fill: '#4338ca'
        });

        const promoTitle = new fabric.IText('MEGA SALE', {
          left: w / 2,
          top: 360,
          originX: 'center',
          originY: 'center',
          fontSize: 80,
          fontFamily: 'Montserrat',
          fontWeight: '700',
          fill: '#38bdf8'
        });

        const discountBadge = new fabric.IText('UP TO 50% OFF', {
          left: w / 2,
          top: 480,
          originX: 'center',
          originY: 'center',
          fontSize: 44,
          fontFamily: 'Poppins',
          fontWeight: '600',
          fill: '#f59e0b'
        });

        const shopBtnBg = new fabric.Rect({
          left: w / 2,
          top: 680,
          originX: 'center',
          originY: 'center',
          width: 320,
          height: 80,
          fill: '#06b6d4',
          rx: 40,
          ry: 40
        });

        const shopBtnText = new fabric.IText('SHOP NOW', {
          left: w / 2,
          top: 680,
          originX: 'center',
          originY: 'center',
          fontSize: 28,
          fontFamily: 'Montserrat',
          fontWeight: '700',
          fill: '#ffffff'
        });

        canvas.add(bgCircle, promoTitle, discountBadge, shopBtnBg, shopBtnText);
        break;

      case 'badge':
        canvas.setBackgroundColor('#f8fafc', canvas.renderAll.bind(canvas));

        const starBadge = createStarPoly(w / 2, h / 2, 16, 320, 280, {
          fill: '#0f172a'
        });

        const innerCircle = new fabric.Circle({
          left: w / 2,
          top: h / 2,
          originX: 'center',
          originY: 'center',
          radius: 250,
          fill: '#ffffff',
          stroke: '#0f172a',
          strokeWidth: 4
        });

        const badgeHeader = new fabric.IText('STUDIO CREATIVE', {
          left: w / 2,
          top: 420,
          originX: 'center',
          originY: 'center',
          fontSize: 32,
          fontFamily: 'Oswald',
          fill: '#6366f1'
        });

        const badgeMain = new fabric.IText('PREMIUM', {
          left: w / 2,
          top: 520,
          originX: 'center',
          originY: 'center',
          fontSize: 72,
          fontFamily: 'Montserrat',
          fontWeight: '700',
          fill: '#0f172a'
        });

        const badgeSub = new fabric.IText('QUALITY DESIGN', {
          left: w / 2,
          top: 620,
          originX: 'center',
          originY: 'center',
          fontSize: 24,
          fontFamily: 'Inter',
          fill: '#64748b'
        });

        canvas.add(starBadge, innerCircle, badgeHeader, badgeMain, badgeSub);
        break;

      case 'gradient':
        canvas.setBackgroundColor('#0284c7', canvas.renderAll.bind(canvas));

        const tri1 = new fabric.Triangle({
          left: 200,
          top: 200,
          originX: 'center',
          originY: 'center',
          width: 500,
          height: 500,
          fill: '#ec4899',
          opacity: 0.8
        });

        const tri2 = new fabric.Triangle({
          left: 800,
          top: 800,
          originX: 'center',
          originY: 'center',
          width: 600,
          height: 600,
          fill: '#8b5cf6',
          angle: 180,
          opacity: 0.8
        });

        const mainTitle = new fabric.IText('MODERN VISION', {
          left: w / 2,
          top: h / 2 - 20,
          originX: 'center',
          originY: 'center',
          fontSize: 72,
          fontFamily: 'Poppins',
          fontWeight: '700',
          fill: '#ffffff'
        });

        const mainSub = new fabric.IText('Explore Infinite Possibilities', {
          left: w / 2,
          top: h / 2 + 60,
          originX: 'center',
          originY: 'center',
          fontSize: 32,
          fontFamily: 'Caveat',
          fill: '#fef08a'
        });

        canvas.add(tri1, tri2, mainTitle, mainSub);
        break;
    }

    canvas.renderAll();
    if (window.MSstudio) window.MSstudio.saveState();
  }

  // Initialize Module
  document.addEventListener('DOMContentLoaded', () => {
    initSidebarTabs();
    initTextPanel();
    initElementsPanel();
    initUploadsPanel();
    initLayersPanelControls();
    initSettingsPanel();
    initTemplatesPanel();
  });

  return {
    getCenterPos,
    renderLayersList,
    highlightActiveLayer
  };

})();
