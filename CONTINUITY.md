# UmbaLabs 3D Continuity Ledger

## Goal
Launch UmbaLabs 3D as a profitable 3D printing service in Kenya:
- Establish brand presence across social media platforms
- Build customer acquisition pipeline (WhatsApp, Jiji, TikTok, Instagram)
- Generate first paying customers within 30 days of launch

**Success Criteria**: 5+ paying customers, consistent social media presence, positive cash flow

---

## Constraints / Assumptions
- Target market: Kenya (Nairobi-focused initially)
- Payment: M-Pesa preferred
- Primary channels: WhatsApp Business, TikTok, Instagram, Jiji
- Language: English + Swahili mix for marketing
- Budget: Bootstrap (minimal paid advertising initially)

---

## Key Decisions
1. **Brand Identity**: UmbaLabs 3D ("Umba" = create in Swahili)
2. **Color Palette**:
   - Umba Orange: #FF6B35 (Primary)
   - Deep Navy: #1A1A2E (Backgrounds)
   - Creation Gold: #F7B801 (Accents)
   - Tech Teal: #00D9C0 (Secondary)
3. **Handle**: @umbalabs3d (consistent across all platforms)
4. **Logo Concept**: Layered design representing 3D printing layer-by-layer process
5. **Website Subdomain**: umbalabs3d.saasita.space (VPS: YOUR_SERVER_IP)

---

## Repo Structure
```
./
├── ARCHITECTURE.md  # System architecture (KEEP UPDATED!)
├── CLAUDE.md        # AI assistant instructions
├── CONTINUITY.md    # This file
├── AGENTS.md        # Agent configuration
├── brand/           # Logo, icon, brand kit, color samples
├── icons/           # Full icon pack (16 files)
├── marketing/       # Templates, marketplace listings, outreach kits
├── docs/            # Guides, plans, original idea
│   └── FILE_UPLOAD_DEPLOYMENT.md  # Upload system deployment guide
├── tasks/           # Task tracking
├── website/         # Landing page (deployed to VPS)
│   ├── index.html   # Main landing page (with upload form)
│   ├── analytics.html # Admin analytics dashboard
│   ├── favicon_32.svg
│   ├── logo_horizontal_light.svg
│   └── icon_circle_dark.svg
├── clients/         # Client tracking (profiles, files, notes)
│   ├── _template/   # Copy for new clients
│   └── prado-radio-trim/  # First client project
└── backend/         # Flask API source
    ├── app.py       # Flask v2.0 with database
    ├── requirements.txt
    ├── umbalabs3d.service
    └── Caddyfile.example
```

---

## State

### Brand Assets (Created)
| Asset | Status | Location |
|-------|--------|----------|
| Brand Kit HTML | Done | `brand/umbalabs3d_brand_kit.html` |
| Logo SVG | Done | `brand/umbalabs3d_logo.svg` |
| Icon SVG | Done | `brand/umbalabs3d_icon.svg` |
| Marketing Templates | Done | `marketing/umbalabs3d_marketing_templates.md` |

### Website Deployment
| Component | Status | Details |
|-----------|--------|---------|
| Website HTML | Done | `website/index.html` (psychology-optimized) |
| VPS Directory | Done | `/var/www/umbalabs3d/` on YOUR_SERVER_IP |
| Caddy Config | Done | Added `umbalabs3d.saasita.space` block |
| DNS A Record | **DONE** | Resolves to `84.32.59.3`, HTTPS active |

### Website Features (Implemented)
- WhatsApp floating button with SVG icon + pulse animation
- Social proof counters (50+ prints, 48hr turnaround, 4.9 rating)
- Urgency/scarcity section (5 slots available)
- Viral WhatsApp share button with referral hook
- Loss aversion copy throughout
- Mobile-responsive design
- SEO meta tags + Open Graph
- **File upload form** with drag-and-drop support
- **Instant STL quoting** (automatic pricing on file drop)
- **User login/register modal** (phone + password)
- **User dashboard** (upload history with status badges)
- **Design services section** (pricing for sketch-to-3D, photo-to-3D, etc.)
- **3D Scanning "Coming Soon"** banner with waitlist signup
- **Admin analytics dashboard** (Chart.js: daily visitors, funnel, devices, referrers, CTAs, scroll depth, hourly)
- JavaScript form validation and async upload

### File Upload System v4.0 (DEPLOYED - 2026-02-04)
| Component | Status | Details |
|-----------|--------|---------|
| Flask API v4.0 | LIVE | `/root/umbalabs3d/app.py` (~1000 lines) |
| SQLite Database | LIVE | users table + uploads.user_id FK |
| **User Auth** | LIVE | Register, login, JWT tokens (30-day) |
| **User Dashboard** | LIVE | Upload history, status badges |
| **Instant Quote** | LIVE | STL parsing, volume calc, auto-pricing |
| Analytics Tracking | LIVE | Page views, events, scroll depth |
| systemd service | LIVE | `umbalabs3d.service` on port 5000 |
| Caddy config | LIVE | `/api/*` proxied to Flask |
| Upload form (HTML) | LIVE | `/var/www/umbalabs3d/index.html` |
| Telegram bot | LIVE | @umbalabs3d_Bot sending notifications |

### VPS Project Structure
```
/root/umbalabs3d/           # Isolated project folder
├── app.py                  # Flask API v4.0 (~1000 lines)
├── data/
│   └── umbalabs3d.db       # SQLite (users, uploads, analytics, page_views)
├── uploads/                # Customer files
└── logs/
    └── app.log             # Application logs
```

