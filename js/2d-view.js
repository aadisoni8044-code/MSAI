/**
 * NV ZIP — 2D Interactive AI Visualizer
 * Canvas rendering multi-mode diagrams: Neural Network, Token Flow, Transformer Blocks,
 * Attention Heatmap, and API Flow with clickable/hoverable interactive nodes.
 */

class Visualizer2D {
  constructor() {
    this.canvas = document.getElementById('canvas-2d');
    this.ctx = this.canvas ? this.canvas.getContext('2d') : null;
    this.buttons = document.querySelectorAll('.c2d-btn');
    this.tooltip = document.getElementById('c2d-tooltip');
    this.inspectorTitle = document.getElementById('c2d-inspector-title');
    this.inspectorBody = document.getElementById('c2d-inspector-body');

    this.currentMode = 'neural';
    this.nodes = [];
    this.animFrame = null;
    this.hoveredNode = null;

    this.init();
  }

  init() {
    if (!this.canvas || !this.ctx) return;

    this.resize();
    window.addEventListener('resize', () => this.resize());

    // Switch visual modes
    this.buttons.forEach(btn => {
      btn.addEventListener('click', (e) => {
        this.buttons.forEach(b => b.classList.remove('active'));
        e.currentTarget.classList.add('active');
        const mode = e.currentTarget.getAttribute('data-mode');
        if (mode) {
          this.currentMode = mode;
          this.buildScene();
        }
      });
    });

    // Mouse movement inspection
    this.canvas.addEventListener('mousemove', (e) => {
      const rect = this.canvas.getBoundingClientRect();
      const mx = e.clientX - rect.left;
      const my = e.clientY - rect.top;

      let found = null;
      for (const node of this.nodes) {
        const dx = mx - node.x;
        const dy = my - node.y;
        if (Math.sqrt(dx * dx + dy * dy) < (node.radius || 15)) {
          found = node;
          break;
        }
      }

      this.hoveredNode = found;

      if (found && this.tooltip) {
        this.tooltip.classList.remove('hidden');
        this.tooltip.style.left = `${mx + 15}px`;
        this.tooltip.style.top = `${my + 15}px`;
        this.tooltip.textContent = `${found.label}: ${found.desc || 'Active Node'}`;

        if (this.inspectorTitle) this.inspectorTitle.textContent = found.label;
        if (this.inspectorBody) this.inspectorBody.textContent = found.details || found.desc || 'Interactive AI Canvas Node';
      } else if (this.tooltip) {
        this.tooltip.classList.add('hidden');
      }
    });

    this.buildScene();
    this.animate();
  }

  resize() {
    if (!this.canvas) return;
    const parent = this.canvas.parentElement;
    this.canvas.width = parent.clientWidth || 800;
    this.canvas.height = parent.clientHeight || 420;
    this.buildScene();
  }

