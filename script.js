/**
 * Enchanted Adventure - Game Website Script
 * Interactive behaviors: Video autoplay handling, sound toggling, responsive navigation
 */

document.addEventListener('DOMContentLoaded', () => {
  // DOM Elements
  const heroVideo = document.getElementById('heroVideo');
  const soundToggleBtn = document.getElementById('soundToggle');
  const menuToggleBtn = document.getElementById('menuToggle');
  const navMenu = document.getElementById('navMenu');
  const navLinks = document.querySelectorAll('.nav-link');

  /* -------------------------------------------------------------------------
   * 1. Video Autoplay & Mute Handling
   * ------------------------------------------------------------------------- */
  if (heroVideo) {
    // Ensure muted initially to satisfy browser autoplay policies
    heroVideo.muted = true;

    // Attempt autoplay
    const playPromise = heroVideo.play();
    if (playPromise !== undefined) {
      playPromise.catch(() => {
        // Autoplay failed or was blocked; retry muted on user interaction without breaking
        console.log('Autoplay deferred by browser policy. Video will play upon interaction.');
        document.body.addEventListener('click', () => {
          if (heroVideo.paused) {
            heroVideo.play().catch(() => {});
          }
        }, { once: true });
      });
    }

    // Sound ON / OFF toggle logic
    if (soundToggleBtn) {
      soundToggleBtn.addEventListener('click', () => {
        heroVideo.muted = !heroVideo.muted;

        const soundIcon = soundToggleBtn.querySelector('.sound-icon');
        const soundText = soundToggleBtn.querySelector('.sound-text');

        if (heroVideo.muted) {
          soundIcon.textContent = '🔇';
          soundText.textContent = 'Sound Off';
        } else {
          soundIcon.textContent = '🔊';
          soundText.textContent = 'Sound On';

          // Ensure video plays if it was paused when unmuted
          if (heroVideo.paused) {
            heroVideo.play().catch(() => {});
          }
        }
      });
    }
  }

  /* -------------------------------------------------------------------------
   * 2. Responsive Mobile Menu Toggle
   * ------------------------------------------------------------------------- */
  if (menuToggleBtn && navMenu) {
    menuToggleBtn.addEventListener('click', () => {
      navMenu.classList.toggle('active');
      menuToggleBtn.classList.toggle('open');
    });

    // Close mobile drawer when clicking a link
    navLinks.forEach(link => {
      link.addEventListener('click', () => {
        navMenu.classList.remove('active');
        menuToggleBtn.classList.remove('open');
      });
    });

    // Close mobile menu if clicking outside
    document.addEventListener('click', (e) => {
      if (!navMenu.contains(e.target) && !menuToggleBtn.contains(e.target) && navMenu.classList.contains('active')) {
        navMenu.classList.remove('active');
        menuToggleBtn.classList.remove('open');
      }
    });
  }

  /* -------------------------------------------------------------------------
   * 3. Smooth Navigation Active Highlight on Scroll
   * ------------------------------------------------------------------------- */
  const sections = document.querySelectorAll('section');
  window.addEventListener('scroll', () => {
    let currentSectionId = '';
    const scrollPosition = window.scrollY + 200;

    sections.forEach(section => {
      const sectionTop = section.offsetTop;
      const sectionHeight = section.offsetHeight;
      if (scrollPosition >= sectionTop && scrollPosition < sectionTop + sectionHeight) {
        currentSectionId = section.getAttribute('id');
      }
    });

    navLinks.forEach(link => {
      link.classList.remove('active');
      if (link.getAttribute('href') === `#${currentSectionId}`) {
        link.classList.add('active');
      }
    });
  });
});
