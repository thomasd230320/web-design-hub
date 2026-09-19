# Build plan: the phone showcase, done properly

**For the agent executing this:** read this whole file first, then `index.html` top to bottom (it is ~1,470 lines, one file, no build step). Work on the branch you were given. Do not introduce a framework, bundler, or `package.json` — this site is deliberately one hand-coded HTML file deployed as static on Vercel, and the copy on the page says so. Everything below is achievable in plain HTML/CSS/JS.

## Why the current version fails (verified with screenshots at 1440 and 390 wide)

1. **The phone shows a chatbot, not a website.** `.phone-body` is a heading, one speech bubble and a reply. On a 340×737 screen roughly 60% is empty gradient. A site that sells web design must put convincing *websites* inside the phone.
2. **The hero has no headline, no offer, no CTA.** First screen is a phone + one italic caption. The actual `<h1>` is on the *second* screen (`.head-scene`). For lead gen, the pitch must be above the fold.
3. **Mobile is the weakest experience, and it's where local-business owners will look.** At `max-width:680px` the scrolly is dismantled (lines ~661–670): four text blocks stack into a wall, then one static phone appears at the bottom. The signature interaction doesn't exist on the device the site is about.
4. **Every image is a hotlink to `images.unsplash.com` at `w=2400`** (12 references). Slow LCP, third-party dependency, and no `<img>` elements so nothing is lazy-loaded or preloaded.
5. **No lead capture.** Contact is `mailto:` and `tel:` only. (Deferred — see Part 6.)
6. The step change is a hard 4-way switch (`Math.floor(progress*steps)`) with opacity crossfades. It works but feels like a slideshow, not a scroll-driven scene.

## What "done" looks like

A visitor on a phone or a laptop sees, in order:

1. **Hero** — headline + subhead + two CTAs on the left (stacked above on mobile), and a phone on the right showing a *complete café website* whose content slowly auto-scrolls inside the frame. Ambient three.js embers behind it on desktop only.
2. **Scrolly ("Built for businesses like yours")** — the phone pins to the viewport. As the visitor scrolls, four full mini-websites (café → barber → electrician → wedding venue) slide through the phone, and *within* each step the mini-site's own page scrolls under the visitor's thumb. Text captions change alongside. The phone tilts a few degrees in 3D as it goes. Works identically on mobile with the phone pinned at the top and captions beneath.
3. Everything else on the page stays, with images self-hosted.

Target: Lighthouse mobile Performance ≥ 90, CLS < 0.05, and it must look like something a paying client would want.

---

## Part 1 — Self-host the images (do this first; everything else depends on it)

Create `/img/`. For each Unsplash URL in `index.html`, download once at a sensible size and convert to WebP. Use the photo IDs already in the file. Sizes:

| Use | Width | File |
|---|---|---|
| Hero / scene / scrolly backgrounds (5 distinct photos) | 1920 | `img/bg-cafe.webp`, `img/bg-night.webp`, `img/bg-field.webp`, `img/bg-forest.webp`, plus whichever `cta-bg` uses |
| Same, mobile variant | 900 | `img/bg-*-m.webp` |
| Work showcase (3) | 1400 | `img/work-*.webp` |
| Mini-site hero photos for the phone (4 new, see Part 3) | 800 | `img/ph-cafe.webp` etc. |

Unsplash supports `?w=1920&fm=webp&q=78` directly, so `curl` with those params gives WebP without a local converter. If you do have `cwebp`/`sharp` available, use `q=78`.

Then:
- Replace every `background-image:url('https://images.unsplash.com/…')` with the local path. Use `image-set()` or a `@media (max-width:680px)` override for the `-m` variants.
- Add `<link rel="preload" as="image" href="/img/bg-cafe.webp" fetchpriority="high">` for the hero background only.
- Remove the `preconnect` to `images.unsplash.com`.
- Keep the footer credit line ("Example imagery sourced from Unsplash") — Unsplash licence needs no attribution but the credit is honest and already there.

**Check:** `grep -c images.unsplash.com index.html` returns 0. Page still renders identically.

---

## Part 2 — Hero restructure

Current: `.hero` (line ~705) is a centred column: phone, caption, scroll hint. Separate `.head-scene` (line ~731) holds the `<h1>`.

Change to:

