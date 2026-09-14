/* Multi-Layer Parallax Background & Environmental Effects Renderer */
class ParallaxBackground {
    constructor(theme = 'forest') {
        this.theme = theme;
        this.fogOffset = 0;
    }

    render(ctx, cameraOffset, viewWidth, viewHeight, levelWidth, levelHeight) {
        this.fogOffset += 0.2;

        // Layer 0: Far Sky & Atmospheric Gradient
        const skyGradients = {
            forest: ['#030a0d', '#0b2328', '#0f3d44'],
            ruins: ['#05080c', '#101e28', '#1c3445'],
            cave: ['#020406', '#091016', '#121f2b'],
            swamp: ['#040a08', '#0c221a', '#14382a'],
            temple: ['#08060d', '#1b1228', '#2e1c45']
        };

        const colors = skyGradients[this.theme] || skyGradients.forest;
        const skyGrad = ctx.createLinearGradient(0, 0, 0, viewHeight);
        skyGrad.addColorStop(0, colors[0]);
        skyGrad.addColorStop(0.5, colors[1]);
        skyGrad.addColorStop(1, colors[2]);

        ctx.fillStyle = skyGrad;
        ctx.fillRect(0, 0, viewWidth, viewHeight);

        // Layer 1: Distant Mountain / Tree Silhouettes (0.1 Parallax)
        ctx.save();
        ctx.fillStyle = 'rgba(7, 24, 28, 0.7)';
        const p1X = -(cameraOffset.x * 0.1) % 400;

        for (let x = p1X - 400; x < viewWidth + 400; x += 400) {
            ctx.beginPath();
            ctx.moveTo(x, viewHeight);
            ctx.lineTo(x + 100, viewHeight - 200);
            ctx.lineTo(x + 250, viewHeight - 280);
            ctx.lineTo(x + 400, viewHeight);
            ctx.fill();
        }
        ctx.restore();

        // Layer 2: Ancient Giant Trees with Hanging Vines & Light Rays (0.25 Parallax)
        ctx.save();
        const p2X = -(cameraOffset.x * 0.25) % 300;

        // Sunlight / Ethereal Rays
        ctx.fillStyle = 'rgba(63, 224, 208, 0.04)';
        for (let r = 0; r < 3; r++) {
            ctx.beginPath();
            ctx.moveTo(100 + r * 300, 0);
            ctx.lineTo(250 + r * 300, 0);
            ctx.lineTo(150 + r * 300 + Math.sin(Date.now() * 0.001 + r) * 20, viewHeight);
            ctx.lineTo(0 + r * 300, viewHeight);
            ctx.fill();
        }

        // Giant Trees
        for (let x = p2X - 300; x < viewWidth + 300; x += 300) {
            ctx.fillStyle = '#0a1f24';
            // Trunk
            ctx.fillRect(x + 80, 0, 90, viewHeight);

            // Twist branches
            ctx.beginPath();
            ctx.moveTo(x + 80, viewHeight * 0.4);
            ctx.quadraticCurveTo(x + 20, viewHeight * 0.2, x - 40, viewHeight * 0.1);
            ctx.lineTo(x + 80, viewHeight * 0.3);
            ctx.fill();

            // Hanging Vines
            ctx.strokeStyle = '#143c3d';
            ctx.lineWidth = 3;
            for (let v = 0; v < 4; v++) {
                ctx.beginPath();
                const vineX = x + 90 + v * 20;
                ctx.moveTo(vineX, 0);
                ctx.quadraticCurveTo(vineX + Math.sin(Date.now() * 0.002 + v) * 10, viewHeight * 0.4, vineX, viewHeight * 0.7);
                ctx.stroke();
            }
        }
        ctx.restore();

        // Layer 3: Midground Mossy Foliage (0.5 Parallax)
        ctx.save();
        ctx.fillStyle = '#0f383e';
        const p3X = -(cameraOffset.x * 0.5) % 200;
        for (let x = p3X - 200; x < viewWidth + 200; x += 200) {
            ctx.beginPath();
            ctx.arc(x + 100, viewHeight - 40, 120, 0, Math.PI * 2);
            ctx.fill();
        }
        ctx.restore();
    }

    renderForeground(ctx, cameraOffset, viewWidth, viewHeight) {
        // Layer 4: Floating Mist / Fog Overlay & Foreground Vegetation
        ctx.save();
        ctx.fillStyle = 'rgba(63, 224, 208, 0.03)';
        const fogX = (this.fogOffset) % viewWidth;
        ctx.fillRect(-fogX, 0, viewWidth * 2, viewHeight);

        // Foreground Dark Branches (1.2 Parallax)
        const fgX = -(cameraOffset.x * 1.2) % 600;
        ctx.fillStyle = '#03080a';

        for (let x = fgX - 600; x < viewWidth + 600; x += 600) {
            // Top hanging dark branches
            ctx.beginPath();
            ctx.moveTo(x, 0);
            ctx.quadraticCurveTo(x + 150, 80, x + 300, 0);
            ctx.fill();

            // Bottom dark shrubs
            ctx.beginPath();
            ctx.arc(x + 200, viewHeight, 60, 0, Math.PI * 2);
            ctx.fill();
        }

        ctx.restore();
    }
}

window.ParallaxBackground = ParallaxBackground;
