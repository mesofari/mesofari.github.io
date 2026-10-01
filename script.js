(() => {
  const header = document.querySelector('[data-header]');
  const menu = document.querySelector('[data-menu-button]');
  const nav = document.querySelector('[data-nav]');
  const syncHeader = () => header?.classList.toggle('scrolled', window.scrollY > 24);
  syncHeader(); window.addEventListener('scroll', syncHeader, {passive:true});
  menu?.addEventListener('click', () => { const open = nav.classList.toggle('open'); menu.setAttribute('aria-expanded', String(open)); });
  nav?.querySelectorAll('a').forEach(a => a.addEventListener('click', () => { nav.classList.remove('open'); menu?.setAttribute('aria-expanded','false'); }));
  const observer = new IntersectionObserver(entries => entries.forEach(e => { if(e.isIntersecting){ e.target.classList.add('visible'); observer.unobserve(e.target); } }), {threshold:.12});
  document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
  document.querySelectorAll('[data-year]').forEach(el => el.textContent = new Date().getFullYear());
  const modal = document.querySelector('[data-lightbox-modal]'); const modalImg = document.querySelector('[data-lightbox-image]');
  const close = () => { modal?.classList.remove('open'); modal?.setAttribute('aria-hidden','true'); document.body.style.overflow=''; };
  document.querySelectorAll('[data-lightbox]').forEach(btn => btn.addEventListener('click', () => { if(!modal || !modalImg) return; modalImg.src = btn.dataset.lightbox; modal.classList.add('open'); modal.setAttribute('aria-hidden','false'); document.body.style.overflow='hidden'; }));
  document.querySelector('[data-lightbox-close]')?.addEventListener('click', close); modal?.addEventListener('click', e => { if(e.target === modal) close(); }); document.addEventListener('keydown', e => { if(e.key === 'Escape') close(); });
})();
