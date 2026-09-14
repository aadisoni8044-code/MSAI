/* Level 08: Final Boss Area */
class Level08 extends Level01 {
    constructor() {
        super();
        this.name = "Final Boss Area";
        this.objective = "Defeat the Corrupted Ancient Forest Guardian!";
        this.isBossLevel = true;
        this.cols = 45; // Arena layout
        this.width = this.cols * this.tileSize;
        this.spawnX = 120;
        this.spawnY = 450;
        this.parallax = new window.ParallaxBackground('temple');
        this.boss = null;
        this.totalCrystals = 1;
    }

    initLevel(player, particles) {
        // Instantiate Boss
        this.boss = new window.ForestBoss(900, 370);
        this.enemies = [this.boss];

        // Arena Health Drops & Rewards
        this.collectibles = [
            new window.Collectible(300, 350, 'health'),
            new window.Collectible(1100, 350, 'energy')
        ];

        this.checkpoints = [
            new window.Checkpoint(80, 464, 'cp8_1')
        ];

        window.hudManager.showBossHealth('ANCIENT FOREST GUARDIAN', this.boss.health, this.boss.maxHealth);
    }

    update(dt, player) {
        super.update(dt, player);

        if (this.boss && !this.boss.isDead) {
            window.hudManager.updateBossHealth(this.boss.health, this.boss.maxHealth);
        }
    }
}

window.Level08 = Level08;
