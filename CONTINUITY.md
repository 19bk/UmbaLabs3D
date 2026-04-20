# UmbaLabs 3D Continuity Ledger

## Goal
Launch UmbaLabs 3D as a profitable 3D printing service in Kenya:
- Establish brand presence across social media platforms
- Build customer acquisition pipeline (WhatsApp, Jiji, TikTok, Instagram)
- Generate first paying customers within 30 days of launch
- Complete ad-hoc concept viability reviews when requested (latest: `littlePenguin.odt` on 2026-03-02)
- Produce Kenya-market-based 12-month revenue projections for LittlePenguin concept (requested 2026-03-02)
- Repair the Tonuino V2 Part 2 front-panel model so it can be printed without STL boolean seam artifacts while preserving fit
- Maintain the current Tiki Tales enclosure baseline: TonUINO-derived casing plus figurine-base v4.3

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
6. **LittlePenguin Year-1 projection assumptions (2026-03-02)**:
   - Pricing anchors used: KSh 5,000-12,000/month coding programs and KSh 2,000-4,500 toy robotics price points from local market sources
   - Working model price points: B2C kit KSh 8,500, school term package KSh 60,000, holiday camp seat KSh 7,500
   - Base scenario Year-1 revenue estimate: KSh 6,305,500 (conservative KSh 3,850,000; aggressive KSh 11,100,000)

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
- [x] Prado client radio data corrected (2026-02-22 — old/current unit is Eclipse Future Link AVN-R8W)
- [x] Prado trim scope clarified (2026-02-22 — OEM Eclipse removed, Sony installed, trim clips into remaining dash gap)
- [x] Prado trim v4 fit review completed (2026-03-10 — likely no-fit as modeled; main blockers are oversized insert assumptions and unresolved clip engagement geometry)
- [x] Prado trim test-fit shell reviewed (2026-03-10 — useful validation step, but still carries likely-oversized envelope and may not isolate angle/DIN issues if it fails to seat)
- [x] Reviewed `littlePenguin.odt` concept viability (2026-03-02 — educational robotics concept strengths/risks and go/no-go criteria)
- [x] Produced Kenya-market-based 12-month revenue projections for LittlePenguin (2026-03-02)
- [x] Logged Prado trim latest physical fitment notes and image review request (2026-03-11)
- [x] Opened 2026-03-11 Prado trim images/sketch and extracted visible measurements/angles (`X -24.2 deg`, `Y 1.0 deg`)
- [x] Created flat Prado trim fitment revision `files/radio-trim-v5-flat.scad` from 2026-03-11 measurements and compiled STL successfully
- [x] Updated `radio-trim-testfit.scad` v2 with corrected dimensions from car test fit (2026-03-11): outer 199×97mm, depth 15mm, tol 0.3mm
- [x] Exported `radio-trim-testfit.stl` and PNG preview for v2
- [x] Verified the active Tiki Tales CAD baseline (2026-04-03): TonUINO-derived casing in `tiki-tales/casing/v3/` and figurine-base v4.3 in `tiki-tales/figurines/figurine-base.scad`

## Key decisions
7. **Prado trim v5 direction (2026-03-11)**:
   - Ignore dash angle temporarily and validate front geometry first
   - Reduce rear insert envelope slightly from the prior 205 x 104 shell
   - Limit rear insertion depth to 14.5mm based on the measured 15mm allowance
   - Build lower L-shape relief into the Sony opening using latest sketch measurements
8. **Test fit v2 approach (2026-03-11)**:
   - Update simple testfit shell (not v5-flat) to isolate basic frame dimensions
   - Verified parameters: 199×97mm body, 15mm depth, 0.3mm tolerance, din_y=15mm kept
   - After basic frame fits: add L-shape wings, 24.2° angle, snap clips in final version
9. **Bayonet base adhesion direction (2026-03-14)**:
   - Investigate `tiki-tales/figurines/ready/base-test-bayonet.stl` via its OpenSCAD source rather than editing the STL directly
   - Replace the thin built-in brim print plate with direct bed contact so both parts start from solid geometry on the Bambu Lab A1
   - Regenerate and inspect the bayonet STL after the export change before considering the same fix for the other lock variants
10. **Tonuino front-panel repair direction (2026-03-26)**:
   - Treat STL hole filling as the root cause of the slicer seam/cantilever artifacts
   - Rebuild the panel from original STL slice profiles instead of unioning filler solids into the imported mesh
   - Keep the requested 45mm grille, LED hole, and inner ridge in the clean solid model
   - Prove the revised panel against the original Part 2 envelope before calling it done
11. **Tonuino regression correction (2026-03-30)**:
   - Do not accept slicer-warning fixes that block the speaker path or leave the wrong switch-hole geometry behind
   - Keep the speaker ridge acoustically open
   - Rebuild the body switch-hole fill from the original side-wall profile instead of a hull fragment or bare cube