```html
<section class="scene hero">
  <div class="scene-bg hero-bg"></div>
  <canvas class="hero-canvas"></canvas>
  <div class="inner hero-inner">
    <div class="hero-copy">
      <span class="scrolly-eyebrow">Witney · Oxfordshire</span>
      <h1>Small-business websites, <em>built by hand</em> in Oxfordshire.</h1>
      <p class="hero-sub">Hand-coded, mobile-first sites that turn Google searches into phone calls. From £395, usually live in about five days.</p>
      <div class="hero-ctas">
        <a href="#contact" class="pill pill-brand pill-lg">Get a free quote</a>
        <a href="#work" class="pill pill-lg">See example sites</a>
      </div>
      <p class="hero-proof">One person, every line of code. No templates, no agencies, no retainers.</p>
    </div>
    <div class="hero-phone">
      <div class="phone"> …café mini-site (Part 3), with class="ms-autoscroll"… </div>
    </div>
  </div>
</section>
```

- Desktop: `.hero-inner{display:grid;grid-template-columns:1.1fr .9fr;align-items:center;gap:60px;max-width:1240px;margin:0 auto}`. Phone sits slightly rotated: `transform:rotate(-4deg) translateY(10px)` with a gentle `hero-float` keyframe (±6px, 7s, ease-in-out) — disabled under `prefers-reduced-motion`.
- Mobile (`≤680px`): single column, copy first, phone below at `width:min(270px,68vw)`; h1 `clamp(2.1rem,9vw,2.8rem)`; both CTAs full-width stacked.
- **Delete `.head-scene` entirely** (section, CSS, and its three.js `buildHeadScene` block ~lines 1345–1418). Its h1 moves to the hero. One `<h1>` on the page. Reuse `.head-scene-bg`'s photo elsewhere or drop it.
- Auto-scroll inside the hero phone: the mini-site's `.ms-page` gets `animation: ms-drift 14s ease-in-out infinite alternate` translating from `0` to `calc(-100% + 100cqh)` … simpler: hard-code `translateY(-52%)` as the end state since you control the content height. Pause on `:hover` and under reduced motion.

**Check:** at 390×844 the h1, subhead and primary CTA are all visible without scrolling. At 1440×900 the phone's full frame is visible.

---

## Part 3 — The mini-sites (this is the heart of it)

Build four self-contained fake websites as HTML/CSS inside the phone screen. These replace the chat-bubble markup in **both** the hero phone and the four `.scrolly-screen` blocks. They must look like real, good websites at 320px wide — the kind the visitor would pay for.

### Shared structure

```html
<div class="ms ms-cafe">                <!-- one per business; .ms sets font, colours -->
  <div class="ms-status"><span>9:41</span><span class="ms-sig"></span></div>
  <div class="ms-nav">
    <span class="ms-logo">Bridge House</span>
    <span class="ms-burger"></span>
  </div>
  <div class="ms-page">                  <!-- this is what scrolls inside the frame -->
    <div class="ms-hero" style="background-image:url(/img/ph-cafe.webp)">
      <h3>Slow coffee.<br>Faster mornings.</h3>
      <a class="ms-btn">See the menu</a>
    </div>
    <section class="ms-sec"> …menu list (4 items with prices)… </section>
    <section class="ms-sec ms-hours"> …opening hours grid… </section>
    <section class="ms-sec ms-map"> …a CSS-drawn map tile with a pin… </section>
    <div class="ms-cta">Order ahead</div>
    <div class="ms-foot">Bridge House Coffee · Witney</div>
  </div>
  <div class="ms-home"></div>             <!-- iOS home indicator -->
</div>
```

Each `.ms-page` should be **~2.2× the screen height** so there is something to scroll.

### The four sites (match the copy already in `.scrolly-text`)

| Step | Business | Palette (inside phone) | Sections in `.ms-page` | Primary CTA |
|---|---|---|---|---|
| 0 | Bridge House Coffee, café | warm cream `#FFF6EC`, ink `#2A1A12`, accent `#C44B1F` | hero photo, "Today's menu" 4 items with £ prices, hours grid, map tile | "Order ahead" |
| 1 | Fade & Co, barber | near-black `#141414`, off-white text, brass accent `#C9A25C` | hero photo, "Book a chair" – 3 barber cards with avatar circles, time-slot pills (11:30 · 14:00 · 16:15), price list | "Book now" |
| 2 | Spark Electrical, electrician | white `#F7F7F5`, navy `#14243D`, safety yellow `#F2C14E` | hero photo, "What we do" 3 icon rows, trust strip (NICEIC ✓, 5★ Google ✓, Fully insured ✓), postcode quote form (input + button) | "Request a quote" |
| 3 | Elmgrove Barn, wedding venue | blush `#FBEDE9`, deep plum `#3B2230`, serif headings | full-bleed hero photo, "Available dates" 3 date rows, gallery 2×2 photo grid, testimonial | "Enquire about a date" |

Use Newsreader for the café and venue headings, Plus Jakarta Sans everywhere else — both are already loaded. Draw icons as inline SVG (Lucide-style, 20px, stroke 1.75). No image icons. The "map tile" is a CSS gradient with a couple of light lines and a brand-coloured pin — it does not need to be real.

