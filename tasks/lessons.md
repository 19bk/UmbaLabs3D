# UmbaLabs 3D - Lessons Learned

## 2026-02-04: NumPy Float32 JSON Serialization

**Mistake**: API returned 500 error when trying to serialize numpy.float32 values to JSON.

**Correction**: Wrap all numpy values with `float()` before returning in JSON response.

**Rule**: Always convert numpy types to native Python types before JSON serialization:
```python
# Bad
'volume_cm3': round(volume_cm3, 2)  # Still numpy.float32

# Good
'volume_cm3': float(round(volume_cm3, 2))  # Native Python float
```

---

## 2026-02-04: API Response Structure Mismatch

**Mistake**: Frontend expected `data.quote` object but API returned flat structure with `data.analysis` and `data.prices`.

**Correction**: Updated frontend JavaScript to correctly parse the API response structure.

**Rule**: When building API + frontend together, document the response schema first and test the integration early. Use browser console to inspect actual API responses.

---

## 2026-02-04: SQLite ALTER TABLE Limitations

**Mistake**: `CREATE TABLE IF NOT EXISTS` doesn't add new columns to existing tables. Database migration failed because `user_id` column didn't exist in production.

**Correction**: Run explicit `ALTER TABLE uploads ADD COLUMN user_id INTEGER` migration.

**Rule**: For schema changes to existing tables:
1. Check current schema: `sqlite3 db.db '.schema tablename'`
2. Run ALTER TABLE for new columns
3. CREATE TABLE IF NOT EXISTS only helps with new tables

---

## 2026-02-04: Design Services = High Margin

**Insight**: Design services (sketch-to-3D, photo-to-3D) have ~80% margins because:
- No material cost
- No machine wear
- Just time/skill

**Rule**: Always upsell design services. They're more profitable than printing.

---

## Template for Future Lessons

```
## YYYY-MM-DD: [Brief Title]

**Mistake**: What went wrong

**Correction**: What the right approach was

**Rule**: Actionable rule to prevent recurrence
```

---

## 2026-02-22: OEM vs Aftermarket Scope Must Be Explicit

**Mistake**: Radio details were updated without clearly separating OEM unit (to be removed) from aftermarket unit (installed), creating scope ambiguity for the trim design.

**Correction**: Documented both units explicitly:
- OEM: Eclipse Future Link AVN-R8W (removal reference)
- Installed: Sony XAV-AX8500 (trim interface target)

**Rule**: For car retrofit projects, always record three distinct references in the client profile:
1. OEM part being removed
2. Replacement part being installed
3. Final opening/gap geometry the printed part must interface with

---

## 2026-03-15: Bayonet Review Must Check Rotation Clearance, Not Just Insertion

**Mistake**: I reviewed the bayonet lid as if matching slot width/depth and insertion height were enough, but missed that the tab top sat above the horizontal channel roof, so it can insert yet still fail to rotate/lock.

**Correction**: Compare the full tab swept envelope against the channel envelope in Z and radial depth after the lid is fully seated. For bayonet locks, verify insertion and rotation as separate conditions.

**Rule**: For any twist-lock geometry, always prove all three before calling it viable:
1. The tab can enter the vertical slot
2. The tab stays fully inside the horizontal channel during rotation
3. The seated position still leaves positive detent/retention geometry

---

## 2026-03-30: Slicer Warning Fixes Must Preserve Part Function

**Mistake**: I accepted a geometry change that removed Bambu warnings by turning the front speaker ridge into a solid disc and by dropping the body's old-hole fill entirely, which preserved slicer cleanliness at the cost of blocking speaker airflow and breaking the intended switch-hole conversion.

**Correction**: Restored function first:
- Front panel: use an open, self-supporting tapered ring instead of a solid disc
- Body: add a real local wall patch before cutting the rectangular switch opening

**Rule**: When fixing CAD/slicer warnings, always verify the functional requirement directly before accepting the change:
1. Acoustic paths must stay open for speakers/grilles
2. A replacement cutout must actually remove or replace the original opening, not rely on bezels to hide leftovers
3. “Cleaner in the slicer” is not a valid fix if it changes what the part is supposed to do

---

## 2026-03-30: Do Not Trade Part Function For Slicer Warnings

**Mistake**: A Tonuino front-panel "fix" turned the inner speaker ridge into a solid disc to silence a cantilever warning, which would have reduced or blocked the speaker airflow. A body "fix" also removed the fill step entirely and relied on the switch bezel to hide the old opening.

**Correction**: Keep the acoustic path and intended hole geometry functional first, then solve printability with geometry that preserves that function. For the Tonuino parts, that meant restoring an open speaker ridge and rebuilding the switch-hole fill from the real wall profile instead of taking a shortcut.

**Rule**: When a slicer warning conflicts with the part's actual job:
1. Treat function as non-negotiable
2. Verify what the geometry is supposed to do in the assembled part
3. Only accept a printability change if it preserves the intended airflow, clearance, mounting, and hardware fit

---

## 2026-04-03: Reconfirm The Active CAD Baseline Before Reasoning From History

**Mistake**: I carried forward the older scratch-built toybox mental model even though the active Tiki Tales CAD had already pivoted to a TonUINO-derived casing and a newer figurine-base architecture.

**Correction**: Re-read the active source files before describing the current design direction. The source of truth is the current CAD in `tiki-tales/casing/v3/` and `tiki-tales/figurines/figurine-base.scad`, not older conversation state.

**Rule**: When a hardware/CAD project has multiple iterations:
1. Verify the latest active source files before reasoning from prior discussion
2. Confirm whether the current baseline is a scratch design, a patched community model, or a clean-room rebuild
3. Update `CONTINUITY.md` immediately once the active baseline is clarified so later work does not drift back to obsolete geometry
