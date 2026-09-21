/**
 * GAME DATA MODULE
 * Centralized metadata store for Shadow Realm: Undead Rising
 */

const GAME_DATA = {
  title: "Shadow Realm: Undead Rising",
  subtitle: "Face the Dark Horde in the Ultimate Tactical Survival Platformer",
  tagline: "Unleash elemental mastery, build impenetrable defenses, and survive endless night in the realm of shadows.",
  description: "Shadow Realm: Undead Rising combines fast-paced dark fantasy action platforming with tactical tower defense mechanics. Battle across 10 dangerous elemental realms, unlock legendary weaponry, and face endless wave survival in Zombie Mode.",
  releaseDate: "2025-10-31",
  version: "v2.4.0 (Latest Update)",
  developer: "Nvisov Game Studios",
  genre: "2D Action Platformer / Survival / Tower Defense",
  platforms: ["PC (Windows/Linux)", "Web Browser", "Android", "iOS"],

  stats: [
    { value: "10+", label: "Elemental Realms" },
    { value: "100+", label: "Max Zombie Waves" },
    { value: "15+", label: "Legendary Weapons" },
    { value: "1M+", label: "Active Hunters" }
  ],

  // 10 Normal Levels required
  levels: [
    {
      id: 1,
      name: "Forest Realm",
      element: "Nature",
      color: "#22c55e",
      badge: "Level 1",
      icon: "🌲",
      description: "Dense, mist-shrouded ancient woods inhabited by infected flora and swift shadow stalkers. Master wall-jumps and tree canopy navigation.",
      boss: "Sylvan Abomination",
      difficulty: "Starter"
    },
    {
      id: 2,
      name: "Fire Realm",
      element: "Flame",
      color: "#ef4444",
      badge: "Level 2",
      icon: "🔥",
      description: "Scorched volcanic caverns with rising magma pools and flame-infused skeletal warriors. Fire resistance and mobility are key.",
      boss: "Inferno Behemoth",
      difficulty: "Moderate"
    },
    {
      id: 3,
      name: "Water Realm",
      element: "Hydro",
      color: "#06b6d4",
      badge: "Level 3",
      icon: "🌊",
      description: "Submerged ruins with treacherous underwater currents, drowned leviathans, and aquatic zombie hazards.",
      boss: "Abyssal Kraken Zombie",
      difficulty: "Challenging"
    },
    {
      id: 4,
      name: "Ice Realm",
      element: "Frost",
      color: "#38bdf8",
      badge: "Level 4",
      icon: "❄️",
      description: "Frozen tundra glaciers with slippery platforms, blinding blizzards, and ice-armored undead berserkers.",
      boss: "Glacial Lich King",
      difficulty: "Challenging"
    },
    {
      id: 5,
      name: "Desert Realm",
      element: "Earth/Sand",
      color: "#f59e0b",
      badge: "Level 5",
      icon: "🏜️",
      description: "Shifting dunes and tomb ruins overrun by mummy hordes, quicksand traps, and sandstorm wraiths.",
      boss: "Pharaoh's Undead Titan",
      difficulty: "Hard"
    },
    {
      id: 6,
      name: "Thunder Realm",
      element: "Lightning",
      color: "#eab308",
      badge: "Level 6",
      icon: "⚡",
      description: "High-voltage skyward citadels filled with Tesla coils, lightning traps, and hyper-agile charged ghouls.",
      boss: "Storm Lord Raijin",
      difficulty: "Hard"
    },
    {
      id: 7,
      name: "Poison Realm",
      element: "Toxin",
      color: "#a855f7",
      badge: "Level 7",
      icon: "🧪",
      description: "Corrosive swamps and toxic refineries leaking lethal sludge that drains health unless purified.",
      boss: "Venomous Broodmother",
      difficulty: "Expert"
    },
    {
      id: 8,
      name: "Sky Realm",
      element: "Wind/Aether",
      color: "#38bdf8",
      badge: "Level 8",
      icon: "☁️",
      description: "Floating islands high in the stratosphere featuring gale-force winds and winged gargoyle undead.",
      boss: "Zephyr Doomwing",
      difficulty: "Expert"
    },
    {
      id: 9,
      name: "Shadow Realm",
      element: "Void",
      color: "#6366f1",
      badge: "Level 9",
      icon: "👁️",
      description: "The abyssal nightmare dimensions where light fades, shadows come alive, and illusions test your reflexes.",
      boss: "Void Reaper Malakor",
      difficulty: "Master"
    },
    {
      id: 10,
      name: "Crystal Realm",
      element: "Prism/Cosmic",
      color: "#ec4899",
      badge: "Level 10 (Final)",
      icon: "💎",
      description: "The final cosmic convergence chamber. Prismatic laser hazards and the ultimate zombie overlord await.",
      boss: "Crystal Undead Sovereign",
      difficulty: "Nightmare"
    }
  ],

  // Feature cards
  features: [
    {
      id: "adventure",
      icon: "🗺️",
      title: "Epic Dark Adventure",
      description: "Journey through a rich, atmospheric dark fantasy world across 10 hand-crafted elemental realms."
    },
    {
      id: "combat",
      icon: "⚔️",
      title: "Fluid High-Octane Combat",
      description: "Chain melee strikes, dash dodges, ranged firepower, and elemental spell casts seamlessly."
    },
    {
      id: "exploration",
      icon: "🔍",
      title: "Secrets & Exploration",
      description: "Discover hidden supply chests, lore scrolls, secret challenge rooms, and hidden weapon blueprints."
    },
    {
      id: "levels",
      icon: "🏔️",
      title: "10 Elemental Levels",
      description: "From Scorched Lava Caverns to Void Crystal Palaces, each level introduces unique hazards and enemies."
    },
    {
      id: "enemies",
      icon: "🧟",
      title: "Dynamic AI Enemies",
      description: "Over 25 distinct enemy types featuring flankers, armored juggernauts, ranged spitters, and flying stalkers."
    },
    {
      id: "weapons",
      icon: "🔫",
      title: "Arsenal & Upgrades",
      description: "Equip swords, plasma rifles, rocket launchers, and the legendary AK-47 air-drop crate unlock."
    },
    {
      id: "towers",
      icon: "🏰",
      title: "Tactical Defense Towers",
      description: "Construct elemental watchtowers, flame turrets, and frost dispensers to protect your strongholds."
    },
    {
      id: "zombies",
      icon: "☣️",
      title: "Deterministic Zombie Mode",
      description: "Test your survival skills against escalating horde waves from 10 to 100+ relentless zombies."
    },
    {
      id: "environments",
      icon: "🎨",
      title: "Cinematic Visual Environments",
      description: "Stunning parallax backgrounds, glowing particle effects, and dynamic weather lighting system."
    }
  ],

  // Zombie Mode details
  zombieMode: {
    title: "Zombie Mode: Endless Wave Survival",
    subtitle: "Survive 10 Deterministic Waves of Undead Escalation",
    overview: "In Zombie Mode, players face relentless waves of undead horrors. The wave system scales deterministically: Wave 1 starts with 10 standard walkers, scaling up to 100+ bloodthirsty nightstalkers by Wave 10.",
    features: [
      {
        title: "Wave Scaling System",
        desc: "Deterministic enemy spawning starting at 10 zombies in Wave 1, adding +10 zombies per wave up to Wave 10 (100 zombies)."
      },
      {
        title: "Milestone Air-Drops",
        desc: "Eliminating 10 zombies triggers a supply crate skydrop animation containing the ultimate AK-47 assault rifle unlock."
      },
      {
        title: "Defense Watchtowers",
        desc: "Build and upgrade defensive watchtowers around the arena to auto-target approaching horde clusters."
      },
      {
        title: "Diverse Zombie Types",
        desc: "Encounter 1-hit Walker Zombies, swift Runners, toxic Spitters, and massive Armored Juggernaut Abominations."
      },
      {
        title: "Endless Procedural World",
        desc: "Dynamic terrain generation and randomized supply crate drops ensure endless tactical replayability."
      }
    ]
  },

  // Weapons Showcase
  weapons: [
    {
      name: "Shadow Blade",
      category: "Melee",
      damage: "85 DMG",
      rate: "Fast",
      icon: "🗡️",
      description: "High-speed dark katana capable of slashing through multiple clustered zombies."
    },
    {
      name: "AK-47 Supply Dropper",
      category: "Assault Rifle",
      damage: "120 DMG",
      rate: "Rapid",
      icon: "🔫",
      description: "Unlocked via the 10-kill milestone supply crate drop. Devastating full-auto firepower."
    },
    {
      name: "Frostbite Bow",
      category: "Ranged",
      damage: "150 DMG",
      rate: "Medium",
      icon: "🏹",
      description: "Fires piercing ice arrows that slow and freeze entire horde corridors."
    },
    {
      name: "Inferno Mortar",
      category: "Heavy",
      damage: "300 DMG",
      rate: "Slow",
      icon: "💣",
      description: "Launches explosive magma shells that obliterate armored zombies in wide splash zones."
    }
  ],

  // Game Controls
  controls: {
    keyboard: [
      { key: "W / A / S / D", action: "Move Player / Jump / Crouch" },
      { key: "SPACE", action: "Jump / Double Jump Dash" },
      { key: "J or Left Click", action: "Melee Attack / Fire Weapon" },
      { key: "K or Right Click", action: "Throw Grenade / Special Ability" },
      { key: "E", action: "Interact / Open Supply Crate" },
      { key: "1 - 4", action: "Switch Active Weapons" },
      { key: "ESC", action: "Pause Game / Settings Menu" }
    ],
    touch: [
      { key: "Virtual Joystick", action: "Smooth 360-degree player movement" },
      { key: "Jump Button", action: "Tap for single jump, double tap for air dash" },
      { key: "Attack Button", action: "Hold for rapid fire / continuous melee strikes" },
      { key: "Weapon Wheel", action: "Quick swipe to switch weapons on the fly" }
    ]
  },

  // Photo Gallery metadata (b.png, c.png, d.png, e.png)
  gallery: [
    {
      id: "img-1",
      src: "b.png",
      altSrc: "assets/images/b.png",
      title: "Inferno Arena Combat",
      category: "combat",
      caption: "Slaying elite fire specters in the lava chambers of Level 2."
    },
    {
      id: "img-2",
      src: "c.png",
      altSrc: "assets/images/c.png",
      title: "Glacial Ice Ruins",
      category: "environment",
      caption: "Exploring ancient ice temples with dynamic refraction visual effects."
    },
    {
      id: "img-3",
      src: "d.png",
      altSrc: "assets/images/d.png",
      title: "Crystal Realm Boss Fight",
      category: "bosses",
      caption: "Facing the Void Sovereign inside the cosmic crystal stronghold."
    },
    {
      id: "img-4",
      src: "e.png",
      altSrc: "assets/images/e.png",
      title: "Zombie Mode Skydrop Event",
      category: "zombies",
      caption: "Opening the 10-kill milestone crate to equip the AK-47 assault rifle."
    }
  ],

  // Video Gallery metadata (a.mp4, b.mp4, c.mp4, d.mp4)
  videos: [
    {
      id: "vid-1",
      src: "a.mp4",
      altSrc: "assets/videos/a.mp4",
      poster: "a.png",
      altPoster: "assets/images/a.png",
      title: "Official Gameplay Reveal Trailer",
      duration: "01:45",
      tag: "Official Trailer",
      description: "Experience the adrenaline-pumping gameplay of Shadow Realm: Undead Rising featuring fast-paced combat and elemental spells."
    },
    {
      id: "vid-2",
      src: "b.mp4",
      altSrc: "assets/videos/b.mp4",
      poster: "b.png",
      altPoster: "assets/images/b.png",
      title: "Zombie Mode Survival Spotlight",
      duration: "02:10",
      tag: "Survival Mode",
      description: "A deep dive into 10-wave zombie survival, watchtower defense strategies, and AK-47 crate unlocks."
    },
    {
      id: "vid-3",
      src: "c.mp4",
      altSrc: "assets/videos/c.mp4",
      poster: "c.png",
      altPoster: "assets/images/c.png",
      title: "10 Elemental Realms Showcase",
      duration: "01:30",
      tag: "Realms Overview",
      description: "Tour through all 10 distinct elemental environments from the Forest Woods to the Crystal Cosmic Convergence."
    },
    {
      id: "vid-4",
      src: "d.mp4",
      altSrc: "assets/videos/d.mp4",
      poster: "d.png",
      altPoster: "assets/images/d.png",
      title: "Weapons & Watchtowers Arsenal",
      duration: "01:15",
      tag: "Weapons Guide",
      description: "Learn how to craft elemental watchtowers and upgrade legendary firearms to obliterate enemy bosses."
    }
  ]
};

if (typeof module !== 'undefined' && module.exports) {
  module.exports = GAME_DATA;
}
