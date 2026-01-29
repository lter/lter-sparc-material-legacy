// Minimal progressive enhancement: reveal animations for elements with .reveal
(() => {
  const els = Array.from(document.querySelectorAll('.reveal'));
  if (!('IntersectionObserver' in window) || els.length === 0) return;

  const io = new IntersectionObserver((entries) => {
    for (const e of entries) {
      if (e.isIntersecting) {
        e.target.classList.add('is-visible');
        io.unobserve(e.target);
      }
    }
  }, { threshold: 0.08 });

  els.forEach(el => io.observe(el));
})();
