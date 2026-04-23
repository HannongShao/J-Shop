/*
 * Preview interaction architecture:
 * 1. Static content libraries and selector contracts
 * 2. DOM helper utilities
 * 3. Feature initializers with one clear responsibility each
 * 4. A single boot sequence that defines page startup order
 */

const MATCH_MEDIA = {
  reducedMotion: window.matchMedia("(prefers-reduced-motion: reduce)"),
  finePointer: window.matchMedia("(pointer: fine)"),
  desktopHeaderPanel: window.matchMedia("(min-width: 1121px)")
};

const SELECTORS = {
  scrollProgress: "[data-scroll-progress]",
  revealItems: "[data-reveal]",
  pageSections: ".page-section[id]",
  sectionIndicator: "[data-section-indicator]",
  primaryNavLinks: ".nav a",
  lensButtons: "[data-lens-toggle]",
  lensCaption: "[data-lens-caption]",
  lensNote: "[data-lens-note]",
  lensPill: "[data-lens-pill]",
  lensCopy: "[data-lens-copy]",
  heroVisual: "[data-hero-visual]",
  tiltCards: ".tilt-card",
  cursorAura: ".cursor-aura",
  sheenCards: "[data-sheen]",
  giftFinderButtons: ".gift-option",
  giftResult: "[data-gift-result]",
  giftTitle: "[data-gift-title]",
  giftCopy: "[data-gift-copy]",
  giftPrice: "[data-gift-price]",
  giftNote: "[data-gift-note]",
  giftPill: "[data-gift-pill]",
  giftImage: "[data-gift-image]",
  giftPoints: "[data-gift-points]",
  siteHeader: ".site-header",
  headerPanel: "[data-header-panel]",
  headerPanelTriggers: "[data-nav-panel]",
  headerPanelEyebrow: "[data-panel-eyebrow]",
  headerPanelTitle: "[data-panel-title]",
  headerPanelCopy: "[data-panel-copy]",
  headerPanelLinks: "[data-panel-links]",
  headerPanelMeta: "[data-panel-meta]",
  floatingCards: ".floating-card"
};

const DEFAULT_STATE = {
  lens: "gift",
  giftFinder: {
    budget: "under-150",
    occasion: "birthday",
    style: "soft"
  }
};

const HERO_LENS_LIBRARY = {
  gift: {
    caption: "Focus the page around gifting clarity and low-risk first purchases.",
    note: "Designed to reduce hesitation for birthdays, thank-you gestures, and first-time jewellery buyers.",
    pill: "Gift-ready focus",
    copy: "首屏优先讲清楚礼物包装、低出错率和澳洲配送安心感，再把用户自然带进爆款区。"
  },
  self: {
    caption: "Shift the page toward repeat wear, layering, and calm self-purchase confidence.",
    note: "Designed to make everyday self-purchase feel polished, practical, and easy to justify.",
    pill: "Everyday styling",
    copy: "首屏更强调层叠佩戴、轻精致气质和高频使用感，让自购动机更顺畅地往下走。"
  },
  occasion: {
    caption: "Frame the page around polished impact, event dressing, and stronger visual anchors.",
    note: "Designed to support dinners, celebrations, and more intentional purchases with clearer occasion cues.",
    pill: "Occasion polish",
    copy: "首屏会更强调亮点单品、场合感和视觉锚点，让用户更快进入更有记忆点的购买状态。"
  }
};

const GIFT_FINDER_LIBRARY = {
  styles: {
    soft: {
      title: "Luna Pearl Earrings",
      image: "../assets/generated/product-pearl-earrings.png",
      copy: "以柔和光泽和低出错率见长，适合第一次送珠宝，也适合想要轻松升级日常气质的购买场景。",
      points: [
        "Soft finish that suits most wardrobes",
        "Low sizing risk for gifting",
        "Feels polished without becoming too formal"
      ]
    },
    pearls: {
      title: "Solstice Pearl Layer Set",
      image: "../assets/generated/model-portrait-necklace.png",
      copy: "珍珠与细链的组合更完整、更有纪念感，适合需要一点情绪价值和仪式感的选择。",
      points: [
        "Photographs beautifully for meaningful moments",
        "Feels more complete than a single-item gift",
        "Balances softness with a dressier finish"
      ]
    },
    evening: {
      title: "Harbour Diamond Ring",
      image: "../assets/generated/model-hand-ring-bracelet.png",
      copy: "更有视觉锚点和里程碑感，适合场合佩戴，也适合奖励自己一件会长期留在首饰盒里的作品。",
      points: [
        "Clear finger-scale imagery reduces hesitation",
        "Adds stronger presence to event dressing",
        "Anchors the brand at a more elevated tier"
      ]
    }
  },
  budgets: {
    "under-150": {
      price: "AU$149",
      note: "Gift box, note card, and 48h dispatch available"
    },
    "150-300": {
      price: "AU$279",
      note: "Priority gift wrapping and signature packaging included"
    },
    "300-plus": {
      price: "AU$329",
      note: "Care reminders and concierge follow-up included"
    }
  },
  occasions: {
    birthday: {
      pill: "Birthday favourite",
      prefix: "适合作为生日礼物，重点是让对方拆开时立刻感到被认真挑选过。"
    },
    anniversary: {
      pill: "Anniversary keepsake",
      prefix: "更适合纪念日与重要节点，强调留存感、纪念感和被珍惜的时间长度。"
    },
    self: {
      pill: "Self-reward choice",
      prefix: "适合送给自己，语气更偏从容、自我奖励和长期佩戴价值。"
    }
  }
};

