/**
 * Pricing / Subscription Plans Controller
 */
import { storage } from './storage.js';
import { notifications } from './notifications.js';
import { i18n } from './language.js';
import { events } from './events.js';
import { sidebarController } from './sidebar.js';

class PricingController {
  constructor() {
    this.pricingScreen = null;
    this.chatContainer = null;
    this.composerWrapper = null;
    this.navPlans = null;
    this.btnBackToChat = null;
    this.currentPlan = 'free';
  }

  init() {
    this.pricingScreen = document.getElementById('pricingScreen');
    this.chatContainer = document.getElementById('chatContainer');
    this.composerWrapper = document.getElementById('composerWrapper');
    this.navPlans = document.getElementById('navPlans');
    this.btnBackToChat = document.getElementById('btnBackToChat');

    this.currentPlan = storage.get('msai_selected_plan', 'free');

    this.setupEvents();
    this.updatePlanStateUI();

    events.on('language:changed', () => this.updateDynamicTexts());
  }

  setupEvents() {
    // Open Pricing Screen from Sidebar
    if (this.navPlans) {
      this.navPlans.addEventListener('click', () => {
        this.showPricingScreen();
      });
    }

    // Back to Chat
    if (this.btnBackToChat) {
      this.btnBackToChat.addEventListener('click', () => {
        this.hidePricingScreen();
      });
    }

    // Expandable Features Toggles
    if (this.pricingScreen) {
      this.pricingScreen.querySelectorAll('.btn-feature-toggle').forEach(btn => {
        btn.addEventListener('click', (e) => {
          e.stopPropagation();
          this.toggleFeatureExpansion(btn);
        });
      });

      // Plan Selection CTAs
      this.pricingScreen.querySelectorAll('.btn-plan-cta').forEach(btn => {
        btn.addEventListener('click', (e) => {
          e.stopPropagation();
          const planId = btn.getAttribute('data-plan-id');
          if (planId) {
            this.selectPlan(planId);
          }
        });
      });

      // Keyboard accessibility for pricing cards
      this.pricingScreen.querySelectorAll('.pricing-card').forEach(card => {
        card.addEventListener('keydown', (e) => {
          if (e.key === 'Enter' || e.key === ' ') {
            if (e.target.classList.contains('pricing-card')) {
              e.preventDefault();
              const cta = card.querySelector('.btn-plan-cta');
              if (cta) cta.click();
            }
          }
        });
      });
    }
  }

  showPricingScreen() {
    if (!this.pricingScreen) return;

    if (this.chatContainer) this.chatContainer.classList.add('hidden');
    if (this.composerWrapper) this.composerWrapper.classList.add('hidden');

    this.pricingScreen.classList.remove('hidden');
    this.updatePlanStateUI();

    if (sidebarController && typeof sidebarController.closeMobileSidebar === 'function') {
      sidebarController.closeMobileSidebar();
    }
  }

  hidePricingScreen() {
    if (!this.pricingScreen) return;

    this.pricingScreen.classList.add('hidden');
    if (this.chatContainer) this.chatContainer.classList.remove('hidden');
    if (this.composerWrapper) this.composerWrapper.classList.remove('hidden');
  }

  toggleFeatureExpansion(btn) {
    const targetId = btn.getAttribute('data-target');
    const targetEl = document.getElementById(targetId);
    if (!targetEl) return;

    const isExpanded = btn.getAttribute('aria-expanded') === 'true';

    if (isExpanded) {
      btn.setAttribute('aria-expanded', 'false');
      targetEl.classList.remove('expanded');
      targetEl.classList.add('collapsed');
      const textSpan = btn.querySelector('.toggle-text');
      if (textSpan) {
        textSpan.textContent = i18n.get('pricing.showFeatures', 'Show all features');
      }
    } else {
      btn.setAttribute('aria-expanded', 'true');
      targetEl.classList.remove('collapsed');
      targetEl.classList.add('expanded');
      const textSpan = btn.querySelector('.toggle-text');
      if (textSpan) {
        textSpan.textContent = i18n.get('pricing.hideFeatures', 'Hide features');
      }
    }
  }

  selectPlan(planId) {
    this.currentPlan = planId;
    storage.set('msai_selected_plan', planId);

    const planNames = {
      free: i18n.get('pricing.free.title', 'Free'),
      pro: i18n.get('pricing.pro.title', 'Pro'),
      max: i18n.get('pricing.max.title', 'Max')
    };

    const selectedName = planNames[planId] || planId.toUpperCase();
    const msgTemplate = i18n.get('notifications.planSelected', 'Switched to {plan} plan (Demo State)');
    const msg = msgTemplate.replace('{plan}', selectedName);

    notifications.success(msg);
    this.updatePlanStateUI();
  }

  updatePlanStateUI() {
    if (!this.pricingScreen) return;

    this.pricingScreen.querySelectorAll('.pricing-card').forEach(card => {
      const plan = card.getAttribute('data-plan');
      const badge = card.querySelector('.plan-status-badge');
      const ctaBtn = card.querySelector('.btn-plan-cta');

      if (plan === this.currentPlan) {
        card.classList.add('selected-active-plan');
        if (badge) badge.classList.remove('hidden');
        if (ctaBtn) {
          ctaBtn.classList.add('active-plan-btn');
          ctaBtn.textContent = i18n.get('pricing.currentPlan', 'Current Plan');
        }
      } else {
        card.classList.remove('selected-active-plan');
        if (badge) badge.classList.add('hidden');
        if (ctaBtn) {
          ctaBtn.classList.remove('active-plan-btn');
          const planCtaKey = `pricing.${plan}.cta`;
          ctaBtn.textContent = i18n.get(planCtaKey, 'Use MSAI for free');
        }
      }
    });
  }

  updateDynamicTexts() {
    this.updatePlanStateUI();

    if (!this.pricingScreen) return;

    this.pricingScreen.querySelectorAll('.btn-feature-toggle').forEach(btn => {
      const isExpanded = btn.getAttribute('aria-expanded') === 'true';
      const textSpan = btn.querySelector('.toggle-text');
      if (textSpan) {
        textSpan.textContent = isExpanded
          ? i18n.get('pricing.hideFeatures', 'Hide features')
          : i18n.get('pricing.showFeatures', 'Show all features');
      }
    });
  }
}

export const pricingController = new PricingController();