**Quality bar:** put each mini-site in an empty test page at 320×690 and look at it. If you wouldn't screenshot it for a portfolio, it's not finished. Real hierarchy, real spacing (16px gutters, 12px radii on cards), real buttons with 44px hit height.

---

## Part 4 — The phone frame

Replace `.phone` / `.phone-notch` (lines ~266–312) with a more convincing device. Pure CSS.

```css
.phone{
  --w:340px;
  position:relative;width:min(var(--w),80vw);aspect-ratio:9/19.5;
  background:#0F0B0A;border-radius:52px;padding:11px;
  box-shadow:
    0 0 0 1.5px #2A2321,            /* frame edge */
    0 0 0 3px #0A0807,
    inset 0 0 0 1px rgba(255,255,255,.08),
    0 60px 120px -30px rgba(0,0,0,.65),
    0 30px 60px -30px rgba(0,0,0,.5);
}
.phone::before{ /* side buttons */
  content:'';position:absolute;left:-3px;top:22%;width:3px;height:9%;
  background:#1B1614;border-radius:2px 0 0 2px;
  box-shadow:0 14% 0 0 #1B1614, 0 27% 0 0 #1B1614; /* volume + mute — use explicit px if % misbehaves */
}
.phone::after{ /* power button */
  content:'';position:absolute;right:-3px;top:26%;width:3px;height:13%;
  background:#1B1614;border-radius:0 2px 2px 0;
}
.phone-screen{
  position:relative;width:100%;height:100%;border-radius:42px;overflow:hidden;
  background:#000;
}
.phone-island{ /* replaces notch */
  position:absolute;top:12px;left:50%;transform:translateX(-50%);
  width:86px;height:26px;border-radius:14px;background:#000;z-index:5;
}
.phone-screen::after{ /* glass reflection */
  content:'';position:absolute;inset:0;pointer-events:none;z-index:6;
  background:linear-gradient(115deg,rgba(255,255,255,.10) 0%,rgba(255,255,255,0) 32%);
  border-radius:inherit;
}
.ms-home{position:absolute;bottom:8px;left:50%;transform:translateX(-50%);width:110px;height:4px;border-radius:2px;background:rgba(0,0,0,.35);z-index:6}
```

Keep the `.phone` container with `transform-style:preserve-3d; will-change:transform` so the tilt in Part 5 is cheap.

---

## Part 5 — Scrolly mechanics (replace lines ~356–427 CSS and ~1446–1465 JS)

Keep the existing section skeleton (`.scrolly` tall wrapper, `.scrolly-stage` sticky) and the four `.scrolly-text > div[data-step]` captions. Change what drives it.

### Progress model

Section height `420vh` desktop, `360vh` mobile. JS computes `progress` 0→1 exactly as now. From it derive:

- `step = min(3, floor(progress * 4))` — which mini-site is active.
- `local = (progress * 4) - step` — 0→1 within the step.
- `--inner` = the mini-site's internal scroll: `local` mapped through an ease so it dwells at top and bottom: `inner = smoothstep(0.12, 0.88, local)`.
- `--tilt-y` = `(progress - .5) * -10` degrees; `--tilt-x` = `sin(progress * π) * 3` degrees.

Write **`--p`, `--inner`, `--tilt-x`, `--tilt-y`** and `data-step` onto `.scrolly`. **Lerp the displayed values** toward the targets in the rAF loop (factor 0.12) so it feels weighted, not 1:1. Keep the rAF running only while the section is on screen (IntersectionObserver, as the three.js code already does).

### CSS driven by those variables

```css
.scrolly-phone-wrap .phone{
  transform:perspective(1400px) rotateY(calc(var(--tilt-y,0)*1deg)) rotateX(calc(var(--tilt-x,0)*1deg));
}
.scrolly-screen{position:absolute;inset:0;opacity:0;transform:translateX(18%) scale(.96);transition:opacity .55s var(--ease),transform .55s var(--ease)}
.scrolly-screen.is-active{opacity:1;transform:none;z-index:2}
.scrolly-screen.is-prev{opacity:0;transform:translateX(-18%) scale(.96)}
.scrolly-screen .ms-page{transform:translateY(calc(var(--inner,0) * (100cqh - 100%)))} /* needs container-type:size on .phone-screen; fallback below */
```

If `cqh` support worries you, set `--page-h` per mini-site in px from JS (`el.scrollHeight - el.parentElement.clientHeight`) on load/resize and use `translateY(calc(var(--inner) * var(--page-h) * -1px))`. That's the safer route; do that.

JS toggles `is-active` / `is-prev` on the four screens instead of relying on `[data-step]` attribute selectors, and also toggles the matching caption and dot.

