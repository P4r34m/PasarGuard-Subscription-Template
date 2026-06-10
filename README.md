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

Each reseller-admin can show **their own** channel / sales bot / support instead of yours. The
template reads the owning admin from PasarGuard (`user.admin.username`) and resolves branding from
`CONFIG.perAdmin`:

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

> Note: only the admin's `username`, `profile_title` and `support_url` are exposed to the page, so
> per-reseller **channel/bot** must be set in the map above. PasarGuard also lets each admin point to a
> different template file (Admin → `sub_template`) for a fully separate page.

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
