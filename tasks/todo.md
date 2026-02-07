# UmbaLabs 3D - Task List

## Completed (2026-02-04)

### User Authentication System (v4.0)
- [x] Add users table to database schema
- [x] Add user_id FK to uploads table
- [x] Implement JWT token helpers (create/verify)
- [x] Create @auth_required decorator
- [x] Create @auth_optional decorator
- [x] Implement POST /api/auth/register
- [x] Implement POST /api/auth/login
- [x] Implement GET /api/auth/me
- [x] Implement GET /api/user/uploads
- [x] Modify /api/upload to link user_id
- [x] Add login/register modal (HTML/CSS)
- [x] Add auth JavaScript (register, login, logout, token storage)
- [x] Update header with login/user menu
- [x] Add user dashboard section
- [x] Add upload history cards with status badges
- [x] Connect dashboard to API
- [x] Update ARCHITECTURE.md
- [x] Update CONTINUITY.md

### Deployment (v4.0)
- [x] Deploy v4.0 backend to VPS
- [x] Deploy v4.0 frontend to VPS
- [x] Add JWT_SECRET to systemd environment
- [x] Run database migration (users table, user_id column)
- [x] Test registration flow
- [x] Test login flow
- [x] Test upload linking
- [x] Test dashboard display

### Instant Quote Fix
- [x] Fix numpy float32 JSON serialization error
- [x] Fix frontend to match API response structure
- [x] Test with real STL file (All parts - v1.stl)
- [x] Verify instant quote works on live site

### Design Services Section
- [x] Add dedicated design services section (dark theme)
- [x] Add pricing cards (Sketch to 3D, Photo to 3D, Custom Design, File Repair)
- [x] Add "Most Popular" badge to Photo to 3D
- [x] Add WhatsApp CTA with pre-filled message
- [x] Add "Design" to navigation menu
- [x] Update services card to link to design section
- [x] Deploy to VPS

### 3D Scanning Coming Soon
- [x] Add "Coming Soon" banner in design services section
- [x] Add pulsing radar icon animation
- [x] Add "Notify Me" WhatsApp CTA for waitlist
- [x] Responsive design for mobile
- [x] Deploy to VPS

## Pending

### DNS
- [ ] Add A record: umbalabs3d → YOUR_SERVER_IP
- [ ] Verify HTTPS after propagation

### Social Media
- [ ] Register @umbalabs3d on Instagram
- [ ] Register @umbalabs3d on TikTok
- [ ] Register @umbalabs3d on Twitter/X
- [ ] Set up WhatsApp Business

### Marketing
- [ ] Create first TikTok content
- [ ] Post first Jiji listing
- [ ] First customer outreach

### Future Enhancements
- [ ] **3D Scanning service** (when equipment acquired)
- [ ] M-Pesa integration (Daraja API)
- [ ] Admin dashboard for order management
- [ ] Email notifications
- [ ] Order status updates via WhatsApp API
