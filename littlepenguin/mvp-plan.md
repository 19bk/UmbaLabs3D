# LittlePenguin — MVP Plan

## Guiding Principle
Don't build a hardware company. Build a prototype and validate demand first.

---

## Phase 1: Paper Prototype (Week 1-2, KSh 0)

Skip electronics. Test the **teaching concept**.

- Print 4 module shapes on paper/cardboard (sphere, cuboid, cube, heart)
- Color them (blue, red, green, yellow)
- Make paper programming cards
- Draw a simple play field on large cardboard
- **Test with 3-5 kids** — do they understand the body analogy? Can they sequence cards?

**Exit criteria**: Kids engage and can explain "what does the brain block do?"

---

## Phase 2: 3D Printed Shell + Off-the-Shelf Electronics (Week 3-6, KSh 15,000-25,000)

UmbaLabs 3D prints the housing. Commodity electronics inside.

### Bill of Materials (per kit)

| Module | Shell | Electronics | Cost |
|--------|-------|-------------|------|
| Brain (head) | 3D printed sphere, blue | ESP32 + small OLED screen | ~KSh 1,500 |
| Motion (legs) | 3D printed cuboid, red | 2x TT motors + L298N driver + 2 wheels | ~KSh 800 |
| Sensors (eyes) | 3D printed cube, green | HC-SR04 ultrasonic + IR line follower | ~KSh 500 |
| Power (heart) | 3D printed heart, yellow | 2x 18650 + BMS board + switch | ~KSh 600 |

**Total BOM per unit: ~KSh 5,000-7,000**

### Key Design Decisions
- **Connectors**: Magnetic pogo pins (KSh 200/set, AliExpress). Kids snap modules together, magnets align, pogo pins make electrical contact. No wires visible.
- **Programming cards**: NFC stickers (KSh 10 each) on printed cardboard. Kid taps card sequence on brain module's NFC reader. Screen-free coding.
- **Battery**: Replaceable 18650 cells, NOT sealed LiPo. African heat degrades LiPo 20-35% annually.

### Strip to MVP
Start with **Brain + Motion only** (2 modules). Add sensors later. This cuts BOM and complexity in half.

---

## Phase 3: Play Field (Week 3-4, KSh 2,000)

- Printed vinyl mat, 60cm x 60cm grid
- Start with 2 scenarios: **Home** and **School** (most relatable)
- 4 tasks per scenario = 8 total challenges
- Local print shop: ~KSh 2,000 per mat

---

## Phase 4: Validate with Paying Customers (Week 7-8)

### Option A — School Pilot (B2B, faster revenue)
- Approach 2-3 private schools in Nairobi
- Offer: "Free 1-hour robotics demo session for Year 1-2"
- Bring 3-4 robot kits + field mat
- After demo: pitch term program (8 sessions x KSh 60,000)
- **Success = 2 schools say yes**

### Option B — Holiday Camp (B2C, tests pricing)
- 3-day "Little Robotics Camp" during school holidays
- KSh 7,500/kid, 10 kids minimum
- Venue: co-working space or community hall
- **Success = 10 sign-ups**

### Option C — Partner with Cobot Kids
- Peter Kimani has 500 students but no proprietary hardware
- Offer: test LittlePenguin kits with his students
- He gets differentiated hardware, you get validation data

---

## MVP Budget

| Item | Cost (KSh) |
|------|------------|
| Electronics (4 kits worth) | 20,000 |
| PLA filament 1kg (confirmed KSh 2,800/spool) | 2,800 |
| NFC stickers + card printing | 2,000 |
| Vinyl play mats (x2) | 4,000 |
| School demo transport/misc | 3,000 |
| **Total** | **~31,800** |

---

## Success Criteria Before Investing More
- [ ] 5+ kids complete tasks without adult hand-holding
- [ ] 2+ schools request paid follow-up sessions
- [ ] OR 10+ parents pay for a holiday camp
- [ ] Kids can explain "what does the brain block do?" after one session

---

## What NOT To Do
- Don't design custom PCBs — ESP32 dev boards work fine
- Don't injection mold — 3D print everything
- Don't build an app — NFC cards are the interface
- Don't write full curriculum yet — test with loose scenarios first
- Don't incorporate a company — validate first
- Don't order from China in bulk — prototype with local/AliExpress parts
