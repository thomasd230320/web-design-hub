# Setup notes

Three things to wire up: a Google Sheet (for lead logging), a Telegram bot
(for phone notifications), and Gmail (for the auto-reply). Then drop in your
n8n workflow. Optional: Adobe Fonts kit and a PNG social banner.

---

## 1. Adobe Express social banner (~5 min)

Most platforms (Facebook, LinkedIn, X, WhatsApp) **won't render an SVG**
when your site is shared. We need a real PNG.

1. Open Adobe Express: https://www.adobe.com/express/
2. Search "social banner" → pick a 1200×630 template.
3. Set the background to obsidian (#08090c) — match the hero.
4. Add the wordmark `WebDesignHub` in a serif font (Instrument Serif or
   anything tasteful), white. Add a teal/coral accent dot or stroke.
5. Add a one-liner: "Web design for small UK businesses · Witney"
6. Download as **PNG**.
7. Save it in the repo root as `social-banner.png` (not `.svg`).
8. Commit + push. The HTML already points at `social-banner.png`.

That's it — Facebook/LinkedIn/WhatsApp previews will now show the banner.

---

## 2. Adobe Fonts (optional — only if you want premium typefaces)

The site already loads good free fonts (Instrument Serif, DM Sans, DM Mono,
Bricolage Grotesque). Adobe Fonts is worth it if you want something genuinely
premium (e.g. *GT Walsheim*, *Söhne*, *Editorial New*).

1. Go to https://fonts.adobe.com/ and sign in (free with any Adobe account).
2. Browse → pick 1–3 fonts → "Add to Web Project".
3. Create a Web Project → name it "webdesignhub" → save.
4. Copy the **Kit ID** (looks like `abc1xyz`).
5. In `index.html`, uncomment this line and paste the ID:

   ```html
   <!-- <link rel="stylesheet" href="https://use.typekit.net/YOUR_KIT_ID.css"> -->
   ```

   becomes:

   ```html
   <link rel="stylesheet" href="https://use.typekit.net/abc1xyz.css">
   ```

6. In the `<style>` block, change the font-family on the token you want to
   replace. e.g. for the serif headlines:

   ```css
   --serif: 'gt-walsheim', 'Instrument Serif', serif;
   ```

   Adobe Fonts lists the CSS name on the kit page. The Google Fonts already
   loaded act as a fallback if Adobe ever fails.

---

## 3. Google Sheet — the mini CRM

1. Create a new Google Sheet called **"WebDesignHub Leads"**.
2. In the first tab, add a sheet named **"Leads"** with these column headers
   in row 1:

   | A | B | C | D | E | F | G | H |
   |---|---|---|---|---|---|---|---|
   | Timestamp | Name | Email | Phone | Brand | Message | Source | Spam score |

3. From the Sheet URL, copy the **Sheet ID** (the long string between
   `/d/` and `/edit`).
4. Keep it open — you'll paste this into n8n later.

---

## 4. Telegram bot — phone notifications

1. Open Telegram, search for **@BotFather**, send `/newbot`.
2. Give it a name (e.g. "WebDesignHub Leads") and a username (e.g.
   `webdesignhub_leads_bot`).
3. BotFather replies with a **bot token** (looks like `123456:ABC-DEF...`).
   Copy it.
4. Search for your new bot, send it any message (e.g. "hi") — this opens
   the chat so n8n can post into it.
5. To find your **chat ID**: in another tab, visit
   `https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates` (replace
   `<YOUR_TOKEN>` with your actual token). You'll see your chat info in
   the JSON — look for `"chat":{"id":12345678,...}`. That number is your
   chat ID.
6. Keep both the token and the chat ID handy.

---

## 5. Import the n8n workflow

1. In n8n cloud → **Workflows → Add workflow → Import from File**.
2. Upload `n8n-workflow.json` from this repo.
3. The workflow appears with 6 nodes connected. Each node that needs
   credentials shows a warning triangle.

### Set up credentials in n8n

For each of these, click **Credentials → New** in n8n's left sidebar:

#### Google Sheets
- Type: **Google Sheets OAuth2**
- Connect with your Google account, allow Sheets access.
- Save as "Google Sheets account".

#### Telegram
- Type: **Telegram**
- Paste the **bot token** from BotFather.
- Save as "Telegram bot".

#### Gmail
- Type: **Gmail OAuth2**
- Connect with the Gmail account you want auto-replies sent *from*
  (probably `thomassmithdonald@gmail.com`).
- Save as "Gmail account".

### Wire credentials into the workflow nodes

Open each of these nodes and select the matching credential from the
dropdown:

- **Log to Google Sheet** → Google Sheets credential
  + In `documentId`, paste the Google Sheet ID from step 3.
  + Sheet name is already set to `Leads`.
- **Telegram (notify phone)** → Telegram credential
  + Replace `YOUR_TELEGRAM_CHAT_ID` with your chat ID from step 4.
- **Telegram (spam log)** → same Telegram credential
  + Same chat ID (spam reports go to the same chat as leads).
- **Auto-reply (Gmail)** → Gmail credential

### Activate

1. Click **Save** (top-right).
2. Toggle **Active** (top-right). The webhook now listens on the
   *production* URL the site is already using:
   `https://tomdonald03.app.n8n.cloud/webhook/webdesignhub-lead`
3. Submit the form on the live site once to test end-to-end:
   - Your phone should buzz (Telegram).
   - The lead should appear in the Google Sheet.
   - The email address you submitted should receive the auto-reply.

---

## 6. Test the spam filter

Submit the form with a message like *"Click here for free crypto money
viagra"* — the workflow scores ≥ 5, so:
- No row added to the sheet.
- No auto-reply sent.
- A `🚫 Spam blocked` message goes to Telegram so you can review false
  positives.

If a real enquiry ever gets blocked, just adjust the threshold in the
**Score (spam filter)** node (it's the line `score >= 5` in the code).

---

## What lives where

| File | Purpose |
|---|---|
| `index.html` | The website itself (one file, no framework) |
| `n8n-workflow.json` | Importable n8n workflow — lead capture + filter + log + notify + reply |
| `social-banner.svg` | Current OG/social image (replace with `.png` for proper rendering) |
| `social-banner.png` | **You'll create this** in Adobe Express, drop in repo root |
| `favicon.svg` | Browser tab icon |
| `sitemap.xml` / `robots.txt` | Search engine plumbing |
| `vercel.json` | Hosting config |
| `SETUP.md` | This file |
