/* Level 06: Dark Swamp */
class Level06 extends Level01 {
    constructor() {
        super();
        this.name = "Dark Swamp";
        this.objective = "Leap across sinking platforms avoiding toxic swamp water";
        this.parallax = new window.ParallaxBackground('swamp');
        this.totalCrystals = 6;
    }

    initLevel(player, particles) {
        this.enemies = [
            new window.ForestSlime(500, 480),
            new window.ForestSlime(900, 480),
            new window.ShadowBeast(1400, 480),
            new window.FlyingSpirit(1800, 200),
            new window.ThornCreature(2400, 480)
        ];

        this.collectibles = [
            new window.Collectible(400, 320, 'crystal'),
            new window.Collectible(800, 280, 'crystal'),
            new window.Collectible(1200, 350, 'health'),
            new window.Collectible(1600, 260, 'crystal'),
            new window.Collectible(2000, 300, 'crystal'),
            new window.Collectible(2600, 320, 'crystal'),
            new window.HiddenChest(2200, 480)
        ];

        this.checkpoints = [
            new window.Checkpoint(1500, 464, 'cp6_1')
        ];

        this.portals = [
            new window.DoorPortal(3080, 448, 7)
        ];
    }
}

window.Level06 = Level06;