12. **Tiki Tales enclosure direction clarified (2026-04-03)**:
   - Current enclosure work is based on the proven TonUINO v2 casing, not the older scratch-built toybox body path
   - `tiki-tales/casing/v3/tonuino-v3-body.scad` patches the original Part 1 mesh by sampling an intact wall slice, then cuts the rectangular KCD1 switch opening
   - `tiki-tales/casing/v3/tonuino-v3-front-v8.scad` is the clean-room Part 2 rebuild that preserves the fit-critical rear profile from STL slices while adding the 45mm speaker grille, screw pattern, LED hole, and open speaker retention ridge
13. **Figurine base direction clarified (2026-04-03)**:
   - Active figurine-base source is `tiki-tales/figurines/figurine-base.scad` v4.3, not the older v3 snap-fit concept
   - Default production direction is a 46mm base with a 42mm x 9mm plain cavity and bayonet lock as the default mechanism
   - Supported lock variants remain `bayonet`, `annular`, `ribs`, and `thread`

## Now
- [x] AI 3D tools research: text-to-3D generators, AI CAD tools, MCP servers, best practices (DONE 2026-03-25 — `docs/ai-3d-tools-research.md`)
- [x] Fix `tiki-tales/figurines/ready/base-test-bayonet.stl` bed adhesion for Bambu Lab A1 by improving first-layer contact in `figurine-base.scad` (DONE 2026-03-14)
- [x] Figurine base v4: wider base (46mm), taller cup (9mm), NFC keychain recess (32mm x 0.3mm) (DONE 2026-03-14)
- [x] Toybox casing v5: measured ports (USB-C BACK, SD LEFT, switch RIGHT), LED diffuser, 42mm speaker, 56mm dish, stepped lid joint, washer ring (DONE 2026-03-14)
- [x] Cascade updates: elephant-tiki.scad + figurine-maker.scad synced to v4 params (DONE 2026-03-14)
- [x] All 4 files render `Simple: yes` in OpenSCAD (DONE 2026-03-14)
- [ ] STL exports in progress (toybox base, toybox lid, figurine cup, figurine lid)
- [x] Tonuino V2 Part 2 front panel repair: rebuilt `tiki-tales/casing/v3/tonuino-v3-front-v8.scad` from STL slice profiles, exported `tiki-tales/casing/v3/tonuino-v3-front.stl`, and verified `Simple: yes`
- [x] Tonuino regression correction (2026-03-30): restored the open speaker ridge, rebuilt the body switch-hole fill from a side-wall slice, and re-exported both Tonuino STLs
- [x] Tonuino front warning reduction (2026-03-30): replaced the continuous rear speaker ring with segmented support lugs and re-exported the front STL for another Bambu Studio check
- [x] Tiki Tales direction corrected (2026-04-03): future work should start from the TonUINO casing baseline and figurine-base v4.3, not the obsolete scratch-built toybox assumption
- [x] ~~Deploy file upload system to VPS~~ (DONE 2026-02-04)

## Next
- Reload `tiki-tales/casing/v3/tonuino-v3-front.stl` in Bambu Studio and verify whether the floating-cantilever warning is gone after the segmented-lug change
- If Bambu still warns, inspect the slice-derived rear recess stack rather than reintroducing any continuous rear annulus
- Keep the body as-is unless a new slicer warning shows up after the front refactor
- Confirm final LED hardware size/position before printing production units
- Correct any remaining docs/specs that still describe the older scratch-built toybox casing or v3 snap-fit figurine base as the current design

## Open questions
- UNCONFIRMED: Exact LED diameter/placement preference if the current modeled 5.5mm at approximately x=35, z=10 differs from the intended hardware
- UNCONFIRMED: Whether the current 45mm grille diameter and 50/45mm ridge ring are the final speaker hardware targets or just working assumptions
- UNCONFIRMED: OpenSCAD reports `Volumes: 2` on both exported Tonuino parts even though each STL is a single connected shell and renders `Simple: yes`; needs slicer confirmation that no trapped internal body remains
- UNCONFIRMED: Exact Bambu Studio warning status after the 2026-03-30 correction pass
- UNCONFIRMED: Whether any other repo docs besides the ledger/task files still present the obsolete scratch-built casing path as current

