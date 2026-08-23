import { ShapeSkin, RenderShapeType } from '../types';

/**
 * Draws any shape skin with its custom geometry, neon outline, inner detail, glow, and animations.
 * @param ctx 2D rendering context
 * @param skin Shape skin definition
 * @param size Base visual size (diameter/width)
 * @param time Animation time in seconds
 * @param isGameplay True if rendered inside gameplay canvas (where rotation angle might already be applied)
 */
export function drawShape(
  ctx: CanvasRenderingContext2D,
  skin: ShapeSkin,
  size: number = 34,
  time: number = 0,
  isGameplay: boolean = false
) {
  const half = size / 2;
  const renderType: RenderShapeType = skin.renderType;

  ctx.save();

  // Glow halo
  const glowGrad = ctx.createRadialGradient(0, 0, size * 0.1, 0, 0, size * 0.9);
  glowGrad.addColorStop(0, skin.color);
  glowGrad.addColorStop(0.5, skin.secondaryColor + '66');
  glowGrad.addColorStop(1, 'transparent');
  ctx.fillStyle = glowGrad;
  ctx.beginPath();
  ctx.arc(0, 0, size * 0.9, 0, Math.PI * 2);
  ctx.fill();

  // Setup main stroke and shadow
  ctx.shadowColor = skin.color;
  ctx.shadowBlur = isGameplay ? 12 : 16;
  ctx.lineWidth = 2.4;
  ctx.strokeStyle = '#ffffff';
  ctx.fillStyle = 'rgba(2, 6, 10, 0.92)';

  switch (renderType) {
    case 'arrow': {
      // Sleek chevron
      ctx.beginPath();
      ctx.moveTo(half, 0);
      ctx.lineTo(-half, -half * 0.75);
      ctx.lineTo(-half * 0.35, 0);
      ctx.lineTo(-half, half * 0.75);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Inner accent
      ctx.strokeStyle = skin.secondaryColor;
      ctx.lineWidth = 1.6;
      ctx.beginPath();
      ctx.moveTo(half * 0.4, 0);
      ctx.lineTo(-half * 0.25, -half * 0.35);
      ctx.lineTo(-half * 0.05, 0);
      ctx.lineTo(-half * 0.25, half * 0.35);
      ctx.closePath();
      ctx.stroke();
      break;
    }

    case 'triangle': {
      // Equilateral delta wing
      ctx.beginPath();
      ctx.moveTo(half, 0);
      ctx.lineTo(-half, -half * 0.85);
      ctx.lineTo(-half, half * 0.85);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Inner core diode
      ctx.fillStyle = skin.secondaryColor;
      ctx.beginPath();
      ctx.arc(-half * 0.15, 0, half * 0.25, 0, Math.PI * 2);
      ctx.fill();

      // Inner vector line
      ctx.strokeStyle = skin.secondaryColor;
      ctx.lineWidth = 1.5;
      ctx.beginPath();
      ctx.moveTo(half * 0.5, 0);
      ctx.lineTo(-half * 0.6, -half * 0.45);
      ctx.lineTo(-half * 0.6, half * 0.45);
      ctx.closePath();
      ctx.stroke();
      break;
    }

    case 'circle': {
      // Circular sphere
      ctx.beginPath();
      ctx.arc(0, 0, half * 0.75, 0, Math.PI * 2);
      ctx.fill();
      ctx.stroke();

      // Orbiting electron rings
      const rot = time * 2;
      ctx.save();
      ctx.rotate(rot);
      ctx.strokeStyle = skin.secondaryColor;
      ctx.lineWidth = 1.4;
      ctx.beginPath();
      ctx.ellipse(0, 0, half * 0.85, half * 0.35, 0, 0, Math.PI * 2);
      ctx.stroke();
      // Orbiting satellite dot
      ctx.fillStyle = '#ffffff';
      ctx.beginPath();
      ctx.arc(half * 0.85, 0, 3, 0, Math.PI * 2);
      ctx.fill();
      ctx.restore();

      // Center nucleus
      ctx.fillStyle = skin.color;
      ctx.beginPath();
      ctx.arc(0, 0, half * 0.3, 0, Math.PI * 2);
      ctx.fill();
      break;
    }

    case 'square': {
      // Tesseract Cube
      const s = half * 0.72;
      ctx.beginPath();
      ctx.rect(-s, -s, s * 2, s * 2);
      ctx.fill();
      ctx.stroke();

      // Internal cross matrix
      ctx.strokeStyle = skin.secondaryColor;
      ctx.lineWidth = 1.5;
      ctx.strokeRect(-s * 0.5, -s * 0.5, s, s);

      // Center glowing core
      ctx.fillStyle = skin.color;
      ctx.fillRect(-s * 0.2, -s * 0.2, s * 0.4, s * 0.4);
      break;
    }

    case 'rounded-square': {
      // Hyper Squircle with corner radius
      const s = half * 0.72;
      const r = s * 0.45;
      ctx.beginPath();
      ctx.roundRect(-s, -s, s * 2, s * 2, r);
      ctx.fill();
      ctx.stroke();

      // Pulsing diode in center
      const pulse = Math.sin(time * 4) * 0.15 + 1;
      ctx.fillStyle = skin.secondaryColor;
      ctx.beginPath();
      ctx.arc(0, 0, half * 0.28 * pulse, 0, Math.PI * 2);
      ctx.fill();
      break;
    }

    case 'rectangle': {
      // Aerodynamic streamline wedge
      const w = half * 0.95;
      const h = half * 0.55;
      ctx.beginPath();
      ctx.moveTo(w, 0);
      ctx.lineTo(-w * 0.8, -h);
      ctx.lineTo(-w, -h * 0.6);
      ctx.lineTo(-w, h * 0.6);
      ctx.lineTo(-w * 0.8, h);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Cockpit laser stripe
      ctx.strokeStyle = skin.secondaryColor;
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.moveTo(w * 0.5, 0);
      ctx.lineTo(-w * 0.4, 0);
      ctx.stroke();
      break;
    }

    case 'diamond': {
      // Prism Diamond
      ctx.beginPath();
      ctx.moveTo(half, 0);
      ctx.lineTo(0, -half * 0.8);
      ctx.lineTo(-half, 0);
      ctx.lineTo(0, half * 0.8);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Facet refraction lines
      ctx.strokeStyle = skin.secondaryColor;
      ctx.lineWidth = 1.4;
      ctx.beginPath();
      ctx.moveTo(half * 0.5, 0);
      ctx.lineTo(0, -half * 0.4);
      ctx.lineTo(-half * 0.5, 0);
      ctx.lineTo(0, half * 0.4);
      ctx.closePath();
      ctx.stroke();

      ctx.beginPath();
      ctx.moveTo(half, 0);
      ctx.lineTo(-half, 0);
      ctx.moveTo(0, -half * 0.8);
      ctx.lineTo(0, half * 0.8);
      ctx.stroke();
      break;
    }

    case 'hexagon': {
      // 6-sided Hex node
      const r = half * 0.78;
      ctx.beginPath();
      for (let i = 0; i < 6; i++) {
        const ang = (i * Math.PI) / 3;
        const px = Math.cos(ang) * r;
        const py = Math.sin(ang) * r;
        if (i === 0) ctx.moveTo(px, py);
        else ctx.lineTo(px, py);
      }
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Rotating inner hex
      ctx.save();
      ctx.rotate(time * 1.5);
      ctx.strokeStyle = skin.secondaryColor;
      ctx.lineWidth = 1.5;
      ctx.beginPath();
      for (let i = 0; i < 6; i++) {
        const ang = (i * Math.PI) / 3;
        const px = Math.cos(ang) * (r * 0.5);
        const py = Math.sin(ang) * (r * 0.5);
        if (i === 0) ctx.moveTo(px, py);
        else ctx.lineTo(px, py);
      }
      ctx.closePath();
      ctx.stroke();
      ctx.restore();
      break;
    }

    case 'octagon': {
      // 8-sided shield
      const r = half * 0.78;
      ctx.beginPath();
      for (let i = 0; i < 8; i++) {
        const ang = (i * Math.PI) / 4 + Math.PI / 8;
        const px = Math.cos(ang) * r;
        const py = Math.sin(ang) * r;
        if (i === 0) ctx.moveTo(px, py);
        else ctx.lineTo(px, py);
      }
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Inner barrier core
      ctx.strokeStyle = skin.secondaryColor;
      ctx.lineWidth = 1.5;
      ctx.strokeRect(-r * 0.35, -r * 0.35, r * 0.7, r * 0.7);
      break;
    }

    case 'star': {
      // 5-point Astral Star
      const spikes = 5;
      const outerR = half * 0.85;
      const innerR = half * 0.4;
      let rot = Math.PI / 2 * 3;
      let x = 0;
      let y = 0;
      const step = Math.PI / spikes;

      ctx.beginPath();
      ctx.moveTo(0, -outerR);
      for (let i = 0; i < spikes; i++) {
        x = Math.cos(rot) * outerR;
        y = Math.sin(rot) * outerR;
        ctx.lineTo(x, y);
        rot += step;

        x = Math.cos(rot) * innerR;
        y = Math.sin(rot) * innerR;
        ctx.lineTo(x, y);
        rot += step;
      }
      ctx.lineTo(0, -outerR);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Glowing center beacon
      ctx.fillStyle = '#ffffff';
      ctx.beginPath();
      ctx.arc(0, 0, innerR * 0.45, 0, Math.PI * 2);
      ctx.fill();
      break;
    }

    case 'pentagon': {
      // 5-point apex shield
      const r = half * 0.8;
      ctx.beginPath();
      for (let i = 0; i < 5; i++) {
        const ang = (i * Math.PI * 2) / 5 - Math.PI / 2;
        // Directional offset
        const px = Math.cos(ang) * r * (i === 0 ? 1.15 : 1);
        const py = Math.sin(ang) * r;
        if (i === 0) ctx.moveTo(px, py);
        else ctx.lineTo(px, py);
      }
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Inner chevron
      ctx.strokeStyle = skin.secondaryColor;
      ctx.lineWidth = 1.8;
      ctx.beginPath();
      ctx.moveTo(r * 0.4, 0);
      ctx.lineTo(-r * 0.3, -r * 0.4);
      ctx.lineTo(-r * 0.3, r * 0.4);
      ctx.closePath();
      ctx.stroke();
      break;
    }

    case 'heart': {
      // Cyber Heart - forward-oriented aerodynamic heart
      const w = half * 0.85;
      const h = half * 0.8;
      ctx.beginPath();
      // Forward apex tip at +w * 0.95
      ctx.moveTo(w * 0.95, 0);
      ctx.bezierCurveTo(w * 0.4, -h * 0.95, -w * 0.95, -h * 0.85, -w * 0.35, 0);
      ctx.bezierCurveTo(-w * 0.95, h * 0.85, w * 0.4, h * 0.95, w * 0.95, 0);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Glowing pulsing heart diode in center
      const pulse = Math.sin(time * 6) * 0.2 + 1;
      ctx.fillStyle = skin.secondaryColor;
      ctx.beginPath();
      ctx.arc(0, 0, half * 0.22 * pulse, 0, Math.PI * 2);
      ctx.fill();

      // Electro-cardio pulse wave line
      ctx.strokeStyle = '#ffffff';
      ctx.lineWidth = 1.5;
      ctx.beginPath();
      ctx.moveTo(-half * 0.45, 0);
      ctx.lineTo(-half * 0.15, 0);
      ctx.lineTo(-half * 0.05, -half * 0.3);
      ctx.lineTo(half * 0.1, half * 0.3);
      ctx.lineTo(half * 0.2, 0);
      ctx.lineTo(half * 0.5, 0);
      ctx.stroke();
      break;
    }

    case 'capsule': {
      // Supersonic capsule
      const w = half * 0.8;
      const h = half * 0.45;
      ctx.beginPath();
      ctx.roundRect(-w, -h, w * 2, h * 2, h);
      ctx.fill();
      ctx.stroke();

      // Front cockpit dome
      ctx.fillStyle = skin.secondaryColor;
      ctx.beginPath();
      ctx.arc(w - h * 0.5, 0, h * 0.6, 0, Math.PI * 2);
      ctx.fill();
      break;
    }

    case 'ring': {
      // Hollow Halo toroid
      ctx.beginPath();
      ctx.arc(0, 0, half * 0.8, 0, Math.PI * 2);
      ctx.fill();
      ctx.stroke();

      // Center void hole
      ctx.beginPath();
      ctx.arc(0, 0, half * 0.45, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(2, 6, 10, 0.98)';
      ctx.fill();
      ctx.strokeStyle = skin.secondaryColor;
      ctx.lineWidth = 2;
      ctx.stroke();

      // Floating central levitating jewel
      ctx.fillStyle = '#ffffff';
      ctx.beginPath();
      ctx.arc(0, 0, half * 0.2, 0, Math.PI * 2);
      ctx.fill();
      break;
    }

    case 'cross': {
      // Tactical cross
      const w = half * 0.8;
      const t = half * 0.32;
      ctx.beginPath();
      ctx.moveTo(t, -w);
      ctx.lineTo(t, -t);
      ctx.lineTo(w, -t);
      ctx.lineTo(w, t);
      ctx.lineTo(t, t);
      ctx.lineTo(t, w);
      ctx.lineTo(-t, w);
      ctx.lineTo(-t, t);
      ctx.lineTo(-w, t);
      ctx.lineTo(-w, -t);
      ctx.lineTo(-t, -t);
      ctx.lineTo(-t, -w);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Center jewel
      ctx.fillStyle = skin.secondaryColor;
      ctx.fillRect(-t * 0.5, -t * 0.5, t, t);
      break;
    }

    case 'lightning': {
      // High-voltage lightning zig-zag
      ctx.beginPath();
      ctx.moveTo(half * 0.9, -half * 0.2);
      ctx.lineTo(half * 0.1, -half * 0.8);
      ctx.lineTo(half * 0.2, -half * 0.2);
      ctx.lineTo(-half * 0.8, -half * 0.8);
      ctx.lineTo(-half * 0.2, 0.1);
      ctx.lineTo(-half * 0.6, 0.1);
      ctx.lineTo(0, half * 0.9);
      ctx.lineTo(-half * 0.05, half * 0.25);
      ctx.lineTo(half * 0.6, half * 0.25);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Electric spark line
      ctx.strokeStyle = '#ffffff';
      ctx.lineWidth = 1.5;
      ctx.stroke();
      break;
    }

    case 'plus': {
      // Medical-Cyber Nexus
      const w = half * 0.75;
      const t = half * 0.28;
      const r = 3;
      ctx.beginPath();
      ctx.roundRect(-w, -t, w * 2, t * 2, r);
      ctx.roundRect(-t, -w, t * 2, w * 2, r);
      ctx.fill();
      ctx.stroke();

      // Center diode
      ctx.fillStyle = '#ffffff';
      ctx.beginPath();
      ctx.arc(0, 0, t * 0.6, 0, Math.PI * 2);
      ctx.fill();
      break;
    }

    case 'cyber-shard': {
      // Asymmetric stealth crystal
      ctx.beginPath();
      ctx.moveTo(half * 1.05, 0);
      ctx.lineTo(-half * 0.4, -half * 0.9);
      ctx.lineTo(-half * 0.95, -half * 0.3);
      ctx.lineTo(-half * 0.6, 0);
      ctx.lineTo(-half * 0.95, half * 0.6);
      ctx.lineTo(-half * 0.3, half * 0.75);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Facet cut line
      ctx.strokeStyle = skin.secondaryColor;
      ctx.lineWidth = 1.8;
      ctx.beginPath();
      ctx.moveTo(half * 1.05, 0);
      ctx.lineTo(-half * 0.6, 0);
      ctx.stroke();
      break;
    }

    case 'quantum-stealth': {
      // Triple phase razor delta
      ctx.beginPath();
      ctx.moveTo(half * 1.1, 0);
      ctx.lineTo(-half * 0.7, -half * 0.9);
      ctx.lineTo(-half * 0.4, -half * 0.3);
      ctx.lineTo(-half * 0.85, 0);
      ctx.lineTo(-half * 0.4, half * 0.3);
      ctx.lineTo(-half * 0.7, half * 0.9);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Hologram ghost wing
      ctx.strokeStyle = skin.secondaryColor;
      ctx.lineWidth = 1.5;
      ctx.beginPath();
      ctx.moveTo(half * 0.6, 0);
      ctx.lineTo(-half * 0.4, -half * 0.6);
      ctx.lineTo(-half * 0.2, 0);
      ctx.lineTo(-half * 0.4, half * 0.6);
      ctx.closePath();
      ctx.stroke();
      break;
    }

    case 'plasma-core': {
      // High-energy Plasma Sun
      const pulse = Math.sin(time * 6) * 0.1 + 0.9;
      // Corona flares
      ctx.fillStyle = skin.secondaryColor;
      ctx.beginPath();
      ctx.arc(0, 0, half * 0.7 * pulse, 0, Math.PI * 2);
      ctx.fill();

      // Rotating magnetic field arcs
      ctx.save();
      ctx.rotate(time * 2);
      ctx.strokeStyle = '#ffffff';
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.arc(0, 0, half * 0.85, 0, Math.PI * 0.8);
      ctx.stroke();
      ctx.beginPath();
      ctx.arc(0, 0, half * 0.85, Math.PI, Math.PI * 1.8);
      ctx.stroke();
      ctx.restore();

      // Superheated nucleus
      ctx.fillStyle = '#ffffff';
      ctx.beginPath();
      ctx.arc(0, 0, half * 0.35, 0, Math.PI * 2);
      ctx.fill();
      break;
    }

    case 'supernova': {
      // 8-point rotating stellar entity
      const spikes = 8;
      const outerR = half * 0.9;
      const innerR = half * 0.35;
      let rot = time * 2;
      const step = Math.PI / spikes;

      ctx.beginPath();
      for (let i = 0; i < spikes * 2; i++) {
        const r = i % 2 === 0 ? outerR : innerR;
        const px = Math.cos(rot) * r;
        const py = Math.sin(rot) * r;
        if (i === 0) ctx.moveTo(px, py);
        else ctx.lineTo(px, py);
        rot += step;
      }
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Center white hot core
      ctx.fillStyle = '#ffffff';
      ctx.beginPath();
      ctx.arc(0, 0, innerR * 0.6, 0, Math.PI * 2);
      ctx.fill();
      break;
    }

    case 'void-warp': {
      // Gravitational black hole accretion disc
      const rot = time * 3;
      ctx.save();
      ctx.rotate(rot);
      // Accretion spiral
      const grad = ctx.createConicGradient(0, 0, 0);
      grad.addColorStop(0, skin.color);
      grad.addColorStop(0.5, skin.secondaryColor);
      grad.addColorStop(1, skin.color);
      ctx.fillStyle = grad;
      ctx.beginPath();
      ctx.arc(0, 0, half * 0.85, 0, Math.PI * 2);
      ctx.fill();
      ctx.restore();

      // Event horizon (pure black void center)
      ctx.fillStyle = '#000000';
      ctx.beginPath();
      ctx.arc(0, 0, half * 0.45, 0, Math.PI * 2);
      ctx.fill();
      ctx.strokeStyle = skin.secondaryColor;
      ctx.lineWidth = 2.2;
      ctx.stroke();
      break;
    }

    case 'chrono-dial': {
      // 12-tooth clockwork tachyon gear
      const teeth = 12;
      const outerR = half * 0.85;
      const innerR = half * 0.68;
      let rot = time * 1.8;
      const step = (Math.PI * 2) / (teeth * 2);

      ctx.beginPath();
      for (let i = 0; i < teeth * 2; i++) {
        const r = i % 2 === 0 ? outerR : innerR;
        const px = Math.cos(rot) * r;
        const py = Math.sin(rot) * r;
        if (i === 0) ctx.moveTo(px, py);
        else ctx.lineTo(px, py);
        rot += step;
      }
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Gear axel & spoke lines
      ctx.fillStyle = 'rgba(2, 6, 10, 0.95)';
      ctx.beginPath();
      ctx.arc(0, 0, innerR * 0.5, 0, Math.PI * 2);
      ctx.fill();
      ctx.strokeStyle = skin.secondaryColor;
      ctx.lineWidth = 2;
      ctx.stroke();

      ctx.fillStyle = '#ffd700';
      ctx.beginPath();
      ctx.arc(0, 0, innerR * 0.25, 0, Math.PI * 2);
      ctx.fill();
      break;
    }

    case 'solar-aegis': {
      // Solar majesty flagship
      ctx.beginPath();
      ctx.moveTo(half * 1.1, 0);
      ctx.lineTo(-half * 0.3, -half * 0.95);
      ctx.lineTo(-half * 0.6, -half * 0.4);
      ctx.lineTo(-half * 0.95, -half * 0.7);
      ctx.lineTo(-half * 0.7, 0);
      ctx.lineTo(-half * 0.95, half * 0.7);
      ctx.lineTo(-half * 0.6, half * 0.4);
      ctx.lineTo(-half * 0.3, half * 0.95);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Divine solar crest
      ctx.fillStyle = '#ffffff';
      ctx.beginPath();
      ctx.arc(0, 0, half * 0.25, 0, Math.PI * 2);
      ctx.fill();
      break;
    }

    case 'phantom-blade':
    default: {
      // Curved razor crescent
      ctx.beginPath();
      ctx.moveTo(half * 1.05, 0);
      ctx.quadraticCurveTo(0, -half * 0.9, -half * 0.8, -half * 0.7);
      ctx.lineTo(-half * 0.3, 0);
      ctx.lineTo(-half * 0.8, half * 0.7);
      ctx.quadraticCurveTo(0, half * 0.9, half * 1.05, 0);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();

      // Inner scythe spine
      ctx.strokeStyle = skin.secondaryColor;
      ctx.lineWidth = 1.8;
      ctx.beginPath();
      ctx.moveTo(half * 0.8, 0);
      ctx.lineTo(-half * 0.2, 0);
      ctx.stroke();
      break;
    }
  }

  ctx.restore();
}
