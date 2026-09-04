/**
 * MSAI Subscriptions Controller
 * Manages subscription plans rendering, localStorage state, feature expand/collapse,
 * confirmation modal lifecycle, and SPA view switching.
 */
import { storage } from './storage.js';
import { notifications } from './notifications.js';
import { i18n } from './language.js';
import { escapeHtml } from './utils.js';

class SubscriptionsController {
  constructor() {
    this.plansData = [];
    this.currentPlan = 'free';
    this.viewContainer = null;
    this.gridContainer = null;
    this.modalBackdrop = null;
    this.selectedPlanForUpgrade = null;
  }

  async init() {
    this.viewContainer = document.getElementById('subscriptionsView');
    this.gridContainer = document.getElementById('subscriptionsGrid');
    this.modalBackdrop = document.getElementById('subscriptionModal');

    // Load active plan from localStorage
    this.currentPlan = storage.get('msai_subscription_plan', storage.get('msai_selected_plan', 'free'));

    // Fetch subscription JSON data
    await this.loadPlansData();

    // Event Bindings
    this.setupEventListeners();

    // Render cards
    this.renderPlans();
  }

  async loadPlansData() {
    try {
      const response = await fetch('/data/subscriptions.json');
      if (response.ok) {
        this.plansData = await response.json();
      } else {
        console.error('Failed to load subscriptions.json');
      }
    } catch (err) {
      console.error('Error fetching subscriptions dataset:', err);
    }
  }

