// ==UserScript==
// @name         YouTube single-play across tabs
// @namespace    qutebrowser
// @version      1.0
// @description  Pause YouTube videos in other tabs when one starts playing
// @match        https://www.youtube.com/*
// @match        https://music.youtube.com/*
// @run-at       document-end
// ==/UserScript==

(function () {
  "use strict";

  const CHANNEL_KEY = "qute_youtube_single_play";
  const TAB_ID = `${Date.now()}_${Math.random().toString(36).slice(2)}`;

  function notifyPlaying() {
    const payload = JSON.stringify({
      tabId: TAB_ID,
      ts: Date.now(),
    });
    localStorage.setItem(CHANNEL_KEY, payload);
  }

  function pauseAllLocal() {
    document.querySelectorAll("video").forEach((video) => {
      if (!video.paused) {
        video.pause();
      }
    });
  }

  function bindVideos() {
    document.querySelectorAll("video").forEach((video) => {
      if (video.dataset.quteSinglePlayBound === "1") {
        return;
      }
      video.dataset.quteSinglePlayBound = "1";
      video.addEventListener("play", notifyPlaying);
    });
  }

  window.addEventListener("storage", (event) => {
    if (event.key !== CHANNEL_KEY || !event.newValue) {
      return;
    }
    try {
      const payload = JSON.parse(event.newValue);
      if (payload.tabId !== TAB_ID) {
        pauseAllLocal();
      }
    } catch (_) {
      // ignore malformed payloads
    }
  });

  bindVideos();
  setInterval(bindVideos, 1000);
})();
