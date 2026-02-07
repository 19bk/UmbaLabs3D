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
Diff behavior between main and your changes when relevant
Ask yourself: "Would a staff engineer approve this?"
Run tests, check logs, demonstrate correctness

### 5. Demand Elegance (Balanced)
For non-trivial changes: pause and ask "is there a more elegant way?"
If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
Skip this for simple, obvious fixes - don't over-engineer
Challenge your own work before presenting it

### 6. Autonomous Bug Fixing (Test-First)
**When a bug is reported: DON'T start by trying to fix it.**
First, write a test that reproduces the bug.
Then, have subagents try to fix the bug and prove it with a passing test.
Point at logs, errors, failing tests -> then resolve them
Zero context switching required from the user
Go fix failing CI tests without being told how

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

## Documentation Maintenance (MANDATORY)

**After ANY architectural change is implemented, update these files:**

1. **`ARCHITECTURE.md`** - Update system diagrams, endpoints, database schema, or infrastructure changes
2. **`CONTINUITY.md`** - Log the change with date (same session)
3. **Update relevant docs** if change affects:
   - Brand assets or colors
   - Business processes
   - Pricing or products
   - Platform configurations
4. **Keep all docs current** - outdated information causes mistakes

### Architecture Updates Required When:
- New API endpoints added/modified
- Database schema changes
- New services deployed
- Infrastructure changes (ports, configs)
- New integrations (Telegram, M-Pesa, etc.)
- File storage locations change
- Security measures added

**Why**: Outdated docs cause repeated mistakes and confusion across sessions.

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
