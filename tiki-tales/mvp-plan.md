# Tiki Tales — MVP Plan

## Strategy: Reuse KidConnect v2 PCB Directly

Don't build from scratch. **Use the existing KidConnect v2 PCB as the Tiki Tales base board.** Leave the TCRT5000 sensor and LM339 comparator footprints empty — just wire the PN532 NFC module to the SPI header.

### What's Already on the KidConnect v2 PCB (reuse as-is)

| Ref | Component | Purpose | Status |
|-----|-----------|---------|--------|
| U1 | ATmega328P-PU (16MHz crystal + 22pF caps) | MCU | ✅ Reuse |
| U2 | DFPlayer Mini (DFR0299) | MP3 playback + SD card | ✅ Reuse |
| U13 | BQ24075RGTR | Li-Po charger | ✅ Reuse |
| U15 | SOT-25 3.3V regulator | Logic supply | ✅ Reuse |
| J1 | USB-C (UJ20-C-H-G-SMT-5-P16-TR) | Charging + serial programming | ✅ Reuse |
| J10 | Battery connector (2-pin) | Li-Po connection | ✅ Reuse |
| J11 | Speaker connector (2-pin) | Audio output | ✅ Reuse |
| J4-J8 | Programming header (DTR auto-reset) | Firmware flashing via USB | ✅ Reuse |
| C3, C4 | 22pF caps | Crystal load | ✅ Reuse |
| C1, C2 | 100nF caps | MCU decoupling | ✅ Reuse |

### What to Leave Empty (don't populate)

| Ref | Component | Why Not Needed |
|-----|-----------|---------------|
| U5-U12 | 8× TCRT5000 sensors | Replaced by PN532 NFC reader |
| U3, U4 | 2× LM339 comparators | No analog→digital conversion needed |
| R18-R25 | 8× 220Ω (IR LED resistors) | No IR LEDs |
| D2-D9 | Threshold reference diodes | No comparators |

### What to ADD (wire to KidConnect PCB)

| Component | Connect To | How |
|-----------|-----------|-----|
| **PN532 NFC module** | SPI pins (MOSI/MISO/SCK/SS) on J4-J8 | 4 jumper wires |
| **PN532 IRQ** | ATmega328P INT0 (pin D2) | 1 jumper wire — wake from sleep |
| **RGB LED** + 3× 220Ω | 3 digital pins (D3/D5/D6) | Solder to proto area or fly wires |
| **Voltage divider** (2× 100KΩ) | A0 (battery sensing) | 2 resistors, fly wires |
| **40mm speaker** | J11 (speaker connector) | Already has connector |
| **Li-Po battery** | J10 (battery connector) | Already has connector |

### Wiring Diagram (PN532 → KidConnect PCB)

```
KidConnect PCB SPI Header          PN532 Module
─────────────────────────          ───────────
MOSI (pin 11) ─────────────────── MOSI
MISO (pin 12) ─────────────────── MISO
SCK  (pin 13) ─────────────────── SCK
SS   (pin 10) ─────────────────── SS
D2   (pin 4)  ─────────────────── IRQ    ← wake from sleep
VCC  ──────────────────────────── VCC (3.3V)
GND  ──────────────────────────── GND
```

**Total new wiring: 7 wires.** That's the entire hardware mod.

---

## Week 1: Wire PN532 to KidConnect PCB + Test

**Your cofounder:**
- Take a KidConnect v2 PCB (populated with ATmega328P, DFPlayer, BQ24075, regulator)
- Leave TCRT5000 + LM339 footprints empty
- Wire PN532 NFC module to SPI header (7 wires — see diagram above)
- Flash test firmware: read NFC tag UID → print to serial monitor
- Verify: tap NTAG213 sticker → UID appears in serial output

**You:**
- Design speaker base enclosure in Blender
  - Flat-top box with recessed NFC zone (~40mm circle on top)
  - Cavity sized to fit KidConnect PCB + PN532 module + battery + speaker
  - Speaker grille on front, USB-C port accessible on back
  - No power switch hole (figurine = switch)
  - ~120×120×80mm
- Print in PLA

**Parts to buy (new spend only):**

