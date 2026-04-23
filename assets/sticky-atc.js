const STICKY_ATC_SELECTORS = {
  bar: "[data-sticky-atc]"
};

function initStickyAddToCartBar(stickyBar) {
  const targetId = stickyBar.getAttribute("data-sticky-target");
  const target = targetId ? document.getElementById(targetId) : null;

  if (!target || !("IntersectionObserver" in window)) {
    return;
  }

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      stickyBar.classList.toggle("is-visible", !entry.isIntersecting);
    });
  }, {
    threshold: 0.15
  });

  observer.observe(target);
}

document.querySelectorAll(STICKY_ATC_SELECTORS.bar).forEach(initStickyAddToCartBar);
