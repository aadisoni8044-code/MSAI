/**
 * ANIMATIONS MODULE
 * IntersectionObserver scroll reveal animations, Animated Stat Counters, Tilt Effects
 */

document.addEventListener('DOMContentLoaded', () => {
  initScrollAnimations();
  initStatCounters();
});

function initScrollAnimations() {
  // Check if reduced motion is requested
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (prefersReducedMotion) return;

  const observerOptions = {
    root: null,
    rootMargin: '0px 0px -60px 0px',
    threshold: 0.15
  };

  const observer = new IntersectionObserver((entries, obs) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('revealed');
        obs.unobserve(entry.target); // Animates once
      }
    });
  }, observerOptions);

  const elementsToAnimate = document.querySelectorAll('.scroll-reveal, .card-grid > *, .feature-card, .level-card, .stat-item');
  elementsToAnimate.forEach(el => observer.observe(el));
}

function initStatCounters() {
  const statNumbers = document.querySelectorAll('.stat-value[data-count]');
  if (!statNumbers.length) return;

  const observer = new IntersectionObserver((entries, obs) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const el = entry.target;
        const targetNum = parseInt(el.getAttribute('data-count'), 10) || 0;
        const suffix = el.getAttribute('data-suffix') || '';
        animateCounter(el, targetNum, suffix);
        obs.unobserve(el);
      }
    });
  }, { threshold: 0.5 });

  statNumbers.forEach(num => observer.observe(num));
}

function animateCounter(element, target, suffix) {
  let start = 0;
  const duration = 1500;
  const startTime = performance.now();

  function update(currentTime) {
    const elapsed = currentTime - startTime;
    const progress = Math.min(elapsed / duration, 1);
    const easeOutQuad = progress * (2 - progress);
    const currentCount = Math.floor(easeOutQuad * target);

    element.textContent = currentCount + suffix;

    if (progress < 1) {
      requestAnimationFrame(update);
    } else {
      element.textContent = target + suffix;
    }
  }

  requestAnimationFrame(update);
}