| Part | Cost (KSh) | Where |
|------|-----------|-------|
| PN532 NFC module | 1,000 | [Pixel Electric](https://www.pixelelectric.com/rfid-readers-and-writers/pn532-nfc-rfid-reader-writer-module/) |
| NTAG213 NFC stickers (10×) | 500 | [Pixel Electric](https://www.pixelelectric.com/rfid-tags-cards/nfc-sticker-ntag213-compatible-with-all-nfc-phones/) |
| RGB LED + resistors | 30 | Nerokas / Pixel Electric |
| 2× 100KΩ resistors (voltage divider) | 5 | Nerokas / Pixel Electric |
| **Total new spend** | **~1,535** | Everything else reused from KidConnect |

---

## Week 2: First Figurines + Audio

**You:**
- Design and print 4 figurines:
  1. **Hare** (East African trickster)
  2. **Lion** (king of the savanna)
  3. **Tortoise** (wisdom tales)
  4. **Mama / Sleepy** (bedtime lullabies — lead use case per Reddit research)
- Each: 60-80mm tall, flat 40mm base, NFC sticker underneath
- ~20g filament each, ~1-2 hours print time
- Also print 1 **Creative figurine** (blank/abstract shape — for custom MP3s)

**Your cofounder:**
- Write firmware (~60 lines of Arduino for ATmega328P):
  ```
  Setup: init PN532 (SPI), DFPlayer (Serial), attach INT0 to PN532 IRQ pin
  Sleep: POWER_DOWN mode (wake on PN532 IRQ when figurine placed)
  Wake: read NTAG213 UID → lookup in array → send DFPlayer serial command
  Remove: pause → 10 min timeout → sleep
  Battery: read A0 on wake → flash RGB LED for 2 sec (green/orange/red)
  ```
- No power switch — figurine placement wakes the device (Tonies model)
- PN532 IRQ pin → ATmega328P INT0 for hardware wake from sleep
- DFPlayer serial protocol is same as KidConnect v2 — **reuse that code directly**
- Create mapping: `{0xA1B2C3D4: track_01, 0xE5F6A7B8: track_02, ...}` (store in PROGMEM)
- Creative figurine: UID maps to a folder on SD card — parent drops MP3s in folder

**Audio (either of you):**
- Record 3 stories (5 min each) — use your own voice or a friend
- Record/source 1 set of lullabies (for Mama/Sleepy figurine)
- English first, Swahili second
- Save as MP3 on SD card
- Stories: "Hare and the Well", "Why Lion Roars", "Tortoise Wins the Race"

---

## Week 3: Test with Kids

- Place base + 4 figurines in front of 3-5 kids
- Zero instruction — see if they figure it out (place figurine → story plays)
- **If a 3-year-old can use it without help, you've nailed it**
- Film their reactions (this is your pitch deck proof)
- Test bedtime use: give Mama figurine to a parent for evening routine

**Test criteria:**
- [ ] Kid places figurine without prompting
- [ ] Audio plays clearly
- [ ] Kid swaps figurines (understands each one = different story)
- [ ] Kid asks for more figurines (collectibility validated)
- [ ] Parent says "where can I buy this?"
- [ ] Bedtime test: parent reports calmer bedtime routine
- [ ] Creative figurine: parent successfully loads their own MP3
- [ ] Battery LED flashes correct color on figurine placement
- [ ] Device sleeps after 10 min idle (measure current draw)

---

## Week 4: Swahili + Second Test

- Record same 3 stories in Swahili
- Create `map_sw.json`
- Add language switch (button or second config figurine)
- Test with different kids — Swahili-speaking household
- **Film everything** — this is your pitch deck proof

---

## Total MVP Budget

| Item | KSh | Source |
|------|-----|-------|
| PN532 NFC module | 1,000 | Pixel Electric |
| NTAG213 stickers (10×) | 500 | Pixel Electric |
| RGB LED + resistors | 35 | Nerokas |
| PLA filament (~250g for base + 5 figurines) | 700 | Existing spool |
| SD card (if not reusing) | 200 | Jumia |
| **Total new spend** | **~2,435** | |

**KidConnect PCB + DFPlayer + battery + speaker + charger + regulator = FREE** (reused).

Compare to building from scratch (~KSh 3,130) or LittlePenguin (KSh 5,240+).

---

## After MVP: First Sales Path

### Option A — Direct to Parents (B2C)
- Price: KSh 3,500 base + KSh 500/figurine
- Starter set (base + 3 figurines): KSh 4,500
- Sell via WhatsApp, Instagram, word of mouth
- Target: 20 families in first month

### Option B — School Pilot (B2B)
- School set: 1 base + 10 figurines + teacher guide = KSh 8,000
- Position as "CBC mother tongue story time tool"
- Target: 3 schools in Nairobi
- Demo: bring base + figurines to a classroom, let kids use it

### Option C — Gift Market
- Tiki Tales as a birthday/Christmas gift
- Gift box: base + 5 figurines = KSh 5,500
- Beautiful packaging, premium feel
- Kenya's gift market for kids is underserved with quality local products

---

## After MVP: Production PCB (Fork KidConnect v2 in KiCad)

When ready to sell units, fork the KidConnect v2 KiCad project:
1. Remove TCRT5000 (U5-U12) + LM339 (U3/U4) footprints
2. Add PN532 header (7-pin: MOSI/MISO/SCK/SS/IRQ/VCC/GND)
3. Add RGB LED + resistors footprint
4. Add voltage divider (2× 100KΩ) for battery sensing on A0
5. Fix safety issues from KidConnect review:
   - Add reverse polarity protection (P-MOSFET on battery input)
   - Add PTC fuse (500mA) on battery line
   - Add 5.1kΩ pull-downs on USB-C CC1/CC2
   - Add ESD protection on USB-C (USBLC6-2SC6)
6. Order from JLCPCB (~$2/board for 5 boards, 1-2 week shipping)

Reference: Marta Musik Maschine open-source KiCad files at [github.com/martamusikmaschine](https://github.com/martamusikmaschine/mmm)

---

## Content Scaling Plan

### Phase 1 (Launch): 12 Stories + Lullabies
- 6 English + 6 Swahili stories
- 1 lullaby/bedtime audio set (lead use case)
- 7 figurines (Hare, Lion, Tortoise, Anansi, Nyamgondho, Mama/Sleepy, Creative)
- Creative figurine for custom parent-loaded MP3s

### Phase 2 (Month 2-3): 30 Stories
- Add Kikuyu, Luo language packs
- 10 figurines total
- CBC-aligned stories for PP1/PP2

### Phase 3 (Month 4-6): 100+ Stories
- Partner with Kenyan children's authors
- Commission local voice actors
- Add music/lullaby figurines
- Seasonal packs (Christmas, Easter, Madaraka Day)

### Content Partnerships to Pursue
- **Storymoja** — Kenya's largest children's publisher
- **Moran Publishers** — CBC textbook publisher
- **Local storytellers/griots** — authentic oral tradition
- **University drama departments** — voice acting students (cheap, talented)
