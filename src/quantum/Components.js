/**
 * Base Component class and core Engine components:
 * Transform, Sprite, Mesh, Rigidbody, Collider, Script.
 */

export class Component {
  constructor() {
    /** @type {import('./Entity.js').Entity|null} */
    this.entity = null;
    this.enabled = true;
  }

  onAttach() {}
  onDetach() {}
  update(dt) {}
  render(ctx, alpha = 1) {}
}

/**
 * Transform Component - Position, Rotation, Scale, and Dimensions.
 */
export class Transform extends Component {
  constructor({ x = 0, y = 0, rotation = 0, scaleX = 1, scaleY = 1, width = 32, height = 32 } = {}) {
    super();
    this.x = x;
    this.y = y;
    this.prevX = x;
    this.prevY = y;
    this.rotation = rotation; // in radians
    this.scaleX = scaleX;
    this.scaleY = scaleY;
    this.width = width;
    this.height = height;
  }

  setPosition(x, y) {
    this.prevX = this.x;
    this.prevY = this.y;
    this.x = x;
    this.y = y;
  }

  getInterpolatedPosition(alpha) {
    return {
      x: this.prevX + (this.x - this.prevX) * alpha,
      y: this.prevY + (this.y - this.prevY) * alpha
    };
  }
}

/**
 * Sprite Component - Visual rendering using images, sprite sheets, or solid shapes.
 */
export class Sprite extends Component {
  constructor({
    image = null,
    color = '#ffffff',
    shape = 'rectangle', // 'rectangle' | 'circle'
    radius = 16,
    frameX = 0,
    frameY = 0,
    frameWidth = 32,
    frameHeight = 32,
    anchorX = 0.5,
    anchorY = 0.5
  } = {}) {
    super();
    this.image = image;
    this.color = color;
    this.shape = shape;
    this.radius = radius;
    this.frameX = frameX;
    this.frameY = frameY;
    this.frameWidth = frameWidth;
    this.frameHeight = frameHeight;
    this.anchorX = anchorX;
    this.anchorY = anchorY;
  }

  render(ctx, alpha = 1) {
    const transform = this.entity ? this.entity.getComponent(Transform) : null;
    if (!transform) return;

    const pos = transform.getInterpolatedPosition(alpha);

    ctx.save();
    ctx.translate(pos.x, pos.y);
    if (transform.rotation !== 0) {
      ctx.rotate(transform.rotation);
    }
    ctx.scale(transform.scaleX, transform.scaleY);

    if (this.image) {
      const dw = transform.width;
      const dh = transform.height;
      const dx = -dw * this.anchorX;
      const dy = -dh * this.anchorY;

      ctx.drawImage(
        this.image,
        this.frameX, this.frameY, this.frameWidth, this.frameHeight,
        dx, dy, dw, dh
      );
    } else {
      ctx.fillStyle = this.color;
      if (this.shape === 'circle') {
        ctx.beginPath();
        ctx.arc(0, 0, this.radius, 0, Math.PI * 2);
        ctx.fill();
        ctx.strokeStyle = 'rgba(255,255,255,0.3)';
        ctx.lineWidth = 2;
        ctx.stroke();
      } else {
        const dw = transform.width;
        const dh = transform.height;
        const dx = -dw * this.anchorX;
        const dy = -dh * this.anchorY;

        ctx.fillRect(dx, dy, dw, dh);
        ctx.strokeStyle = 'rgba(255,255,255,0.2)';
        ctx.lineWidth = 2;
        ctx.strokeRect(dx, dy, dw, dh);
      }
    }

    ctx.restore();
  }
}

/**
 * Rigidbody Component - 2D physics properties (velocity, acceleration, mass, friction, gravity).
 */
export class Rigidbody extends Component {
  constructor({
    vx = 0,
    vy = 0,
    mass = 1,
    drag = 0.9,
    useGravity = false,
    gravity = 980,
    isStatic = false
  } = {}) {
    super();
    this.vx = vx;
    this.vy = vy;
    this.ax = 0;
    this.ay = 0;
    this.mass = mass;
    this.drag = drag;
    this.useGravity = useGravity;
    this.gravity = gravity;
    this.isStatic = isStatic;
  }

  applyForce(fx, fy) {
    if (this.isStatic || this.mass === 0) return;
    this.ax += fx / this.mass;
    this.ay += fy / this.mass;
  }

  update(dt) {
    if (this.isStatic) return;

    const transform = this.entity ? this.entity.getComponent(Transform) : null;
    if (!transform) return;

    if (this.useGravity) {
      this.ay += this.gravity;
    }

    // Integrate acceleration
    this.vx += this.ax * dt;
    this.vy += this.ay * dt;

    // Apply linear drag
    this.vx *= Math.pow(this.drag, dt * 60);
    this.vy *= Math.pow(this.drag, dt * 60);

    // Save previous position for interpolation
    transform.prevX = transform.x;
    transform.prevY = transform.y;

    // Integrate velocity
    transform.x += this.vx * dt;
    transform.y += this.vy * dt;

    // Reset acceleration for next frame
    this.ax = 0;
    this.ay = 0;
  }
}

/**
 * Collider Component - Defines physical bounding box or circle for collision detection.
 */
export class Collider extends Component {
  constructor({
    type = 'box', // 'box' | 'circle'
    width = 32,
    height = 32,
    radius = 16,
    isTrigger = false,
    offsetX = 0,
    offsetY = 0,
    onCollision = null
  } = {}) {
    super();
    this.type = type;
    this.width = width;
    this.height = height;
    this.radius = radius;
    this.isTrigger = isTrigger; // Triggers detect overlap without physical response
    this.offsetX = offsetX;
    this.offsetY = offsetY;
    this.onCollision = onCollision;
  }

  /**
   * Get world space center position.
   */
  getCenterPosition() {
    const transform = this.entity ? this.entity.getComponent(Transform) : null;
    if (!transform) return { x: 0, y: 0 };
    return {
      x: transform.x + this.offsetX,
      y: transform.y + this.offsetY
    };
  }

  /**
   * Get Axis-Aligned Bounding Box (AABB) bounds.
   */
  getAABB() {
    const center = this.getCenterPosition();
    const transform = this.entity ? this.entity.getComponent(Transform) : null;
    const w = this.type === 'box' ? (transform ? transform.width : this.width) : this.radius * 2;
    const h = this.type === 'box' ? (transform ? transform.height : this.height) : this.radius * 2;

    return {
      left: center.x - w / 2,
      right: center.x + w / 2,
      top: center.y - h / 2,
      bottom: center.y + h / 2,
      width: w,
      height: h
    };
  }
}

/**
 * Script Component - Allows attaching custom logic scripts to entities.
 */
export class Script extends Component {
  constructor(updateCallback = null) {
    super();
    this.updateCallback = updateCallback;
  }

  update(dt) {
    if (this.updateCallback) {
      this.updateCallback.call(this, dt);
    }
  }
}
