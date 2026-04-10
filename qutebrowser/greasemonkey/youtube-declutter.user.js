// ==UserScript==
// @name         YouTube Declutter
// @namespace    qutebrowser
// @version      2.0
// @description  Clean up YouTube: hide distracting UI elements. Shorts only hidden on home.
// @match        https://www.youtube.com/*
// @match        https://m.youtube.com/*
// @run-at       document-start
// @grant        none
// ==/UserScript==

(function () {
  "use strict";

  /**
   * CONFIGURATION: Customize what to hide by setting these to true/false
   */
  const CONFIG = {
    hideHomeShorts: true,           // Hide shorts shelf on home page
    hideHomeFeed: true,             // Hide the entire home feed (keeps recommendations off)
    hideWatchPageSidebar: true,     // Hide recommendations on video watch page
    hideComments: true,             // Hide comments section
    hideMerch: true,                // Hide merch shelves
    hideAds: true,                  // Hide ads and promotions
    hideLiveChat: true,             // Hide live chat
    hideCards: true,                // Hide video cards and end screens
    hideCommunityPosts: true,       // Hide community posts
    hideTrendingTab: true,          // Hide trending in sidebar
    hideExploreTab: true,           // Hide explore in sidebar
    hideShortsGuide: true,          // Hide shorts from sidebar guide
    hidePlayables: true,            // Hide playables/games
    hideBreakingNews: true,         // Hide news banners
    hidePodcasts: true,             // Hide podcasts shelf
  };

  /**
   * Build CSS based on CONFIG
   */
  function buildCSS() {
    const selectors = [];

    // Always hide on every page
    if (CONFIG.hideWatchPageSidebar) {
      selectors.push("#secondary", "#secondary-inner", "ytd-watch-next-secondary-results-renderer");
    }

    if (CONFIG.hideComments) {
      selectors.push("#comments", "ytd-comments", "ytd-comment-thread-renderer");
    }

    if (CONFIG.hideMerch) {
      selectors.push("ytd-merch-shelf-renderer", "ytd-product-list-renderer");
    }

    if (CONFIG.hideAds) {
      selectors.push(
        "ytd-video-masthead-ad-advertiser-info-renderer",
        "ytd-display-ad-renderer",
        "ytd-ad-slot-renderer",
        "ytd-promoted-sparkles-web-renderer",
        "ytd-feed-nudge-renderer",
        "ytd-statement-banner-renderer",
        "ytd-banner-promo-renderer",
        "ytd-inline-survey-renderer",
        "ytd-primetime-promo-renderer"
      );
    }

    if (CONFIG.hideLiveChat) {
      selectors.push("#clarify-box", "#chat", "ytd-live-chat-frame");
    }

    if (CONFIG.hideCards) {
      selectors.push(
        ".ytp-ce-element",
        ".ytp-cards-teaser",
        ".ytp-paid-content-overlay",
        ".iv-branding",
        "ytd-engagement-panel-section-list-renderer[target-id='engagement-panel-structured-description']",
        "ytd-engagement-panel-section-list-renderer[target-id='engagement-panel-clip-create']",
        "ytd-engagement-panel-section-list-renderer[target-id='engagement-panel-shopping-shelf']",
        "ytd-engagement-panel-section-list-renderer[target-id='engagement-panel-macro-markers-description-chapters']"
      );
    }

    if (CONFIG.hideCommunityPosts) {
      selectors.push("ytd-rich-shelf-renderer:has(yt-formatted-string:contains('Community'))");
    }

    if (CONFIG.hidePlayables) {
      selectors.push("ytd-rich-shelf-renderer:has(yt-formatted-string:contains('Playables'))");
    }

    if (CONFIG.hidePodcasts) {
      selectors.push("ytd-rich-shelf-renderer:has(yt-formatted-string:contains('Podcasts'))");
    }

    if (CONFIG.hideBreakingNews) {
      selectors.push(
        "ytd-rich-shelf-renderer:has(yt-formatted-string:contains('Breaking'))",
        "ytd-rich-shelf-renderer:has(yt-formatted-string:contains('Latest'))",
        "ytd-rich-shelf-renderer:has(yt-formatted-string:contains('Live Now'))"
      );
    }

    // Only on home page
    if (isHomePage()) {
      if (CONFIG.hideHomeShorts) {
        selectors.push(
          "ytd-reel-shelf-renderer",
          "ytd-rich-shelf-renderer[is-shorts]",
          "ytd-rich-section-renderer:has(ytd-reel-shelf-renderer)",
          "ytd-rich-item-renderer:has(a[href^='/shorts'])",
          "ytd-video-renderer:has(a[href^='/shorts'])",
          "ytd-grid-video-renderer:has(a[href^='/shorts'])",
          "ytd-compact-video-renderer:has(a[href^='/shorts'])",
          "ytd-rich-grid-media:has(a[href^='/shorts'])"
        );
      }

      if (CONFIG.hideHomeFeed) {
        // Hide main feed container but keep header
        selectors.push("ytd-rich-grid-renderer");
      }

      if (CONFIG.hideShortsGuide) {
        selectors.push(
          "ytd-guide-entry-renderer:has(yt-formatted-string:contains('Shorts'))",
          "ytm-pivot-bar-item-renderer:has(yt-formatted-string:contains('Shorts'))"
        );
      }

      if (CONFIG.hideExploreTab) {
        selectors.push(
          "ytd-guide-entry-renderer:has(yt-formatted-string:contains('Explore'))",
          "ytm-pivot-bar-item-renderer:has(yt-formatted-string:contains('Explore'))"
        );
      }

      if (CONFIG.hideTrendingTab) {
        selectors.push(
          "ytd-guide-entry-renderer:has(yt-formatted-string:contains('Trending'))",
          "ytm-pivot-bar-item-renderer:has(yt-formatted-string:contains('Trending'))"
        );
      }
    }

    const css = selectors.map((s) => s).join(",\n") + " { display: none !important; }";

    // Adjust video player width on watch page
    const adjustments = `
      ytd-watch-flexy[is-two-columns_] #primary {
        max-width: min(100%, 1600px) !important;
        margin-inline: auto !important;
      }
      ytd-watch-flexy[is-two-columns_] #columns {
        display: block !important;
      }
    `;

    return css + "\n" + adjustments;
  }

  function isHomePage() {
    const path = location.pathname;
    // Don't hide shorts on channel /shorts pages or anywhere other than home
    if (path.includes("/shorts") || path.includes("/c/") || path.includes("/@")) {
      return false;
    }
    return path === "/" || path === "" || path === "/feed/home" || path === "/feed/discover";
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

    const newCSS = buildCSS();
    if (style.textContent !== newCSS) {
      style.textContent = newCSS;
    }
  }

  // Initial injection
  injectStyle();
  document.addEventListener("readystatechange", injectStyle);

  // Re-inject on page navigation
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", () => {
      injectStyle();
      observeChanges();
    });
  } else {
    injectStyle();
    observeChanges();
  }

  function observeChanges() {
    // Re-inject style when DOM changes (for dynamic page loads)
    const observer = new MutationObserver(() => {
      injectStyle();
    });
    observer.observe(document.body, { childList: true, subtree: true });

    // Also check for navigation changes every 1 second
    let lastUrl = location.href;
    setInterval(() => {
      if (location.href !== lastUrl) {
        lastUrl = location.href;
        injectStyle();
      }
    }, 1000);
  }
})();
