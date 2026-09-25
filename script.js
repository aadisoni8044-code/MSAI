document.addEventListener('DOMContentLoaded', () => {
    // Navbar Scroll Handler
    const navbar = document.querySelector('.navbar');
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    });

    // Mobile Navigation Drawer Toggle
    const mobileMenuBtn = document.getElementById('mobileMenuBtn');
    const mobileDrawer = document.getElementById('mobileDrawer');
    const drawerLinks = document.querySelectorAll('.drawer-link');

    if (mobileMenuBtn && mobileDrawer) {
        mobileMenuBtn.addEventListener('click', () => {
            mobileMenuBtn.classList.toggle('open');
            mobileDrawer.classList.toggle('open');
        });

        drawerLinks.forEach(link => {
            link.addEventListener('click', () => {
                mobileMenuBtn.classList.remove('open');
                mobileDrawer.classList.remove('open');
            });
        });
    }

    // Hero Background Video Autoplay & Mute Control
    const heroVideo = document.getElementById('heroVideo');
    const soundToggleBtn = document.getElementById('soundToggleBtn');
    const soundIcon = document.getElementById('soundIcon');
    const soundText = document.getElementById('soundText');

    if (heroVideo) {
        // Ensure standard autoplay attributes are respected programmatically
        heroVideo.muted = true;
        heroVideo.play().catch(err => {
            console.log('Autoplay deferred by browser policy:', err);
        });

        if (soundToggleBtn && soundIcon && soundText) {
            soundToggleBtn.addEventListener('click', () => {
                if (heroVideo.muted) {
                    heroVideo.muted = false;
                    soundIcon.className = 'fa-solid fa-volume-high';
                    soundText.textContent = 'Mute Trailer';
                } else {
                    heroVideo.muted = true;
                    soundIcon.className = 'fa-solid fa-volume-xmark';
                    soundText.textContent = 'Unmute Trailer';
                }
            });
        }
    }

    // Download Button Toast Trigger
    const downloadTriggers = document.querySelectorAll('.download-btn-trigger');
    const downloadToast = document.getElementById('downloadToast');
    const toastTitle = document.getElementById('toastTitle');
    const toastSub = document.getElementById('toastSub');

    downloadTriggers.forEach(btn => {
        btn.addEventListener('click', (e) => {
            const platform = btn.getAttribute('data-platform') || 'Game';
            if (downloadToast && toastTitle && toastSub) {
                toastTitle.textContent = `Downloading ${platform} Version`;
                toastSub.textContent = `File transfer initiated. Enjoy Aetheria!`;
                downloadToast.classList.add('show');

                setTimeout(() => {
                    downloadToast.classList.remove('show');
                }, 4000);
            }
        });
    });

    // FAQ Accordion Handler
    const faqQuestions = document.querySelectorAll('.faq-question');
    faqQuestions.forEach(btn => {
        btn.addEventListener('click', () => {
            const faqItem = btn.parentElement;
            const isOpen = faqItem.classList.contains('active');

            // Close all items
            document.querySelectorAll('.faq-item').forEach(item => {
                item.classList.remove('active');
            });

            // Toggle current item if it wasn't open
            if (!isOpen) {
                faqItem.classList.add('active');
            }
        });
    });

    // Active Nav Link Highlight on Scroll
    const sections = document.querySelectorAll('section[id]');
    const navItems = document.querySelectorAll('.nav-links .nav-item');

    window.addEventListener('scroll', () => {
        let currentSection = '';
        sections.forEach(section => {
            const sectionTop = section.offsetTop - 100;
            const sectionHeight = section.offsetHeight;
            if (window.scrollY >= sectionTop && window.scrollY < sectionTop + sectionHeight) {
                currentSection = section.getAttribute('id');
            }
        });

        navItems.forEach(item => {
            item.classList.remove('active');
            if (item.getAttribute('href') === `#${currentSection}`) {
                item.classList.add('active');
            }
        });
    });
});
