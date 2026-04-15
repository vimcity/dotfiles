# YouTube Declutter Prompt

Please help me fix and improve this userscript:

- File: `qutebrowser/greasemonkey/youtube-declutter.user.js`
- Environment: qutebrowser userscript / greasemonkey-style script
- Goal: declutter YouTube without breaking page rendering or slowing the site down

## What I want

1. Hide Shorts on the YouTube home page.
2. Do not hide Shorts when viewing a channel page, especially channel Shorts tabs/pages like:
   - `/@handle/shorts`
   - `/c/name/shorts`
   - `/channel/.../shorts`
3. Hide the entire left sidebar `Explore` section, including entries like:
   - Shopping
   - Music
   - Movies & TV
   - Live
   - Gaming
   - News
   - Sports
   - Learning
   - Courses
   - Fashion & Beauty
   - Podcasts
   - Playables
4. Hide the entire `More from YouTube` section, including entries like:
   - YouTube Premium
   - YouTube TV
   - YouTube Music
   - YouTube Kids
5. Hide `Report history`.
6. Avoid making YouTube feel slow, half-rendered, or broken.

## Important notes

1. A previous attempt used unsupported CSS selectors like `:contains(...)`; please avoid that.
2. A previous attempt also rescanned the DOM too aggressively and may have slowed YouTube down.
3. Please use Chrome DevTools MCP to inspect the real current YouTube DOM before changing logic.
4. Prefer a minimal, robust implementation over a huge over-engineered one.
5. If possible, use stable selectors for structural elements and lightweight JS text matching only where necessary.

## What I want from you

1. Inspect the live YouTube DOM with Chrome DevTools MCP on:
   - the home page
   - a normal watch page
   - a channel page
   - a channel `/shorts` page
2. Identify exactly which elements should be hidden for the sidebar sections above.
3. Update `qutebrowser/greasemonkey/youtube-declutter.user.js` accordingly.
4. Keep Shorts visible on channel pages.
5. Verify the script does not break homepage rendering.
6. Summarize the final selectors / logic used and any tradeoffs.

## Current suspicion

The script is currently mixing CSS hiding and JS mutation scanning in a way that may be too broad. The homepage rendering issue may be caused by overly aggressive mutation handling or hiding the wrong home feed containers.
