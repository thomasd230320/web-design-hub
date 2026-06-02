# web-design-hub

Marketing site for **WebDesignHub** — a one-person web studio in Witney, Oxfordshire,
building hand-coded websites for small businesses across Oxfordshire and the UK.

- **Live:** https://webdesignhub.net/
- **Stack:** a single hand-written `index.html` (HTML + CSS + a little vanilla JS).
  No framework, no build step, no page builder.
- **Hero animation:** ambient Three.js (warm embers in the hero, a slow particle
  field behind the headline). Loaded from a CDN via import map.
- **Hosting:** static, deployed on Vercel (`vercel.json`).

## Structure

Everything lives in `index.html`:

- `<head>` — SEO meta, Open Graph/Twitter cards, and JSON-LD structured data
  (`Organization`, `ProfessionalService` / `LocalBusiness` with geo + areas served,
  and a `FAQPage`).
- Hero → headline → studio intro → "what I build" scroller → work showcase →
  stat → areas covered → pricing → testimonials → FAQ → contact → footer.

## Before launch

- Replace the **placeholder testimonials** (`#reviews` section) with real,
  verifiable client quotes.
- Add Google/Bing verification tokens to the empty `<meta>` tags in `<head>`.
- Swap the example work mockups for screenshots of real client sites as they go live.
