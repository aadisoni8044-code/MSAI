import { Transform, Rigidbody, Collider } from './Components.js';

/**
 * PhysicsSystem - Manages collision detection (AABB vs AABB, Circle vs Circle, AABB vs Circle)
 * and impulse physical response/resolution.
 */
export class PhysicsSystem {
  constructor() {
    this.gravity = { x: 0, y: 0 };
  }

  /**
   * Run collision checks across all physics-enabled entities.
   * @param {import('./Entity.js').Entity[]} entities
   */
  update(entities) {
    // Filter active entities with Transform and Collider components
    const collidables = entities.filter(
      (e) => e.active && e.hasComponent(Transform) && e.hasComponent(Collider)
    );

    for (let i = 0; i < collidables.length; i++) {
      for (let j = i + 1; j < collidables.length; j++) {
        const entityA = collidables[i];
        const entityB = collidables[j];

        const colliderA = entityA.getComponent(Collider);
        const colliderB = entityB.getComponent(Collider);

        if (!colliderA.enabled || !colliderB.enabled) continue;

        const collision = this.checkCollision(entityA, colliderA, entityB, colliderB);

        if (collision.collided) {
          // Trigger callbacks on both colliders if present
          if (typeof colliderA.onCollision === 'function') {
            colliderA.onCollision(entityB, collision);
          }
          if (typeof colliderB.onCollision === 'function') {
            colliderB.onCollision(entityA, { ...collision, normalX: -collision.normalX, normalY: -collision.normalY });
          }

          // If neither collider is a trigger, resolve physical separation
          if (!colliderA.isTrigger && !colliderB.isTrigger) {
            this.resolveCollision(entityA, entityB, collision);
          }
        }
      }
    }
  }

  /**
   * Collision detection dispatcher.
   */
  checkCollision(entityA, colliderA, entityB, colliderB) {
    if (colliderA.type === 'box' && colliderB.type === 'box') {
      return this.checkAABBVsAABB(entityA, colliderA, entityB, colliderB);
    } else if (colliderA.type === 'circle' && colliderB.type === 'circle') {
      return this.checkCircleVsCircle(entityA, colliderA, entityB, colliderB);
    } else if (colliderA.type === 'box' && colliderB.type === 'circle') {
      return this.checkAABBVsCircle(entityA, colliderA, entityB, colliderB);
    } else if (colliderA.type === 'circle' && colliderB.type === 'box') {
      const res = this.checkAABBVsCircle(entityB, colliderB, entityA, colliderA);
      return {
        ...res,
        normalX: -res.normalX,
        normalY: -res.normalY
      };
    }

    return { collided: false, overlapX: 0, overlapY: 0, normalX: 0, normalY: 0, depth: 0 };
  }

  /**
   * AABB vs AABB collision detection.
   */
  checkAABBVsAABB(entityA, colliderA, entityB, colliderB) {
    const boxA = colliderA.getAABB();
    const boxB = colliderB.getAABB();

    const overlapX = Math.min(boxA.right, boxB.right) - Math.max(boxA.left, boxB.left);
    const overlapY = Math.min(boxA.bottom, boxB.bottom) - Math.max(boxA.top, boxB.top);

    if (overlapX > 0 && overlapY > 0) {
      const centerA = colliderA.getCenterPosition();
      const centerB = colliderB.getCenterPosition();

      let normalX = 0;
      let normalY = 0;
      let depth = 0;

      // Minimum translation vector direction
      if (overlapX < overlapY) {
        depth = overlapX;
        normalX = centerA.x < centerB.x ? -1 : 1;
      } else {
        depth = overlapY;
        normalY = centerA.y < centerB.y ? -1 : 1;
      }

      return { collided: true, overlapX, overlapY, normalX, normalY, depth };
    }

    return { collided: false, overlapX: 0, overlapY: 0, normalX: 0, normalY: 0, depth: 0 };
  }

  /**
   * Circle vs Circle collision detection.
   */
  checkCircleVsCircle(entityA, colliderA, entityB, colliderB) {
    const centerA = colliderA.getCenterPosition();
    const centerB = colliderB.getCenterPosition();

    const dx = centerB.x - centerA.x;
    const dy = centerB.y - centerA.y;
    const distSq = dx * dx + dy * dy;
    const radiusSum = colliderA.radius + colliderB.radius;

    if (distSq < radiusSum * radiusSum) {
      const dist = Math.sqrt(distSq) || 0.0001;
      const depth = radiusSum - dist;
      const normalX = -dx / dist;
      const normalY = -dy / dist;

      return { collided: true, overlapX: depth, overlapY: depth, normalX, normalY, depth };
    }

    return { collided: false, overlapX: 0, overlapY: 0, normalX: 0, normalY: 0, depth: 0 };
  }

