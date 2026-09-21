/**
 * GAME DATA - Centralized Data Repository
 * Contains metadata for Game Info, Features, 10 Elemental Levels, Zombie Mode, Weapons, Controls, Gallery & Videos.
 */

const GAME_DATA = {
  info: {
    title: "SHADOW FOREST: ZOMBIE OUTBREAK",
    subtitle: "The Ultimate AAA Action-Adventure & Zombie Survival Experience",
    version: "v2.5.0",
    releaseDate: "2026-10-15",
    developer: "Nvisov Game Studios",
    engine: "Custom Canvas 3D & WebGL Engine",
    genre: "Action / Survival / Fantasy Platformer",
    rating: "M for Mature (17+)",
    platforms: ["PC (Windows)", "macOS", "Linux", "Mobile (Android/iOS)"],
    tagline: "Survive the darkness. Conquer the elemental realm. Battle infinite horde waves.",
    description: "Step into an immersive dark fantasy world filled with high-octane combat, elemental magic, strategic tower defenses, and adrenaline-pumping zombie survival waves. Master 10 unique elemental realms, unleash lethal firepower, and survive the endless undead outbreak."
  },

  features: [
    {
      id: "feat-adventure",
      icon: "⚡",
      title: "Epic Fantasy Adventure",
      tag: "Story Mode",
      description: "Embark on a mythical quest across 10 distinct elemental biomes, unraveling ancient dark magic secrets and legendary lore."
    },
    {
      id: "feat-combat",
      icon: "⚔️",
      title: "Dynamic Combat System",
      tag: "Fluid Action",
      description: "Perform lightning-fast directional attacks, spell casting, dodge rolls, and devastating ultimate combos against intelligent AI foes."
    },
    {
      id: "feat-exploration",
      icon: "🗺️",
      title: "Expansive Exploration",
      tag: "Parallax Biomes",
      description: "Explore lush, multi-layered parallax worlds with dynamic weather, hidden secret areas, chest loots, and environmental puzzles."
    },
    {
      id: "feat-levels",
      icon: "🔥",
      title: "10 Elemental Levels",
      tag: "Campaign",
      description: "Battle through Forest, Fire, Water, Ice, Desert, Thunder, Poison, Sky, Shadow, and Crystal biomes with scaling boss fights."
    },
    {
      id: "feat-enemies",
      icon: "👾",
      title: "Diverse AI Enemies",
      tag: "Challenging AI",
      description: "Face 20+ enemy types featuring unique behaviors, patrol paths, ranged attacks, enraged modes, and tactical squad mechanics."
    },
    {
      id: "feat-weapons",
      icon: "🔫",
      title: "Lethal Arsenal",
      tag: "Weapons & Gear",
      description: "Equip blades, elemental bows, shotgun, plasma cannons, and unlock the legendary air-dropped AK-47 assault rifle."
    },
    {
      id: "feat-towers",
      icon: "🏰",
      title: "Defense Watchtowers",
      tag: "Tactical Defense",
      description: "Claim strategic high-ground watchtowers equipped with auto-turrets and healing stations to defend against mass horde invasions."
    },
    {
      id: "feat-zombies",
      icon: "🧟",
      title: "Deterministic Zombie Mode",
      tag: "Survival Wave",
      description: "Survive 10 escalating wave rounds starting from 10 walker zombies up to 100 fast mutated infected monsters."
    },
    {
      id: "feat-environments",
      icon: "🌌",
      title: "Dynamic Atmospheric FX",
      tag: "Visual FX",
      description: "Experience firefly particle systems, spatial sound attenuation, procedural pitch modulation, dynamic lighting, and cinematic screenshake."
    }
  ],

  levels: [
    {
      number: 1,
      name: "Forest",
      element: "Nature",
      color: "#10b981",
      badge: "Level 01",
      bgImage: "b.png",
      description: "Dense enchanted woodland filled with glowing fireflies, ancient rune monoliths, and crawling vine traps.",
      difficulty: "Normal",
      enemiesCount: 15,
      boss: "Sylvan Treant Guardian"
    },
    {
      number: 2,
      name: "Fire",
      element: "Ignis",
      color: "#ef4444",
      badge: "Level 02",
      bgImage: "c.png",
      description: "Scorching magma caverns and boiling lava rivers where flame specters and fire drakes lurk.",
      difficulty: "Hard",
      enemiesCount: 22,
      boss: "Infernal Molten Titan"
    },
    {
      number: 3,
      name: "Water",
      element: "Aqua",
      color: "#06b6d4",
      badge: "Level 03",
      bgImage: "d.png",
      description: "Submerged ruins and glowing bioluminescent aquatic depths filled with high pressure tidal hazards.",
      difficulty: "Hard",
      enemiesCount: 25,
      boss: "Abyssal Leviathan"
    },
    {
      number: 4,
      name: "Ice",
      element: "Glacier",
      color: "#38bdf8",
      badge: "Level 04",
      bgImage: "e.png",
      description: "Frozen mountain peaks and treacherous slippery ice bridges subject to howling blizzards.",
      difficulty: "Very Hard",
      enemiesCount: 28,
      boss: "Frostbite Yeti Monarch"
    },
    {
      number: 5,
      name: "Desert",
      element: "Terra",
      color: "#f59e0b",
      badge: "Level 05",
      bgImage: "b.png",
      description: "Sun-drenched golden dunes and ancient desert tombs guarded by venomous sand scorpions.",
      difficulty: "Expert",
      enemiesCount: 30,
      boss: "Anubis Sand Sentinel"
    },
    {
      number: 6,
      name: "Thunder",
      element: "Volt",
      color: "#eab308",
      badge: "Level 06",
      bgImage: "c.png",
      description: "Electrified stormy spires with plasma lightning strikes, Tesla coils, and charged elemental spirits.",
      difficulty: "Expert",
      enemiesCount: 35,
      boss: "Stormbringer Tempest"
    },
    {
      number: 7,
      name: "Poison",
      element: "Miasma",
      color: "#84cc16",
      badge: "Level 07",
      bgImage: "d.png",
      description: "Toxic marshlands emitting corrosive spores and acidic fog traps that test stamina and timing.",
      difficulty: "Master",
      enemiesCount: 40,
      boss: "Viperous Hydra King"
    },
    {
      number: 8,
      name: "Sky",
      element: "Aether",
      color: "#a855f7",
      badge: "Level 08",
      bgImage: "e.png",
      description: "Floating sky islands linked by air currents and wind bridges high above the clouds.",
      difficulty: "Master",
      enemiesCount: 45,
      boss: "Celestial Griffin Archon"
    },
    {
      number: 9,
      name: "Shadow",
      element: "Umbra",
      color: "#6366f1",
      badge: "Level 09",
      bgImage: "b.png",
      description: "Pitch black void realms where shadows distort reality and illusions clone your character.",
      difficulty: "Nightmare",
      enemiesCount: 50,
      boss: "Void Wraith Overlord"
    },
    {
      number: 10,
      name: "Crystal",
      element: "Prism",
      color: "#ec4899",
      badge: "Level 10 - Final",
      bgImage: "c.png",
      description: "Resonating crystal cathedral glowing with concentrated primal magic for the ultimate final showdown.",
      difficulty: "Legendary",
      enemiesCount: 65,
      boss: "Prismatic Chaos Empress"
    }
  ],

  zombieMode: {
    title: "DETERMINISTIC ZOMBIE OUTBREAK SURVIVAL",
    tagline: "10 Waves. 550 total zombies. Infinite adrenaline.",
    description: "Enter the survival arena where bloodthirsty infected horde waves spawn continuously. Manage ammo, secure watchtower perimeters, trigger a 10-zombie milestone skydrop supply crate, and unleash the legendary AK-47 assault rifle.",
    waveRules: [
      { wave: 1, count: 10, title: "Initial Contagion", speed: "Slow Walkers", hp: "100 HP (1-hit KO)" },
      { wave: 2, count: 20, title: "Infection Spreads", speed: "Jogging Walkers", hp: "150 HP" },
      { wave: 3, count: 30, title: "Horde Gathering", speed: "Runners", hp: "200 HP" },
      { wave: 4, count: 40, title: "Midnight Surge", speed: "Fast Runners", hp: "250 HP" },
      { wave: 5, count: 50, title: "Halfway Outbreak", speed: "Sprinting Infected", hp: "300 HP" },
      { wave: 6, count: 60, title: "Blood Moon Assault", speed: "Armored Crawlers", hp: "350 HP" },
      { wave: 7, count: 70, title: "Toxic Swarm", speed: "Poison Spitters", hp: "400 HP" },
      { wave: 8, count: 80, title: "Relentless Swarm", speed: "Enraged Berserkers", hp: "500 HP" },
      { wave: 9, count: 90, title: "Nightmare Outbreak", speed: "High Speed Horde", hp: "650 HP" },
      { wave: 10, count: 100, title: "Final Extinction Wave", speed: "Apex Infected Tyrants", hp: "1000 HP" }
    ],

    highlights: [
      { title: "Skydrop Supply Crate", desc: "Eliminate 10 zombies to trigger an animated supply crate drop from the sky unlocking the high-capacity AK-47." },
      { title: "Watchtower High Ground", desc: "Climb fortified defensive towers equipped with auto-turrets to funnel hordes into choke points." },
      { title: "Spatial Zombie Audio", desc: "Real-time distance attenuation and pitch modulation let you sense nearby footsteps and screams." },
      { title: "Deterministic Spawning", desc: "Strict spawn counter mechanics ensure zero random lag and pure tactical skill mastery." }
    ]
  },

  weapons: [
    {
      name: "Shadow Blade",
      type: "Melee",
      damage: 75,
      rate: "Fast",
      range: "Close",
      icon: "🗡️",
      desc: "Lightweight obsidian sword capable of slicing through light zombie armor with rapid combo slashes."
    },
    {
      name: "Elemental Bow",
      type: "Ranged / Magic",
      damage: 120,
      rate: "Medium",
      range: "Long",
      icon: "🏹",
      desc: "Fires elemental charged arrows that pierce through multiple enemies in a straight trajectory."
    },
    {
      name: "Scatter Shotgun",
      type: "Heavy Firearm",
      damage: 240,
      rate: "Slow",
      range: "Medium",
      icon: "💥",
      desc: "High-impact close-range weapon that blast clusters of incoming infected back into the shadows."
    },
    {
      name: "Air-Dropped AK-47",
      type: "Assault Rifle",
      damage: 180,
      rate: "Ultra-Fast",
      range: "Long",
      icon: "🔫",
      desc: "Unlocked via 10-kill milestone supply crate skydrop. Shreds entire waves with rapid-fire automatic bullets."
    }
  ],

  controls: [
    { key: "WASD / Arrow Keys", action: "Move character Left / Right & Jump / Crouch" },
    { key: "SPACEBAR", action: "Jump / Double Jump / Climb Ladder" },
    { key: "J / Left Click", action: "Primary Melee / Fire Weapon" },
    { key: "K / Right Click", action: "Secondary Elemental Ability / Dash Roll" },
    { key: "1 / 2 / 3", action: "Switch Active Arsenal Weapon" },
    { key: "E", action: "Interact / Open Supply Crates / Mount Turret" },
    { key: "ESC", action: "Pause Game / Close Modal Windows" }
  ],

  photos: [
    {
      id: "photo-1",
      src: "b.png",
      title: "Forest Biome Gameplay",
      category: "Gameplay",
      desc: "Navigating lush 5-layer parallax forest background with firefly particles and platform puzzles."
    },
    {
      id: "photo-2",
      src: "c.png",
      title: "Inferno Boss Arena",
      category: "Boss Battles",
      desc: "Challenging the Molten Titan inside Level 02 Fire caverns."
    },
    {
      id: "photo-3",
      src: "d.png",
      title: "Zombie Outbreak Horde",
      category: "Zombie Mode",
      desc: "Defending a watchtower against 50+ sprinting infected in Zombie Mode Wave 5."
    },
    {
      id: "photo-4",
      src: "e.png",
      title: "Crystal Realm Showdown",
      category: "Levels",
      desc: "High altitude combat on sky islands with dynamic lighting and spell effects."
    }
  ],

  videos: [
    {
      id: "vid-1",
      src: "a.mp4",
      poster: "b.png",
      title: "Official Gameplay Reveal Trailer",
      duration: "02:15",
      desc: "Experience 4K gameplay showcasing elemental powers, high-speed combat, and the 10 elemental biomes."
    },
    {
      id: "vid-2",
      src: "b.mp4",
      poster: "c.png",
      title: "Zombie Outbreak Survival Deep Dive",
      duration: "03:40",
      desc: "Full breakdown of zombie wave mechanics, supply crate skydrops, and the AK-47 assault rifle in action."
    },
    {
      id: "vid-3",
      src: "c.mp4",
      poster: "d.png",
      title: "Boss Battle Showcase",
      duration: "01:50",
      desc: "High-intensity encounters against elemental titan bosses across Fire, Ice, and Thunder realms."
    },
    {
      id: "vid-4",
      src: "d.mp4",
      poster: "e.png",
      title: "Developer Combat Walkthrough",
      duration: "04:10",
      desc: "Behind-the-scenes walkthrough of combat mechanics, weapon switching, watchtowers, and dynamic physics."
    }
  ]
};

// Freeze object to prevent accidental runtime mutation
if (typeof Object.freeze === 'function') {
  Object.freeze(GAME_DATA);
}
