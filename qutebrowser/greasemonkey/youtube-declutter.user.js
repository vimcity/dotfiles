// ==UserScript==
// @name         YouTube Declutter
// @namespace    qutebrowser
// @version      1.0
// @description  Hide distracting YouTube UI like recommendations, Shorts, comments, merch, and promo shelves
// @match        https://www.youtube.com/*
// @match        https://m.youtube.com/*
// @run-at       document-start
// @grant        none
// ==/UserScript==

(function () {
  "use strict";

  const HIDDEN_ATTR = "data-qute-yt-hidden";
  const BLOCKED_SHELF_TEXT = [
    "shorts",
    "people also watched",
    "for you",
    "recommended",
    "recommended for you",
    "because you watched",
    "you might also like",
    "new to you",
    "top picks for you",
    "playables",
    "podcasts",
    "community posts",
    "breaking news",
    "latest news",
    "live now",
    "shopping",
    "products for this video",
    "from the shop",
  ];

  const CSS = `
    #secondary,
    #secondary-inner,
    ytd-watch-next-secondary-results-renderer,
    #comments,
    ytd-comments,
    ytd-comment-thread-renderer,
    ytd-reel-shelf-renderer,
    ytd-rich-shelf-renderer[is-shorts],
    ytd-rich-section-renderer:has(ytd-reel-shelf-renderer),
    ytd-rich-item-renderer:has(a[href^="/shorts"]),
    ytd-video-renderer:has(a[href^="/shorts"]),
    ytd-grid-video-renderer:has(a[href^="/shorts"]),
    ytd-compact-video-renderer:has(a[href^="/shorts"]),
    ytd-rich-grid-media:has(a[href^="/shorts"]),
    a[href^="/shorts"],
    ytd-merch-shelf-renderer,
    ytd-product-list-renderer,
    ytd-video-masthead-ad-advertiser-info-renderer,
    ytd-display-ad-renderer,
    ytd-ad-slot-renderer,
    ytd-promoted-sparkles-web-renderer,
    ytd-feed-nudge-renderer,
    ytd-statement-banner-renderer,
    ytd-banner-promo-renderer,
    ytd-inline-survey-renderer,
    ytd-primetime-promo-renderer,
    .ytp-ce-element,
    .ytp-cards-teaser,
    .ytp-paid-content-overlay,
    .iv-branding,
    #clarify-box,
    #chat,
    ytd-live-chat-frame,
    ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-structured-description"],
    ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-clip-create"],
    ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-shopping-shelf"],
    ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-macro-markers-description-chapters"] {
      display: none !important;
    }

    ytd-watch-flexy[is-two-columns_] #primary {
      max-width: min(100%, 1600px) !important;
      margin-inline: auto !important;
    }

    ytd-watch-flexy[is-two-columns_] #columns {
      display: block !important;
    }
  `;

  function injectStyle() {
    if (document.head && !document.getElementById("qute-youtube-declutter-style")) {
      const style = document.createElement("style");
      style.id = "qute-youtube-declutter-style";
      style.textContent = CSS;
      document.head.appendChild(style);
    }
  }

  function textOf(node) {
    return (node?.textContent || "").replace(/\s+/g, " ").trim().toLowerCase();
  }

  function hide(node) {
    if (!node || node.nodeType !== Node.ELEMENT_NODE || node.getAttribute(HIDDEN_ATTR) === "1") {
      return;
    }
    node.setAttribute(HIDDEN_ATTR, "1");
    node.style.setProperty("display", "none", "important");
  }

  function maybeHideGuideEntry(entry) {
    const label = textOf(entry);
    if (label === "shorts" || label === "explore" || label === "trending") {
      hide(entry);
    }
  }

  function maybeHideShelf(shelf) {
    const label = textOf(shelf.querySelector("#title, #header, yt-formatted-string")) || textOf(shelf);
    if (BLOCKED_SHELF_TEXT.some((text) => label.includes(text))) {
      hide(shelf);
    }
  }

  function scan(root) {
    if (!root || root.nodeType !== Node.ELEMENT_NODE) {
      return;
    }

    if (root.matches?.("ytd-guide-entry-renderer, ytm-pivot-bar-item-renderer")) {
      maybeHideGuideEntry(root);
    }

    if (
      root.matches?.(
        "ytd-rich-shelf-renderer, ytd-rich-section-renderer, ytd-item-section-renderer, ytd-shelf-renderer"
      )
    ) {
      maybeHideShelf(root);
    }

    root
      .querySelectorAll?.("ytd-guide-entry-renderer, ytm-pivot-bar-item-renderer")
      .forEach(maybeHideGuideEntry);

    root
      .querySelectorAll?.(
        "ytd-rich-shelf-renderer, ytd-rich-section-renderer, ytd-item-section-renderer, ytd-shelf-renderer"
      )
      .forEach(maybeHideShelf);
  }

  function boot() {
    injectStyle();
    if (!document.body) {
      return;
    }

    scan(document.body);

    const observer = new MutationObserver((mutations) => {
      injectStyle();
      for (const mutation of mutations) {
        for (const node of mutation.addedNodes) {
          if (node.nodeType === Node.ELEMENT_NODE) {
            scan(node);
          }
        }
      }
    });

    observer.observe(document.body, { childList: true, subtree: true });

    let lastUrl = location.href;
    setInterval(() => {
      injectStyle();
      if (location.href !== lastUrl) {
        lastUrl = location.href;
        scan(document.body);
      }
    }, 1000);
  }

  injectStyle();
  document.addEventListener("readystatechange", injectStyle);
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
