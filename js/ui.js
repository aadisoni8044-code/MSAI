/* SYLVAN WHISPERS - UI & HUD MANAGER */
window.UIManager = (function() {
    let healthBarInner = null;
    let healthText = null;
    let staminaBarInner = null;
    let staminaText = null;
    let collectibleCount = null;
    let interactionPrompt = null;
    let interactionText = null;
    let sectionBanner = null;
    let sectionTitle = null;
    let sectionSubtitle = null;

    let bannerTimeout = null;

    function init() {
        healthBarInner = document.getElementById('health-bar-inner');
        healthText = document.getElementById('health-text');
        staminaBarInner = document.getElementById('stamina-bar-inner');
        staminaText = document.getElementById('stamina-text');
        collectibleCount = document.getElementById('collectible-count');
        interactionPrompt = document.getElementById('interaction-prompt');
        interactionText = document.getElementById('interaction-text');
        sectionBanner = document.getElementById('section-banner');
        sectionTitle = document.getElementById('section-title');
        sectionSubtitle = document.getElementById('section-subtitle');
    }

    function updateHUD(health, maxHealth, stamina, maxStamina, collectibles, totalCollectibles = 25) {
        if (healthBarInner) {
            const hpPct = Math.max(0, Math.min(100, (health / maxHealth) * 100));
            healthBarInner.style.width = hpPct + '%';
        }
        if (healthText) {
            healthText.textContent = `${Math.ceil(health)} / ${maxHealth}`;
        }
        if (staminaBarInner) {
            const stPct = Math.max(0, Math.min(100, (stamina / maxStamina) * 100));
            staminaBarInner.style.width = stPct + '%';
        }
        if (staminaText) {
            staminaText.textContent = `${Math.ceil(stamina)} / ${maxStamina}`;
        }
        if (collectibleCount) {
            collectibleCount.textContent = collectibles;
        }
    }

    function showSectionBanner(title, subtitle = '') {
        if (!sectionBanner || !sectionTitle) return;

        sectionTitle.textContent = title;
        if (sectionSubtitle) sectionSubtitle.textContent = subtitle;

        sectionBanner.classList.remove('hidden');
        sectionBanner.style.opacity = '1';

        if (bannerTimeout) clearTimeout(bannerTimeout);

        bannerTimeout = setTimeout(() => {
            sectionBanner.style.opacity = '0';
            setTimeout(() => {
                sectionBanner.classList.add('hidden');
            }, 800);
        }, 3000);
    }

    function showInteraction(promptText) {
        if (!interactionPrompt || !interactionText) return;
        interactionText.textContent = promptText;
        interactionPrompt.classList.remove('hidden');
    }

    function hideInteraction() {
        if (!interactionPrompt) return;
        interactionPrompt.classList.add('hidden');
    }

    function showModal(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.classList.remove('hidden');
        }
    }

    function hideModal(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.classList.add('hidden');
        }
    }

    function showScreen(screenId) {
        const screens = document.querySelectorAll('.screen');
        screens.forEach(s => s.classList.remove('active'));

        const target = document.getElementById(screenId);
        if (target) {
            target.classList.add('active');
        }
    }

    return {
        init,
        updateHUD,
        showSectionBanner,
        showInteraction,
        hideInteraction,
        showModal,
        hideModal,
        showScreen
    };
})();
