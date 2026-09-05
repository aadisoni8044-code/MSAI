/**
 * MSAI Subscriptions Controller
 * Manages subscription plans rendering, localStorage state, feature expand/collapse,
 * and SPA view switching.
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
  }

  async init() {
    this.viewContainer = document.getElementById('subscriptionsView');
    this.gridContainer = document.getElementById('subscriptionsGrid');

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
      const displayPrice = i18n.get(`subscriptions.plans.${plan.id}.price`, plan.price);
      const defaultBtnText = plan.buttonText;
      const ctaText = i18n.get(`subscriptions.plans.${plan.id}.btn`, defaultBtnText);

      const card = document.createElement('div');
      card.className = `subscription-card ${isCurrent ? 'current-plan-card' : ''}`;
      card.dataset.planId = plan.id;

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
        </div>

        <button class="plan-cta-btn ${isCurrent ? 'disabled-btn' : ''}" data-action="choose-plan">
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
    this.setCurrentPlan(planId);

    let toastMsg = '';
    if (planId === 'free') {
      toastMsg = i18n.get('subscriptions.toasts.free', 'Free MSAI plan selected.');
    } else if (planId === 'pro') {
      toastMsg = i18n.get('subscriptions.toasts.pro', 'MSAI Pro selected — currently free.');
    } else if (planId === 'max') {
      toastMsg = i18n.get('subscriptions.toasts.max', 'MSAI Max selected — currently free.');
    }

    notifications.success(toastMsg);
  }
}

export const subscriptionsController = new SubscriptionsController();
