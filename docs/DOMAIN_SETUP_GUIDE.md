# Domain & HTTPS Setup Guide

This guide covers how domains, HTTPS, and subdomains work on your VPS (YOUR_SERVER_IP) using Caddy.

---

## How It All Works

```
┌─────────────────────────────────────────────────────────────────┐
│                         INTERNET                                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  DNS (Cloudflare/Registrar)                                     │
│  saasita.space → YOUR_SERVER_IP                                     │
│  essay.saasita.space → YOUR_SERVER_IP                               │
│  api.saasita.space → YOUR_SERVER_IP                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  VPS (YOUR_SERVER_IP)                                               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Caddy (Port 80/443)                                      │  │
│  │  - Automatic HTTPS (Let's Encrypt)                        │  │
│  │  - Routes requests based on domain                        │  │
│  │                                                           │  │
│  │  essay.saasita.space → localhost:3001 (EssayAlly)         │  │
│  │  api.saasita.space → localhost:8080 (API)                 │  │
│  │  saasita.space → localhost:3000 (Main site)               │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐               │
│  │ EssayAlly   │ │ API Service │ │ Main Site   │               │
│  │ :3001       │ │ :8080       │ │ :3000       │               │
│  └─────────────┘ └─────────────┘ └─────────────┘               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Current Setup

### Domain: saasita.space

| Subdomain | Port | Service |
|-----------|------|---------|
| saasita.space | 3000 | Main site |
| essay.saasita.space | 3001 | EssayAlly |
| api.saasita.space | 8080 | API + Webhooks |
| dtaskbot.saasita.space | 8000 | Task bot |

### Caddy Config Location
```
/etc/caddy/Caddyfile
```

---

## Adding a New Subdomain

### Step 1: Add DNS Record

Go to your domain registrar/DNS provider (likely Cloudflare) and add:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | newapp | YOUR_SERVER_IP | Auto |

This creates `newapp.saasita.space` pointing to your VPS.

**If using Cloudflare:**
1. Log in to Cloudflare dashboard
2. Select saasita.space
3. Go to DNS → Records
4. Click "Add record"
5. Type: A, Name: newapp, IPv4: YOUR_SERVER_IP
6. Proxy status: DNS only (grey cloud) OR Proxied (orange cloud)

### Step 2: Deploy Your App

```bash
# SSH to server
ssh root@YOUR_SERVER_IP

# Create directory
mkdir -p /root/newapp

