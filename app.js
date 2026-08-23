/**
 * MSstudio Core Application State & Canvas Engine
 */

document.addEventListener('DOMContentLoaded', () => {
  // Application State
  const state = {
    canvas: null,
    canvasWidth: 1080,
    canvasHeight: 1080,
    zoomLevel: 1.0,
    historyStack: [],
    redoStack: [],
    isModifyingState: false,
    maxHistorySize: 30,
    activeTab: 'templates',
    selectedObject: null
  };

  // Initialize Fabric Canvas
  function initCanvas() {
    state.canvas = new fabric.Canvas('main-canvas', {
      width: state.canvasWidth,
      height: state.canvasHeight,
      backgroundColor: '#ffffff',
      preserveObjectStacking: true,
      selection: true,
      controlsAboveOverlay: true
    });

    // Custom Fabric Handle Styles
    fabric.Object.prototype.set({
      transparentCorners: false,
      cornerColor: '#6366f1',
      cornerStrokeColor: '#ffffff',
      cornerSize: 10,
      cornerStyle: 'circle',
      borderColor: '#6366f1',
      borderScaleFactor: 1.5,
      padding: 4
    });

    // Initial Zoom & Center Fit
    fitCanvasToViewport();

    // Setup Canvas Event Listeners
    setupCanvasEvents();

    // Save Initial State
    saveState();
  }

  // Viewport Zoom & Fit Math
  function fitCanvasToViewport() {
    const wrapper = document.getElementById('canvas-viewport');
    if (!wrapper || !state.canvas) return;

    const padding = 80;
    const availWidth = wrapper.clientWidth - padding;
    const availHeight = wrapper.clientHeight - padding;

    if (availWidth <= 0 || availHeight <= 0) return;

    const scaleX = availWidth / state.canvasWidth;
    const scaleY = availHeight / state.canvasHeight;
    const fitScale = Math.min(scaleX, scaleY, 1.0); // Don't auto zoom > 100%

    setZoom(fitScale);
  }

  function setZoom(scale) {
    // Clamp zoom level between 10% and 500%
    const clampedScale = Math.min(Math.max(scale, 0.1), 5.0);
    state.zoomLevel = clampedScale;

    const shadowContainer = document.getElementById('canvas-shadow-container');
    if (shadowContainer) {
      shadowContainer.style.width = `${state.canvasWidth * clampedScale}px`;
      shadowContainer.style.height = `${state.canvasHeight * clampedScale}px`;
    }

    state.canvas.setDimensions({
      width: state.canvasWidth * clampedScale,
      height: state.canvasHeight * clampedScale
    });

    state.canvas.setZoom(clampedScale);
    state.canvas.renderAll();

    // Update UI Zoom Percentage Display
    const zoomText = document.getElementById('zoom-percentage');
    if (zoomText) {
      zoomText.textContent = `${Math.round(clampedScale * 100)}%`;
    }
  }

  // History Engine (Undo / Redo)
  function saveState() {
    if (state.isModifyingState) return;

    const jsonState = JSON.stringify(state.canvas.toJSON([
      'id', 'selectable', 'hasControls', 'lockMovementX', 'lockMovementY'
    ]));

    // Avoid pushing duplicate consecutive states
    if (state.historyStack.length > 0 && state.historyStack[state.historyStack.length - 1] === jsonState) {
      return;
    }

    state.historyStack.push(jsonState);
    if (state.historyStack.length > state.maxHistorySize) {
      state.historyStack.shift();
    }

    // Clear redo stack on new action
    state.redoStack = [];

    updateUndoRedoButtons();
    updateLayersList();
  }

  function undo() {
    if (state.historyStack.length <= 1) return;

    state.isModifyingState = true;
    const currentState = state.historyStack.pop();
    state.redoStack.push(currentState);

    const previousState = state.historyStack[state.historyStack.length - 1];
    state.canvas.loadFromJSON(previousState, () => {
      state.canvas.renderAll();
      state.isModifyingState = false;
      updateUndoRedoButtons();
      updateLayersList();
      updateContextualToolbar();
    });
  }

  function redo() {
    if (state.redoStack.length === 0) return;

    state.isModifyingState = true;
    const nextState = state.redoStack.pop();
    state.historyStack.push(nextState);

    state.canvas.loadFromJSON(nextState, () => {
      state.canvas.renderAll();
      state.isModifyingState = false;
      updateUndoRedoButtons();
      updateLayersList();
      updateContextualToolbar();
    });
  }

  function updateUndoRedoButtons() {
    const btnUndo = document.getElementById('btn-undo');
    const btnRedo = document.getElementById('btn-redo');

    if (btnUndo) btnUndo.disabled = state.historyStack.length <= 1;
    if (btnRedo) btnRedo.disabled = state.redoStack.length === 0;
  }

  // Canvas Interactions Event Handling
  function setupCanvasEvents() {
    state.canvas.on('object:added', () => {
      saveState();
    });

    state.canvas.on('object:modified', () => {
      saveState();
    });

    state.canvas.on('object:removed', () => {
      saveState();
    });

    state.canvas.on('selection:created', (e) => {
      state.selectedObject = e.selected ? e.selected[0] : null;
      updateContextualToolbar();
      updateLayersListHighlight();
    });

    state.canvas.on('selection:updated', (e) => {
      state.selectedObject = e.selected ? e.selected[0] : null;
      updateContextualToolbar();
      updateLayersListHighlight();
    });

    state.canvas.on('selection:cleared', () => {
      state.selectedObject = null;
      updateContextualToolbar();
      updateLayersListHighlight();
    });
  }

  // Clear All
  function clearAllCanvas() {
    if (confirm('Are you sure you want to clear the entire canvas? This action can be undone.')) {
      state.canvas.clear();
      state.canvas.setBackgroundColor('#ffffff', state.canvas.renderAll.bind(state.canvas));
      saveState();
    }
  }

  // Zoom Controls Event Listeners
  document.getElementById('btn-zoom-in')?.addEventListener('click', () => {
    setZoom(state.zoomLevel + 0.1);
  });

  document.getElementById('btn-zoom-out')?.addEventListener('click', () => {
    setZoom(state.zoomLevel - 0.1);
  });

  document.getElementById('btn-zoom-reset')?.addEventListener('click', () => {
    setZoom(1.0);
  });

  document.getElementById('btn-zoom-fit')?.addEventListener('click', () => {
    fitCanvasToViewport();
  });

  // Top Nav Actions
  document.getElementById('btn-undo')?.addEventListener('click', undo);
  document.getElementById('btn-redo')?.addEventListener('click', redo);
  document.getElementById('btn-clear-all')?.addEventListener('click', clearAllCanvas);

  // Keyboard Shortcuts (Ctrl+Z, Ctrl+Y, Delete)
  window.addEventListener('keydown', (e) => {
    const activeElem = document.activeElement;
    if (activeElem && (activeElem.tagName === 'INPUT' || activeElem.tagName === 'TEXTAREA' || activeElem.isContentEditable)) {
      return; // Ignore inside input fields
    }

    if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'z') {
      if (e.shiftKey) {
        redo();
      } else {
        undo();
      }
      e.preventDefault();
    } else if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'y') {
      redo();
      e.preventDefault();
    } else if (e.key === 'Delete' || e.key === 'Backspace') {
      const activeObj = state.canvas.getActiveObject();
      if (activeObj && !activeObj.isEditing) {
        state.canvas.remove(activeObj);
        state.canvas.discardActiveObject();
        state.canvas.renderAll();
        e.preventDefault();
      }
    }
  });

  // Window Resize Auto-fit
  window.addEventListener('resize', () => {
    fitCanvasToViewport();
  });

  // Expose global app object for module access
  window.MSstudio = {
    state,
    setZoom,
    fitCanvasToViewport,
    saveState,
    undo,
    redo,
    clearAllCanvas
  };

  // Launch Canvas Engine
  initCanvas();
});

// Helper stubs for layer/toolbar updates (implemented in subsequent modules)
function updateLayersList() {
  if (window.MSstudioPanels && window.MSstudioPanels.renderLayersList) {
    window.MSstudioPanels.renderLayersList();
  }
}

function updateLayersListHighlight() {
  if (window.MSstudioPanels && window.MSstudioPanels.highlightActiveLayer) {
    window.MSstudioPanels.highlightActiveLayer();
  }
}

function updateContextualToolbar() {
  if (window.MSstudioToolbar && window.MSstudioToolbar.updateToolbar) {
    window.MSstudioToolbar.updateToolbar();
  }
}
