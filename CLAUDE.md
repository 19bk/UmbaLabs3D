## Workflow Orchestration

### 0. Session Start (MANDATORY)
- Read `tasks/3d-lessons.md` — check which rules apply to the current task
- Read relevant .scad files BEFORE proposing any changes
- If modifying an STL: render the ORIGINAL from all relevant angles, count every feature

### 1. Plan Mode Default
Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
If something goes sideways, STOP and re-plan immediately - don't keep pushing
Use plan mode for verification steps, not just building
Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy to keep main context window clean
Offload research, exploration, and parallel analysis to subagents
For complex problems, throw more compute at it via subagents
One task per subagent for focused execution

### 3. Self-Improvement Loop
After ANY correction from the user:
- Update `tasks/3d-lessons.md` with incident (what happened, root cause, fix, rule)
- Add the rule to the Critical Rules section of 3d-lessons.md
- Update CLAUDE.md Common Mistakes table if broadly applicable
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review `tasks/3d-lessons.md` at session start for relevant project

### 4. Verification Before Done
Never mark a task complete without proving it works
Preview designs in browser before marking complete
Ask yourself: "Would a professional brand designer approve this?"
Test links, check images render, verify colors match spec

### 5. Demand Elegance (Balanced)
For non-trivial changes: pause and ask "is there a more elegant way?"
If a design feels cluttered: "Simplify while keeping impact"
Skip this for simple, obvious fixes - don't over-engineer
Challenge your own work before presenting it

### 6. Autonomous Bug Fixing (Test-First)
**When a bug is reported: DON'T start by trying to fix it.**
First, reproduce the issue visually or in code.
Then fix and verify the fix works.
Zero context switching required from the user

## Task Management
**Plan First**: Write plan to 'tasks/todo.md' with checkable items
**Verify Plan**: Check in before starting implementation
**Track Progress**: Mark items complete as you go
**Explain Changes**: High-level summary at each step
**Document Results**: Add review to 'tasks/todo.md'
**Capture Lessons**: Update 'tasks/lessons.md' after corrections

## Core Principles
**Simplicity First**: Make every change as simple as possible. Impact minimal code.
**No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
**Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

---

## Available MCP Tools for 3D

### OpenSCAD MCP (`openscad`)
- Render .scad files directly without shelling out
- Export STL/3MF with validation
- Syntax checking and dimension analysis
- **Use for**: all parametric design, render verification, STL export

### Blender MCP (`blender`)
- Control Blender from Claude for organic shapes
- Mesh operations, sculpting, UV mapping
- **Use for**: figurine editing, mesh repair, organic modeling

