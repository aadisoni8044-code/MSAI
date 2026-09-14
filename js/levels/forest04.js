/* Level 04: Underground Cave */
class Level04 extends Level01 {
    constructor() {
        super();
        this.name = "Underground Cave";
        this.objective = "Ascend out of the subterranean spider nest";
        this.parallax = new window.ParallaxBackground('cave');
        this.totalCrystals = 7;
    }

    initLevel(player, particles) {
        this.enemies = [
            new window.GiantSpider(400, 150),
            new window.GiantSpider(800, 150),
            new window.FlyingSpirit(1200, 200),
            new window.GiantSpider(1600, 150),
            new window.ShadowBeast(2200, 480)
        ];

        this.collectibles = [
            new window.Collectible(400, 300, 'crystal'),
            new window.Collectible(750, 250, 'crystal'),
            new window.Collectible(1100, 200, 'crystal'),
            new window.Collectible(1500, 280, 'crystal'),
            new window.Collectible(1900, 320, 'crystal'),
            new window.Collectible(2300, 300, 'crystal'),
            new window.Collectible(2700, 350, 'crystal'),
            new window.HiddenChest(1100, 480)
        ];

        this.checkpoints = [
            new window.Checkpoint(1500, 464, 'cp4_1')
        ];

        this.portals = [
            new window.DoorPortal(3080, 448, 5)
        ];
    }
}

window.Level04 = Level04;