# Copy files (from local)
scp -r ./your-app/* root@YOUR_SERVER_IP:/root/newapp/

# Install dependencies
cd /root/newapp && npm install
```

### Step 3: Create Systemd Service

```bash
sudo nano /etc/systemd/system/newapp.service
```

Paste this template:
```ini
[Unit]
Description=New App Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/newapp
EnvironmentFile=/root/newapp/.env
Environment=PYTHONUNBUFFERED=1
ExecStart=/usr/bin/node /root/newapp/server.js
# OR for Python: ExecStart=/usr/bin/python3 -u /root/newapp/main.py
Restart=always
RestartSec=10
StandardOutput=append:/root/newapp/app.log
StandardError=append:/root/newapp/app.log

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable newapp
sudo systemctl start newapp
sudo systemctl status newapp
```

### Step 4: Add to Caddy

```bash
sudo nano /etc/caddy/Caddyfile
```

Add your new subdomain block:
```
newapp.saasita.space {
    reverse_proxy 127.0.0.1:YOUR_PORT
}
```

Reload Caddy:
```bash
sudo systemctl reload caddy
```

**That's it!** Caddy automatically:
- Obtains SSL certificate from Let's Encrypt
- Configures HTTPS
- Redirects HTTP → HTTPS
- Renews certificates before expiry

### Step 5: Verify

```bash
# Check Caddy status
sudo systemctl status caddy

# Check certificate
curl -I https://newapp.saasita.space

# Check logs if issues
journalctl -u caddy -f
```

---

## Common Caddy Configurations

### Basic Reverse Proxy
```
myapp.saasita.space {
    reverse_proxy 127.0.0.1:3000
}
```

### With Security Headers
```
myapp.saasita.space {
    header {
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
        -Server
        -X-Powered-By
    }
    reverse_proxy 127.0.0.1:3000
}
```

### With Rate Limiting
```
myapp.saasita.space {
    rate_limit {
        zone myapp {
            key {remote_host}
            events 100
            window 1m
        }
    }
    reverse_proxy 127.0.0.1:3000
}
```

### Path-Based Routing
```
myapp.saasita.space {
    handle /api/* {
        reverse_proxy 127.0.0.1:8080
    }
    handle {
        reverse_proxy 127.0.0.1:3000
    }
}
```

### Static Files + API
```
myapp.saasita.space {
    handle /api/* {
        reverse_proxy 127.0.0.1:8080
    }
    handle {
        root * /var/www/myapp
        file_server
    }
}
```

### Redirect www to non-www
```
www.myapp.saasita.space {
    redir https://myapp.saasita.space{uri} permanent
}

myapp.saasita.space {
    reverse_proxy 127.0.0.1:3000
}
```

### WebSocket Support
```
myapp.saasita.space {
    reverse_proxy 127.0.0.1:3000 {
        header_up Host {host}
        header_up X-Real-IP {remote_host}
        header_up X-Forwarded-For {remote_host}
        header_up X-Forwarded-Proto {scheme}
    }
}
```

---

## Troubleshooting

### Certificate Not Working

```bash
# Check Caddy logs
journalctl -u caddy --since "10 minutes ago"

# Common issues:
# 1. DNS not propagated yet (wait 5-10 min)
# 2. Port 80/443 blocked by firewall
# 3. Another service using port 80/443
```

### Check Open Ports
```bash
ss -tlnp | grep -E ':80|:443'
# Should show caddy on both ports
```

### Force Certificate Renewal
```bash
# Caddy auto-renews, but if needed:
sudo systemctl stop caddy
sudo rm -rf /var/lib/caddy/.local/share/caddy/certificates
sudo systemctl start caddy
```

### DNS Not Resolving
```bash
# Check DNS propagation
dig newapp.saasita.space

# Should return YOUR_SERVER_IP
```

### App Not Responding
```bash
# Check if app is running
systemctl status newapp

# Check if port is listening
ss -tlnp | grep YOUR_PORT

# Check app logs
tail -100 /root/newapp/app.log
```

---

## Port Allocation

Keep track of which ports are used:

| Port | Service | Subdomain |
|------|---------|-----------|
| 3000 | Main site | saasita.space |
| 3001 | EssayAlly | essay.saasita.space |
| 8000 | Task bot | dtaskbot.saasita.space |
| 8080 | API | api.saasita.space |
| 8081 | Turnitin webhooks | api.saasita.space/webhooks/turnit |

**Next available ports:** 3002, 3003, 8082, 5000, etc.

---

## Quick Reference

```bash
# SSH to server
ssh root@YOUR_SERVER_IP

# Edit Caddy config
sudo nano /etc/caddy/Caddyfile

# Reload Caddy (apply changes)
sudo systemctl reload caddy

# Restart Caddy (full restart)
sudo systemctl restart caddy

# Check Caddy status
sudo systemctl status caddy

# View Caddy logs
journalctl -u caddy -f

# List all services
systemctl list-units --type=service --state=running

# Check SSL certificate
curl -vI https://yoursite.saasita.space 2>&1 | grep -A 5 "Server certificate"
```

---

## Security Checklist for New Subdomains

- [ ] DNS record points to YOUR_SERVER_IP
- [ ] App runs as systemd service (not nohup/tmux)
- [ ] Environment variables in `.env` file (not hardcoded)
- [ ] `.env` not committed to git
- [ ] Security headers configured in Caddy
- [ ] Rate limiting if public-facing
- [ ] Logs being written to file
- [ ] Service enabled for boot persistence
