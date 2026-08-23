/**
 * MSstudio Contextual Toolbar, Exports, and Theme Module
 */

window.MSstudioToolbar = (function() {

  function getCanvas() {
    return window.MSstudio && window.MSstudio.state ? window.MSstudio.state.canvas : null;
  }

  // Update Dynamic Contextual Toolbar State
  function updateToolbar() {
    const canvas = getCanvas();
    if (!canvas) return;

    const placeholder = document.querySelector('.toolbar-placeholder');
    const textGroup = document.getElementById('toolbar-text-group');
    const shapeGroup = document.getElementById('toolbar-shape-group');
    const commonGroup = document.getElementById('toolbar-common-group');

    const activeObj = canvas.getActiveObject();

    if (!activeObj) {
      placeholder?.classList.remove('hidden');
      textGroup?.classList.add('hidden');
      shapeGroup?.classList.add('hidden');
      commonGroup?.classList.add('hidden');
      return;
    }

    placeholder?.classList.add('hidden');
    commonGroup?.classList.remove('hidden');

    // Update Opacity Control
    const opacitySlider = document.getElementById('object-opacity');
    const opacityVal = document.getElementById('opacity-val');
    if (opacitySlider && opacityVal) {
      const op = activeObj.opacity !== undefined ? activeObj.opacity : 1;
      opacitySlider.value = op;
      opacityVal.textContent = `${Math.round(op * 100)}%`;
    }

    // Check if Text Object
    if (activeObj.type === 'i-text' || activeObj.type === 'text') {
      textGroup?.classList.remove('hidden');
      shapeGroup?.classList.add('hidden');

      // Populate Text Values
      const fontFamilySelect = document.getElementById('font-family-select');
      const fontSizeInput = document.getElementById('font-size-input');
      const textColorPicker = document.getElementById('text-color-picker');
      const btnBold = document.getElementById('btn-text-bold');
      const btnItalic = document.getElementById('btn-text-italic');
      const btnUnderline = document.getElementById('btn-text-underline');

      if (fontFamilySelect) fontFamilySelect.value = activeObj.fontFamily || 'Inter';
      if (fontSizeInput) fontSizeInput.value = Math.round(activeObj.fontSize * (activeObj.scaleY || 1));
      if (textColorPicker) textColorPicker.value = rgbToHex(activeObj.fill) || '#000000';

      if (btnBold) btnBold.classList.toggle('active', activeObj.fontWeight === 'bold' || activeObj.fontWeight === '700');
      if (btnItalic) btnItalic.classList.toggle('active', activeObj.fontStyle === 'italic');
      if (btnUnderline) btnUnderline.classList.toggle('active', activeObj.underline === true);

      // Alignment Active State
      const btnLeft = document.getElementById('btn-align-left');
      const btnCenter = document.getElementById('btn-align-center');
      const btnRight = document.getElementById('btn-align-right');

      const align = activeObj.textAlign || 'left';
      if (btnLeft) btnLeft.classList.toggle('active', align === 'left');
      if (btnCenter) btnCenter.classList.toggle('active', align === 'center');
      if (btnRight) btnRight.classList.toggle('active', align === 'right');

    } else {
      // Shape / Image Object
      textGroup?.classList.add('hidden');
      shapeGroup?.classList.remove('hidden');

      const fillPicker = document.getElementById('shape-fill-picker');
      const strokePicker = document.getElementById('shape-stroke-picker');
      const strokeWidthInput = document.getElementById('shape-stroke-width');
      const strokeWidthVal = document.getElementById('stroke-width-val');

      if (fillPicker && activeObj.fill && typeof activeObj.fill === 'string') {
        fillPicker.value = rgbToHex(activeObj.fill) || '#6366f1';
      }
      if (strokePicker && activeObj.stroke) {
        strokePicker.value = rgbToHex(activeObj.stroke) || '#000000';
      }
      if (strokeWidthInput && strokeWidthVal) {
        const sw = activeObj.strokeWidth || 0;
        strokeWidthInput.value = sw;
        strokeWidthVal.textContent = `${sw}px`;
      }
    }
  }

  // Bind Dynamic Toolbar Actions
  function initToolbarEvents() {
    const canvas = getCanvas();

    // Text Font Family
    document.getElementById('font-family-select')?.addEventListener('change', (e) => {
      const activeObj = getCanvas()?.getActiveObject();
      if (activeObj && (activeObj.type === 'i-text' || activeObj.type === 'text')) {
        activeObj.set('fontFamily', e.target.value);
        getCanvas().renderAll();
        if (window.MSstudio) window.MSstudio.saveState();
      }
    });

    // Font Size
    document.getElementById('font-size-input')?.addEventListener('input', (e) => {
      const activeObj = getCanvas()?.getActiveObject();
      if (activeObj && (activeObj.type === 'i-text' || activeObj.type === 'text')) {
        activeObj.set({
          fontSize: parseInt(e.target.value, 10) || 12,
          scaleX: 1,
          scaleY: 1
        });
        getCanvas().renderAll();
        if (window.MSstudio) window.MSstudio.saveState();
      }
    });

    // Formatting Buttons (Bold, Italic, Underline)
    document.getElementById('btn-text-bold')?.addEventListener('click', () => {
      const activeObj = getCanvas()?.getActiveObject();
      if (activeObj && (activeObj.type === 'i-text' || activeObj.type === 'text')) {
        const isBold = activeObj.fontWeight === 'bold' || activeObj.fontWeight === '700';
        activeObj.set('fontWeight', isBold ? 'normal' : 'bold');
        getCanvas().renderAll();
        updateToolbar();
        if (window.MSstudio) window.MSstudio.saveState();
      }
    });

    document.getElementById('btn-text-italic')?.addEventListener('click', () => {
      const activeObj = getCanvas()?.getActiveObject();
      if (activeObj && (activeObj.type === 'i-text' || activeObj.type === 'text')) {
        const isItalic = activeObj.fontStyle === 'italic';
        activeObj.set('fontStyle', isItalic ? 'normal' : 'italic');
        getCanvas().renderAll();
        updateToolbar();
        if (window.MSstudio) window.MSstudio.saveState();
      }
    });

    document.getElementById('btn-text-underline')?.addEventListener('click', () => {
      const activeObj = getCanvas()?.getActiveObject();
      if (activeObj && (activeObj.type === 'i-text' || activeObj.type === 'text')) {
        activeObj.set('underline', !activeObj.underline);
        getCanvas().renderAll();
        updateToolbar();
        if (window.MSstudio) window.MSstudio.saveState();
      }
    });

    // Alignment
    ['left', 'center', 'right'].forEach(align => {
      document.getElementById(`btn-align-${align}`)?.addEventListener('click', () => {
        const activeObj = getCanvas()?.getActiveObject();
        if (activeObj && (activeObj.type === 'i-text' || activeObj.type === 'text')) {
          activeObj.set('textAlign', align);
          getCanvas().renderAll();
          updateToolbar();
          if (window.MSstudio) window.MSstudio.saveState();
        }
      });
    });

    // Colors & Fill
    document.getElementById('text-color-picker')?.addEventListener('input', (e) => {
      const activeObj = getCanvas()?.getActiveObject();
      if (activeObj) {
        activeObj.set('fill', e.target.value);
        getCanvas().renderAll();
        if (window.MSstudio) window.MSstudio.saveState();
      }
    });

    document.getElementById('shape-fill-picker')?.addEventListener('input', (e) => {
      const activeObj = getCanvas()?.getActiveObject();
      if (activeObj) {
        activeObj.set('fill', e.target.value);
        getCanvas().renderAll();
        if (window.MSstudio) window.MSstudio.saveState();
      }
    });

    document.getElementById('shape-stroke-picker')?.addEventListener('input', (e) => {
      const activeObj = getCanvas()?.getActiveObject();
      if (activeObj) {
        activeObj.set('stroke', e.target.value);
        getCanvas().renderAll();
        if (window.MSstudio) window.MSstudio.saveState();
      }
    });

    document.getElementById('shape-stroke-width')?.addEventListener('input', (e) => {
      const activeObj = getCanvas()?.getActiveObject();
      const val = parseInt(e.target.value, 10);
      const valDisplay = document.getElementById('stroke-width-val');
      if (valDisplay) valDisplay.textContent = `${val}px`;

      if (activeObj) {
        activeObj.set('strokeWidth', val);
        getCanvas().renderAll();
        if (window.MSstudio) window.MSstudio.saveState();
      }
    });

    // Opacity
    document.getElementById('object-opacity')?.addEventListener('input', (e) => {
      const activeObj = getCanvas()?.getActiveObject();
      const val = parseFloat(e.target.value);
      const valDisplay = document.getElementById('opacity-val');
      if (valDisplay) valDisplay.textContent = `${Math.round(val * 100)}%`;

      if (activeObj) {
        activeObj.set('opacity', val);
        getCanvas().renderAll();
        if (window.MSstudio) window.MSstudio.saveState();
      }
    });

    // Common Actions: Duplicate, Lock, Delete
    document.getElementById('btn-duplicate-obj')?.addEventListener('click', () => {
      const canvas = getCanvas();
      const activeObj = canvas?.getActiveObject();
      if (!canvas || !activeObj) return;

      activeObj.clone((clonedObj) => {
        canvas.discardActiveObject();
        clonedObj.set({
          left: activeObj.left + 20,
          top: activeObj.top + 20,
          evented: true
        });
        if (clonedObj.type === 'activeSelection') {
          clonedObj.canvas = canvas;
          clonedObj.forEachObject((obj) => {
            canvas.add(obj);
          });
          clonedObj.setCoordinates();
        } else {
          canvas.add(clonedObj);
        }
        canvas.setActiveObject(clonedObj);
        canvas.renderAll();
        if (window.MSstudio) window.MSstudio.saveState();
      });
    });

    document.getElementById('btn-lock-obj')?.addEventListener('click', () => {
      const canvas = getCanvas();
      const activeObj = canvas?.getActiveObject();
      if (!canvas || !activeObj) return;

      const isLocked = activeObj.selectable === false;
      activeObj.set({
        selectable: isLocked,
        hasControls: isLocked,
        lockMovementX: !isLocked,
        lockMovementY: !isLocked
      });
      canvas.renderAll();
      if (window.MSstudioPanels) window.MSstudioPanels.renderLayersList();
      if (window.MSstudio) window.MSstudio.saveState();
    });

    document.getElementById('btn-delete-obj')?.addEventListener('click', () => {
      const canvas = getCanvas();
      const activeObj = canvas?.getActiveObject();
      if (canvas && activeObj) {
        canvas.remove(activeObj);
        canvas.discardActiveObject();
        canvas.renderAll();
        if (window.MSstudioPanels) window.MSstudioPanels.renderLayersList();
      }
    });
  }

  // Theme Toggle Engine
  function initThemeToggle() {
    const btnTheme = document.getElementById('btn-theme-toggle');
    const htmlElem = document.documentElement;

    btnTheme?.addEventListener('click', () => {
      const currentTheme = htmlElem.getAttribute('data-theme') || 'dark';
      const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
      htmlElem.setAttribute('data-theme', newTheme);
    });
  }

  // Export Engine (PNG, JPG, PDF)
  function initExportMenu() {
    const btnExportMenu = document.getElementById('btn-export-menu');
    const exportDropdown = document.getElementById('export-dropdown');

    btnExportMenu?.addEventListener('click', (e) => {
      e.stopPropagation();
      exportDropdown?.classList.toggle('hidden');
    });

    document.addEventListener('click', () => {
      exportDropdown?.classList.add('hidden');
    });

    document.getElementById('export-png')?.addEventListener('click', () => {
      exportCanvas('png');
    });

    document.getElementById('export-jpg')?.addEventListener('click', () => {
      exportCanvas('jpg');
    });

    document.getElementById('export-pdf')?.addEventListener('click', () => {
      exportCanvas('pdf');
    });
  }

  function getProjectName() {
    const titleInput = document.getElementById('canvas-title-input');
    return (titleInput && titleInput.value.trim()) ? titleInput.value.trim() : 'MSstudio-project';
  }

  function exportCanvas(format) {
    const canvas = getCanvas();
    if (!canvas) return;

    // Deselect objects prior to export so bounding box handles aren't rendered in export
    canvas.discardActiveObject();
    canvas.renderAll();

    const fileName = getProjectName();

    if (format === 'png') {
      const dataURL = canvas.toDataURL({
        format: 'png',
        multiplier: 2, // High resolution export
        quality: 1.0
      });
      downloadFile(dataURL, `${fileName}.png`);

    } else if (format === 'jpg') {
      const dataURL = canvas.toDataURL({
        format: 'jpeg',
        multiplier: 2,
        quality: 0.95
      });
      downloadFile(dataURL, `${fileName}.jpg`);

    } else if (format === 'pdf') {
      const dataURL = canvas.toDataURL({
        format: 'png',
        multiplier: 2
      });

      const { jsPDF } = window.jspdf || {};
      if (!jsPDF) {
        alert('PDF Export Library is loading. Please try again.');
        return;
      }

      const width = canvas.width;
      const height = canvas.height;
      const orientation = width > height ? 'landscape' : 'portrait';

      const pdf = new jsPDF({
        orientation: orientation,
        unit: 'px',
        format: [width, height]
      });

      pdf.addImage(dataURL, 'PNG', 0, 0, width, height);
      pdf.save(`${fileName}.pdf`);
    }
  }

  function downloadFile(dataURL, filename) {
    const link = document.createElement('a');
    link.download = filename;
    link.href = dataURL;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }

  // Utility RGB/Color string converter
  function rgbToHex(color) {
    if (!color) return '#000000';
    if (color.startsWith('#')) return color;

    const matches = color.match(/\d+/g);
    if (!matches || matches.length < 3) return '#000000';

    const r = parseInt(matches[0], 10).toString(16).padStart(2, '0');
    const g = parseInt(matches[1], 10).toString(16).padStart(2, '0');
    const b = parseInt(matches[2], 10).toString(16).padStart(2, '0');

    return `#${r}${g}${b}`;
  }

  // Initialization
  document.addEventListener('DOMContentLoaded', () => {
    initToolbarEvents();
    initThemeToggle();
    initExportMenu();
  });

  return {
    updateToolbar
  };

})();
