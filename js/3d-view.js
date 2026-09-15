/**
 * NV ZIP — 3D WebGL Visualizer (Three.js)
 * Implements 3D floating neural topologies, rotating transformer cube architecture,
 * and 3D token particle streams with orbit controls and fallback detection.
 */

class Visualizer3D {
  constructor() {
    this.container = document.getElementById('canvas3d-container');
    this.fallbackMsg = document.getElementById('c3d-fallback-msg');
    this.modeNeuralBtn = document.getElementById('c3d-mode-neural');
    this.modeCubeBtn = document.getElementById('c3d-mode-cube');
    this.modeParticlesBtn = document.getElementById('c3d-mode-particles');
    this.toggleRotateBtn = document.getElementById('c3d-toggle-rotate');
    this.resetCamBtn = document.getElementById('c3d-reset-cam');

    this.scene = null;
    this.camera = null;
    this.renderer = null;
    this.mainGroup = null;
    this.currentMode = 'neural';
    this.autoRotate = true;
    this.animFrameId = null;

    this.isDragging = false;
    this.previousMousePosition = { x: 0, y: 0 };

    this.init();
  }

  init() {
    if (!this.container) return;

    if (typeof THREE === 'undefined') {
      this.showFallback("Three.js library failed to load.");
      return;
    }

    try {
      this.setupThree();
      this.setupControls();
      this.buildCurrentScene();
      this.animate();
    } catch (e) {
      console.warn("WebGL initialization failed:", e);
      this.showFallback("3D WebGL context not supported on this device.");
    }
  }

  showFallback(msg) {
    if (this.fallbackMsg) {
      this.fallbackMsg.classList.remove('hidden');
      this.fallbackMsg.querySelector('span').textContent = msg;
    }
  }

  setupThree() {
    const width = this.container.clientWidth || 800;
    const height = this.container.clientHeight || 480;

    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x020617);

    this.camera = new THREE.PerspectiveCamera(60, width / height, 0.1, 1000);
    this.camera.position.set(0, 0, 40);

    this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    this.renderer.setSize(width, height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.container.appendChild(this.renderer.domElement);

    // Ambient & Point Lighting
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
    this.scene.add(ambientLight);

    const cyanLight = new THREE.PointLight(0x38bdf8, 2, 100);
    cyanLight.position.set(20, 20, 20);
    this.scene.add(cyanLight);

    const purpleLight = new THREE.PointLight(0xa855f7, 2, 100);
    purpleLight.position.set(-20, -20, 20);
    this.scene.add(purpleLight);

    this.mainGroup = new THREE.Group();
    this.scene.add(this.mainGroup);

    // Mouse Orbit Listener
    const dom = this.renderer.domElement;
    dom.addEventListener('mousedown', (e) => {
      this.isDragging = true;
      this.previousMousePosition = { x: e.clientX, y: e.clientY };
    });

    window.addEventListener('mousemove', (e) => {
      if (!this.isDragging || !this.mainGroup) return;
      const deltaX = e.clientX - this.previousMousePosition.x;
      const deltaY = e.clientY - this.previousMousePosition.y;

      this.mainGroup.rotation.y += deltaX * 0.005;
      this.mainGroup.rotation.x += deltaY * 0.005;

      this.previousMousePosition = { x: e.clientX, y: e.clientY };
    });

    window.addEventListener('mouseup', () => { this.isDragging = false; });

    window.addEventListener('resize', () => {
      if (!this.container || !this.renderer || !this.camera) return;
      const w = this.container.clientWidth;
      const h = this.container.clientHeight;
      this.camera.aspect = w / h;
      this.camera.updateProjectionMatrix();
      this.renderer.setSize(w, h);
    });
  }

  setupControls() {
    if (this.modeNeuralBtn) {
      this.modeNeuralBtn.addEventListener('click', () => {
        this.currentMode = 'neural';
        this.updateModeBtn(this.modeNeuralBtn);
        this.buildCurrentScene();
      });
    }

    if (this.modeCubeBtn) {
      this.modeCubeBtn.addEventListener('click', () => {
        this.currentMode = 'cube';
        this.updateModeBtn(this.modeCubeBtn);
        this.buildCurrentScene();
      });
    }

    if (this.modeParticlesBtn) {
      this.modeParticlesBtn.addEventListener('click', () => {
        this.currentMode = 'particles';
        this.updateModeBtn(this.modeParticlesBtn);
        this.buildCurrentScene();
      });
    }

    if (this.toggleRotateBtn) {
      this.toggleRotateBtn.addEventListener('click', () => {
        this.autoRotate = !this.autoRotate;
        this.toggleRotateBtn.textContent = this.autoRotate ? '🔄 Pause Rotate' : '▶ Auto Rotate';
      });
    }

    if (this.resetCamBtn) {
      this.resetCamBtn.addEventListener('click', () => {
        if (this.mainGroup) {
          this.mainGroup.rotation.set(0, 0, 0);
        }
        if (this.camera) {
          this.camera.position.set(0, 0, 40);
        }
      });
    }
  }

