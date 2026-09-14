/* Level 02: Misty Forest */
class Level02 extends Level01 {
    constructor() {
        super();
        this.name = "Misty Forest";
        this.objective = "Navigate through the heavy enchanted mist";
        this.parallax = new window.ParallaxBackground('forest');
        this.totalCrystals = 6;
    }

    initLevel(player, particles) {
        this.enemies = [
            new window.FlyingSpirit(300, 250),
            new window.ForestSlime(600, 480),
            new window.FlyingSpirit(900, 200),
            new window.ShadowBeast(1400, 480),
            new window.GiantSpider(1900, 200),
            new window.ThornCreature(2400, 480)
        ];

        this.collectibles = [
            new window.Collectible(300, 200, 'crystal'),
            new window.Collectible(600, 300, 'crystal'),
            new window.Collectible(1000, 250, 'crystal'),
            new window.Collectible(1400, 350, 'energy'),
            new window.Collectible(1900, 300, 'crystal'),
            new window.Collectible(2400, 250, 'crystal'),
            new window.Collectible(2800, 300, 'crystal'),
            new window.HiddenChest(2100, 480)
        ];

        this.checkpoints = [
            new window.Checkpoint(1500, 464, 'cp2_1')
        ];

        this.portals = [
            new window.DoorPortal(3080, 448, 3)
        ];
    }
}

window.Level02 = Level02;
