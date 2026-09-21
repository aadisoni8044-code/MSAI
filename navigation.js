/**
 * NAVIGATION.JS - Sticky Navigation, Mobile Drawer Toggle & Smooth Scroll Logic
 */

document.addEventListener('DOMContentLoaded', () => {
  const navbarHeader = document.querySelector('.navbar-header');
  const hamburgerToggle = document.querySelector('.hamburger-toggle');
  const navMenu = document.querySelector('.nav-menu');
  const navLinks = document.querySelectorAll('.nav-link');

  // Sticky navbar shadow on scroll
  window.addEventListener('scroll', () => {
    if (window.scrollY > 40) {
      navbarHeader?.classList.add('scrolled');
    } else {
      navbarHeader?.classList.remove('scrolled');
    }
  }, { passive: true });

  // Mobile drawer toggle
  if (hamburgerToggle && navMenu) {
    hamburgerToggle.addEventListener('click', () => {
      const isActive = navMenu.classList.toggle('active');
      hamburgerToggle.classList.toggle('active', isActive);
      hamburgerToggle.setAttribute('aria-expanded', isActive ? 'true' : 'false');
    });

    // Close mobile menu when clicking outside
    document.addEventListener('click', (e) => {
      if (!navMenu.contains(e.target) && !hamburgerToggle.contains(e.target)) {
        navMenu.classList.remove('active');
        hamburgerToggle.classList.remove('active');
        hamburgerToggle.setAttribute('aria-expanded', 'false');
      }
    });
  }

  // Smooth scroll for internal anchor links & active nav highlighting
  navLinks.forEach(link => {
    link.addEventListener('click', (e) => {
      const href = link.getAttribute('href');
      if (href && href.startsWith('#') && href.length > 1) {
        e.preventDefault();
        const targetElement = document.querySelector(href);
        if (targetElement) {
          // Close mobile nav drawer if open
          navMenu?.classList.remove('active');
          hamburgerToggle?.classList.remove('active');

          const navHeight = navbarHeader?.offsetHeight || 80;
          const targetPosition = targetElement.getBoundingClientRect().top + window.pageYOffset - navHeight;

          window.scrollTo({
            top: targetPosition,
            behavior: 'smooth'
          });
        }
      }
    });
  });

  // Highlight active page link based on current path
  const currentPath = window.location.pathname.split('/').pop() || 'index.html';
  navLinks.forEach(link => {
    const linkPath = link.getAttribute('href')?.split('/').pop();
    if (linkPath === currentPath || (currentPath === '' && linkPath === 'index.html')) {
      link.classList.add('active');
    }
  });
});
