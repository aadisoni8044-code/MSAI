import { InputState, PlayerStats } from '../types/game';

export class Player implements PlayerStats {
  public x: number;
  public y: number;
  public width: number = 44;
  public height: number = 56;
  public vx: number = 0;
  public vy: number = 0;
  public isGrounded: boolean = true;
  public isJumping: boolean = false;
  public canDoubleJump: boolean = true;
  public isAttacking: boolean = false;
  public attackTimer: number = 0;
  public attackCooldown: number = 0;
  public attackBox = { x: 0, y: 0, width: 50, height: 50 };
  public facingRight: boolean = true;
  public health: number = 3;
  public maxHealth: number = 3;
  public invulnerableTimer: number = 0;
  public animationFrame: number = 0;

  private gravity: number = 0.65;
  private moveSpeed: number = 6.5;
  private jumpForce: number = -13.5;
  private groundY: number = 0;

  constructor(startX: number, groundY: number) {
    this.x = startX;
    this.groundY = groundY;
    this.y = groundY - this.height;
  }

  public reset(groundY: number): void {
    this.groundY = groundY;
    this.x = 100;
    this.y = groundY - this.height;
    this.vx = 0;
    this.vy = 0;
    this.isGrounded = true;
    this.isJumping = false;
    this.canDoubleJump = true;
    this.isAttacking = false;
    this.attackTimer = 0;
    this.attackCooldown = 0;
    this.facingRight = true;
    this.health = this.maxHealth;
    this.invulnerableTimer = 0;
  }

  public update(input: InputState, canvasWidth: number): void {
    // 1. Horizontal Movement
    if (input.left) {
      this.vx = -this.moveSpeed;
      this.facingRight = false;
    } else if (input.right) {
      this.vx = this.moveSpeed;
      this.facingRight = true;
    } else {
      this.vx *= 0.8; // Dampening
      if (Math.abs(this.vx) < 0.1) this.vx = 0;
    }

    this.x += this.vx;

    // Boundary check
    if (this.x < 10) this.x = 10;
    if (this.x + this.width > canvasWidth - 10) this.x = canvasWidth - 10 - this.width;

    // 2. Jumping Logic (Single & Double Jump)
    if (input.jumpPressed) {
      if (this.isGrounded) {
        this.vy = this.jumpForce;
        this.isGrounded = false;
        this.isJumping = true;
        this.canDoubleJump = true;
      } else if (this.canDoubleJump) {
        this.vy = this.jumpForce * 0.88;
        this.canDoubleJump = false;
      }
    }

    // Apply Gravity
    this.vy += this.gravity;
    this.y += this.vy;

    // Ground Collision
    if (this.y + this.height >= this.groundY) {
      this.y = this.groundY - this.height;
      this.vy = 0;
      this.isGrounded = true;
      this.isJumping = false;
    }

    // 3. Attack Mechanics
    if (this.attackCooldown > 0) {
      this.attackCooldown -= 1;
    }

    if (input.attackPressed && this.attackCooldown === 0) {
      this.isAttacking = true;
      this.attackTimer = 12; // Duration in frames
      this.attackCooldown = 22; // Cooldown before next attack
    }

    if (this.isAttacking) {
      this.attackTimer -= 1;
      if (this.attackTimer <= 0) {
        this.isAttacking = false;
      }
    }

    // Update attack hitbox
    this.attackBox.x = this.facingRight ? this.x + this.width : this.x - this.attackBox.width;
    this.attackBox.y = this.y + 5;

    // Invulnerability timer
    if (this.invulnerableTimer > 0) {
      this.invulnerableTimer -= 1;
    }

    this.animationFrame++;
  }

  public takeDamage(amount: number = 1): boolean {
    if (this.invulnerableTimer > 0) return false;

    this.health -= amount;
    this.invulnerableTimer = 60; // 1 sec invulnerability
    this.vy = -6; // Knockback up
    this.vx = this.facingRight ? -8 : 8; // Knockback back
    return true;
  }

  public render(ctx: CanvasRenderingContext2D): void {
    // Flash if invulnerable
    if (this.invulnerableTimer > 0 && Math.floor(this.invulnerableTimer / 5) % 2 === 0) {
      return;
    }

    ctx.save();

    // Flip context if facing left
    if (!this.facingRight) {
      ctx.translate(this.x + this.width, this.y);
      ctx.scale(-1, 1);
    } else {
      ctx.translate(this.x, this.y);
    }

    // Body (Hero Armor Canvas Vector Art)
    const legOffset = this.isGrounded ? Math.sin(this.animationFrame * 0.3) * 6 : 0;

    // Legs
    ctx.fillStyle = '#1a252c';
    ctx.fillRect(8, 38 + legOffset, 10, 18);
    ctx.fillRect(24, 38 - legOffset, 10, 18);

    // Torso / Armor
    ctx.fillStyle = '#3a86ff';
    ctx.fillRect(6, 16, 30, 24);
    ctx.fillStyle = '#ff006e'; // Belt / Accent
    ctx.fillRect(6, 34, 30, 5);

    // Head / Helmet
    ctx.fillStyle = '#ffbe0b';
    ctx.beginPath();
    ctx.arc(21, 12, 12, 0, Math.PI * 2);
    ctx.fill();

    // Helmet Visor
    ctx.fillStyle = '#050505';
    ctx.fillRect(20, 8, 11, 6);

    // Sword (Idle or Attack)
    if (this.isAttacking) {
      ctx.fillStyle = '#fb5607';
      // Sword Swing Arc Effect
      ctx.beginPath();
      ctx.arc(22, 22, 45, -Math.PI / 4, Math.PI / 3);
      ctx.lineWidth = 8;
      ctx.strokeStyle = 'rgba(255, 0, 110, 0.8)';
      ctx.stroke();

      // Blade Graphic
      ctx.fillStyle = '#ffffff';
      ctx.fillRect(32, 12, 35, 8);
    } else {
      // Sheathed / Held Sword
      ctx.fillStyle = '#8d99ae';
      ctx.fillRect(28, 20, 6, 22);
    }

    ctx.restore();
  }
}
