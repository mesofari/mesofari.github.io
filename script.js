const menuButton = document.querySelector('[data-menu-button]');
const nav = document.querySelector('[data-nav]');
const header = document.querySelector('[data-header]');

if (menuButton && nav) {
  menuButton.addEventListener('click', () => {
    const open = nav.classList.toggle('open');
    menuButton.setAttribute('aria-expanded', String(open));
  });
  nav.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
      nav.classList.remove('open');
      menuButton.setAttribute('aria-expanded', 'false');
    });
  });
}

const syncHeader = () => {
  if (!header) return;
  header.classList.toggle('scrolled', window.scrollY > 16);
};
syncHeader();
window.addEventListener('scroll', syncHeader, { passive: true });

const revealItems = document.querySelectorAll('.reveal');
if ('IntersectionObserver' in window) {
  const observer = new IntersectionObserver((entries, obs) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        obs.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });
  revealItems.forEach(item => observer.observe(item));
} else {
  revealItems.forEach(item => item.classList.add('visible'));
}

const modal = document.querySelector('[data-lightbox-modal]');
const modalImage = document.querySelector('[data-lightbox-image]');
const modalClose = document.querySelector('[data-lightbox-close]');
const openers = document.querySelectorAll('[data-lightbox]');

function closeLightbox() {
  if (!modal) return;
  modal.classList.remove('open');
  modal.setAttribute('aria-hidden', 'true');
  document.body.classList.remove('modal-open');
  if (modalImage) modalImage.src = '';
}

openers.forEach(opener => {
  opener.addEventListener('click', () => {
    if (!modal || !modalImage) return;
    modalImage.src = opener.getAttribute('data-lightbox');
    modal.classList.add('open');
    modal.setAttribute('aria-hidden', 'false');
    document.body.classList.add('modal-open');
  });
});

if (modalClose) modalClose.addEventListener('click', closeLightbox);
if (modal) modal.addEventListener('click', (event) => { if (event.target === modal) closeLightbox(); });
document.addEventListener('keydown', (event) => { if (event.key === 'Escape') closeLightbox(); });

const year = document.getElementById('year');
if (year) year.textContent = new Date().getFullYear();
