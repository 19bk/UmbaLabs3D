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
