# UmbaLabs 3D - File Upload System Deployment Guide

This guide covers deploying the file upload and quote system to the VPS.

## Architecture Overview

```
User uploads file on website
        |
        v
Caddy receives request (HTTPS, /api/upload)
        |
        v
Flask API (port 5000)
  - Validates file type
  - Saves to /var/uploads/
  - Sends Telegram notification
        |
        v
Owner receives notification
  - File details in Telegram
  - Contacts customer via WhatsApp
```

---

## Step 1: Create Telegram Bot

1. **Open Telegram** and search for `@BotFather`

2. **Start a chat** and send `/newbot`

3. **Follow prompts**:
   - Name: `UmbaLabs 3D Uploads`
   - Username: `umbalabs3d_uploads_bot` (must end in `_bot`)

4. **Save the token** - it looks like: `7123456789:AAF-xyzABC123def456...`

5. **Get your Chat ID**:
   - Start a chat with your new bot (send any message)
   - Visit: `https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates`
   - Find `"chat":{"id":123456789}` - that number is your Chat ID

---

## Step 2: Deploy to VPS

SSH to your server and run these commands:

```bash
# SSH to VPS
ssh root@YOUR_SERVER_IP

# 1. Create directories
mkdir -p /root/umbalabs3d
mkdir -p /var/uploads
mkdir -p /var/log/umbalabs3d
chmod 750 /var/uploads

# 2. Copy files from local machine (run on LOCAL machine)
# From your local dev folder:
scp backend/app.py root@YOUR_SERVER_IP:/root/umbalabs3d/
scp backend/requirements.txt root@YOUR_SERVER_IP:/root/umbalabs3d/
scp backend/umbalabs3d.service root@YOUR_SERVER_IP:/etc/systemd/system/
scp website/index.html root@YOUR_SERVER_IP:/var/www/umbalabs3d/

# 3. Back on VPS - Install dependencies
pip3 install -r /root/umbalabs3d/requirements.txt

# 4. Edit service file with your Telegram credentials
nano /etc/systemd/system/umbalabs3d.service
# Replace YOUR_BOT_TOKEN_HERE with actual token
# Replace YOUR_CHAT_ID_HERE with actual chat ID

# 5. Start the Flask service
systemctl daemon-reload
systemctl enable umbalabs3d
systemctl start umbalabs3d

# 6. Check it's running
systemctl status umbalabs3d
curl http://127.0.0.1:5000/api/health

# 7. Update Caddy config
nano /etc/caddy/Caddyfile
```

---

## Step 3: Update Caddyfile

Add this configuration to `/etc/caddy/Caddyfile`:

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

Then reload Caddy:

```bash
systemctl reload caddy
```

---

## Step 4: Verify Deployment

### Test health endpoint:
```bash
curl https://umbalabs3d.saasita.space/api/health
```

Expected response:
```json
{"status":"healthy","service":"UmbaLabs 3D Upload API","timestamp":"..."}
```

### Test file upload:
```bash
# Create a test file
echo "test stl content" > /tmp/test.stl

# Upload it
curl -X POST \
  -F "file=@/tmp/test.stl" \
  -F "name=Test User" \
  -F "phone=0712345678" \
  https://umbalabs3d.saasita.space/api/upload
```

Expected:
- Response with `"success": true`
- Telegram notification on your phone
- File saved in `/var/uploads/`

---

## Troubleshooting

### Check Flask logs:
```bash
tail -f /var/log/umbalabs3d/api.log
```

### Check Caddy logs:
```bash
journalctl -u caddy -f
```

### Restart services:
```bash
systemctl restart umbalabs3d
systemctl restart caddy
```

### Common issues:

| Issue | Solution |
|-------|----------|
| 502 Bad Gateway | Flask not running: `systemctl start umbalabs3d` |
| 413 Request Entity Too Large | Caddy config missing `request_body { max_size }` |
| No Telegram notification | Check token/chat ID in service file |
| File not saving | Check `/var/uploads/` permissions |

---

## Security Notes

1. **Files stored outside web root**: `/var/uploads/` is not accessible via URL
2. **File type validation**: Only STL, OBJ, STEP, STP, 3MF allowed
3. **Filename sanitization**: `secure_filename()` prevents path traversal
4. **Size limit**: 100MB max enforced at both Caddy and Flask levels

---

## Verification Checklist

- [ ] Flask app running on port 5000
- [ ] Caddy proxying /api/* to Flask
- [ ] File uploads save to /var/uploads/
- [ ] Telegram notification received
- [ ] Website form submits successfully
- [ ] Error messages show for wrong file types
- [ ] Error messages show for files > 100MB

---

## File Locations on VPS

| File | Path |
|------|------|
| Flask app | `/root/umbalabs3d/app.py` |
| Dependencies | `/root/umbalabs3d/requirements.txt` |
| Systemd service | `/etc/systemd/system/umbalabs3d.service` |
| Uploaded files | `/var/uploads/` |
| API logs | `/var/log/umbalabs3d/api.log` |
| Website | `/var/www/umbalabs3d/index.html` |
| Caddy config | `/etc/caddy/Caddyfile` |
