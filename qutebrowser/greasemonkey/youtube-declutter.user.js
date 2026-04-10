// ==UserScript==
// @name         YouTube Declutter
// @namespace    qutebrowser
// @version      3.0
// @description  Hide distracting YouTube UI. Shorts are hidden on home, but kept on channel pages.
// @match        https://www.youtube.com/*
// @match        https://m.youtube.com/*
// @run-at       document-start
// @grant        none
// ==/UserScript==

(function () {
  "use strict";

  const HIDDEN_ATTR = "data-qute-yt-hidden";

  const CONFIG = {
    hideHomeFeed: true,
    hideHomeShorts: true,
    hideWatchPageSidebar: true,
    hideComments: true,
    hideMerch: true,
    hideAds: true,
    hideLiveChat: true,
    hideCards: true,
    hideExploreSection: true,
    hideMoreFromYoutubeSection: true,
    hideReportHistory: true,
    hideGuideEntries: ["shorts", "explore", "trending"],
    hideShelves: [
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
    ],
  };

  const BASE_CSS = `
    ${CONFIG.hideWatchPageSidebar ? `
    #secondary,
    #secondary-inner,
    ytd-watch-next-secondary-results-renderer,
    ` : ""}
    ${CONFIG.hideComments ? `
    #comments,
    ytd-comments,
    ytd-comment-thread-renderer,
    ` : ""}
    ${CONFIG.hideMerch ? `
    ytd-merch-shelf-renderer,
    ytd-product-list-renderer,
    ` : ""}
    ${CONFIG.hideAds ? `
    ytd-video-masthead-ad-advertiser-info-renderer,
    ytd-display-ad-renderer,
    ytd-ad-slot-renderer,
    ytd-promoted-sparkles-web-renderer,
    ytd-feed-nudge-renderer,
    ytd-statement-banner-renderer,
    ytd-banner-promo-renderer,
    ytd-inline-survey-renderer,
    ytd-primetime-promo-renderer,
    ` : ""}
    ${CONFIG.hideLiveChat ? `
    #clarify-box,
    #chat,
    ytd-live-chat-frame,
    ` : ""}
    ${CONFIG.hideCards ? `
    .ytp-ce-element,
    .ytp-cards-teaser,
    .ytp-paid-content-overlay,
    .iv-branding,
    ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-structured-description"],
    ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-clip-create"],
    ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-shopping-shelf"],
    ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-macro-markers-description-chapters"],
    ` : ""}
    [${HIDDEN_ATTR}="1"] {
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

  function isHomePage() {
    return location.pathname === "/" || location.pathname === "" || location.pathname === "/feed/home";
  }

  function isChannelPage() {
    const path = location.pathname;
    return path.startsWith("/@") || path.startsWith("/c/") || path.startsWith("/channel/") || path.startsWith("/user/");
  }

  function textOf(node) {
    return (node?.textContent || "").replace(/\s+/g, " ").trim().toLowerCase();
  }

  function hide(node) {
    if (!node || node.nodeType !== Node.ELEMENT_NODE || node.getAttribute(HIDDEN_ATTR) === "1") {
      return;
    }
    node.setAttribute(HIDDEN_ATTR, "1");
  }

  function injectStyle() {
    if (!document.head) {
      return;
    }

    let style = document.getElementById("qute-youtube-declutter-style");
    if (!style) {
      style = document.createElement("style");
      style.id = "qute-youtube-declutter-style";
      document.head.appendChild(style);
    }

    let css = BASE_CSS;

    if (CONFIG.hideHomeFeed && isHomePage()) {
      css += `
        ytd-page-manager[page-subtype="home"] ytd-rich-grid-renderer,
        ytd-page-manager[page-subtype="home"] ytd-rich-section-renderer,
        ytd-browse[page-subtype="home"] ytd-rich-grid-renderer,
        ytd-browse[page-subtype="home"] ytd-rich-section-renderer {
          display: none !important;
        }
      `;
    }

    if (CONFIG.hideHomeShorts && isHomePage()) {
      css += `
        ytd-page-manager[page-subtype="home"] ytd-reel-shelf-renderer,
        ytd-page-manager[page-subtype="home"] ytd-rich-shelf-renderer[is-shorts],
        ytd-browse[page-subtype="home"] ytd-reel-shelf-renderer,
        ytd-browse[page-subtype="home"] ytd-rich-shelf-renderer[is-shorts] {
          display: none !important;
        }
      `;
    }

    if (style.textContent !== css) {
      style.textContent = css;
    }
  }

  function maybeHideGuideEntry(entry) {
    const label = textOf(entry);
    if (CONFIG.hideGuideEntries.some((item) => label === item)) {
      hide(entry);
    }

    if (CONFIG.hideReportHistory && label === "report history") {
      hide(entry);
    }
  }

  function maybeHideGuideSection(section) {
    const title = textOf(section.querySelector("h3, #header, yt-formatted-string"));
    if (CONFIG.hideExploreSection && title === "explore") {
      hide(section);
      return;
    }

    if (CONFIG.hideMoreFromYoutubeSection && title === "more from youtube") {
      hide(section);
    }
  }

  function maybeHideShelf(shelf) {
    const label = textOf(shelf.querySelector("#title, #header, yt-formatted-string")) || textOf(shelf);

    if (label.includes("shorts") && !isHomePage() && isChannelPage()) {
      return;
    }

    if (CONFIG.hideShelves.some((text) => label.includes(text))) {
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

    if (root.matches?.("ytd-guide-section-renderer")) {
      maybeHideGuideSection(root);
    }

    if (
      root.matches?.(
        "ytd-rich-shelf-renderer, ytd-rich-section-renderer, ytd-item-section-renderer, ytd-shelf-renderer"
      )
    ) {
      maybeHideShelf(root);
    }

    root.querySelectorAll?.("ytd-guide-entry-renderer, ytm-pivot-bar-item-renderer").forEach(maybeHideGuideEntry);
    root.querySelectorAll?.("ytd-guide-section-renderer").forEach(maybeHideGuideSection);
    root
      .querySelectorAll?.("ytd-rich-shelf-renderer, ytd-rich-section-renderer, ytd-item-section-renderer, ytd-shelf-renderer")
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
