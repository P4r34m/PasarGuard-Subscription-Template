# Custom PasarGuard subscription template

A **single-file, no-build** subscription page for [PasarGuard](https://github.com/PasarGuard),
branded with your own Telegram channel and VPN sales/renewal bot. The whole template (including
the QR-code library) lives in one `index.html` and works fully offline.

The UI is Persian / RTL by default with an English toggle. All **code comments** and the
**installer's terminal output** are in English.

> When opened directly (file or local server) it shows sample data for preview.
> When served by PasarGuard, the panel injects the real user data.

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

## 2) Install on PasarGuard

### Option A — installer script (English output)

Copy `index.html` and `install.sh` to the server (same folder), then:

```sh
sudo ./install.sh
```

It copies the template to `/var/lib/pasarguard/templates/subscription/index.html`, sets the
two required environment variables, and restarts PasarGuard. Run `./install.sh --help` for options
(`--file`, `--url`, `--dest`, `--env`).

### Option B — manual

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