const HEADER_PANEL_LIBRARY = {
  gift: {
    eyebrow: "Guided gifting",
    title: "Choose a piece with less second-guessing",
    copy: "Start with budget, occasion, and style mood to arrive at a piece that feels considered from the first click.",
    links: [
      { label: "Birthday favourites", href: "#gift-finder" },
      { label: "Anniversary keepsakes", href: "#gift-finder" },
      { label: "Self-reward picks", href: "#gift-finder" }
    ],
    meta: ["Gift note included", "Low-risk suggestions"]
  },
  collections: {
    eyebrow: "Curated edits",
    title: "Browse by mood instead of guessing where to begin",
    copy: "Move between gifting, daily wear, and occasion dressing through edits that feel more like a stylist's selection than a catalog.",
    links: [
      { label: "Gifts under AU$150", href: "#collections" },
      { label: "Everyday layers", href: "#collections" },
      { label: "Occasion shine", href: "#collections" }
    ],
    meta: ["Edited pathways", "Clear occasion cues"]
  },
  bestsellers: {
    eyebrow: "Most loved",
    title: "Start with pieces that already feel easy to trust",
    copy: "Our hero products lead with gentle proportions, polished materials, and styling that feels believable in real life.",
    links: [
      { label: "Luna Pearl Earrings", href: "#featured" },
      { label: "Solstice Chain Necklace", href: "#featured" },
      { label: "Harbour Diamond Ring", href: "#featured" }
    ],
    meta: ["Low-friction entry", "Gift-ready presentation"]
  },
  materials: {
    eyebrow: "Material clarity",
    title: "Explain value with calm, transparent detail",
    copy: "Metal notes, size guidance, sensitive-skin information, and care rituals should feel refined, readable, and worth paying for.",
    links: [
      { label: "Metal notes", href: "#story" },
      { label: "Size guidance", href: "#story" },
      { label: "Care ritual", href: "#story" }
    ],
    meta: ["Skin-friendly notes", "Aftercare clarity"]
  }
};

function queryOne(selector, scope = document) {
  return scope.querySelector(selector);
}

function queryAll(selector, scope = document) {
  return Array.from(scope.querySelectorAll(selector));
}

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

function setText(node, value) {
  if (node) {
    node.textContent = value;
  }
}

function setImage(node, src, alt) {
  if (!node) {
    return;
  }

  node.src = src;
  node.alt = alt;
}

function replaceChildrenWithText(container, items, tagName) {
  if (!container) {
    return;
  }

  const fragment = document.createDocumentFragment();

  items.forEach((item) => {
    const node = document.createElement(tagName);
    node.textContent = item;
    fragment.appendChild(node);
  });

  container.replaceChildren(fragment);
}

function replaceChildrenWithLinks(container, items) {
  if (!container) {
    return;
  }

  const fragment = document.createDocumentFragment();

  items.forEach((item) => {
    const link = document.createElement("a");
    link.href = item.href;
    link.textContent = item.label;
    fragment.appendChild(link);
  });

  container.replaceChildren(fragment);
}

function hasReducedMotion() {
  return MATCH_MEDIA.reducedMotion.matches;
}

function hasFinePointer() {
  return MATCH_MEDIA.finePointer.matches;
}

function canUseDesktopHeaderPanel() {
  return hasFinePointer() && MATCH_MEDIA.desktopHeaderPanel.matches;
}

function syncScrollProgress() {
  const progressBar = queryOne(SELECTORS.scrollProgress);
  if (!progressBar) {
    return;
  }

  const maxScroll = document.documentElement.scrollHeight - window.innerHeight;
  const progress = maxScroll > 0 ? window.scrollY / maxScroll : 0;
  progressBar.style.transform = `scaleY(${clamp(progress, 0, 1)})`;
}

