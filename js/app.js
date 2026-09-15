/**
 * NV ZIP — Main Application Controller & Event Coordination
 * Handles navigation active state tracking, smooth scroll, mobile menu toggles,
 * section intersection observers, and global application orchestration.
 */

class AppController {
  constructor() {
    this.navLinks = document.querySelectorAll('.nav-link');
    this.mobileMenuBtn = document.getElementById('mobile-menu-btn');
    this.navLinksContainer = document.getElementById('nav-links');
    this.sections = document.querySelectorAll('section');

    this.init();
  }

  init() {
    this.setupSmoothScroll();
    this.setupMobileMenu();
    this.setupIntersectionObserver();
  }

  setupSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', (e) => {
        const href = anchor.getAttribute('href');
        if (href === '#' || !href) return;

        const target = document.querySelector(href);
        if (target) {
          e.preventDefault();
          target.scrollIntoView({ behavior: 'smooth' });

          // Close mobile menu if open
          if (this.navLinksContainer && this.navLinksContainer.classList.contains('open')) {
            this.navLinksContainer.classList.remove('open');
          }
        }
      });
    });
  }

  setupMobileMenu() {
    if (this.mobileMenuBtn && this.navLinksContainer) {
      this.mobileMenuBtn.addEventListener('click', () => {
        this.navLinksContainer.classList.toggle('open');
      });
    }
  }

  setupIntersectionObserver() {
    const observerOptions = {
      root: null,
      rootMargin: '-20% 0px -70% 0px',
      threshold: 0
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const id = entry.target.getAttribute('id');
          this.navLinks.forEach(link => {
            if (link.getAttribute('href') === `#${id}`) {
              link.classList.add('active');
            } else {
              link.classList.remove('active');
            }
          });
        }
      });
    }, observerOptions);

    this.sections.forEach(section => observer.observe(section));
  }
}

document.addEventListener('DOMContentLoaded', () => {
  window.appController = new AppController();
  console.log("NV ZIP Interactive AI Laboratory successfully initialized.");
});
