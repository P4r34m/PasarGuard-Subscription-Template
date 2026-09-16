# Custom PasarGuard subscription template

A **single-file, no-build** subscription page for [PasarGuard](https://github.com/PasarGuard),
branded with your own Telegram channel and VPN sales/renewal bot. The whole template (including
the QR-code library) lives in one `index.html` and works fully offline.

The UI is Persian / RTL by default with an English toggle. All **code comments** and the
**installer's terminal output** are in English.

> When opened directly (file or local server) it shows sample data for preview.
> When served by PasarGuard, the panel injects the real user data.

## ⚡ Quick install (one line)

Run this on your PasarGuard server:

```sh
curl -fsSL https://raw.githubusercontent.com/P4r34m/PasarGuard-Subscription-Template/main/install.sh | sudo bash
```

It downloads the template, configures the panel, and restarts it. Re-run any time to update.

---

## 1) Customize (just a few lines)

Open `index.html`, find the `CONFIG` block near the top of the script and edit the values:

```js
const CONFIG = {
  brandName: "Parsashonam",        // your brand / panel name
  brandLogo: "🛡️",                 // emoji or letter (used only when brandLogoUrl is empty)
  brandLogoUrl: "",                // optional image logo: a URL or a data: URI (overrides brandLogo)
  accent:    "#2aabee",            // primary theme color (hex)

  salesBot:        "ParsashonamRobot", // Telegram sales / renewal bot   (without @)
  telegramChannel: "Parsashonam",      // Telegram channel               (without @)
  supportId:       "P4r34M",           // Telegram support account       (without @)
  website:         "",                 // website (optional)
};
```

**Image logo:** to use an image instead of the emoji, set `brandLogoUrl`. For a fully offline
single file, use a base64 data URI, e.g. `brandLogoUrl: "data:image/png;base64,AAAA..."`. A plain
`https://...` URL also works if the image host is reachable from the client.

Do **not** edit the `window.__INITIAL_DATA__` block at the top of the file — the panel fills it in.

---

## 2) Per-admin branding (resellers)

Each reseller-admin can show **their own** shop name, logo, colour, channel, sales bot, support and a
short notice instead of yours. There are two ways to set it, and the first needs no file editing at
all.

### a) From the panel — per admin, no redeploy (recommended)

PasarGuard gives every admin a list of **custom variables** and passes them to this page on
`user.admin`. Set these on the admin (panel UI, or `PUT /api/admin/{username}` with
`custom_variables`) and the page picks them up on the next load:

| Key | What it sets |
|---|---|
| `SUB_BRAND` | shop name shown at the top |
| `SUB_LOGO` | emoji or letter logo (used when no image) |
| `SUB_LOGO_URL` | `https` image URL, or a short `data:image/...;base64,` URI |
| `SUB_ACCENT` | theme colour, e.g. `#10b981` |
| `SUB_BOT` | sales/renewal bot username (no `@`) |
| `SUB_CHANNEL` | channel username (no `@`) |
| `SUB_SUPPORT` | support account username (no `@`) |
| `SUB_SITE` | website (`https`) |
| `SUB_NOTICE` | a message shown in a card at the top of the page |
| `SUB_NOTICE_URL` | makes that message a link (`https`) |

- A value is capped at **512 characters** by the panel, so a logo goes in as a URL rather than a
  full base64 image.
- Every value is validated in the page: handles are cleaned (`@name`, `t.me/name` and `name` all
  work), colours must be hex, URLs must be `https` (or `data:image/...` for the logo), and all text
  is inserted as **text**, never HTML. An invalid value is ignored rather than blanking anything.
- Anything an admin sets this way **wins over everything below**, including `hideBranding` — that
  switch is about not leaking *your* channel and bot to somebody else's customers, and theirs is not
  yours.

### b) From the file — a static map

The template reads the owning admin from PasarGuard (`user.admin.username`) and resolves branding
from `CONFIG.perAdmin`:

```js
perAdmin: {
  enabled: true,            // turn the feature on
  fallback: "neutral",      // unlisted admins: "neutral" (hide your channel/bot, use their own
                            //   panel support link) or "default" (show your branding)
  byAdmin: {
    "your_admin_username": {},                       // you -> your default branding above
    "reseller1": { brandName:"R1 VPN", telegramChannel:"r1_channel", salesBot:"r1_bot", supportId:"r1_support" },
  },
},
```

- Key each entry by the admin's **PasarGuard username**. An empty `{}` = use your default branding.
- Omitted fields fall back to your defaults; `accent` and `brandLogoUrl` can be per-admin too.
- With `fallback: "neutral"`, an admin you have **not** listed never shows your channel/bot — it uses
  that admin's own **Support URL** and **Profile title** (set per admin in the panel).

> Note: besides the custom variables above, the page is given the admin's `username`,
> `profile_title` and `support_url`. PasarGuard also lets each admin point to a different template
> file (Admin → `sub_template`) for a fully separate page.

---

## 3) Install on PasarGuard

### One-line install (recommended)

```sh
curl -fsSL https://raw.githubusercontent.com/P4r34m/PasarGuard-Subscription-Template/main/install.sh | sudo bash
```

This downloads `index.html` from this repository, sets the two required environment variables, and
restarts PasarGuard. All terminal output is in English. Run it again any time to update.

### From a local copy

Copy `index.html` and `install.sh` to the server (same folder), then:

```sh
sudo ./install.sh
```

Run `./install.sh --help` for options (`--file`, `--url`, `--dest`, `--env`).

### Manual

1. Place the file at:
   ```
   /var/lib/pasarguard/templates/subscription/index.html
   ```
2. In `/opt/pasarguard/.env` set:
   ```env
   CUSTOM_TEMPLATES_DIRECTORY="/var/lib/pasarguard/templates/"
   SUBSCRIPTION_PAGE_TEMPLATE="subscription/index.html"
   ```
3. Restart:
   ```sh
   pasarguard restart
   ```

---

## Features

- **Usage chart** the user can see — an interactive area chart of consumption over time
  (`1h / 12h / 24h / 7d / 30d / 90d`), fetched from the panel's `/usage` endpoint, with a
  hover tooltip. Same data contract as the official PasarGuard template.
- Two progress rings: data used / remaining and days left (with warning colors).
- Jalali (Persian) expiry date and Persian digits; English dates in EN mode.
- User status badge (active / on hold / limited / expired / disabled) and a live "online" indicator.
- Subscription link with copy + QR.
- One-tap import into Hiddify, v2rayNG, Streisand, NekoBox, Clash Meta, sing-box, Shadowrocket.
- Per-config copy + QR, and "copy all".
- Recommended apps (when configured in PasarGuard).
- Branding buttons: **Buy / Renew** (your bot), **Telegram channel**, **Support**.
- Dark / light theme and Persian / English toggle.
- No CDN required for core functionality (Vazirmatn font is a progressive enhancement).

---

## Preview locally

```sh
python -m http.server 8777 --directory .
# then open http://localhost:8777
```