function initRevealItems() {
  const revealItems = queryAll(SELECTORS.revealItems);
  if (!revealItems.length) {
    return;
  }

  if (hasReducedMotion()) {
    revealItems.forEach((item) => item.classList.add("is-visible"));
    return;
  }

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) {
        return;
      }

      entry.target.classList.add("is-visible");
      observer.unobserve(entry.target);
    });
  }, {
    threshold: 0.18,
    rootMargin: "0px 0px -8% 0px"
  });

  revealItems.forEach((item) => observer.observe(item));
}

function initSectionTracking() {
  const sections = queryAll(SELECTORS.pageSections);
  const indicator = queryOne(SELECTORS.sectionIndicator);
  const navLinks = queryAll(SELECTORS.primaryNavLinks);

  if (!sections.length) {
    return;
  }

  const setActiveSection = (sectionId, sectionTitle) => {
    setText(indicator, sectionTitle);

    navLinks.forEach((link) => {
      const isActive = link.getAttribute("href") === `#${sectionId}`;
      link.classList.toggle("is-active", isActive);
    });
  };

  const observer = new IntersectionObserver((entries) => {
    const activeEntry = entries
      .filter((entry) => entry.isIntersecting)
      .sort((entryA, entryB) => entryB.intersectionRatio - entryA.intersectionRatio)[0];

    if (!activeEntry) {
      return;
    }

    const { id, dataset } = activeEntry.target;
    setActiveSection(id, dataset.sectionTitle || id);
  }, {
    threshold: [0.2, 0.45, 0.7],
    rootMargin: "-20% 0px -45% 0px"
  });

  sections.forEach((section) => observer.observe(section));

  const firstSection = sections[0];
  setActiveSection(firstSection.id, firstSection.dataset.sectionTitle || firstSection.id);
}

function initHeroLens() {
  const lensButtons = queryAll(SELECTORS.lensButtons);
  if (!lensButtons.length) {
    return;
  }

  const lensCaption = queryOne(SELECTORS.lensCaption);
  const lensNote = queryOne(SELECTORS.lensNote);
  const lensPill = queryOne(SELECTORS.lensPill);
  const lensCopy = queryOne(SELECTORS.lensCopy);

  const applyLens = (lensKey) => {
    const lensContent = HERO_LENS_LIBRARY[lensKey];
    if (!lensContent) {
      return;
    }

    document.body.dataset.lens = lensKey;
    setText(lensCaption, lensContent.caption);
    setText(lensNote, lensContent.note);
    setText(lensPill, lensContent.pill);
    setText(lensCopy, lensContent.copy);

    lensButtons.forEach((button) => {
      const isActive = button.dataset.lensToggle === lensKey;
      button.classList.toggle("is-active", isActive);
      button.setAttribute("aria-pressed", String(isActive));
    });
  };

  lensButtons.forEach((button) => {
    button.addEventListener("click", () => {
      applyLens(button.dataset.lensToggle || DEFAULT_STATE.lens);
    });
  });

  applyLens(document.body.dataset.lens || DEFAULT_STATE.lens);
}

function initHeroGlow() {
  if (hasReducedMotion()) {
    return;
  }

  const heroVisual = queryOne(SELECTORS.heroVisual);
  if (!heroVisual) {
    return;
  }

  const updateHeroGlow = (event) => {
    const bounds = heroVisual.getBoundingClientRect();
    const pointerX = ((event.clientX - bounds.left) / bounds.width) * 100;
    const pointerY = ((event.clientY - bounds.top) / bounds.height) * 100;

    heroVisual.style.setProperty("--pointer-x", `${pointerX}%`);
    heroVisual.style.setProperty("--pointer-y", `${pointerY}%`);
  };

  heroVisual.addEventListener("pointermove", updateHeroGlow);
  heroVisual.addEventListener("pointerleave", () => {
    heroVisual.style.setProperty("--pointer-x", "64%");
    heroVisual.style.setProperty("--pointer-y", "34%");
  });
}

