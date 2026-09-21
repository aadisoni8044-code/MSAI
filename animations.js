/**
 * ANIMATIONS.JS - Scroll Reveal Trigger & Parallax Subtle Effects
 */

document.addEventListener('DOMContentLoaded', () => {
  // Intersection Observer for scroll reveal elements
  const revealElements = document.querySelectorAll('.reveal');

  if ('IntersectionObserver' in window) {
    const observerOptions = {
      root: null,
      rootMargin: '0px 0px -50px 0px',
      threshold: 0.15
    };

    const revealObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('revealed');
          observer.unobserve(entry.target);
        }
      });
    }, observerOptions);

    revealElements.forEach(el => revealObserver.observe(el));
  } else {
    // Fallback for browsers without IntersectionObserver
    revealElements.forEach(el => el.classList.add('revealed'));
  }

  // Subtle Parallax Scroll Effect for Hero Content
  const heroContent = document.querySelector('.hero-content');
  if (heroContent && window.innerWidth > 1024) {
    window.addEventListener('scroll', () => {
      const scrolled = window.pageYOffset;
      if (scrolled < 800) {
        heroContent.style.transform = `translateY(${scrolled * 0.25}px)`;
        heroContent.style.opacity = `${1 - (scrolled / 700)}`;
      }
    }, { passive: true });
  }
});
