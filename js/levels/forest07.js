/* Level 07: Forest Temple */
class Level07 extends Level01 {
    constructor() {
        super();
        this.name = "Forest Temple";
        this.objective = "Bypass temple traps to reach the Guardian's lair";
        this.parallax = new window.ParallaxBackground('temple');
        this.totalCrystals = 8;
    }

    initLevel(player, particles) {
        this.enemies = [
            new window.AncientGuardian(500, 448),
            new window.FlyingSpirit(900, 180),
            new window.AncientGuardian(1400, 448),
            new window.ShadowBeast(1900, 480),
            new window.AncientGuardian(2400, 448)
        ];

        this.collectibles = [
            new window.Collectible(400, 300, 'crystal'),
            new window.Collectible(800, 250, 'crystal'),
            new window.Collectible(1200, 200, 'crystal'),
            new window.Collectible(1600, 280, 'crystal'),
            new window.Collectible(2000, 320, 'crystal'),
            new window.Collectible(2400, 300, 'crystal'),
            new window.Collectible(2700, 350, 'crystal'),
            new window.Collectible(2900, 300, 'crystal'),
            new window.HiddenChest(1600, 480)
        ];

        this.checkpoints = [
            new window.Checkpoint(1500, 464, 'cp7_1')
        ];

        this.portals = [
            new window.DoorPortal(3080, 448, 8)
        ];
    }
}

window.Level07 = Level07;
