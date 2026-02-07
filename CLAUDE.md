## Workflow Orchestration

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
After ANY correction from the user: update 'tasks/lessons.md' with the pattern
Write rules for yourself that prevent the same mistake
Ruthlessly iterate on these lessons until mistake rate drops
Review lessons at session start for relevant project

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

## Lessons Learned (UmbaLabs-Specific)

*(Add lessons here as the project progresses)*

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