### API Endpoints
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/health` | GET | Health check (version 4.0) |
| `/api/auth/register` | POST | Create user account |
| `/api/auth/login` | POST | Login, get JWT token |
| `/api/auth/me` | GET | Current user info (JWT req) |
| `/api/user/uploads` | GET | User's upload history (JWT req) |
| `/api/quote` | POST | **Instant quote** - STL analysis |
| `/api/upload` | POST | File upload (links user_id if JWT) |
| `/api/track` | POST | Analytics tracking |
| `/api/stats` | GET | Dashboard stats |
| `/api/uploads` | GET | List all uploads |
| `/api/uploads/<id>` | GET/PATCH | Manage single upload |
| `/api/analytics/dashboard` | GET | Full analytics dashboard data (?range=today\|7d\|30d\|all) |

### Design Services Pricing (High-Margin)
| Service | Price | Turnaround | Margin |
|---------|-------|------------|--------|
| Sketch to 3D | KES 1,500+ | 24-48 hrs | ~80% |
| Photo to 3D | KES 2,500+ | 48-72 hrs | ~80% |
| Custom Product Design | KES 5,000+ | 3-5 days | ~80% |
| File Repair | KES 500+ | Same day | ~90% |

### Platform Registration
| Platform | Handle | Status |
|----------|--------|--------|
| Instagram | @umbalabs3d | PENDING |
| TikTok | @umbalabs3d | PENDING |
| Twitter/X | @umbalabs3d | PENDING |
| WhatsApp Business | TBD | PENDING |
| Domain | umbalabs3d.saasita.space | LIVE (HTTPS) |

---

## Done
- [x] Brand concept defined (UmbaLabs 3D)
- [x] Color palette selected
- [x] Handle availability checked (@umbalabs3d)
- [x] Logo SVG created (full logo with layered icon)
- [x] Icon SVG created (profile picture version)
- [x] Brand kit HTML page created (interactive, printable)
- [x] Marketing templates created
- [x] Psychology-optimized landing page built
- [x] Website deployed to VPS (files + Caddy config)
- [x] Repo reorganized with clean folder structure
- [x] **File upload system created** (Flask API + frontend form)
- [x] **Instant quoting system** (STL parsing, auto-pricing, material selection)
- [x] **User authentication** (register, login, JWT tokens, password hashing)
- [x] **User dashboard** (upload history, status badges, linked uploads)
- [x] **Design services section** (pricing: KES 1,500-5,000, WhatsApp CTA)
- [x] **3D Scanning "Coming Soon"** banner with notify me CTA
- [x] **Admin analytics dashboard** (`/api/analytics/dashboard` + `analytics.html` with Chart.js)

## Now
- [x] ~~Deploy file upload system to VPS~~ (DONE 2026-02-04)
- [x] ~~Create Telegram bot~~ (DONE - @umbalabs3d_Bot)
- [x] ~~Implement instant quoting~~ (DONE 2026-02-04 - STL parsing + auto-pricing)
- [x] ~~Implement user authentication~~ (DONE 2026-02-04 - JWT + dashboard)
- [x] ~~Deploy v4.0 to VPS~~ (DONE 2026-02-04 - user auth live)
- [x] ~~Add DNS A record~~ (DONE — resolves to 84.32.59.3)
- [x] ~~Verify HTTPS works~~ (DONE — Caddy auto-cert, HTTP→HTTPS 308 redirect)
- [x] ~~Replace `254XXXXXXXXX` with real WhatsApp number~~ (DONE - 254719281149)
- [x] ~~Admin analytics dashboard~~ (DONE 2026-02-09 — `/api/analytics/dashboard` + `analytics.html`)
- [x] Product strategy & profit projections v2.0 (DONE 2026-02-19 — `docs/3d_print_product_strategy.md` + PDF)
- [x] Client tracking system (DONE 2026-02-21 — `clients/` with template + first client)

## Next
- [ ] Register social media handles (@umbalabs3d on all platforms)
- [ ] Set up WhatsApp Business with auto-reply templates
- [ ] Create first TikTok content (behind-the-scenes, print timelapses)
- [ ] Post first Jiji listings
- [ ] First customer outreach campaign
- [ ] Buy 2 PLA spools (White + Black) — KES 7,000
- [ ] Print first 3 phone stands (black) from MakerWorld #470013
- [ ] Print first 2 desk organizer modules (black) from MakerWorld #1470721

---

## Open Questions
- `UNCONFIRMED`: Physical location/workshop address for customers?
- `UNCONFIRMED`: Printer specifications (FDM/SLA, build volume)?
- `UNCONFIRMED`: Real WhatsApp number to replace placeholder?
- `UNCONFIRMED`: M-Pesa Till/Paybill number?

---

## Working Set

### Key Files
- `./website/index.html` - Live landing page (with upload form)
- `./backend/app.py` - Flask upload API
- `./backend/umbalabs3d.service` - Systemd service
- `./docs/FILE_UPLOAD_DEPLOYMENT.md` - Deployment guide
- `./brand/umbalabs3d_icon.svg` - Profile picture
- `./marketing/umbalabs3d_marketing_templates.md` - All templates

### VPS Deployment
- Server: `root@YOUR_SERVER_IP`
- Website path: `/var/www/umbalabs3d/`
- Caddy config: `/etc/caddy/Caddyfile`
- Subdomain: `umbalabs3d.saasita.space`

### Brand Colors Reference
```
Umba Orange:   #FF6B35  (Primary, CTAs)
Deep Navy:     #1A1A2E  (Backgrounds, text)
Creation Gold: #F7B801  (Accents, highlights)
Tech Teal:     #00D9C0  (Secondary accent)
WhatsApp:      #25D366  (Floating button)
```

### DNS Record Needed
```
Type: A
Name: umbalabs3d
Value: YOUR_SERVER_IP
TTL: Auto
```