## Working set
- `tiki-tales/casing/v3/tonuino-original/Tonuino V2 - Part 2 (1).stl`
- `tiki-tales/casing/v3/tonuino-v3-front-v8.scad`
- `tiki-tales/casing/v3/tonuino-v3-front.stl`
- `tiki-tales/casing/v3/tonuino-v3-body.scad`
- `tiki-tales/casing/v3/tonuino-v3-body.stl`
- `tiki-tales/figurines/figurine-base.scad`
- `tasks/todo.md`
- `tasks/lessons.md`
- Commands: `rg`, `sed`, `openscad`, mesh inspection scripts
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
- [x] ~~Update Prado client profile with corrected old radio details (Eclipse Future Link AVN-R8W)~~ (DONE 2026-02-22)
- [x] ~~Clarify Prado trim design target (OEM removal + Sony fitment)~~ (DONE 2026-02-22)
- [x] Ad-hoc review: `littlePenguin.odt` viability assessment (DONE 2026-03-02)
- [x] Build 12-month LittlePenguin revenue projections (Kenya benchmarks; conservative/base/aggressive scenarios)
- [x] Reddit research: scraped 200+ comments on Tonies/Yoto/kids toys (DONE 2026-03-08)
- [x] Reddit insights synthesis: `tiki-tales/reddit_insights.md` — 10 actionable takeaways for Tiki Tales (DONE 2026-03-08)
- [x] Refresh context on `clients/prado-radio-trim` contents and current design status (DONE 2026-03-10)
- [x] Independent review of `clients/prado-radio-trim/design-review-v4.md` and `files/radio-trim-v4.scad` (DONE 2026-03-10)
- [x] Review of `clients/prado-radio-trim/files/radio-trim-testfit.scad` and test plan (DONE 2026-03-10)
- [ ] Print test fit v2 (`radio-trim-testfit.stl`) and validate basic frame at car

## Next
- Decide whether to apply the same direct-bed-contact export to `base-test-annular.stl`, `base-test-ribs.stl`, and `base-test-thread.stl`
- [ ] After v2 frame fits: create final version with L-shaped wings, 24.2° angle, snap clips
- [ ] If v5 face geometry is correct, add final retention strategy (clips or alternate fastening) on top of the v5 baseline
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
- `UNCONFIRMED`: Exact OEM Eclipse AVN-R8W outer dimensions and clip points in this Prado dashboard?
- `UNCONFIRMED`: Exact gap/opening measurements after OEM removal with Sony XAV-AX8500 installed?
- `UNCONFIRMED`: Exact front opening size of this specific Prado cavity after fascia trim removal/retention geometry behind the gloss black edge
- `UNCONFIRMED`: Exact DIN cage position relative to the cavity (screen-gap measurements are not enough to locate the trim cutout reliably)
- `UNCONFIRMED`: Whether a 10mm-deep shell is sufficient to detect side bracket interference in the real cavity
- `UNCONFIRMED`: Whether the user wants the same adhesion-oriented export regenerated for the non-bayonet lock test STLs
- Bayonet review finding on 2026-03-15: current geometry likely does **not** lock correctly because the seated tab spans about `z=9.0..10.6` while the horizontal channel spans about `z=8.5..10.3`, leaving an interference of roughly `0.3mm` at the channel roof during rotation

---

## Working Set

### Key Files
- `./website/index.html` - Live landing page (with upload form)
- `./backend/app.py` - Flask upload API
- `./backend/umbalabs3d.service` - Systemd service
- `./docs/FILE_UPLOAD_DEPLOYMENT.md` - Deployment guide
- `./brand/umbalabs3d_icon.svg` - Profile picture
- `./marketing/umbalabs3d_marketing_templates.md` - All templates
- `./clients/prado-radio-trim/design-review-v4.md` - Prado trim v4 review draft
- `./clients/prado-radio-trim/files/radio-trim-v4.scad` - Current Prado trim CAD
- `./clients/prado-radio-trim/files/radio-trim-testfit.scad` - Prado test-fit shell CAD
- `./clients/prado-radio-trim/profile.md` - Client measurements and observations
- `./clients/prado-radio-trim/notes.md` - Prado project log
- `./tiki-tales/figurines/figurine-base.scad` - Lock-test figurine base source for bayonet STL
- `./tiki-tales/figurines/ready/base-test-bayonet.stl` - Regenerated bayonet lock test STL with direct bed contact on both parts
- `/Users/bernard/Downloads/littlePenguin.odt` - External concept doc reviewed for viability (2026-03-02)
- `./tasks/todo.md` - Added in-progress projection checklist (2026-03-02)

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
## Open questions
- UNCONFIRMED: whether the lower L-shape relief in `radio-trim-v5-flat.scad` should be taller or shorter than the assumed 14mm band
- UNCONFIRMED: whether the final part should keep a rectangular rear insert body or switch to a more profile-matched insert after the next fit check

## Working set
- `CONTINUITY.md`
- `tasks/todo.md`
- `tiki-tales/figurines/figurine-base.scad` — v4 (NFC keychain disc)
- `tiki-tales/casing/tiki-tales-base.scad` — v5 (measured ports + LED diffuser)
- `tiki-tales/figurines/elephant-tiki.scad` — synced to v4 params
- `tiki-tales/figurines/figurine-maker.scad` — synced to v4 params
