/* Level 05: Giant Tree */
class Level05 extends Level01 {
    constructor() {
        super();
        this.name = "Giant Tree";
        this.objective = "Climb the ancient canopy platforms";
        this.parallax = new window.ParallaxBackground('forest');
        this.totalCrystals = 6;
    }

    initLevel(player, particles) {
        this.enemies = [
            new window.FlyingSpirit(400, 200),
            new window.ForestSlime(700, 480),
            new window.FlyingSpirit(1100, 150),
            new window.ThornCreature(1600, 480),
            new window.FlyingSpirit(2100, 220)
        ];

        this.collectibles = [
            new window.Collectible(400, 150, 'crystal'),
            new window.Collectible(800, 250, 'crystal'),
            new window.Collectible(1200, 180, 'crystal'),
            new window.Collectible(1600, 220, 'crystal'),
            new window.Collectible(2000, 260, 'crystal'),
            new window.Collectible(2500, 300, 'crystal'),
            new window.HiddenChest(1800, 480)
        ];

        this.checkpoints = [
            new window.Checkpoint(1400, 464, 'cp5_1')
        ];

        this.portals = [
            new window.DoorPortal(3080, 448, 6)
        ];
    }
}

window.Level05 = Level05;
