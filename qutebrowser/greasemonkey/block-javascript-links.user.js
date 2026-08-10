// ==UserScript==
// @name         Block javascript: link navigation
// @namespace    qutebrowser
// @version      1.1
// @description  Block javascript: and data:text/html link navigations (QtWebEngine crash on enterprise UIs).
// @match        *://*/*
// @run-at       document-start
// @grant        none
// ==/UserScript==

(function () {
  "use strict";

  const BLOCKED = /^(javascript:|data:text\/html)/i;

  function nearestAnchor(node) {
    return node instanceof Element ? node.closest("a[href]") : null;
  }

  function shouldBlock(href) {
    if (!href || href === "#") {
      return false;
    }
    return BLOCKED.test(href);
  }

  function blockIfUnsafeLink(event) {
    const anchor = nearestAnchor(event.target);
    if (!anchor) {
      return;
    }
    const href = anchor.getAttribute("href") || "";
    if (!shouldBlock(href)) {
      return;
    }
    event.preventDefault();
    event.stopPropagation();
    console.debug("[qute-safe] blocked unsafe navigation:", href.slice(0, 120));
  }

  // Capture phase so we beat site handlers that navigate via href.
  for (const type of ["click", "auxclick"]) {
    document.addEventListener(type, blockIfUnsafeLink, true);
  }
})();