  setupEventListeners() {
    // Back to Chat button
    const btnBack = document.getElementById('btnBackToChat');
    if (btnBack) {
      btnBack.addEventListener('click', () => this.closeSubscriptionsView());
    }

    // Modal Close buttons
    const btnCloseModal = document.getElementById('btnCloseSubModal');
    const btnCancelModal = document.getElementById('btnSubModalCancel');
    if (btnCloseModal) {
      btnCloseModal.addEventListener('click', () => this.closeModal());
    }
    if (btnCancelModal) {
      btnCancelModal.addEventListener('click', () => this.closeModal());
    }

    // Modal Continue button
    const btnContinueModal = document.getElementById('btnSubModalContinue');
    if (btnContinueModal) {
      btnContinueModal.addEventListener('click', () => {
        if (this.selectedPlanForUpgrade) {
          this.executePaymentProviderHook(this.selectedPlanForUpgrade);
        }
      });
    }

    // Close modal on click outside backdrop
    if (this.modalBackdrop) {
      this.modalBackdrop.addEventListener('click', (e) => {
        if (e.target === this.modalBackdrop) {
          this.closeModal();
        }
      });
    }

    // ESC key closes modal
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.modalBackdrop && this.modalBackdrop.classList.contains('open')) {
        this.closeModal();
      }
    });

    // Handle i18n changes
    window.addEventListener('language:changed', () => this.renderPlans());
  }

  openSubscriptionsView() {
    if (!this.viewContainer) return;

    // Hide chat container & composer
    const chatContainer = document.getElementById('chatContainer');
    const composerWrapper = document.getElementById('composerWrapper');
    const headerCenter = document.querySelector('.header-center');

    if (chatContainer) chatContainer.classList.add('hidden');
    if (composerWrapper) composerWrapper.classList.add('hidden');
    if (headerCenter) headerCenter.style.visibility = 'hidden';

    // Show Subscriptions View
    this.viewContainer.classList.remove('hidden');

    // Notify user
    notifications.info(i18n.get('notifications.subViewOpened', 'Subscription screen opened'));
  }

  closeSubscriptionsView() {
    if (!this.viewContainer) return;

    // Hide Subscriptions View
    this.viewContainer.classList.add('hidden');

    // Restore chat container & composer
    const chatContainer = document.getElementById('chatContainer');
    const composerWrapper = document.getElementById('composerWrapper');
    const headerCenter = document.querySelector('.header-center');

    if (chatContainer) chatContainer.classList.remove('hidden');
    if (composerWrapper) composerWrapper.classList.remove('hidden');
    if (headerCenter) headerCenter.style.visibility = 'visible';
  }

  getCurrentPlan() {
    return storage.get('msai_subscription_plan', storage.get('msai_selected_plan', 'free'));
  }

  setCurrentPlan(planId) {
    this.currentPlan = planId;
    storage.set('msai_subscription_plan', planId);
    storage.set('msai_selected_plan', planId);
    this.renderPlans();
  }

  renderPlans() {
    if (!this.gridContainer || !this.plansData.length) return;

    this.currentPlan = this.getCurrentPlan();
    this.gridContainer.innerHTML = '';

    this.plansData.forEach(plan => {
      const isCurrent = this.currentPlan.toLowerCase() === plan.id.toLowerCase();

      // Localized name & description & CTA button
      const planName = i18n.get(`subscriptions.plans.${plan.id}.name`, plan.name);
      const planDesc = i18n.get(`subscriptions.plans.${plan.id}.desc`, plan.description);
      const defaultBtnText = plan.buttonText;
      const ctaText = i18n.get(`subscriptions.plans.${plan.id}.btn`, defaultBtnText);

      const card = document.createElement('div');
      card.className = `subscription-card ${isCurrent ? 'current-plan-card' : ''}`;
      card.dataset.planId = plan.id;

      // Price formatting
      const displayPrice = plan.price === "0" ? `${plan.currency}0` : `${plan.currency}${plan.price}`;

      const currentBadgeHtml = isCurrent ? `
        <span class="current-plan-badge" data-i18n="subscriptions.currentPlan">
          ${i18n.get('subscriptions.currentPlan', 'Current plan')}
        </span>
      ` : '';

      const featuresListHtml = plan.features.map(f => `
        <li class="feature-item">
          <svg class="feature-check-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <polyline points="20 6 9 17 4 12"></polyline>
          </svg>
          <span>${escapeHtml(f)}</span>
        </li>
      `).join('');

      card.innerHTML = `
        <div class="card-header-row">
          <h2 class="plan-name">${escapeHtml(planName)}</h2>
          ${currentBadgeHtml}
        </div>
        <p class="plan-description">${escapeHtml(planDesc)}</p>

        <div class="plan-price-wrapper">
          <span class="plan-price">${escapeHtml(displayPrice)}</span>
          <span class="plan-billing-period">${escapeHtml(plan.billingPeriod)}</span>
        </div>

        <button class="plan-cta-btn ${isCurrent && plan.id === 'free' ? 'disabled-btn' : ''}" data-action="choose-plan">
          ${escapeHtml(ctaText)}
        </button>

        <button class="features-toggle-btn" aria-expanded="false" data-action="toggle-features">
          <span class="toggle-text">${i18n.get('subscriptions.showFeatures', 'Show all features')}</span>
          <svg class="chevron-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <polyline points="6 9 12 15 18 9"></polyline>
          </svg>
        </button>

        <div class="features-container">
          <ul class="features-list">
            ${featuresListHtml}
          </ul>
        </div>
      `;

      // Event Listeners for Card
      const btnCta = card.querySelector('[data-action="choose-plan"]');
      if (btnCta) {
        btnCta.addEventListener('click', () => this.handlePlanSelection(plan.id));
      }

      const btnToggle = card.querySelector('[data-action="toggle-features"]');
      const featuresContainer = card.querySelector('.features-container');
      const toggleText = card.querySelector('.toggle-text');

      if (btnToggle && featuresContainer) {
        btnToggle.addEventListener('click', () => {
          const isExpanded = btnToggle.getAttribute('aria-expanded') === 'true';
          btnToggle.setAttribute('aria-expanded', !isExpanded);
          featuresContainer.classList.toggle('expanded', !isExpanded);
          if (toggleText) {
            toggleText.textContent = !isExpanded
              ? i18n.get('subscriptions.hideFeatures', 'Hide features')
              : i18n.get('subscriptions.showFeatures', 'Show all features');
          }
        });
      }

      this.gridContainer.appendChild(card);
    });
  }

  handlePlanSelection(planId) {
    if (planId === 'free') {
      if (this.currentPlan === 'free') {
        notifications.info(i18n.get('subscriptions.freeCurrentNotice', 'You are currently using the MSAI Free plan.'));
      } else {
        // Downgrade or switch to free
        this.setCurrentPlan('free');
        notifications.success('Switched to MSAI Free plan.');
      }
      return;
    }

    // Pro or Max Upgrade
    this.startSubscription(planId);
  }

  startSubscription(planId) {
    const plan = this.plansData.find(p => p.id === planId);
    if (!plan) return;

    this.selectedPlanForUpgrade = plan;

    // Populate Modal
    const modalTitle = document.getElementById('subscriptionModalTitle');
    const modalPlanName = document.getElementById('subModalPlanName');
    const modalPrice = document.getElementById('subModalPrice');
    const modalFeatureSummary = document.getElementById('subModalFeatureSummary');

    const localizedTitle = i18n.get('subscriptions.upgradeModalTitle', `Upgrade to MSAI ${plan.name}`).replace('{plan}', plan.name);
    if (modalTitle) modalTitle.textContent = localizedTitle;
    if (modalPlanName) modalPlanName.textContent = plan.name;
    if (modalPrice) modalPrice.textContent = `${plan.currency}${plan.price} ${plan.billingPeriod}`;

    if (modalFeatureSummary) {
      modalFeatureSummary.innerHTML = `
        <div style="font-weight: 600; color: var(--msai-text); margin-bottom: 6px;">Includes:</div>
        <ul style="padding-left: 18px; margin: 0;">
          ${plan.features.map(f => `<li>${escapeHtml(f)}</li>`).join('')}
        </ul>
      `;
    }

    this.openModal();
  }

  openModal() {
    if (this.modalBackdrop) {
      this.modalBackdrop.classList.add('open');
    }
  }

  closeModal() {
    if (this.modalBackdrop) {
      this.modalBackdrop.classList.remove('open');
    }
    this.selectedPlanForUpgrade = null;
  }

  /**
   * Clearly defined extension point for integration with actual payment gateways (Stripe, Razorpay, etc.)
   * Does NOT claim payment succeeded unless verified by payment provider.
   */
  executePaymentProviderHook(plan) {
    this.closeModal();

    // Log integration hook
    console.log(`[Payment Integration Hook] Initializing gateway checkout for plan: ${plan.id}`);

    // Trigger explicit upgrade process notification without mock payment success claim
    notifications.info(i18n.get('subscriptions.upgradeStarted', 'Upgrade process started.'));

    /*
     * REAL PAYMENT GATEWAY CONNECTION POINT:
     * e.g., Razorpay / Stripe Checkout initialization:
     *
     * const options = {
     *   key: "YOUR_PAYMENT_KEY",
     *   amount: plan.price * 100,
     *   currency: "INR",
     *   name: "MSAI",
     *   description: `Upgrade to ${plan.name}`,
     *   handler: function (response) {
     *     // Verify payment signature on backend server before setting current plan:
     *     subscriptionsController.setCurrentPlan(plan.id);
     *     notifications.success(`Successfully upgraded to MSAI ${plan.name}!`);
     *   }
     * };
     * const rzp = new Razorpay(options);
     * rzp.open();
     */
  }
}

export const subscriptionsController = new SubscriptionsController();