function initTiltCards() {
  if (hasReducedMotion() || !hasFinePointer()) {
    return;
  }

  const tiltCards = queryAll(SELECTORS.tiltCards);

  tiltCards.forEach((card) => {
    const resetCardTilt = () => {
      card.style.setProperty("--tilt-x", "0deg");
      card.style.setProperty("--tilt-y", "0deg");
    };

    card.addEventListener("pointermove", (event) => {
      const bounds = card.getBoundingClientRect();
      const percentX = (event.clientX - bounds.left) / bounds.width;
      const percentY = (event.clientY - bounds.top) / bounds.height;
      const rotateX = (0.5 - percentY) * 8;
      const rotateY = (percentX - 0.5) * 8;

      card.style.setProperty("--tilt-x", `${rotateX.toFixed(2)}deg`);
      card.style.setProperty("--tilt-y", `${rotateY.toFixed(2)}deg`);
    });

    card.addEventListener("pointerleave", resetCardTilt);
    card.addEventListener("blur", resetCardTilt, true);
  });
}

function initFloatingCards() {
  if (hasReducedMotion()) {
    return;
  }

  const floatingCards = queryAll(SELECTORS.floatingCards);

  floatingCards.forEach((card, index) => {
    const offset = index % 2 === 0 ? "-8px" : "8px";
    card.style.setProperty("--float-offset", offset);
  });
}

function initCursorAura() {
  if (hasReducedMotion() || !hasFinePointer()) {
    return;
  }

  const cursorAura = queryOne(SELECTORS.cursorAura);
  if (!cursorAura) {
    return;
  }

  const updateAura = (event) => {
    const pointerX = event.clientX;
    const pointerY = event.clientY;

    cursorAura.style.transform = `translate3d(${pointerX}px, ${pointerY}px, 0)`;
    document.documentElement.style.setProperty("--cursor-x", `${pointerX}px`);
    document.documentElement.style.setProperty("--cursor-y", `${pointerY}px`);
  };

  window.addEventListener("pointermove", updateAura, { passive: true });
}

function initSheenCards() {
  if (hasReducedMotion() || !hasFinePointer()) {
    return;
  }

  const sheenCards = queryAll(SELECTORS.sheenCards);

  sheenCards.forEach((card) => {
    const resetCardSheen = () => {
      card.style.setProperty("--sheen-x", "50%");
      card.style.setProperty("--sheen-y", "50%");
    };

    resetCardSheen();

    card.addEventListener("pointermove", (event) => {
      const bounds = card.getBoundingClientRect();
      const pointerX = ((event.clientX - bounds.left) / bounds.width) * 100;
      const pointerY = ((event.clientY - bounds.top) / bounds.height) * 100;

      card.style.setProperty("--sheen-x", `${pointerX}%`);
      card.style.setProperty("--sheen-y", `${pointerY}%`);
    });

    card.addEventListener("pointerleave", resetCardSheen);
  });
}

function initGiftFinder() {
  const optionButtons = queryAll(SELECTORS.giftFinderButtons);

  if (!optionButtons.length || !queryOne(SELECTORS.giftResult)) {
    return;
  }

  const resultNodes = {
    title: queryOne(SELECTORS.giftTitle),
    copy: queryOne(SELECTORS.giftCopy),
    price: queryOne(SELECTORS.giftPrice),
    note: queryOne(SELECTORS.giftNote),
    pill: queryOne(SELECTORS.giftPill),
    image: queryOne(SELECTORS.giftImage),
    points: queryOne(SELECTORS.giftPoints)
  };

  const state = { ...DEFAULT_STATE.giftFinder };

  const renderGiftFinder = () => {
    const styleContent = GIFT_FINDER_LIBRARY.styles[state.style];
    const budgetContent = GIFT_FINDER_LIBRARY.budgets[state.budget];
    const occasionContent = GIFT_FINDER_LIBRARY.occasions[state.occasion];

    if (!styleContent || !budgetContent || !occasionContent) {
      return;
    }

    setText(resultNodes.pill, occasionContent.pill);
    setText(resultNodes.title, styleContent.title);
    setText(resultNodes.copy, `${occasionContent.prefix}${styleContent.copy}`);
    setText(resultNodes.price, budgetContent.price);
    setText(resultNodes.note, budgetContent.note);
    setImage(resultNodes.image, styleContent.image, `${styleContent.title} recommendation image`);
    replaceChildrenWithText(resultNodes.points, styleContent.points, "li");
  };

  optionButtons.forEach((button) => {
    button.addEventListener("click", () => {
      const { giftGroup, giftValue } = button.dataset;
      if (!giftGroup || !giftValue) {
        return;
      }

      state[giftGroup] = giftValue;

      optionButtons.forEach((candidate) => {
        if (candidate.dataset.giftGroup !== giftGroup) {
          return;
        }

        const isActive = candidate.dataset.giftValue === giftValue;
        candidate.classList.toggle("is-active", isActive);
      });

      renderGiftFinder();
    });
  });

  renderGiftFinder();
}

