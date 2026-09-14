/* SYLVAN WHISPERS - LEVEL DESIGN & SECTION GENERATOR */
window.LevelManager = (function() {

    // 5 Distinct Forest Regions inspired by the deep teal fantasy forest art
    const SECTIONS = [
        {
            id: 0,
            title: 'Forest Entrance',
            subtitle: 'The Edge of Sylvan Realm',
            theme: {
                skyTop: '#041017',
                skyBottom: '#0b242a',
                fogColor: 'rgba(78, 252, 228, 0.05)',
                treeBark: '#1b3238',
                leafColor: '#14b8a6',
                accentLight: '#4efce4'
            },
            width: 3200,
            height: 800,
            spawnX: 120,
            spawnY: 550,
            platforms: [
                // Ground platforms
                { x: 0, y: 650, width: 1200, height: 150, type: 'ground' },
                { x: 1300, y: 650, width: 900, height: 150, type: 'ground' },
                { x: 2300, y: 650, width: 900, height: 150, type: 'ground' },
                // Stepping platforms
                { x: 400, y: 520, width: 140, height: 24, isOneWay: true },
                { x: 620, y: 410, width: 140, height: 24, isOneWay: true },
                { x: 840, y: 320, width: 180, height: 24, isOneWay: true },
                { x: 1200, y: 550, width: 120, height: 24, isOneWay: true },
                { x: 1450, y: 460, width: 160, height: 24, isOneWay: true },
                { x: 1750, y: 380, width: 200, height: 24, isOneWay: true },
                { x: 2050, y: 480, width: 150, height: 24, isOneWay: true }
            ],
            hazards: [
                { x: 1200, y: 760, width: 100, height: 40, type: 'abyss' },
                { x: 2200, y: 760, width: 100, height: 40, type: 'abyss' },
                { x: 750, y: 626, width: 80, height: 24, type: 'spikes' }
            ],
            orbs: [
                { id: 'sec0_1', x: 460, y: 470, collected: false },
                { id: 'sec0_2', x: 680, y: 360, collected: false },
                { id: 'sec0_3', x: 920, y: 270, collected: false },
                { id: 'sec0_4', x: 1520, y: 410, collected: false },
                { id: 'sec0_5', x: 1850, y: 330, collected: false }
            ],
            checkpoints: [
                { id: 'cp_0_1', x: 1350, y: 580, active: false }
            ],
            tablets: [
                { x: 250, y: 590, text: 'Ancient Sylvan Legend: Beware the shadows that lurk within the Canopy.' }
            ],
            enemies: [
                { type: 'patrol', x: 800, y: 600, patrolMin: 650, patrolMax: 1050 },
                { type: 'patrol', x: 1600, y: 600, patrolMin: 1400, patrolMax: 1800 },
                { type: 'flyer', x: 900, y: 240, minY: 180, maxY: 380 },
                { type: 'flyer', x: 1800, y: 280, minY: 200, maxY: 420 }
            ],
            nextPortal: { x: 3050, y: 550, targetSection: 1 }
        },
        {
            id: 1,
            title: 'Ancient Tree Area',
            subtitle: 'Canopy of Eternal Spirits',
            theme: {
                skyTop: '#021219',
                skyBottom: '#07323a',
                fogColor: 'rgba(34, 211, 238, 0.08)',
                treeBark: '#264248',
                leafColor: '#22d3ee',
                accentLight: '#67e8f9'
            },
            width: 3400,
            height: 900,
            spawnX: 120,
            spawnY: 650,
            platforms: [
                { x: 0, y: 750, width: 800, height: 150, type: 'ground' },
                { x: 950, y: 750, width: 1000, height: 150, type: 'ground' },
                { x: 2100, y: 750, width: 1300, height: 150, type: 'ground' },
                // Ancient giant tree branch platforms
                { x: 300, y: 600, width: 180, height: 28, isOneWay: true },
                { x: 550, y: 480, width: 180, height: 28, isOneWay: true },
                { x: 800, y: 360, width: 220, height: 28, isOneWay: true },
                { x: 1150, y: 480, width: 160, height: 28, isOneWay: true },
                { x: 1400, y: 360, width: 240, height: 28, isOneWay: true },
                { x: 1750, y: 260, width: 180, height: 28, isOneWay: true },
                { x: 2050, y: 380, width: 160, height: 28, isOneWay: true },
                { x: 2350, y: 500, width: 180, height: 28, isOneWay: true },
                { x: 2650, y: 620, width: 200, height: 28, isOneWay: true }
            ],
            hazards: [
                { x: 800, y: 860, width: 150, height: 40, type: 'abyss' },
                { x: 1950, y: 860, width: 150, height: 40, type: 'abyss' },
                { x: 1250, y: 726, width: 100, height: 24, type: 'spikes' }
            ],
            orbs: [
                { id: 'sec1_1', x: 600, y: 430, collected: false },
                { id: 'sec1_2', x: 890, y: 310, collected: false },
                { id: 'sec1_3', x: 1500, y: 310, collected: false },
                { id: 'sec1_4', x: 1840, y: 210, collected: false },
                { id: 'sec1_5', x: 2440, y: 450, collected: false }
            ],
            checkpoints: [
                { id: 'cp_1_1', x: 1050, y: 680, active: false }
            ],
            tablets: [
                { x: 1000, y: 690, text: 'The Great Sylvan Tree holds ancient power. Jump higher across its branches.' }
            ],
            enemies: [
                { type: 'patrol', x: 400, y: 700, patrolMin: 200, patrolMax: 700 },
                { type: 'flyer', x: 850, y: 280, minY: 200, maxY: 400 },
                { type: 'shadow', x: 1500, y: 300, patrolMin: 1400, patrolMax: 1620 },
                { type: 'flyer', x: 2200, y: 300, minY: 220, maxY: 450 }
            ],
            nextPortal: { x: 3200, y: 650, targetSection: 2 }
        },
        {
            id: 2,
            title: 'Dark Swamp',
            subtitle: 'Murky Depths & Bioluminescence',
            theme: {
                skyTop: '#061316',
                skyBottom: '#0e2b25',
                fogColor: 'rgba(16, 185, 129, 0.08)',
                treeBark: '#183830',
                leafColor: '#10b981',
                accentLight: '#34d399'
            },
            width: 3600,
            height: 850,
            spawnX: 120,
            spawnY: 600,
            platforms: [
                { x: 0, y: 700, width: 700, height: 150, type: 'ground' },
                { x: 850, y: 700, width: 700, height: 150, type: 'ground' },
                { x: 1700, y: 700, width: 800, height: 150, type: 'ground' },
                { x: 2650, y: 700, width: 950, height: 150, type: 'ground' },
                // Swamp log platforms
                { x: 450, y: 560, width: 140, height: 24, isOneWay: true },
                { x: 720, y: 460, width: 150, height: 24, isOneWay: true },
                { x: 1000, y: 540, width: 140, height: 24, isOneWay: true },
                { x: 1250, y: 440, width: 160, height: 24, isOneWay: true },
                { x: 1500, y: 340, width: 180, height: 24, isOneWay: true },
                { x: 1950, y: 550, width: 150, height: 24, isOneWay: true },
                { x: 2200, y: 440, width: 160, height: 24, isOneWay: true },
                { x: 2450, y: 560, width: 150, height: 24, isOneWay: true }
            ],
            hazards: [
                { x: 700, y: 810, width: 150, height: 40, type: 'abyss' },
                { x: 1550, y: 810, width: 150, height: 40, type: 'abyss' },
                { x: 2500, y: 810, width: 150, height: 40, type: 'abyss' },
                { x: 1100, y: 676, width: 120, height: 24, type: 'spikes' }
            ],
            orbs: [
                { id: 'sec2_1', x: 500, y: 510, collected: false },
                { id: 'sec2_2', x: 780, y: 410, collected: false },
                { id: 'sec2_3', x: 1300, y: 390, collected: false },
                { id: 'sec2_4', x: 1580, y: 290, collected: false },
                { id: 'sec2_5', x: 2260, y: 390, collected: false }
            ],
            checkpoints: [
                { id: 'cp_2_1', x: 1750, y: 630, active: false }
            ],
            tablets: [
                { x: 900, y: 640, text: 'The swamp water is treacherous. Tread carefully across floating moss roots.' }
            ],
            enemies: [
                { type: 'patrol', x: 300, y: 650, patrolMin: 150, patrolMax: 600 },
                { type: 'shadow', x: 1050, y: 480, patrolMin: 1000, patrolMax: 1120 },
                { type: 'shadow', x: 1850, y: 650, patrolMin: 1720, patrolMax: 2300 },
                { type: 'flyer', x: 2300, y: 350, minY: 250, maxY: 480 }
            ],
            nextPortal: { x: 3450, y: 600, targetSection: 3 }
        },
        {
            id: 3,
            title: 'Hidden Cave',
            subtitle: 'Whispering Crystals & Gloom',
            theme: {
                skyTop: '#030a11',
                skyBottom: '#071827',
                fogColor: 'rgba(99, 102, 241, 0.08)',
                treeBark: '#1e293b',
                leafColor: '#6366f1',
                accentLight: '#818cf8'
            },
            width: 3800,
            height: 900,
            spawnX: 120,
            spawnY: 650,
            platforms: [
                { x: 0, y: 750, width: 600, height: 150, type: 'ground' },
                { x: 750, y: 750, width: 800, height: 150, type: 'ground' },
                { x: 1700, y: 750, width: 800, height: 150, type: 'ground' },
                { x: 2700, y: 750, width: 1100, height: 150, type: 'ground' },
                // Crystal cavern ledge platforms
                { x: 380, y: 600, width: 140, height: 26, isOneWay: true },
                { x: 600, y: 480, width: 150, height: 26, isOneWay: true },
                { x: 850, y: 380, width: 180, height: 26, isOneWay: true },
                { x: 1150, y: 480, width: 150, height: 26, isOneWay: true },
                { x: 1400, y: 360, width: 200, height: 26, isOneWay: true },
                { x: 1800, y: 580, width: 160, height: 26, isOneWay: true },
                { x: 2050, y: 460, width: 160, height: 26, isOneWay: true },
                { x: 2350, y: 350, width: 180, height: 26, isOneWay: true },
                { x: 2600, y: 480, width: 150, height: 26, isOneWay: true }
            ],
            hazards: [
                { x: 600, y: 860, width: 150, height: 40, type: 'abyss' },
                { x: 1550, y: 860, width: 150, height: 40, type: 'abyss' },
                { x: 2500, y: 860, width: 200, height: 40, type: 'abyss' },
                { x: 950, y: 724, width: 120, height: 26, type: 'spikes' },
                { x: 1950, y: 724, width: 120, height: 26, type: 'spikes' }
            ],
            orbs: [
                { id: 'sec3_1', x: 440, y: 550, collected: false },
                { id: 'sec3_2', x: 920, y: 330, collected: false },
                { id: 'sec3_3', x: 1480, y: 310, collected: false },
                { id: 'sec3_4', x: 2110, y: 410, collected: false },
                { id: 'sec3_5', x: 2420, y: 300, collected: false }
            ],
            checkpoints: [
                { id: 'cp_3_1', x: 1750, y: 680, active: false }
            ],
            tablets: [
                { x: 800, y: 690, text: 'Glow-crystals illuminate the path forward. Shadow creatures lurk ahead.' }
            ],
            enemies: [
                { type: 'shadow', x: 400, y: 700, patrolMin: 150, patrolMax: 550 },
                { type: 'shadow', x: 1000, y: 700, patrolMin: 800, patrolMax: 1400 },
                { type: 'flyer', x: 1450, y: 280, minY: 200, maxY: 400 },
                { type: 'shadow', x: 2100, y: 400, patrolMin: 2050, patrolMax: 2200 },
                { type: 'flyer', x: 2800, y: 400, minY: 300, maxY: 600 }
            ],
            nextPortal: { x: 3650, y: 650, targetSection: 4 }
        },
        {
            id: 4,
            title: 'Ancient Temple',
            subtitle: 'Sanctuary of Sylvan Light',
            theme: {
                skyTop: '#081c1b',
                skyBottom: '#103e3a',
                fogColor: 'rgba(245, 158, 11, 0.08)',
                treeBark: '#334155',
                leafColor: '#f59e0b',
                accentLight: '#fbbf24'
            },
            width: 4000,
            height: 950,
            spawnX: 120,
            spawnY: 700,
            platforms: [
                { x: 0, y: 800, width: 800, height: 150, type: 'ground' },
                { x: 950, y: 800, width: 800, height: 150, type: 'ground' },
                { x: 1900, y: 800, width: 800, height: 150, type: 'ground' },
                { x: 2850, y: 800, width: 1150, height: 150, type: 'ground' },
                // Temple stone pillars and altars
                { x: 450, y: 660, width: 160, height: 28, isOneWay: true },
                { x: 700, y: 520, width: 180, height: 28, isOneWay: true },
                { x: 1000, y: 400, width: 200, height: 28, isOneWay: true },
                { x: 1300, y: 520, width: 160, height: 28, isOneWay: true },
                { x: 1550, y: 380, width: 220, height: 28, isOneWay: true },
                { x: 2000, y: 650, width: 160, height: 28, isOneWay: true },
                { x: 2250, y: 500, width: 180, height: 28, isOneWay: true },
                { x: 2550, y: 380, width: 220, height: 28, isOneWay: true },
                { x: 2900, y: 520, width: 200, height: 28, isOneWay: true },
                { x: 3250, y: 650, width: 240, height: 28, isOneWay: true }
            ],
            hazards: [
                { x: 800, y: 910, width: 150, height: 40, type: 'abyss' },
                { x: 1750, y: 910, width: 150, height: 40, type: 'abyss' },
                { x: 2700, y: 910, width: 150, height: 40, type: 'abyss' },
                { x: 1200, y: 774, width: 140, height: 26, type: 'spikes' },
                { x: 2150, y: 774, width: 140, height: 26, type: 'spikes' }
            ],
            orbs: [
                { id: 'sec4_1', x: 520, y: 610, collected: false },
                { id: 'sec4_2', x: 1090, y: 340, collected: false },
                { id: 'sec4_3', x: 1640, y: 320, collected: false },
                { id: 'sec4_4', x: 2330, y: 440, collected: false },
                { id: 'sec4_5', x: 2640, y: 320, collected: false }
            ],
            checkpoints: [
                { id: 'cp_4_1', x: 1950, y: 730, active: false }
            ],
            tablets: [
                { x: 1000, y: 740, text: 'The Temple Altar lies ahead. Cleanse the forest to complete your quest!' }
            ],
            enemies: [
                { type: 'patrol', x: 400, y: 750, patrolMin: 150, patrolMax: 700 },
                { type: 'shadow', x: 1100, y: 750, patrolMin: 980, patrolMax: 1600 },
                { type: 'flyer', x: 1600, y: 300, minY: 200, maxY: 420 },
                { type: 'shadow', x: 2100, y: 750, patrolMin: 1950, patrolMax: 2600 },
                { type: 'flyer', x: 2600, y: 320, minY: 220, maxY: 450 },
                { type: 'shadow', x: 3000, y: 750, patrolMin: 2900, patrolMax: 3400 }
            ],
            nextPortal: { x: 3800, y: 700, isFinalVictory: true }
        }
    ];

    function getSection(index) {
        if (index < 0 || index >= SECTIONS.length) return SECTIONS[0];
        return SECTIONS[index];
    }

    return {
        sections: SECTIONS,
        getSection
    };
})();
