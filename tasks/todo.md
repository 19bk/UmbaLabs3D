# UmbaLabs 3D - Task List

## Completed (2026-03-02)

### LittlePenguin Revenue Projections (Kenya)
- [x] Gather Kenya market benchmarks for early STEM/coding products
- [x] Build 12-month revenue projections (conservative/base/aggressive)
- [x] Summarize assumptions, risks, and break-even triggers

## Completed (2026-03-10)

### Prado Radio Trim v4 Fit Review
- [x] Read `clients/prado-radio-trim/design-review-v4.md` and `files/radio-trim-v4.scad`
- [x] Cross-check OEM Eclipse and Sony dimensions from local manuals
- [x] Compare v4 body envelope against Toyota 200mm fascia references
- [x] Review clip geometry for insertion/retention feasibility
- [x] Deliver fit verdict and next validation steps

## Completed (2026-03-02)

### External Concept Viability Review
- [x] Review `/Users/bernard/Downloads/littlePenguin.odt` for concept viability
- [x] Identify strengths, risks, and missing execution details
- [x] Produce go/no-go recommendation with next validation steps

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

## Completed (2026-02-22)

### Prado Radio Trim Scope Clarification
- [x] Clarify OEM radio is Eclipse Future Link AVN-R8W (to be removed)
- [x] Clarify installed aftermarket unit is Sony XAV-AX8500
- [x] Update profile to define design target: clip-in trim for gap after OEM removal + Sony install
- [x] Update client notes with clarified design intent

### 3D Scanning Coming Soon
- [x] Add "Coming Soon" banner in design services section
- [x] Add pulsing radar icon animation
- [x] Add "Notify Me" WhatsApp CTA for waitlist
- [x] Responsive design for mobile
- [x] Deploy to VPS

## Pending

### Tonuino V2 Front Panel Repair (2026-03-26)
- [x] Inspect `tiki-tales/casing/v3/tonuino-original/Tonuino V2 - Part 2 (1).stl` and compare it against the current rebuilt front-panel model
- [x] Update the front-panel CAD so it preserves the original fit envelope while replacing the large speaker opening with a 45mm grille
- [x] Fill the 3 right-side button holes, add the LED hole, and keep/add the inside speaker ridge ring in solid geometry
- [x] Export the revised front panel STL and verify it is manifold and free of imported-mesh seam artifacts
- [x] Record the outcome and verification notes
- Review: replaced STL filler booleans with a slice-derived clean rebuild in `tiki-tales/casing/v3/tonuino-v3-front-v8.scad`, kept the speaker ridge open instead of the bad solid-disc regression, re-exported `tiki-tales/casing/v3/tonuino-v3-front.stl`, matched the original 91.6 x 70.6 panel envelope, and got a single connected STL shell plus `Simple: yes`; residual check is that OpenSCAD still reports `Volumes: 2`, so Bambu preview remains the deciding proof

### Tonuino V2 Body Switch Cutout Repair (2026-03-30)
- [x] Review the current `tiki-tales/casing/v3/tonuino-v3-body.scad` regression and confirm why the raw rectangle cut is not sufficient
- [x] Replace the blunt fill block with a local wall patch derived from the original body wall profile
- [x] Re-cut the rectangular switch opening and export `tiki-tales/casing/v3/tonuino-v3-body.stl`
- [x] Verify the exported body is a single connected STL shell and renders `Simple: yes` in OpenSCAD
- Review: `tiki-tales/casing/v3/tonuino-v3-body.scad` now fills the legacy switch opening with an extruded side-wall slice instead of a raw cube or hull fragment, then re-cuts the KCD1 rectangle; the exported STL is one connected mesh shell and preserves the original body bbox

### Tonuino Regression Fix (2026-03-30)
- [x] Verify the latest front/body edits against the intended speaker airflow and switch-hole behavior
- [x] Restore the front speaker support so it does not block the grille acoustically while still avoiding unsupported geometry
- [x] Restore the body switch-hole modification so the original opening is actually converted to the intended rectangular cutout
- [x] Export corrected Tonuino STL files and verify them in OpenSCAD
- [x] Record the final outcome and any remaining slicer-specific checks
- Review: replaced the front's incorrect solid speaker disc with an open tapered ring in `tiki-tales/casing/v3/tonuino-v3-front-v8.scad`, restored a real local fill patch before the rectangular switch cut in `tiki-tales/casing/v3/tonuino-v3-body.scad`, and re-exported `tonuino-v3-front.stl` plus `tonuino-v3-body.stl`; both render `Simple: yes` and each STL is one connected mesh shell, but OpenSCAD still reports `Volumes: 2`, so Bambu Studio preview remains the final warning check

### Tonuino Front Warning Fix (2026-03-30)
- [x] Refactor the front panel's slice-derived back profile to remove the floating-cantilever warning in Bambu Studio
- [x] Re-export `tiki-tales/casing/v3/tonuino-v3-front.stl`
- [x] Verify OpenSCAD output and mesh connectivity after the refactor
- [x] Record the outcome and any remaining slicer-specific risks
- Review: replaced the continuous rear speaker ring with segmented tapered support lugs in `tiki-tales/casing/v3/tonuino-v3-front-v8.scad` and re-exported `tonuino-v3-front.stl`; OpenSCAD still reports `Volumes: 2`, but the continuous annular feature most likely responsible for Bambu's floating-cantilever warning is gone, so the next proof step is to reload the STL in Bambu Studio

### Bayonet Base Bed Adhesion (2026-03-14)
- [x] Inspect `tiki-tales/figurines/figurine-base.scad` print-plate export and confirm why `ready/base-test-bayonet.stl` has weak first-layer contact
- [x] Patch the export so the cup and mirrored lid both sit directly on the bed
- [x] Regenerate `tiki-tales/figurines/ready/base-test-bayonet.stl`
- [x] Verify the updated STL geometry with OpenSCAD/output inspection
- [x] Record the outcome and any follow-up for the other lock variants
- Review: the old export lifted the mirrored lid to `z=0.3` on a thin sacrificial disc; the regenerated STL now has direct bed contact at `z=0` for both parts and no vertices at `z=0.3`

### Tiki Tales Design Direction Clarification (2026-04-03)
- [x] Re-read the active TonUINO casing sources and confirm whether the project still uses the older scratch-built toybox body
- [x] Re-read the active figurine-base source and confirm the current lock/cavity architecture
- [x] Update project tracking to reflect the actual current direction
- Review: current casing work is anchored to the TonUINO v2 community enclosure, not the old scratch-built body path. `tiki-tales/casing/v3/tonuino-v3-body.scad` patches the original Part 1 mesh from a sampled wall slice before re-cutting the KCD1 rectangle, and `tiki-tales/casing/v3/tonuino-v3-front-v8.scad` is the clean-room Part 2 rebuild preserving the original fit profile while adding the 45mm grille, measured screw pattern, LED hole, and open speaker ridge. `tiki-tales/figurines/figurine-base.scad` is the active v4.3 design with a 46mm base, 42mm x 9mm plain cavity, four lock options, and bayonet as the default.

### Prado Radio Trim Fitment Review (2026-03-11)
- [x] Read latest user fitment notes from physical test print
- [x] Open today's attached photos/sketches
- [x] Translate notes into exact CAD adjustment list for next revision
- [x] Confirm angle measurements from bubble level screenshots
- [x] Create flat v5 fitment shell using latest physical measurements and ignoring angle
- [x] Validate new SCAD compiles cleanly
- [x] Record review outcome for next modeling step

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
