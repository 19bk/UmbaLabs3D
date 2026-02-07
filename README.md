# UmbaLabs 3D

A production 3D printing service platform built for the Kenyan market. Customers upload STL files through the landing page, receive instant pricing quotes calculated from mesh volume analysis, and place orders -- all without leaving the browser. The owner gets notified via Telegram the moment a new order arrives.

**Live:** [umbalabs3d.saasita.space](https://umbalabs3d.saasita.space)

---

## What It Does

1. Customer drops an STL file on the upload form.
2. The backend parses the binary/ASCII STL, calculates volume using the signed tetrahedron method, and returns per-material pricing in under a second.
3. Customer picks a material (PLA, PETG, or TPU), confirms their details, and submits.
4. Flask saves the file, writes to SQLite, fires a Telegram notification to the owner, and tracks the event for analytics.
5. Owner contacts the customer on WhatsApp to confirm and arrange M-Pesa payment.

No frameworks on the frontend. No external databases. One Python process, one static HTML file, one reverse proxy.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | HTML / CSS / vanilla JavaScript |
| Backend | Python 3.12, Flask 3.0 |
| Database | SQLite 3 (users, uploads, analytics, page views) |
| Auth | JWT (PyJWT) with PBKDF2-SHA256 password hashing |
| STL Parsing | NumPy + custom binary/ASCII parser |
| Notifications | Telegram Bot API |
| Reverse Proxy | Caddy (automatic HTTPS via Let's Encrypt) |
| Process Manager | systemd |

---

## Architecture

```
Browser (index.html)
    |
    v
Caddy (HTTPS, port 443)
    |
    +-- /api/*  -->  Flask API (port 5000)
    |                   |-- SQLite (users, uploads, analytics)
    |                   |-- File storage (uploads/)
    |                   +-- Telegram Bot API
    |
    +-- /*      -->  Static files (/var/www/umbalabs3d/)
```

The entire platform runs on a single VPS. Caddy handles TLS termination and routes `/api/*` to the Flask backend. Everything else is served as static files. The Flask process is managed by systemd with automatic restart on failure.

---

## Key Features

**Instant STL Quoting** -- The `/api/quote` endpoint parses uploaded STL files (binary and ASCII), computes mesh volume via signed tetrahedra, estimates print time with a heuristic slicer model, and returns prices for all materials. Includes printability checks against a 256x256x256mm build volume.

**User Accounts** -- Phone-based registration with JWT tokens (30-day expiry). Authenticated users see an upload history dashboard with status badges (pending, quoted, printing, completed).

**Telegram Order Alerts** -- Every upload triggers a formatted Telegram message with file details, customer contact info, quote amount, and upload ID. The owner can respond within minutes.

**Analytics Pipeline** -- Tracks page views, scroll depth, CTA clicks, and upload events. Aggregated daily in `page_views`, raw events in `analytics`. All queryable via `/api/stats`.

**Mesh Quality Checks** -- Detects open edges, non-manifold geometry, degenerate triangles, and thin walls before quoting. Warns users about printability issues upfront.

---

## API Endpoints

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/health` | GET | None | Service health and version |
| `/api/pricing` | GET | None | Current material pricing |
| `/api/quote` | POST | None | Upload STL, get instant price |
| `/api/upload` | POST | Optional | Submit order with file |
| `/api/auth/register` | POST | None | Create account (phone + password) |
| `/api/auth/login` | POST | None | Login, receive JWT |
| `/api/auth/me` | GET | Required | Current user info |
| `/api/user/uploads` | GET | Required | Authenticated user's orders |
| `/api/track` | POST | None | Analytics event tracking |
| `/api/stats` | GET | None | Dashboard statistics |
| `/api/uploads` | GET | None | List all uploads |
| `/api/uploads/<id>` | GET/PATCH | None | View or update an order |

---

## Project Structure

```
UmbaLabs3D/
├── website/
│   └── index.html              # Landing page (upload form, instant quote UI, dashboard)
├── backend/
│   ├── app.py                  # Flask API (~1250 lines, STL parser, auth, analytics)
│   ├── requirements.txt        # Python dependencies
│   ├── umbalabs3d.service      # systemd unit file
│   └── Caddyfile.example       # Caddy reverse proxy config
├── brand/
│   ├── umbalabs3d_logo.svg     # Full logo
│   ├── umbalabs3d_icon.svg     # Icon (profile pictures, favicon)
│   ├── umbalabs3d_brand_kit.html   # Interactive brand guide
│   └── color_samples.html      # Color palette reference
├── marketing/                  # Outreach templates, marketplace listings
├── docs/
│   ├── VPS_DEPLOYMENT_GUIDE.md
│   ├── FILE_UPLOAD_DEPLOYMENT.md
│   └── DOMAIN_SETUP_GUIDE.md
└── ARCHITECTURE.md             # Detailed system architecture
```

---

## Quick Start

### Local Development

```bash
# Clone and install
git clone <repo-url> && cd UmbaLabs3D
pip install -r backend/requirements.txt

# Set environment variables
export TELEGRAM_BOT_TOKEN="your-bot-token"
export TELEGRAM_CHAT_ID="your-chat-id"
export JWT_SECRET="your-secret-key"

# Run the API
python backend/app.py
# Flask starts on http://127.0.0.1:5000

# Serve the frontend (separate terminal)
cd website && python -m http.server 8080
# Open http://localhost:8080
```

### Production Deployment

See [docs/VPS_DEPLOYMENT_GUIDE.md](docs/VPS_DEPLOYMENT_GUIDE.md) and [docs/FILE_UPLOAD_DEPLOYMENT.md](docs/FILE_UPLOAD_DEPLOYMENT.md) for full deployment instructions covering systemd, Caddy configuration, Telegram bot setup, and DNS.

---

## Pricing Model

| Material | Rate (KES/g) | Time Rate (KES/hr) | Minimum | Lead Time |
|----------|-------------|---------------------|---------|-----------|
| PLA | 15 | 120 | KES 500 | 2-3 days |
| PETG | 20 | 150 | KES 600 | 2-3 days |
| TPU | 25 | 180 | KES 700 | 3-4 days |

Prices are calculated from estimated material weight and print time, both derived from STL mesh analysis. Final quotes are rounded up to the nearest KES 50.

---

## Brand

**Name:** UmbaLabs 3D ("Umba" means "create" in Swahili)

| Color | Hex | Usage |
|-------|-----|-------|
| Umba Orange | `#FF6B35` | Primary, CTAs |
| Deep Navy | `#1A1A2E` | Backgrounds |
| Creation Gold | `#F7B801` | Accents |
| Tech Teal | `#00D9C0` | Secondary |

Handle: **@umbalabs3d** across all platforms.

---

## License

Proprietary. All rights reserved.