  /**
   * AABB vs Circle collision detection.
   */
  checkAABBVsCircle(entityBox, colliderBox, entityCircle, colliderCircle) {
    const box = colliderBox.getAABB();
    const circleCenter = colliderCircle.getCenterPosition();

    // Find closest point on AABB to circle center
    const closestX = Math.max(box.left, Math.min(circleCenter.x, box.right));
    const closestY = Math.max(box.top, Math.min(circleCenter.y, box.bottom));

    const dx = circleCenter.x - closestX;
    const dy = circleCenter.y - closestY;
    const distSq = dx * dx + dy * dy;

    if (distSq < colliderCircle.radius * colliderCircle.radius) {
      const dist = Math.sqrt(distSq);
      let normalX = 0;
      let normalY = 0;
      let depth = 0;

      if (dist === 0) {
        // Circle center is inside the box
        const centerBox = colliderBox.getCenterPosition();
        const offsetX = circleCenter.x - centerBox.x;
        const offsetY = circleCenter.y - centerBox.y;
        if (Math.abs(offsetX) > Math.abs(offsetY)) {
          normalX = offsetX > 0 ? 1 : -1;
          depth = colliderCircle.radius + (box.width / 2) - Math.abs(offsetX);
        } else {
          normalY = offsetY > 0 ? 1 : -1;
          depth = colliderCircle.radius + (box.height / 2) - Math.abs(offsetY);
        }
      } else {
        depth = colliderCircle.radius - dist;
        normalX = dx / dist; // Vector pointing from Box towards Circle
        normalY = dy / dist;
      }

      return { collided: true, overlapX: depth, overlapY: depth, normalX: -normalX, normalY: -normalY, depth };
    }

    return { collided: false, overlapX: 0, overlapY: 0, normalX: 0, normalY: 0, depth: 0 };
  }

  /**
   * Physical collision resolution (positional correction and velocity response).
   */
  resolveCollision(entityA, entityB, collision) {
    const transformA = entityA.getComponent(Transform);
    const transformB = entityB.getComponent(Transform);

    const rbA = entityA.getComponent(Rigidbody);
    const rbB = entityB.getComponent(Rigidbody);

    const isStaticA = !rbA || rbA.isStatic;
    const isStaticB = !rbB || rbB.isStatic;

    if (isStaticA && isStaticB) return;

    // Positional separation correction
    const normalX = collision.normalX;
    const normalY = collision.normalY;
    const depth = collision.depth;

    if (!isStaticA && isStaticB) {
      transformA.x += normalX * depth;
      transformA.y += normalY * depth;
    } else if (isStaticA && !isStaticB) {
      transformB.x -= normalX * depth;
      transformB.y -= normalY * depth;
    } else {
      // Both dynamic - separate based on mass
      const massA = rbA.mass || 1;
      const massB = rbB.mass || 1;
      const totalMass = massA + massB;

      transformA.x += normalX * depth * (massB / totalMass);
      transformA.y += normalY * depth * (massB / totalMass);

      transformB.x -= normalX * depth * (massA / totalMass);
      transformB.y -= normalY * depth * (massA / totalMass);
    }

    // Velocity response (Simple impulse elastic / in-elastic bounce)
    if (rbA && rbB) {
      const rvX = rbB.vx - rbA.vx;
      const rvY = rbB.vy - rbA.vy;

      const velAlongNormal = rvX * normalX + rvY * normalY;

      // Do not resolve if velocities are separating
      if (velAlongNormal > 0) return;

      const restitution = 0.2; // Bounciness
      let j = -(1 + restitution) * velAlongNormal;
      const invMassA = isStaticA ? 0 : 1 / rbA.mass;
      const invMassB = isStaticB ? 0 : 1 / rbB.mass;

      j /= (invMassA + invMassB || 1);

      const impulseX = j * normalX;
      const impulseY = j * normalY;

      if (!isStaticA) {
        rbA.vx -= invMassA * impulseX;
        rbA.vy -= invMassA * impulseY;
      }
      if (!isStaticB) {
        rbB.vx += invMassB * impulseX;
        rbB.vy += invMassB * impulseY;
      }
    }
  }
}
