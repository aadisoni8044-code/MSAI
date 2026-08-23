/**
 * Entity - Lightweight GameObject container holding attached components.
 */
let _entityIdCounter = 0;

export class Entity {
  /**
   * @param {string} [name='Entity']
   */
  constructor(name = 'Entity') {
    this.id = ++_entityIdCounter;
    this.name = name;
    this.active = true;
    this.layer = 'gameplay'; // 'background' | 'gameplay' | 'ui'
    this.zIndex = 0;
    this.tags = new Set();
    this.components = new Map();
  }

  /**
   * Attach a component instance to this entity.
   * @param {Component} component
   * @returns {Entity} returns self for chaining
   */
  addComponent(component) {
    component.entity = this;
    const typeName = component.constructor.name;
    this.components.set(typeName, component);
    if (typeof component.onAttach === 'function') {
      component.onAttach();
    }
    return this;
  }

  /**
   * Get component attached to this entity by Class or type name string.
   * @template T
   * @param {new (...args: any[]) => T | string} ComponentClassOrName
   * @returns {T|null}
   */
  getComponent(ComponentClassOrName) {
    const key = typeof ComponentClassOrName === 'string' ? ComponentClassOrName : ComponentClassOrName.name;
    return this.components.get(key) || null;
  }

  /**
   * Check if component exists on entity.
   */
  hasComponent(ComponentClassOrName) {
    return this.getComponent(ComponentClassOrName) !== null;
  }

  /**
   * Remove component from entity.
   */
  removeComponent(ComponentClassOrName) {
    const key = typeof ComponentClassOrName === 'string' ? ComponentClassOrName : ComponentClassOrName.name;
    const comp = this.components.get(key);
    if (comp) {
      if (typeof comp.onDetach === 'function') {
        comp.onDetach();
      }
      comp.entity = null;
      this.components.delete(key);
    }
  }

  addTag(tag) {
    this.tags.add(tag);
    return this;
  }

  hasTag(tag) {
    return this.tags.has(tag);
  }

  /**
   * Update lifecycle for attached components.
   */
  update(dt) {
    if (!this.active) return;
    for (const comp of this.components.values()) {
      if (comp.enabled && typeof comp.update === 'function') {
        comp.update(dt);
      }
    }
  }

  /**
   * Render lifecycle for components.
   */
  render(ctx, alpha = 1) {
    if (!this.active) return;
    for (const comp of this.components.values()) {
      if (comp.enabled && typeof comp.render === 'function') {
        comp.render(ctx, alpha);
      }
    }
  }
}