### Background photos per step

Keep the four `.scrolly-bg` layers and the crossfade — they carry the atmosphere. Add a slow Ken Burns to the active one: `scale(1) → scale(1.08)` over the step via `--inner`. Only on desktop.

### Mobile layout (`≤680px`) — **the scrolly stays sticky**

Delete the current mobile teardown (lines ~661–670). Replace with:

```css
@media (max-width:680px){
  .scrolly{height:360vh}
  .scrolly-stage{
    grid-template-columns:1fr;grid-template-rows:auto 1fr;
    padding:calc(env(safe-area-inset-top) + 88px) 20px 90px;gap:18px;align-content:start;
  }
  .scrolly-phone-wrap{order:1}
  .phone{--w:230px}                                 /* fits with captions below at 844px tall */
  .scrolly-text{order:2;min-height:150px;text-align:center}
  .scrolly-text h2{font-size:1.55rem}
  .scrolly-text p{font-size:.98rem;max-width:32ch;margin:10px auto 0}
  .scrolly-dots{bottom:22px}
}
@media (max-width:680px) and (max-height:700px){ .phone{--w:190px} .scrolly-text p{display:none} }
```

The tilt stays on mobile (it's cheap — one transform). Ken Burns off.

Remove the `!isSmall` guard in the JS so the scroll driver runs on mobile too. Keep the `reduceMotion` guard: under reduced motion, show step 0 statically and drop the sticky (current fallback is fine for that case).

**Check:** on 390×844, scroll through `#work` — phone stays pinned, four sites slide through, each one scrolls internally, captions change. No layout jump when a screen swaps (fixed `aspect-ratio` on the phone prevents it).

---

## Part 6 — Deferred (do NOT build in this pass)

The owner wants the core styling and phone showcase finished first. Leave these for a later PR:

- Enquiry form / Formspree
- Sticky mobile Call / Quote bar
- Analytics click events

Keep the existing `mailto:` and `tel:` pills in `#contact` exactly as they are.

## Part 7 — Performance and loading order

- three.js: keep the hero embers, **delete the head-scene cloud** (section is gone). Only import three.js when `matchMedia('(min-width:900px) and (pointer:fine)').matches && !reduceMotion`; wrap the import in `requestIdleCallback` (fallback `setTimeout 1`) so it never competes with LCP. Cap `COUNT` at 200.
- Google Fonts: add `&display=swap` (already there) and preload the two WOFF2 files that the CSS response returns for Newsreader 500 and Plus Jakarta Sans 500/600 — or keep it simple and just keep the `preconnect`s. Don't self-host fonts; not worth it for one page.
- Add `loading="lazy" decoding="async"` to any `<img>` you introduce below the fold (mini-site hero photos use `background-image`; those are fine, they only paint when visible).
- No layout shift: `.phone` has `aspect-ratio`, hero grid rows are `auto`, CTA bar reserves body padding.

---

## Part 8 — Verification (do all of it before you push)

Playwright is available (`playwright-core` + `/opt/pw-browsers/chromium-*`). Serve the folder with `python3 -m http.server 8765` and screenshot:

| Viewport | Positions |
|---|---|
| 1440×900 | top; `#work` at 5%, 30%, 55%, 80%, 98% of its scroll range |
| 390×844 (isMobile, hasTouch) | top; the same five `#work` positions |
| 390×844 with `reducedMotion:'reduce'` | top; `#work` at 50% |

Look at every screenshot. Specifically confirm:
- hero: h1, subhead, primary CTA visible at top on both widths
- scrolly mobile: phone pinned, caption readable beneath, no overlap with the header
- each of the four mini-sites at its 55% point shows *mid-page* content (i.e. internal scroll is working)
- no horizontal scrollbar at 390 (`document.documentElement.scrollWidth === 390`)

Then run Lighthouse in the same Chromium (`npx lighthouse http://localhost:8765/ --preset=mobile --only-categories=performance,accessibility,best-practices,seo --chrome-flags="--no-sandbox --headless"`) and paste the four scores in the PR body. Performance must be ≥ 90 on mobile. If it isn't, the usual culprits are image bytes (re-check the `-m` variants are used) and three.js loading too early.

Commit in logical steps (images → hero → mini-sites → scrolly → perf), push, open a draft PR with before/after screenshots attached.

## Things not to do

- Don't add a framework, build step, or `node_modules` to the repo (the Playwright install goes in a scratch directory, not the repo).
- Don't touch the JSON-LD, meta tags, pricing, FAQ, or areas copy — they're tuned for local SEO.
- Don't put real client names on the mini-sites; the four names above are fictional and the caption "Example builds" should stay.
- Don't reintroduce a chat/AI-assistant metaphor in the phone. It's a website mock, full stop.
