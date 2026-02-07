# VPS Deployment Guide

## Server Details
- **IP**: YOUR_SERVER_IP
- **User**: root
- **SSH**: `ssh root@YOUR_SERVER_IP`

---

## CRITICAL RULES

### 1. ALWAYS USE SYSTEMD - NO EXCEPTIONS
```bash
# NEVER DO THIS:
nohup python3 script.py &          # FORBIDDEN
tmux new -s bot                     # FORBIDDEN
screen -S bot                       # FORBIDDEN
python3 script.py &                 # FORBIDDEN

# ALWAYS DO THIS:
sudo systemctl start umbalabs3d    # CORRECT
sudo systemctl enable umbalabs3d   # CORRECT
```

**Why systemd only:**
- Auto-restarts on crash
- Survives SSH disconnects
- Proper logging via journald
- Clean process management
- Boot persistence

### 2. DO NOT TOUCH OTHER SERVICES
The VPS runs **multiple production services**. NEVER modify, stop, or interfere with services you did not create.

---

## UmbaLabs 3D Deployment

### File Locations
```
/root/umbalabs3d/
├── app.py                  # Flask API v4.0
├── data/
│   └── umbalabs3d.db       # SQLite database
├── uploads/                # Customer files
└── logs/
    └── app.log             # Application logs

/var/www/umbalabs3d/        # Static website
├── index.html
├── favicon_32.svg
├── logo_horizontal_light.svg
└── icon_circle_dark.svg
```

### Service File
Location: `/etc/systemd/system/umbalabs3d.service`

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

## Common Operations

### Check Status
```bash
sudo systemctl status umbalabs3d
```

### View Logs (Live)
```bash
tail -f /root/umbalabs3d/logs/app.log
# OR
journalctl -u umbalabs3d -f
```

### Restart Service
```bash
sudo systemctl restart umbalabs3d
```

### Stop Service
```bash
sudo systemctl stop umbalabs3d
```

### Start Service
```bash
sudo systemctl start umbalabs3d
```

---

## Deploying Code Changes

### Step 1: Copy Files from Local
```bash
# From local machine:
scp backend/app.py root@YOUR_SERVER_IP:/root/umbalabs3d/
scp website/index.html root@YOUR_SERVER_IP:/var/www/umbalabs3d/
```

### Step 2: Restart Service
```bash
ssh root@YOUR_SERVER_IP "sudo systemctl restart umbalabs3d"
```

### Step 3: Verify Running
```bash
ssh root@YOUR_SERVER_IP "sudo systemctl status umbalabs3d"
```

### Step 4: Check Logs for Errors
```bash
ssh root@YOUR_SERVER_IP "tail -50 /root/umbalabs3d/logs/app.log"
```

---

## Creating a New Service (Template)

### Step 1: Create Service File
```bash
sudo nano /etc/systemd/system/my-new-bot.service
```

### Step 2: Use This Template
```ini
[Unit]
Description=My New Bot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/my_new_bot
EnvironmentFile=/root/my_new_bot/.env
Environment=PYTHONUNBUFFERED=1
ExecStart=/usr/bin/python3 -u /root/my_new_bot/main.py
Restart=always
RestartSec=10
StandardOutput=append:/root/my_new_bot/bot.log
StandardError=append:/root/my_new_bot/bot.log

[Install]
WantedBy=multi-user.target
```

### Step 3: Reload and Enable
```bash
sudo systemctl daemon-reload
sudo systemctl enable my-new-bot
sudo systemctl start my-new-bot
```

---

## Troubleshooting

### Service Not Starting
```bash
# Check logs for errors
journalctl -u umbalabs3d -n 100 --no-pager

# Check if port is in use
ss -tlnp | grep python

# Check application errors
tail -100 /root/umbalabs3d/logs/app.log
```

---

## Quick Reference

```bash
# SSH to VPS
ssh root@YOUR_SERVER_IP

# Service Status
systemctl status umbalabs3d

# Service Restart
systemctl restart umbalabs3d

# Service Logs
tail -f /root/umbalabs3d/logs/app.log

# List ALL running services
systemctl list-units --type=service --state=running

# Deploy code update (one-liner)
scp backend/app.py root@YOUR_SERVER_IP:/root/umbalabs3d/ && ssh root@YOUR_SERVER_IP "systemctl restart umbalabs3d && systemctl status umbalabs3d"
```
