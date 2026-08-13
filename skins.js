/**
 * Speedy Arrow - Skins & Themes Database
 * This file contains the SVG definitions for 20+ ship skins,
 * trail effects, and screen/color themes.
 */

const THEMES = {
  purple: {
    id: "purple",
    name: "Deep Purple",
    primary: "#6200ea",
    secondary: "#b388ff",
    background: "#120024",
    accent: "#00e5ff",
    trail: "#00e5ff"
  },
  orange: {
    id: "orange",
    name: "Volcanic Orange",
    primary: "#ff6d00",
    secondary: "#ffd180",
    background: "#1f0b00",
    accent: "#ffeb3b",
    trail: "#ffeb3b"
  },
  olive: {
    id: "olive",
    name: "Golden Olive",
    primary: "#827717",
    secondary: "#f4ff81",
    background: "#131400",
    accent: "#00e676",
    trail: "#f4ff81"
  },
  cyan: {
    id: "cyan",
    name: "Cyber Cyan",
    primary: "#00b0ff",
    secondary: "#80d8ff",
    background: "#00101d",
    accent: "#ff4081",
    trail: "#00e5ff"
  },
  crimson: {
    id: "crimson",
    name: "Crimson Eclipse",
    primary: "#d50000",
    secondary: "#ff8a80",
    background: "#1c0000",
    accent: "#ffab40",
    trail: "#ff1744"
  },
  pink: {
    id: "pink",
    name: "Neon Pink",
    primary: "#c51162",
    secondary: "#ff4081",
    background: "#1f0010",
    accent: "#00e5ff",
    trail: "#ff4081"
  }
};

