const SITE_SELECTORS = {
  drawerToggle: "[data-drawer-toggle]",
  drawerClose: "[data-drawer-close]",
  accordionTrigger: "[data-accordion-trigger]",
  openDrawers: ".mobile-drawer.is-open"
};

function closeDrawer(drawer) {
  if (!drawer) {
    return;
  }

  drawer.classList.remove("is-open");
  document.body.classList.remove("overflow-hidden");
}

function openDrawerById(drawerId) {
  if (!drawerId) {
    return;
  }

  const drawer = document.getElementById(drawerId);
  if (!drawer) {
    return;
  }

  drawer.classList.add("is-open");
  document.body.classList.add("overflow-hidden");
}

function toggleAccordionItem(trigger) {
  if (!trigger) {
    return;
  }

  const item = trigger.closest(".accordion__item");
  const content = item ? item.querySelector(".accordion__content") : null;
  const isExpanded = trigger.getAttribute("aria-expanded") === "true";

  trigger.setAttribute("aria-expanded", String(!isExpanded));

  if (content) {
    content.hidden = isExpanded;
  }
}

function handleSiteClick(event) {
  const drawerToggle = event.target.closest(SITE_SELECTORS.drawerToggle);
  const drawerClose = event.target.closest(SITE_SELECTORS.drawerClose);
  const accordionTrigger = event.target.closest(SITE_SELECTORS.accordionTrigger);

  if (drawerToggle) {
    openDrawerById(drawerToggle.getAttribute("data-drawer-toggle"));
  }

  if (drawerClose) {
    closeDrawer(drawerClose.closest(".mobile-drawer"));
  }

  if (accordionTrigger) {
    toggleAccordionItem(accordionTrigger);
  }
}

function handleEscapeKey(event) {
  if (event.key !== "Escape") {
    return;
  }

  document.querySelectorAll(SITE_SELECTORS.openDrawers).forEach((drawer) => {
    closeDrawer(drawer);
  });
}

document.documentElement.classList.remove("no-js");
document.addEventListener("click", handleSiteClick);
document.addEventListener("keydown", handleEscapeKey);
