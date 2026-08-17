import { Entity, EnemyType } from '../types/game';

export class Enemy implements Entity {
  public id: string;
  public type: EnemyType;
  public x: number;
  public y: number;
  public width: number;
  public height: number;
  public vx: number;
  public vy: number;
  public health: number;
  public isHazard: boolean;
  public color: string;
  public sineOffset: number;
  public animationFrame: number = 0;

  constructor(type: EnemyType, startX: number, groundY: number) {
    this.id = Math.random().toString(36).substring(2, 9);
    this.type = type;
    this.x = startX;
    this.sineOffset = Math.random() * Math.PI * 2;
    this.vy = 0;

    switch (type) {
      case 'slime':
        this.width = 38;
        this.height = 28;
        this.y = groundY - this.height;
        this.vx = -2.5;
        this.health = 1;
        this.isHazard = false;
        this.color = '#00f5d4';
        break;

      case 'goblin':
        this.width = 40;
        this.height = 48;
        this.y = groundY - this.height;
        this.vx = -3.8;
        this.health = 2;
        this.isHazard = false;
        this.color = '#70e000';
        break;

      case 'bat':
        this.width = 36;
        this.height = 26;
        this.y = groundY - 120 - Math.random() * 80;
        this.vx = -4.2;
        this.health = 1;
        this.isHazard = false;
        this.color = '#7209b7';
        break;

      case 'dragon':
        this.width = 65;
        this.height = 50;
        this.y = groundY - 150 - Math.random() * 60;
        this.vx = -5.0;
        this.health = 3;
        this.isHazard = false;
        this.color = '#f72585';
        break;

      case 'spike':
        this.width = 32;
        this.height = 30;
        this.y = groundY - this.height;
        this.vx = -3.0; // Moves with map scroll
        this.health = 999;
        this.isHazard = true;
        this.color = '#adb5bd';
        break;

      case 'lava':
        this.width = 60;
        this.height = 20;
        this.y = groundY - 10;
        this.vx = -3.0;
        this.health = 999;
        this.isHazard = true;
        this.color = '#d00000';
        break;

      case 'fireball':
        this.width = 24;
        this.height = 24;
        this.y = groundY - 100;
        this.vx = -5.5;
        this.health = 999;
        this.isHazard = true;
        this.color = '#ffb703';
        break;
    }
  }

  public update(scrollSpeed: number): void {
    this.animationFrame++;

    if (this.type === 'bat' || this.type === 'dragon') {
      this.x += this.vx - scrollSpeed * 0.3;
      this.y += Math.sin(this.animationFrame * 0.1 + this.sineOffset) * 2.5;
    } else if (this.type === 'fireball') {
      this.x += this.vx - scrollSpeed * 0.3;
      this.y += Math.cos(this.animationFrame * 0.15 + this.sineOffset) * 3;
    } else if (this.isHazard) {
      this.x -= scrollSpeed;
    } else {
      // Slime & Goblin ground movement
      this.x += this.vx - scrollSpeed * 0.2;
    }
  }

  public render(ctx: CanvasRenderingContext2D): void {
    ctx.save();
    ctx.translate(this.x, this.y);

    if (this.type === 'slime') {
      const stretch = Math.sin(this.animationFrame * 0.2) * 4;
      ctx.fillStyle = this.color;
      ctx.beginPath();
      ctx.ellipse(this.width / 2, this.height / 2 + stretch / 2, this.width / 2, this.height / 2 - stretch / 2, 0, 0, Math.PI * 2);
      ctx.fill();

      // Slime Eyes
      ctx.fillStyle = '#ffffff';
      ctx.beginPath();
      ctx.arc(12, 10, 4, 0, Math.PI * 2);
      ctx.arc(26, 10, 4, 0, Math.PI * 2);
      ctx.fill();

      ctx.fillStyle = '#000000';
      ctx.beginPath();
      ctx.arc(10, 10, 2, 0, Math.PI * 2);
      ctx.arc(24, 10, 2, 0, Math.PI * 2);
      ctx.fill();
    } else if (this.type === 'bat') {
      const wingFlap = Math.sin(this.animationFrame * 0.3) * 12;
      ctx.fillStyle = this.color;

      // Bat Body
      ctx.beginPath();
      ctx.arc(this.width / 2, this.height / 2, 8, 0, Math.PI * 2);
      ctx.fill();

      // Wings
      ctx.beginPath();
      ctx.moveTo(this.width / 2, this.height / 2);
      ctx.lineTo(0, this.height / 2 - wingFlap);
      ctx.lineTo(this.width / 4, this.height / 2 + 6);
      ctx.closePath();
      ctx.fill();

      ctx.beginPath();
      ctx.moveTo(this.width / 2, this.height / 2);
      ctx.lineTo(this.width, this.height / 2 - wingFlap);
      ctx.lineTo((this.width * 3) / 4, this.height / 2 + 6);
      ctx.closePath();
      ctx.fill();
    } else if (this.type === 'goblin') {
      ctx.fillStyle = this.color;
      ctx.fillRect(8, 12, 24, 32);

      // Goblin Head
      ctx.fillStyle = '#38b000';
      ctx.fillRect(6, 0, 28, 16);

      // Ears
      ctx.beginPath();
      ctx.moveTo(6, 4);
      ctx.lineTo(0, 0);
      ctx.lineTo(6, 10);
      ctx.fill();

      // Red Eyes
      ctx.fillStyle = '#d00000';
      ctx.fillRect(10, 4, 4, 4);
      ctx.fillRect(22, 4, 4, 4);
    } else if (this.type === 'dragon') {
      ctx.fillStyle = this.color;
      ctx.fillRect(10, 10, 45, 30);

      // Dragon Wings
      ctx.fillStyle = '#ff758f';
      ctx.beginPath();
      ctx.moveTo(25, 10);
      ctx.lineTo(10, -15);
      ctx.lineTo(40, 10);
      ctx.fill();

      // Dragon Head
      ctx.fillStyle = '#c77dff';
      ctx.fillRect(0, 5, 20, 20);
    } else if (this.type === 'spike') {
      ctx.fillStyle = this.color;
      ctx.beginPath();
      ctx.moveTo(0, this.height);
      ctx.lineTo(this.width / 2, 0);
      ctx.lineTo(this.width, this.height);
      ctx.closePath();
      ctx.fill();
    } else if (this.type === 'lava') {
      ctx.fillStyle = '#ff4800';
      ctx.fillRect(0, 0, this.width, this.height);
      ctx.fillStyle = '#ffb703';
      ctx.fillRect(0, 0, this.width, 4);
    } else if (this.type === 'fireball') {
      const glow = ctx.createRadialGradient(12, 12, 2, 12, 12, 12);
      glow.addColorStop(0, '#ffffff');
      glow.addColorStop(0.5, '#ffb703');
      glow.addColorStop(1, '#d00000');
      ctx.fillStyle = glow;
      ctx.beginPath();
      ctx.arc(12, 12, 12, 0, Math.PI * 2);
      ctx.fill();
    }

    ctx.restore();
  }
}