  updateModeBtn(activeBtn) {
    [this.modeNeuralBtn, this.modeCubeBtn, this.modeParticlesBtn].forEach(btn => {
      if (btn) btn.classList.remove('active');
    });
    if (activeBtn) activeBtn.classList.add('active');
  }

  clearGroup() {
    while (this.mainGroup.children.length > 0) {
      const obj = this.mainGroup.children[0];
      this.mainGroup.remove(obj);
      if (obj.geometry) obj.geometry.dispose();
      if (obj.material) {
        if (Array.isArray(obj.material)) obj.material.forEach(m => m.dispose());
        else obj.material.dispose();
      }
    }
  }

  buildCurrentScene() {
    this.clearGroup();

    if (this.currentMode === 'neural') {
      this.buildNeuralWeb();
    } else if (this.currentMode === 'cube') {
      this.buildTransformerCube();
    } else if (this.currentMode === 'particles') {
      this.buildParticleStream();
    }
  }

  buildNeuralWeb() {
    const numNodes = 40;
    const geometry = new THREE.SphereGeometry(0.8, 16, 16);
    const cyanMat = new THREE.MeshPhongMaterial({ color: 0x38bdf8, emissive: 0x1e3a8a, shininess: 100 });
    const purpleMat = new THREE.MeshPhongMaterial({ color: 0xa855f7, emissive: 0x581c87, shininess: 100 });

    const positions = [];

    for (let i = 0; i < numNodes; i++) {
      const mesh = new THREE.Mesh(geometry, i % 2 === 0 ? cyanMat : purpleMat);
      const x = (Math.random() - 0.5) * 30;
      const y = (Math.random() - 0.5) * 30;
      const z = (Math.random() - 0.5) * 30;
      mesh.position.set(x, y, z);
      this.mainGroup.add(mesh);
      positions.push(new THREE.Vector3(x, y, z));
    }

    // Connect close nodes with line beams
    const lineMat = new THREE.LineBasicMaterial({ color: 0x6366f1, transparent: true, opacity: 0.35 });
    for (let i = 0; i < positions.length; i++) {
      for (let j = i + 1; j < positions.length; j++) {
        if (positions[i].distanceTo(positions[j]) < 12) {
          const lineGeo = new THREE.BufferGeometry().setFromPoints([positions[i], positions[j]]);
          const line = new THREE.Line(lineGeo, lineMat);
          this.mainGroup.add(line);
        }
      }
    }
  }

  buildTransformerCube() {
    const boxGeo = new THREE.BoxGeometry(16, 16, 16);
    const wireMat = new THREE.MeshPhongMaterial({ color: 0xa855f7, wireframe: true });
    const cube = new THREE.Mesh(boxGeo, wireMat);
    this.mainGroup.add(cube);

    const innerGeo = new THREE.SphereGeometry(6, 32, 32);
    const innerMat = new THREE.MeshPhongMaterial({ color: 0x38bdf8, emissive: 0x0284c7, shininess: 80 });
    const innerSphere = new THREE.Mesh(innerGeo, innerMat);
    this.mainGroup.add(innerSphere);
  }

  buildParticleStream() {
    const particleCount = 800;
    const geometry = new THREE.BufferGeometry();
    const positions = new Float32Array(particleCount * 3);

    for (let i = 0; i < particleCount * 3; i += 3) {
      positions[i] = (Math.random() - 0.5) * 50;
      positions[i + 1] = (Math.random() - 0.5) * 50;
      positions[i + 2] = (Math.random() - 0.5) * 50;
    }

    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    const material = new THREE.PointsMaterial({ color: 0x38bdf8, size: 0.6, transparent: true, opacity: 0.8 });
    const particles = new THREE.Points(geometry, material);
    this.mainGroup.add(particles);
  }

  animate() {
    if (this.renderer && this.scene && this.camera) {
      if (this.autoRotate && this.mainGroup && !this.isDragging) {
        this.mainGroup.rotation.y += 0.005;
        this.mainGroup.rotation.x += 0.002;
      }
      this.renderer.render(this.scene, this.camera);
    }
    this.animFrameId = requestAnimationFrame(() => this.animate());
  }
}

document.addEventListener('DOMContentLoaded', () => {
  window.visualizer3D = new Visualizer3D();
});
