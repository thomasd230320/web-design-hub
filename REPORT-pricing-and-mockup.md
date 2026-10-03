# Report: pricing restructure and hand-built site mockup

Branch: `claude/relaxed-johnson-ep8n53` · PR: #17 (draft) · Written 2026-10-03

This covers two changes on the branch: a rebuilt rate card in `index.html`, and a design mockup at `mockup/index.html`. Nothing here is on `main` yet.

## 1. Why the pricing changed

The old ladder topped out at £2,495 and called its top rung "E-commerce", which describes a payment integration rather than size or complexity. A buyer anchors on the highest advertised number, so every larger conversation started below the real price of the work. Nothing on the page described migration work, no tier said what it excluded, and the only recurring income was a hosting ladder framed as a markup.

## 2. Tier changes

| Was | Becomes | Basis |
|---|---|---|
| Starter £395 | **Starter £395** (unchanged) | Entry price deliberately left alone as the door-opener |
| Pro £895 | **Business, from £1,500** | UK freelance small-business band, roughly £1,000–£3,000 |
| Premium £1,495 | **Content & catalogue, from £3,000** (now "most chosen") | Bottom of the agency band, roughly £2,500–£10,000 |
| E-commerce £2,495 | **Large builds & migrations, quoted per project** | Removes the ceiling; checkout becomes an add-on |

"Most chosen" moved from Pro to Content & catalogue. On the £895 tier the badge told every visitor that £895 was the normal price of the work.

Every tier now carries a "who it's for" and an explicit "not included", so out-of-scope work is quoted separately instead of being absorbed.

### Market reference (2026, UK)

These figures were used as the range to position inside, not as fixed rules.

- Freelancer, small-business site: £1,000–£3,000 (earlier brief assumed £800 as the floor)
- Agency, standard small-business site: £2,500–£10,000
- Basic ecommerce build: £4,000–£12,000
- Standalone URL migration, a few hundred URLs: £900–£2,500 (not independently verified; the add-on bands sit inside this range)

Sources consulted: baslondigital.com, luminarybrands.co.uk, expertsure.com (web design cost guides, 2026).

## 3. Add-ons and care plan

| Add-on | From |
|---|---|
| GA4 analytics | £150 |
| Cloudflare setup | £150 |
| Google Business Profile | £200 |
| Content migration, up to 50 URLs | £300 |
| Content migration, 51–150 URLs | £700 |
| Content migration, 151–350 URLs | £1,400 (above 350: quoted) |
| Accessibility audit | £450 |
| Payment checkout (Stripe or Shopify) | £900 |
| Extra pages | £120 each |

**Care plan:** £50–£145 a month, optional on every package, written as a service (hosting and SSL, domain renewals at cost, monthly content changes, updates, form testing, backups, a monthly traffic note, a named contact). This replaces the old per-tier hosting ladder of £55–£245 a month, so the old £245 top line no longer exists.

## 4. Mockup

`mockup/index.html` is a self-contained design preview of a hand-built site that sells hand-built sites. It is `noindex`, not linked from the main site and not in the sitemap.

- Palette: `#D5E2D9` primary, `#073911` secondary, `#B4502A` (clay) as the second secondary.
- Contrast: forest on mist 9.8:1; white on clay 5.1:1.
- Navigation: five anchor links plus one button, sticky, with a skip link and a mobile menu that closes on Escape. The FAQ uses native `<details>` and works without JavaScript.
- No testimonials, client names or guarantees. Anything unconfirmed is a bracketed placeholder.

## 5. Open items before merge

**Placeholders I estimated and you have not confirmed:**

- Accessibility audit £450, payment checkout £900, extra pages £120
- 75-item catalogue cap on Content & catalogue; 50-URL migration cut-off
- Care plan band £50–£145
- Turnaround times (deliberately left out)
- Mockup: brand name, email, phone, town, project screenshot

**Decisions still open:**

- Top tier reads "Custom — let's talk" with no number. A `From £5,000` anchor is a one-line change.
- Starter is £395 on the page but was described as £400 in the brief. It has been left at £395.

## 6. Things found along the way

- **Live site did not match the repo.** When checked on 2026-09-19, webdesignhub.net showed three tiers (£400 / £900 / £2,000) while `main` had four (£395 / £895 / £1,495 / £2,495) plus a hosting ladder not on the live page. Confirm which deploy is current before relying on either.
- **Testimonials are placeholders.** The reviews section carries invented quotes, flagged in a source comment. They are live and should be replaced with real, permitted quotes or removed.
- **A competing branch exists.** `claude/pricing-restructure` (`7e729e2`) was not created by this work and has not been compared against PR #17. If it also edits the rate card in `index.html`, the two will conflict.

## 7. Before this reaches `main`

This repository is public and the site deploys as static files, so this report would be served at the site URL once merged. It contains pricing rationale, so remove it from the branch before merging if that is not intended.
