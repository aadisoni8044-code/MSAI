/* HUD UI Manager */
class HUDManager {
    constructor() {
        this.hudLayer = document.getElementById('hud-layer');
        this.healthFill = document.getElementById('health-bar-fill');
        this.healthText = document.getElementById('health-text');
        this.staminaFill = document.getElementById('stamina-bar-fill');
        this.staminaText = document.getElementById('stamina-text');

        this.coinCount = document.getElementById('coin-count');
        this.crystalCount = document.getElementById('crystal-count');
        this.keyCount = document.getElementById('key-count');

        this.objectiveText = document.getElementById('objective-text');
        this.toastMessage = document.getElementById('toast-message');
        this.interactionPrompt = document.getElementById('interaction-prompt');
        this.interactText = document.getElementById('interact-text');

        this.bossContainer = document.getElementById('boss-health-container');
        this.bossName = document.getElementById('boss-name');
        this.bossFill = document.getElementById('boss-health-fill');
        this.bossPhase = document.getElementById('boss-phase-indicator');

        this.btnPause = document.getElementById('btn-pause-hud');
        if (this.btnPause) {
            this.btnPause.addEventListener('click', () => {
                if (window.game) window.game.pauseGame();
            });
        }

        this.toastTimeout = null;
    }

    showHUD() {
        if (this.hudLayer) this.hudLayer.classList.remove('hidden');
    }

    hideHUD() {
        if (this.hudLayer) this.hudLayer.classList.add('hidden');
    }

    update(player) {
        if (!player) return;

        // Health Bar
        const hpPct = Math.max(0, (player.health / player.maxHealth) * 100);
        if (this.healthFill) this.healthFill.style.width = `${hpPct}%`;
        if (this.healthText) this.healthText.textContent = `${Math.ceil(player.health)} / ${player.maxHealth}`;

        // Stamina Bar
        const stPct = Math.max(0, (player.stamina / player.maxStamina) * 100);
        if (this.staminaFill) this.staminaFill.style.width = `${stPct}%`;
        if (this.staminaText) this.staminaText.textContent = `${Math.ceil(player.stamina)} / ${player.maxStamina}`;

        // Collectibles
        if (this.coinCount) this.coinCount.textContent = window.saveSystem.data.coins;
        if (this.crystalCount) this.crystalCount.textContent = window.saveSystem.data.crystals;
        if (this.keyCount) this.keyCount.textContent = window.saveSystem.data.keys;
    }

    updateObjective(text) {
        if (this.objectiveText) this.objectiveText.textContent = text;
    }

    showToast(message, duration = 2500) {
        if (!this.toastMessage) return;
        this.toastMessage.textContent = message;
        this.toastMessage.classList.remove('hidden');

        if (this.toastTimeout) clearTimeout(this.toastTimeout);
        this.toastTimeout = setTimeout(() => {
            this.toastMessage.classList.add('hidden');
        }, duration);
    }

    showInteractPrompt(text) {
        if (!this.interactionPrompt) return;
        if (this.interactText) this.interactText.textContent = text;
        this.interactionPrompt.classList.remove('hidden');
    }

    hideInteractPrompt() {
        if (this.interactionPrompt) this.interactionPrompt.classList.add('hidden');
    }

    showBossHealth(name, currentHp, maxHp) {
        if (!this.bossContainer) return;
        if (this.bossName) this.bossName.textContent = name;
        this.updateBossHealth(currentHp, maxHp);
        this.bossContainer.classList.remove('hidden');
    }

    updateBossHealth(currentHp, maxHp) {
        const pct = Math.max(0, (currentHp / maxHp) * 100);
        if (this.bossFill) this.bossFill.style.width = `${pct}%`;
    }

    updateBossPhase(phaseText) {
        if (this.bossPhase) this.bossPhase.textContent = phaseText;
    }

    hideBossHealth() {
        if (this.bossContainer) this.bossContainer.classList.add('hidden');
    }
}

window.hudManager = new HUDManager();