const SHIPS = [
  {
    id: "classic",
    name: "Arrow Classic",
    price: 0,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 20,20 L 85,50 L 20,80 L 35,50 Z" fill="currentColor" stroke="none"/>
    </svg>`
  },
  {
    id: "teardrop",
    name: "Teardrop",
    price: 0,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 15,50 C 15,25, 45,15, 85,50 C 45,85, 15,75, 15,50 Z" fill="currentColor" stroke="none"/>
    </svg>`
  },
  {
    id: "paper_airplane",
    name: "Paper Plane",
    price: 150,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 15,15 L 85,50 L 35,60 L 15,85 L 45,55 Z" fill="currentColor" stroke="none"/>
    </svg>`
  },
  {
    id: "rocket",
    name: "Rocket Wing",
    price: 300,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 15,35 L 35,35 L 85,50 L 35,65 L 15,65 L 25,50 Z M 15,35 L 5,50 L 15,65 Z" fill="currentColor" stroke="none"/>
    </svg>`
  },
  {
    id: "shuriken",
    name: "Shuriken DX",
    price: 500,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 50,15 L 60,40 L 85,50 L 60,60 L 50,85 L 40,60 L 15,50 L 40,40 Z" fill="currentColor" stroke="none"/>
    </svg>`
  },
  {
    id: "falcon",
    name: "Falcon Jet",
    price: 800,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 15,25 L 30,35 L 85,50 L 30,65 L 15,75 L 25,50 Z" fill="currentColor" stroke="none"/>
    </svg>`
  },
  {
    id: "diamond_tail",
    name: "Diamond Tail",
    price: 1200,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 15,50 L 50,25 L 85,50 L 50,75 Z M 15,50 L 5,35 L 5,65 Z" fill="currentColor" stroke="none"/>
    </svg>`
  },
  {
    id: "eye_ship",
    name: "Cyclops",
    price: 1500,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 15,50 Q 50,15 85,50 Q 50,85 15,50 Z" fill="currentColor" stroke="none"/>
      <circle cx="50" cy="50" r="15" fill="#120024"/>
      <circle cx="50" cy="50" r="7" fill="currentColor"/>
    </svg>`
  },
  {
    id: "batwing",
    name: "Batwing",
    price: 2000,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 15,20 Q 35,40 50,20 Q 65,40 85,20 L 75,50 L 85,80 Q 65,60 50,80 Q 35,60 15,80 L 25,50 Z" fill="currentColor" stroke="none"/>
    </svg>`
  },
  {
    id: "ufo",
    name: "UFO Voyager",
    price: 2500,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <ellipse cx="50" cy="50" rx="35" ry="15" fill="currentColor"/>
      <circle cx="50" cy="40" r="15" fill="currentColor" opacity="0.7"/>
      <circle cx="35" cy="50" r="4" fill="#000"/>
      <circle cx="50" cy="50" r="4" fill="#000"/>
      <circle cx="65" cy="50" r="4" fill="#000"/>
    </svg>`
  },
  {
    id: "cyber_dart",
    name: "Cyber Dart",
    price: 3000,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 10,40 L 90,50 L 10,60 L 25,50 Z" fill="currentColor" stroke="none"/>
    </svg>`
  },
  {
    id: "phoenix",
    name: "Phoenix Wing",
    price: 3500,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 15,45 Q 35,10 60,35 L 85,50 L 60,65 Q 35,90 15,55 L 30,50 Z" fill="currentColor" stroke="none"/>
    </svg>`
  },
  {
    id: "nautilus",
    name: "Nautilus",
    price: 4000,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 15,50 A 35,35 0 1,1 85,50 A 25,25 0 1,1 35,50 A 15,15 0 1,1 65,50 L 85,50" fill="none" stroke="currentColor" stroke-width="10"/>
    </svg>`
  },
  {
    id: "phantom",
    name: "Phantom Bomber",
    price: 4500,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 15,15 L 85,50 L 15,85 L 30,50 Z" fill="currentColor" stroke="none"/>
    </svg>`
  },
  {
    id: "hammerhead",
    name: "Hammerhead",
    price: 5000,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 15,30 L 15,70 L 30,60 L 85,55 L 85,45 L 30,40 Z" fill="currentColor" stroke="none"/>
    </svg>`
  },
  {
    id: "waverider",
    name: "Wave Rider",
    price: 6000,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 15,50 C 30,20 70,20 85,50 C 70,80 30,80 15,50 Z M 35,50 A 15,15 0 1,0 65,50 A 15,15 0 1,0 35,50 Z" fill="currentColor" stroke="none"/>
    </svg>`
  },
  {
    id: "spearhead",
    name: "Spearhead DX",
    price: 7000,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 15,30 L 40,40 L 85,50 L 40,60 L 15,70 L 30,50 Z" fill="currentColor" stroke="none"/>
    </svg>`
  },
  {
    id: "vortex",
    name: "Vortex Flare",
    price: 8000,
    currency: "gem",
    isPremium: false,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 50,15 C 65,15 85,35 85,50 C 85,65 65,85 50,85 C 35,85 15,65 15,50 C 15,35 35,15 50,15 Z M 50,35 A 15,15 0 1,0 50,65 A 15,15 0 1,0 50,35 Z" fill="currentColor" stroke="none"/>
    </svg>`
  },
  {
    id: "orion",
    name: "Orion Starship",
    price: 5,
    currency: "premium",
    isPremium: true,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 15,50 L 40,30 L 85,50 L 40,70 Z M 40,30 L 40,10 L 55,30 Z M 40,70 L 40,90 L 55,70 Z" fill="currentColor" stroke="none"/>
    </svg>`
  },
  {
    id: "dragonfly",
    name: "Dragonfly",
    price: 15,
    currency: "premium",
    isPremium: true,
    svg: `<svg viewBox="0 0 100 100" width="100%" height="100%">
      <path d="M 10,50 L 90,50 M 50,15 L 50,85 M 35,25 L 35,75" stroke="currentColor" stroke-width="8" stroke-linecap="round" fill="none"/>
    </svg>`
  }
];

const TRAILS = [
  {
    id: "solid",
    name: "Solid Glow",
    price: 0,
    isPremium: false,
    color: "#ffffff"
  },
  {
    id: "rainbow",
    name: "Rainbow Dash",
    price: 400,
    isPremium: false,
    color: "rainbow"
  },
  {
    id: "neon_cyan",
    name: "Cyber Pulse",
    price: 800,
    isPremium: false,
    color: "#00e5ff"
  },
  {
    id: "gold",
    name: "Golden Spark",
    price: 1500,
    isPremium: false,
    color: "#ffd700"
  },
  {
    id: "premium_fire",
    name: "Cosmic Flame",
    price: 10,
    isPremium: true,
    color: "fire"
  }
];

// Export to window so they are globally accessible in single-page scripts without build-steps
window.THEMES = THEMES;
window.SHIPS = SHIPS;
window.TRAILS = TRAILS;