  buildScene() {
    this.nodes = [];
    const w = this.canvas.width;
    const h = this.canvas.height;

    if (this.currentMode === 'neural') {
      // 3-layer neural network
      const layers = [4, 6, 3];
      const colSpacing = w / (layers.length + 1);

      layers.forEach((count, colIdx) => {
        const rowSpacing = h / (count + 1);
        for (let i = 0; i < count; i++) {
          this.nodes.push({
            x: colSpacing * (colIdx + 1),
            y: rowSpacing * (i + 1),
            radius: 16,
            layer: colIdx,
            label: colIdx === 0 ? `Input Neuron ${i+1}` : colIdx === 1 ? `Hidden Neuron ${i+1}` : `Output Neuron ${i+1}`,
            desc: `Activation value: ${(Math.random()).toFixed(2)}`,
            details: `Neuron in Layer ${colIdx + 1}. Weight sum calculation: z = Wx + b. Activation function: SwiGLU / GELU.`,
            color: colIdx === 0 ? '#38bdf8' : colIdx === 1 ? '#a855f7' : '#10b981'
          });
        }
      });
    } else if (this.currentMode === 'tokens') {
      // Horizontal token pipeline
      const words = ["Prompt", "Tokenizer", "Vocabulary ID", "Vector", "Prediction"];
      const spacing = w / (words.length + 1);
      words.forEach((wName, idx) => {
        this.nodes.push({
          x: spacing * (idx + 1),
          y: h / 2,
          radius: 24,
          label: wName,
          desc: `Stage ${idx + 1} of Token Processing`,
          details: `Transforms raw inputs into discrete IDs and maps them to continuous vector dimensions.`,
          color: '#38bdf8'
        });
      });
    } else if (this.currentMode === 'transformer') {
      // Transformer blocks
      const blocks = ["Input Embeddings", "Multi-Head Attention", "Feed-Forward Net", "Softmax Probabilities"];
      const spacing = w / (blocks.length + 1);
      blocks.forEach((bName, idx) => {
        this.nodes.push({
          x: spacing * (idx + 1),
          y: h / 2,
          radius: 28,
          label: bName,
          desc: `Transformer Core Block ${idx + 1}`,
          details: `Executes parallel self-attention and non-linear weight matrix projections.`,
          color: '#a855f7'
        });
      });
    } else if (this.currentMode === 'heatmap') {
      // 4x4 Grid
      for (let r = 0; r < 4; r++) {
        for (let c = 0; c < 4; c++) {
          this.nodes.push({
            x: w / 2 - 120 + c * 80,
            y: h / 2 - 120 + r * 80,
            radius: 20,
            label: `Token (${r}, ${c})`,
            desc: `Attention Score: ${(Math.random()).toFixed(2)}`,
            details: `Attention weight score measuring contextual relationship between position ${r} and position ${c}.`,
            color: r === c ? '#ec4899' : '#6366f1'
          });
        }
      }
    } else if (this.currentMode === 'api') {
      // API nodes
      const apiNodes = ["Your App", "API Gateway", "GPU Server Cluster", "JSON Output"];
      const spacing = w / (apiNodes.length + 1);
      apiNodes.forEach((aName, idx) => {
        this.nodes.push({
          x: spacing * (idx + 1),
          y: h / 2,
          radius: 22,
          label: aName,
          desc: `API Endpoint Step ${idx + 1}`,
          details: `Handles HTTPS request formatting, rate limiting, and inference token streaming.`,
          color: '#10b981'
        });
      });
    }
  }

  animate() {
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

    // Draw connections between nodes
    for (let i = 0; i < this.nodes.length; i++) {
      for (let j = i + 1; j < this.nodes.length; j++) {
        const n1 = this.nodes[i];
        const n2 = this.nodes[j];

        if (this.currentMode === 'neural' && n2.layer === n1.layer + 1) {
          this.ctx.beginPath();
          this.ctx.moveTo(n1.x, n1.y);
          this.ctx.lineTo(n2.x, n2.y);
          this.ctx.strokeStyle = 'rgba(255, 255, 255, 0.12)';
          this.ctx.lineWidth = 1;
          this.ctx.stroke();
        } else if (this.currentMode !== 'neural' && this.currentMode !== 'heatmap' && j === i + 1) {
          this.ctx.beginPath();
          this.ctx.moveTo(n1.x, n1.y);
          this.ctx.lineTo(n2.x, n2.y);
          this.ctx.strokeStyle = 'rgba(56, 189, 248, 0.3)';
          this.ctx.lineWidth = 2;
          this.ctx.stroke();
        }
      }
    }

    // Draw nodes
    this.nodes.forEach(node => {
      const isHovered = this.hoveredNode === node;
      this.ctx.beginPath();
      this.ctx.arc(node.x, node.y, node.radius + (isHovered ? 4 : 0), 0, Math.PI * 2);
      this.ctx.fillStyle = node.color || '#38bdf8';
      this.ctx.fill();

      this.ctx.lineWidth = isHovered ? 3 : 1;
      this.ctx.strokeStyle = '#ffffff';
      this.ctx.stroke();

      // Label text
      this.ctx.fillStyle = '#ffffff';
      this.ctx.font = '12px "Plus Jakarta Sans", sans-serif';
      this.ctx.textAlign = 'center';
      this.ctx.fillText(node.label, node.x, node.y + node.radius + 18);
    });

    this.animFrame = requestAnimationFrame(() => this.animate());
  }
}

document.addEventListener('DOMContentLoaded', () => {
  window.visualizer2D = new Visualizer2D();
});