### PrintPal (browser tool)
- [printpal.io/3dgenerator](https://printpal.io/3dgenerator) — 10 free generations/month
- Text/image → STL in 60 seconds
- **Use for**: generating figurine STLs from descriptions

### Workflow: When to Use What
| Task | Tool |
|------|------|
| Parametric parts (enclosures, bases, mounts) | OpenSCAD MCP |
| Figurine generation from text/image | PrintPal browser |
| Mesh repair, organic shapes | Blender MCP |
| STL validation | OpenSCAD MCP (`Simple: yes` check) |
| Print settings | Bambu Studio (Single_Color.3mf profile) |

---

## Smooth Print Design Rules (Bambu A1)

### Design for Surface Quality
| Rule | Why |
|------|-----|
| Chamfer bottom edges, fillet top edges | Bottom fillets create overhangs that sag |
| Wall thickness = multiples of 0.4mm | 0.8, 1.2, 1.6mm — avoids gap-fill artifacts |
| Add a sharp vertical edge for seam hiding | Seam aligns to corners, becomes invisible |
| Flat bottom, smooth face on build plate | Plate side is always smoothest surface |
| 4 walls minimum for cosmetic parts | Prevents infill pattern ghosting through walls |
| Monotonic top surface pattern | Lines go one direction — no scarring |
| No features smaller than 2× nozzle width (0.8mm) | Prints as blobs |
| Gradual curves need 0.12mm layers | Reduces stairstepping on domes/curves |

### Bambu A1 Cosmetic Profile
```
Layer height:        0.12mm
Outer wall speed:    30 mm/s (inner: 80-100 mm/s)
Wall count:          4
Seam:                Aligned + Scarf joint (15-25mm length)
Top surface:         Monotonic
Ironing:             On (10% flow, 15 mm/s)
Fan:                 100% after layer 3
Nozzle temp:         200-210°C (lower = less stringing)
Bed temp:            55°C (higher = elephant's foot)
Plate:               Smooth PEI for glass-smooth bottom
Wall generator:      Arachne
Outer wall accel:    1000-2000 mm/s²
```

### A1-Specific Quirks
- **Bed-slinger** — tall parts get Y-axis ringing. Keep cosmetic parts short or reduce speed
- **Retraction**: Stock 0.8mm at 30mm/s is good. Don't increase — causes clogs
- **Input shaper**: Run calibration if ghosting appears
- **Y-belt tension**: Check periodically. Loose belt = wavy walls

### Post-Processing (Quick Finish)
1. Sand at 220 grit (30 seconds per face)
2. Spray filler primer (2 light coats, 10 min between)
3. Sand at 400 grit
4. Final paint coat
5. **Total: 30-45 min for professional finish**
6. **XTC-3D** epoxy coating: glossy, layer-free in one coat (adds ~0.5mm)

---

## UmbaLabs 3D - Domain Knowledge

### Brand Identity
```
Name: UmbaLabs 3D
"Umba" = "create" in Swahili
Tagline options:
  - "We Build What You Imagine"
  - "From Digital to Physical"
  - "Your Ideas, Printed"
```

### Color Palette (CRITICAL - Use Exact Values)
| Color | Hex | RGB | Use |
|-------|-----|-----|-----|
| Umba Orange | #FF6B35 | 255, 107, 53 | Primary brand, CTAs, buttons |
| Deep Navy | #1A1A2E | 26, 26, 46 | Backgrounds, body text |
| Creation Gold | #F7B801 | 247, 184, 1 | Accents, highlights, premium |
| Tech Teal | #00D9C0 | 0, 217, 192 | Secondary accent, links |
| White | #FFFFFF | 255, 255, 255 | Text on dark, backgrounds |

### Typography Guidelines
- **Headlines**: Bold, modern sans-serif (Poppins, Inter, or Montserrat)
- **Body**: Clean sans-serif (Inter, Open Sans)
- **Accent**: Can use monospace for tech/code feel

### Logo Usage
- **Full Logo**: Use on website headers, marketing materials, print
- **Icon Only**: Profile pictures, favicons, small spaces
- **Minimum Size**: Icon at least 32x32px, full logo at least 120px wide
- **Clear Space**: Maintain padding equal to icon height around logo

### Social Media Handles
**Consistent handle: @umbalabs3d** across all platforms:
- Instagram: @umbalabs3d
- TikTok: @umbalabs3d
- Twitter/X: @umbalabs3d
- Facebook: /umbalabs3d

### Kenya Market Context
- **Payment**: M-Pesa is dominant - always offer M-Pesa option
- **Communication**: WhatsApp is primary business communication channel
- **Marketplace**: Jiji.co.ke is the main classifieds platform
- **Pricing**: Quote in KES (Kenyan Shillings)
- **Language**: Mix of English and Swahili acceptable in marketing
- **Delivery**: Many customers prefer pickup; delivery adds complexity

### 3D Printing Terminology
- **FDM**: Fused Deposition Modeling (most common, uses filament)
- **SLA/Resin**: Stereolithography (higher detail, uses liquid resin)
- **Filament**: PLA, PETG, ABS (common materials)
- **Layer Height**: Affects print quality (0.1mm = fine, 0.3mm = draft)
- **Infill**: Internal structure density (20% typical, 100% = solid)
- **Build Volume**: Maximum print size (X × Y × Z mm)
- **STL/3MF**: Common 3D file formats customers provide

### Content Ideas for TikTok/Instagram
1. **Timelapse prints** - Satisfying to watch
2. **Before/after** - Digital model → physical object
3. **Failed prints** - Relatable, educational
4. **Customer reveals** - Reactions to finished products
5. **Process videos** - Slicing, bed leveling, post-processing
6. **Local context** - Printing Kenya-related items

---

## Documentation Maintenance (MANDATORY)

**After ANY significant change, update these files:**

1. **`ARCHITECTURE.md`** - Update when technical architecture changes:
   - New/modified API endpoints
   - Database schema changes
   - New services or integrations
   - Infrastructure changes (ports, configs, file paths)
   - Security measures
2. **`CONTINUITY.md`** - Log the change with date (same session)
3. **Update relevant sections** if change affects:
   - Brand colors or logo
   - Pricing structure
   - Platform accounts
   - Business processes
   - Key decisions

### Architecture Doc Update Checklist:
- [ ] API endpoints table updated?
- [ ] Database schema section current?
- [ ] File locations accurate?
- [ ] Data flow diagrams reflect changes?
- [ ] Deployment commands updated?
- [ ] Changelog entry added?

**Why**: Outdated docs cause repeated mistakes and confusion across sessions.

---

## 3D Design System (OpenSCAD + FDM)

### Design Session Protocol
1. **Read first**: ALWAYS read the existing .scad file top-to-bottom before changing anything
2. **Parameters at top**: Never hardcode dimensions inline — all values in the parameter block
3. **Derived values**: Use `inner_dia = base_dia - wall * 2` not raw numbers
4. **Version files**: `part-v3.scad`, never overwrite the original
5. **One change per iteration**: When debugging fit, change ONE variable per print
6. **Mark uncertainty**: `// UNCONFIRMED — assumed from [source]` for unmeasured values

### Before ANY STL Export (Mandatory Checklist)
- [ ] `Simple: yes` in OpenSCAD console (F6 render, not F5 preview)
- [ ] No overhangs > 45° without support design
- [ ] No cantilevers > 2mm unsupported
- [ ] No floating geometry (disconnected shells from CSG)
- [ ] Flat bottom surface for bed adhesion (minimum 10mm² contact)
- [ ] Part oriented for printing (smooth face on bed, features pointing up)
- [ ] Wall thickness ≥ 1.2mm everywhere
- [ ] Hole diameters have +0.2mm compensation for FDM shrink
- [ ] All screw holes are through-holes (not blind from wrong CSG)
- [ ] Render a preview image and visually verify before delivering to user

### STL Mesh Modification Rules
**Golden rule: modify the .scad source, not the STL. STL editing is lossy.**

When modifying an existing STL with CSG:
1. **Fill holes**: Use blocks that extend WELL beyond the hole (±10mm past edges)
2. **Don't change the shape**: Never add geometry that alters the original surface profile
3. **Trim flush**: After filling, trim to the original body outline
4. **Union overlap**: Ensure ≥0.5mm overlap when unioning — touching faces = non-manifold
5. **Verify after every operation**: Re-render, check `Simple: yes`, visually inspect
6. **Accept limitations**: Some STL features (internal retainers, recesses) can't be filled with CSG — document what the switch/component bezel will cover

### FDM Print-Readiness (Bambu A1)
| Check | Rule |
|-------|------|
| Walls | ≥1.6mm (4 perimeters at 0.4mm nozzle) for strength |
| Infill | 10-15% gyroid for display, 30%+ for functional |
| First layer | Flat, full contact, 50mm/s speed |
| Bed | Textured PEI plate, clean with IPA |
| Brim | Auto 5mm for parts > 80mm |
| Supports | OFF unless overhangs > 45° exist |
| Orientation | Smooth/cosmetic face on bed, features up |
| Seam | Back or nearest |

### Physical Test Fit Protocol
1. **Before printing**: State what you're testing (one hypothesis)
2. **After printing**: Measure with calipers, compare to CAD dimensions
3. **Record**: Date, measured vs designed, pass/fail per criterion
4. **Max 2 variables** changed per iteration
5. **After 3 failed iterations**: STOP — re-measure the target geometry from scratch
6. **Keep every version's STL** — never overwrite

### Common Mistakes to Avoid
| Mistake | Rule |
|---------|------|
| Filling holes changes body shape | Fill blocks must not extend beyond the original surface — use intersection with original if needed |
| Adding screw holes that don't exist | Count holes in original STL render BEFORE modifying |
| Wrong speaker/hole center | Measure from mesh data, don't estimate from renders |
| Grille slots overflow circle | Use `intersection()` with clip cylinder, not per-slot bounds check |
| Ridge/feature creates cantilever | Orient for print: feature UP, flat face DOWN |
| Reducing box dimensions without checking components fit | NEVER change bh/bw/bd without verifying ALL components still fit |
| Fill block covers screw holes | Check which holes the fill covers, re-cut at exact original positions |

---

## Lessons Learned (UmbaLabs-Specific)

### 2026-03-25: STL Mesh Modification — Fill Blocks Destroy Shape
**Mistake**: Adding cubic fill blocks to seal circular holes in STL meshes changed the body's rounded surface profile
**Correction**: Either (a) make the rectangle large enough to fully contain the circle, or (b) accept small remnants that the component bezel covers
**Rule**: When modifying an STL, NEVER add geometry that changes the original surface. Cut-only operations preserve shape.

### 2026-03-25: Screw Hole Count Verification
**Mistake**: Added 6 screw holes when the original only had 4 — kept adding fake "re-cut" holes at wrong positions
**Correction**: Render the original STL front-on, count exact holes, note positions before modifying
**Rule**: Before modifying any part, render the ORIGINAL from the relevant angle and count/document every feature

### 2026-03-25: Speaker Center Offset
**Mistake**: Assumed speaker opening center at X=-7 without verifying, causing grille offset from ridge
**Correction**: Run mesh analysis or overlay renders to find actual center
**Rule**: For any circular feature, verify center coordinates from the mesh before building geometry around it

### 2026-03-15: Bayonet Tab vs Channel Clearance
**Mistake**: Tab height exceeded channel height — tab hit the channel roof during rotation and jammed
**Correction**: Calculate global Z positions for both tab and channel, verify clearance ≥0.3mm on all sides
**Rule**: For any moving/engaging parts, write the Z-stack math in comments and verify clearance before exporting

### 2026-03-14: Lid Too Thick / Solid Lip Melting
**Mistake**: Made lid lip a solid 41mm cylinder — overheated during printing, caused melting
**Correction**: Use a thick-walled tube (2mm walls) instead of solid — cools properly between passes
**Rule**: Never make cylindrical features > 20mm diameter solid — use tube walls for proper FDM cooling

### Template
```
### YYYY-MM-DD: [Brief Title]
**Mistake**: What went wrong
**Correction**: What the right approach was
**Rule**: Actionable rule to prevent recurrence
```

---

## Continuity Ledger (compaction-safe)
Maintain a single Continuity Ledger for this workspace in `CONTINUITY.md`. The ledger is the canonical session briefing designed to survive context compaction; do not rely on earlier chat text unless it's reflected in the ledger.

### How it works
- At the start of every assistant turn: read `CONTINUITY.md`, update it to reflect the latest goal/constraints/decisions/state, then proceed with the work.
- Update `CONTINUITY.md` again whenever any of these change: goal, constraints/assumptions, key decisions, progress state (Done/Now/Next), or important tool outcomes.
- Keep it short and stable: facts only, no transcripts. Prefer bullets. Mark uncertainty as `UNCONFIRMED` (never guess).
- If you notice missing recall or a compaction/summary event: refresh/rebuild the ledger from visible context, mark gaps `UNCONFIRMED`, ask up to 1-3 targeted questions, then continue.

### `CONTINUITY.md` format (keep headings)
- **Goal** (incl. success criteria):
- **Constraints/Assumptions**:
- **Key decisions**:
- **State**:
- **Done**:
- **Now**:
- **Next**:
- **Open questions** (UNCONFIRMED if needed):
- **Working set** (files/ids/commands):