function syncHeaderTriggerState(triggers, activeKey = null) {
  triggers.forEach((trigger) => {
    const isActive = trigger.dataset.navPanel === activeKey;
    trigger.classList.toggle("is-panel-active", isActive);
    trigger.setAttribute("aria-expanded", String(isActive));
  });
}

function closeHeaderPanelState(header, panel, triggers) {
  header.classList.remove("has-open-panel");
  panel.setAttribute("aria-hidden", "true");
  syncHeaderTriggerState(triggers, null);
}

function initHeaderPanel() {
  if (!canUseDesktopHeaderPanel()) {
    return;
  }

  const header = queryOne(SELECTORS.siteHeader);
  const panel = queryOne(SELECTORS.headerPanel);
  const triggers = queryAll(SELECTORS.headerPanelTriggers);

  if (!header || !panel || !triggers.length) {
    return;
  }

  const panelNodes = {
    eyebrow: queryOne(SELECTORS.headerPanelEyebrow, panel),
    title: queryOne(SELECTORS.headerPanelTitle, panel),
    copy: queryOne(SELECTORS.headerPanelCopy, panel),
    links: queryOne(SELECTORS.headerPanelLinks, panel),
    meta: queryOne(SELECTORS.headerPanelMeta, panel)
  };

  let closeTimerId = 0;
  let activePanelKey = null;

  const clearCloseTimer = () => {
    if (closeTimerId) {
      window.clearTimeout(closeTimerId);
      closeTimerId = 0;
    }
  };

  const renderHeaderPanel = (panelKey) => {
    const panelContent = HEADER_PANEL_LIBRARY[panelKey];
    if (!panelContent) {
      return;
    }

    setText(panelNodes.eyebrow, panelContent.eyebrow);
    setText(panelNodes.title, panelContent.title);
    setText(panelNodes.copy, panelContent.copy);
    replaceChildrenWithLinks(panelNodes.links, panelContent.links);
    replaceChildrenWithText(panelNodes.meta, panelContent.meta, "span");
  };

  const openHeaderPanel = (panelKey) => {
    clearCloseTimer();

    activePanelKey = panelKey;
    renderHeaderPanel(panelKey);
    syncHeaderTriggerState(triggers, panelKey);

    header.classList.add("has-open-panel");
    panel.setAttribute("aria-hidden", "false");
  };

  const closeHeaderPanel = () => {
    activePanelKey = null;
    closeHeaderPanelState(header, panel, triggers);
  };

  const scheduleHeaderClose = () => {
    clearCloseTimer();
    closeTimerId = window.setTimeout(closeHeaderPanel, 120);
  };

  triggers.forEach((trigger) => {
    const panelKey = trigger.dataset.navPanel;

    trigger.addEventListener("pointerenter", () => openHeaderPanel(panelKey));
    trigger.addEventListener("focus", () => openHeaderPanel(panelKey));
    trigger.addEventListener("pointerleave", scheduleHeaderClose);
  });

  panel.addEventListener("pointerenter", clearCloseTimer);
  panel.addEventListener("pointerleave", scheduleHeaderClose);

  header.addEventListener("focusout", (event) => {
    if (!header.contains(event.relatedTarget)) {
      scheduleHeaderClose();
    }
  });

  window.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && activePanelKey) {
      clearCloseTimer();
      closeHeaderPanel();
    }
  });
}

function initHeaderCondense() {
  const header = queryOne(SELECTORS.siteHeader);
  const panel = queryOne(SELECTORS.headerPanel);
  const triggers = queryAll(SELECTORS.headerPanelTriggers);

  if (!header) {
    return;
  }

  const updateHeaderCondenseState = () => {
    const shouldCondense = window.scrollY > 36;
    header.classList.toggle("is-condensed", shouldCondense);

    if (shouldCondense && panel && triggers.length) {
      closeHeaderPanelState(header, panel, triggers);
    }
  };

  updateHeaderCondenseState();
  window.addEventListener("scroll", updateHeaderCondenseState, { passive: true });
}

const BOOT_SEQUENCE = [
  syncScrollProgress,
  initRevealItems,
  initSectionTracking,
  initHeroLens,
  initHeroGlow,
  initTiltCards,
  initFloatingCards,
  initCursorAura,
  initSheenCards,
  initGiftFinder,
  initHeaderPanel,
  initHeaderCondense
];

function initPreviewPage() {
  BOOT_SEQUENCE.forEach((bootTask) => bootTask());

  window.addEventListener("scroll", syncScrollProgress, { passive: true });
  window.addEventListener("resize", syncScrollProgress);
}

window.addEventListener("DOMContentLoaded", initPreviewPage);
