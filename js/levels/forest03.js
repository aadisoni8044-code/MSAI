/* Level 03: Forgotten Ruins */
class Level03 extends Level01 {
    constructor() {
        super();
        this.name = "Forgotten Ruins";
        this.objective = "Find the Ancient Key to unlock the Temple gate";
        this.parallax = new window.ParallaxBackground('ruins');
        this.requiredKeys = 1;
        this.totalCrystals = 6;
    }

    initLevel(player, particles) {
        this.enemies = [
            new window.AncientGuardian(500, 448),
            new window.ThornCreature(900, 480),
            new window.FlyingSpirit(1300, 200),
            new window.ShadowBeast(1800, 480),
            new window.AncientGuardian(2300, 448)
        ];

        this.collectibles = [
            new window.Collectible(500, 350, 'key'),
            new window.Collectible(800, 300, 'crystal'),
            new window.Collectible(1200, 250, 'crystal'),
            new window.Collectible(1600, 300, 'crystal'),
            new window.Collectible(2000, 280, 'crystal'),
            new window.Collectible(2500, 350, 'crystal'),
            new window.HiddenChest(1600, 480)
        ];

        this.checkpoints = [
            new window.Checkpoint(1400, 464, 'cp3_1')
        ];

        this.portals = [
            new window.DoorPortal(3080, 448, 4)
        ];
    }
}

window.Level03 = Level03;
