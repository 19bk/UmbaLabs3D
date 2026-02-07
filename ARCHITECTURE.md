# UmbaLabs 3D - System Architecture

> **Last Updated**: 2026-02-04
> **Version**: 4.0 (with User Authentication)

---

## Overview

UmbaLabs 3D is a 3D printing service website with file upload capabilities, customer management via Telegram notifications, and built-in analytics tracking.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              INTERNET                                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    umbalabs3d.saasita.space (HTTPS)                          │
│                         Caddy Reverse Proxy                                  │
│                           VPS: YOUR_SERVER_IP                                    │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    │                               │
              Static Files                    API Routes
              (Caddy serves)                 (/api/* → Flask)
                    │                               │
                    ▼                               ▼
        ┌───────────────────┐         ┌───────────────────────────┐
        │ /var/www/umbalabs │         │  Flask API (port 5000)    │
        │    index.html     │         │  /root/umbalabs3d/app.py  │
        │    *.svg icons    │         └───────────────────────────┘
        └───────────────────┘                       │
                                    ┌───────────────┼───────────────┐
                                    │               │               │
                                    ▼               ▼               ▼
                            ┌───────────┐   ┌───────────┐   ┌───────────────┐
                            │  SQLite   │   │  Uploads  │   │   Telegram    │
                            │  Database │   │  Storage  │   │  Bot API      │
                            └───────────┘   └───────────┘   └───────────────┘
```

---

## Components

### 1. Frontend (Static Website)

**Location**: `/var/www/umbalabs3d/` on VPS

| File | Purpose |
|------|---------|
| `index.html` | Main landing page with upload form |
| `favicon_32.svg` | Browser tab icon |
| `logo_horizontal_light.svg` | Header logo |
| `icon_circle_dark.svg` | Footer icon |

**Features**:
- Responsive design (mobile-first)
- File upload form with drag-and-drop
- **Instant STL quoting** (automatic pricing on file drop)
- **User authentication** (login/register modal, JWT tokens)
- **User dashboard** (upload history with status badges)
- **Design services section** (pricing for sketch-to-3D, photo-to-3D, etc.)
- **3D Scanning "Coming Soon"** banner with waitlist
- Analytics tracking (pageviews, scroll depth, CTA clicks)
- WhatsApp integration for customer contact

**Tech Stack**:
- Pure HTML/CSS/JavaScript (no frameworks)
- Google Fonts (Inter, Space Grotesk)
- CSS custom properties for theming

---

### 2. Backend API (Flask)

**Location**: `/root/umbalabs3d/` on VPS

```
/root/umbalabs3d/
├── app.py              # Flask application v4.0 (~1000 lines)
├── data/
│   └── umbalabs3d.db   # SQLite database (users, uploads, analytics)
├── uploads/            # Customer 3D files
└── logs/
    └── app.log         # Application logs
```

**Endpoints**:

| Endpoint | Method | Purpose | Auth |
|----------|--------|---------|------|
| `/api/health` | GET | Health check (returns version, features) | None |
| `/api/auth/register` | POST | Create new user account | None |
| `/api/auth/login` | POST | Login and get JWT token | None |
| `/api/auth/me` | GET | Get current user info | JWT Required |
| `/api/user/uploads` | GET | Get user's upload history | JWT Required |
| `/api/quote` | POST | **Instant quote** - STL analysis & pricing | None |
| `/api/upload` | POST | File upload with optional material/price | JWT Optional |
| `/api/track` | POST | Analytics event | None |
| `/api/stats` | GET | Dashboard stats | None |
| `/api/uploads` | GET | List uploads | None |
| `/api/uploads/<id>` | GET | Get single upload | None |
| `/api/uploads/<id>` | PATCH | Update upload | None |

**Tech Stack**:
- Python 3.12
- Flask 3.0.2 (via apt: `python3-flask`)
- PyJWT (for authentication tokens)
- Werkzeug (password hashing)
- SQLite 3 (built-in)
- Requests (for Telegram API)

**Instant Quote System** (v3.0):

The `/api/quote` endpoint parses STL files and returns instant pricing:

```
POST /api/quote
Content-Type: multipart/form-data
Body: file=@model.stl

Response:
{
  "success": true,
  "quote": {
    "volume_cm3": 12.5,
    "dimensions": { "x": 50.0, "y": 30.0, "z": 25.0 },
    "surface_area_cm2": 85.3,
    "triangle_count": 1234,
    "prices": { "PLA": 188, "PETG": 250, "RESIN": 438 },
    "printability": { "printable": true, "warnings": [] }
  }
}
```

**Pricing Formula**:
| Material | Rate (KES/cm³) | Minimum |
|----------|----------------|---------|
| PLA | 15 | KES 200 |
| PETG | 20 | KES 300 |
| RESIN | 35 | KES 500 |

**STL Parser**: Pure Python implementation (no numpy-stl dependency) that handles:
- Binary STL format (most common)
- ASCII STL format
- Calculates volume using signed tetrahedron method
- Extracts bounding box dimensions
- Validates printability (size limits, manifold check)

---

### 3. Database Schema

**Location**: `/root/umbalabs3d/data/umbalabs3d.db`

```sql
-- User accounts (for login/dashboard)
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    phone TEXT UNIQUE NOT NULL,       -- Normalized (e.g., 254712345678)
    name TEXT NOT NULL,
    password_hash TEXT NOT NULL,      -- Werkzeug PBKDF2-SHA256
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);
CREATE INDEX idx_users_phone ON users(phone);

-- Customer uploads
CREATE TABLE uploads (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT NOT NULL,           -- Saved filename (timestamped)
    original_filename TEXT NOT NULL,  -- Original customer filename
    file_size INTEGER NOT NULL,       -- Size in bytes
    file_type TEXT,                   -- STL, OBJ, STEP, etc.
    user_id INTEGER REFERENCES users(id), -- NULL for anonymous uploads
    customer_name TEXT,
    customer_phone TEXT,
    ip_address TEXT,
    user_agent TEXT,
    status TEXT DEFAULT 'pending',    -- pending, quoted, paid, printing, completed
    quote_amount REAL,                -- Quote in KES
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_uploads_user ON uploads(user_id);

-- Raw analytics events
CREATE TABLE analytics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_type TEXT NOT NULL,         -- pageview, scroll, cta_click, upload_complete
    page TEXT,
    referrer TEXT,
    ip_address TEXT,
    user_agent TEXT,
    session_id TEXT,
    metadata TEXT,                    -- JSON blob for event-specific data
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Aggregated daily page views
CREATE TABLE page_views (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date DATE NOT NULL,
    page TEXT NOT NULL,
    views INTEGER DEFAULT 1,
    unique_visitors INTEGER DEFAULT 1,
    UNIQUE(date, page)
);
```

---

### 4. Notifications (Telegram Bot)

**Bot**: @umbalabs3d_Bot

**Flow**:
```
Customer uploads file
        │
        ▼
Flask saves to database + disk
        │
        ▼
Flask calls Telegram API
        │
        ▼
Owner receives notification with:
  - File name & size
  - Customer name & phone
  - Upload ID
  - Timestamp
        │
        ▼
Owner contacts customer via WhatsApp
```

**Environment Variables** (in systemd service):
```
TELEGRAM_BOT_TOKEN=<token>
TELEGRAM_CHAT_ID=<owner_chat_id>
JWT_SECRET=<random-secret-key>
```

---

### 5. Infrastructure

**VPS**: YOUR_SERVER_IP (Ubuntu 24.04)

**Services**:

| Service | Purpose | Port |
|---------|---------|------|
| `caddy.service` | Reverse proxy + HTTPS | 80, 443 |
| `umbalabs3d.service` | Flask API | 5000 |

**Caddy Configuration** (`/etc/caddy/Caddyfile`):

```caddyfile
umbalabs3d.saasita.space {
    # Allow large file uploads (100MB)
    request_body {
        max_size 100MB
    }

    # API routes -> Flask backend
    handle /api/* {
        reverse_proxy 127.0.0.1:5000
    }

    # Static files
    handle {
        root * /var/www/umbalabs3d
        file_server
    }
}
```

**Systemd Service** (`/etc/systemd/system/umbalabs3d.service`):

```ini
[Unit]
Description=UmbaLabs 3D File Upload API v4.0
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/umbalabs3d
ExecStart=/usr/bin/python3 /root/umbalabs3d/app.py
Environment="TELEGRAM_BOT_TOKEN=..."
Environment="TELEGRAM_CHAT_ID=..."
Environment="JWT_SECRET=your-secure-random-secret-here"
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

---

## Data Flow

### File Upload Flow

```
1. Customer fills form (name, phone, file)
                │
                ▼
2. JavaScript validates file type & size
                │
                ▼
3. POST /api/upload with FormData
                │
                ▼
4. Flask validates:
   - File extension (STL, OBJ, STEP, 3MF)
   - File size (≤100MB)
                │
                ▼
5. Save file to /root/umbalabs3d/uploads/
   (filename: YYYYMMDD_HHMMSS_originalname.ext)
                │
                ▼
6. Insert record into `uploads` table
                │
                ▼
7. Track 'upload_complete' analytics event
                │
                ▼
8. Send Telegram notification to owner
                │
                ▼
9. Return success JSON to frontend
                │
                ▼
10. Frontend shows success message
```

### Analytics Flow

```
1. Page loads → track('pageview')
                │
                ▼
2. User scrolls → track('scroll', {depth: 25/50/75/100})
                │
                ▼
3. User clicks CTA → track('cta_click', {button: '...'})
                │
                ▼
4. POST /api/track with event data
                │
                ▼
5. Flask inserts into `analytics` table
                │
                ▼
6. Flask updates `page_views` aggregation
```

---

## File Locations Summary

### Local Development

```
./
├── ARCHITECTURE.md         # This file
├── CLAUDE.md               # AI instructions
├── AGENTS.md               # Agent configuration
├── CONTINUITY.md           # Session state
├── backend/
│   └── app.py              # Flask source (sync with VPS)
├── website/
│   ├── index.html          # Landing page source
│   └── *.svg               # Icon files
├── icons/                  # Full icon pack
├── brand/                  # Brand assets
├── marketing/              # Marketing templates
└── docs/                   # Guides
```

### VPS Production

```
/root/umbalabs3d/           # Flask application
├── app.py
├── data/umbalabs3d.db
├── uploads/
└── logs/app.log

/var/www/umbalabs3d/        # Static website
├── index.html
├── favicon_32.svg
├── logo_horizontal_light.svg
└── icon_circle_dark.svg

/etc/caddy/Caddyfile        # Caddy config
/etc/systemd/system/umbalabs3d.service
```

---

## Security Considerations

| Risk | Mitigation |
|------|------------|
| Path traversal | `secure_filename()` sanitizes uploads |
| Large file DoS | 100MB limit at Caddy + Flask |
| File type attacks | Whitelist: STL, OBJ, STEP, STP, 3MF only |
| Direct file access | Uploads stored outside web root |
| SQL injection | Parameterized queries throughout |
| Telegram token leak | Stored in systemd env, not in code |

---

## Monitoring & Operations

### Health Check
```bash
curl https://umbalabs3d.saasita.space/api/health
```

### View Stats
```bash
curl https://umbalabs3d.saasita.space/api/stats
```

### Service Status
```bash
ssh root@YOUR_SERVER_IP "systemctl status umbalabs3d"
```

### View Logs
```bash
ssh root@YOUR_SERVER_IP "tail -f /root/umbalabs3d/logs/app.log"
```

### Restart Service
```bash
ssh root@YOUR_SERVER_IP "systemctl restart umbalabs3d"
```

### Database Query
```bash
ssh root@YOUR_SERVER_IP "sqlite3 /root/umbalabs3d/data/umbalabs3d.db 'SELECT * FROM uploads'"
```

---

## Deployment Process

### Update Website
```bash
scp website/index.html root@YOUR_SERVER_IP:/var/www/umbalabs3d/
```

### Update Backend
```bash
scp backend/app.py root@YOUR_SERVER_IP:/root/umbalabs3d/
ssh root@YOUR_SERVER_IP "systemctl restart umbalabs3d"
```

### Update Icons
```bash
scp website/*.svg root@YOUR_SERVER_IP:/var/www/umbalabs3d/
ssh root@YOUR_SERVER_IP "chmod 644 /var/www/umbalabs3d/*.svg"
```

---

## Future Enhancements (Planned)

1. ~~**Auto-Quote System**~~ ✅ Implemented in v3.0
   - Parse STL files for volume calculation
   - Generate instant price estimates

2. ~~**Customer Portal**~~ ✅ Implemented in v4.0
   - User registration and login
   - Upload history dashboard
   - Order tracking

3. **M-Pesa Integration**
   - Daraja API for payments
   - Auto-confirm orders

4. **Admin Dashboard**
   - Web-based upload management
   - Analytics visualization

---

## Changelog

| Date | Version | Changes |
|------|---------|---------|
| 2026-02-04 | 4.0 | Added user authentication: users table, JWT tokens, login/register endpoints, user dashboard, upload history |
| 2026-02-04 | 3.0 | Added instant quoting: STL parsing, volume calculation, material pricing (PLA/PETG/RESIN), updated UI |
| 2026-02-04 | 2.0 | Added SQLite database, analytics tracking, isolated project structure |
| 2026-02-04 | 1.0 | Initial deployment with file upload and Telegram notifications |
