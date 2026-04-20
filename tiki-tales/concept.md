# Tiki Tales — Product Concept

## What It Is
A speaker base + collectible 3D-printed figurines. Place a figurine on the base → it plays a story. That's it.

## How It Works
1. Kid picks a figurine (e.g., Hare, Anansi, Lion)
2. Places it on the speaker base
3. NFC chip in figurine's base is read by the reader in the speaker
4. ATmega328P looks up the figurine ID → sends play command to DFPlayer Mini
5. Plays 5-15 minute story through speaker
6. Kid can pause, replay, or swap figurines

## Why It Works
- **No screens** — "Give them stories, not screens" (proven emotional hook with parents)
- **No internet** — works offline, perfect for rural Kenya
- **No reading required** — audio-first, works for pre-literate kids
- **Physical interaction** — placing a figurine is tactile and fun (kids as young as 12 months can do it)
- **Collectible** — kids want more figurines = recurring revenue
- **Cultural** — African stories in African languages, not imported content
- **Bedtime hero** — Reddit parents confirm: #1 use case is bedtime/naptime wind-down
- **Passes the purge test** — audio-only, kid-controlled, calming. Survives the Christmas toy purge.

## Primary Use Cases (from Reddit research)
1. **Bedtime wind-down** — calming stories/lullabies as part of sleep routine (lead with this)
2. **Quiet time** — when child drops nap but needs a rest period
3. **Independent play** — while parent cooks, works, or rests
4. **Car rides** — portable audio for travel
5. **Language learning** — stories in mother tongue for diaspora families

## The Tonies Model (Proven at Scale)
Tonies (Germany, founded 2016):
- Simple concept: speaker box + figurines
- Revenue: $500M+/year
- 7M+ Tonieboxes sold
- 90M+ figurines sold
- Available in: Europe, US, UK, Australia
- **NOT available in Africa** — that's our gap

### What Tonies Gets Right
- Dead simple UX (toddlers can use it)
- Collectible figurines drive repeat purchases
- Content partnerships (Disney, Peppa Pig, etc.)
- Premium pricing ($100 base, $15-20/figurine)

### Where We Differentiate
- **African content** — Tonies has zero African stories or languages
- **3D printed figurines** — we manufacture locally, they injection mold in China
- **Price point** — KSh 3,500 base (~$27) vs Tonies $100. 75% cheaper. Kills the "cash grab" objection.
- **Figurine price** — KSh 500 (~$4) vs Tonies $15-20. 75% cheaper. Impulse-buy territory.
- **Original audio** — we record our own. Reddit parents hate Tonies' cheap cover versions of songs.
- **Language flexibility** — swap SD card = new language. Tonies is locked to purchase.
- **Fully offline** — no WiFi ever. Tonies requires WiFi for initial setup (parent complaint).
- **Custom content** — Creative figurine lets parents load MP3s. Yoto's #1 feature, Tonies doesn't have it.
- **Solar-ready** — designed for off-grid use (same as KidConnect)

### Age Segmentation (from Reddit research)
| Age | Best Content | Figurine Type |
|-----|-------------|---------------|
| 1-2 | Nursery rhymes, simple songs | Music figurines (Mama, Lullaby) |
| 2-3 | Short stories (5 min), animal sounds | Character figurines (Sungura, Simba) |
| 3-5 | Full folktales (10-15 min), CBC content | Story figurines (Anansi, Nyamgondho) |
| 5-8 | Chapter series, language learning | Series figurines, Creative figurine |

## Hardware

### Base Unit (aligned with KidConnect v2 platform)
| Component | Purpose | Cost (KSh) |
|-----------|---------|-----------|
| ATmega328P-PU | MCU (same as KidConnect v2) | 200 |
| PN532 NFC reader (SPI) | Reads figurine NFC chips | 350 |
| DFPlayer Mini (DFR0299) | MP3 decoding + amp + SD slot (same as KidConnect v2) | 250 |
| 40mm 4Ω speaker | Sound output | 100 |
| BQ24075RGTR | Li-Po charger (same as KidConnect v2) | 150 |
| Li-Po battery | Power | 300 |
| SOT-25 3.3V regulator | Logic supply (same as KidConnect v2) | 50 |
| USB-C connector | Charging | 50 |
| RGB LED + resistors | Battery level indicator | 30 |
| Voltage divider (2× 100KΩ) | Battery voltage sensing on A0 | 5 |
| **Total** | | **~1,485** |

### What's shared with KidConnect v2
| Component | KidConnect v2 | Tiki Tales |
|-----------|--------------|-------------|
| MCU | ATmega328P-PU | ATmega328P-PU ✅ |
| Audio | DFPlayer Mini | DFPlayer Mini ✅ |
| Power management | BQ24075RGTR | BQ24075RGTR ✅ |
| Regulator | SOT-25 3.3V | SOT-25 3.3V ✅ |
| USB-C charging | Same connector | Same connector ✅ |
| Card reader | 8× TCRT5000 optical | PN532 NFC ❌ (different) |
| Signal conditioning | 2× LM339 comparators | N/A ❌ (not needed) |

**~70% hardware shared.** Different input method (NFC vs optical) but same MCU, audio, and power platform. Firmware structure is similar: read input → lookup → play audio.

### Enclosure (3D Printed)
- Rounded box, ~120×120×80mm
- Flat top surface with recessed NFC zone (figurine sits here)
- Speaker grille on front
- USB-C port on back
- No power switch (figurine placement = power on, Tonies model)
- Filament: ~150g (~KSh 420)

### Battery Level Indicator (Tonies Model)
No screen, no app — single **RGB LED** shows battery status when figurine is placed (2-3 sec flash, then off):

| LED Color | Voltage | Meaning |
|-----------|---------|---------|
| Green | >3.8V | Above 60% |
| Orange | 3.5–3.8V | 20–60% |
| Red | <3.5V | Below 20% — charge soon |
| Flashing red | <3.3V | Critical — shutting down |
| Solid red (charging) | — | TP4056 charging |
| Solid green (charging) | — | TP4056 charge complete |

**Circuit**: Battery+ → 100KΩ → ATmega328P A0 → 100KΩ → GND (voltage divider). RGB LED on 3 digital pins with 220Ω resistors.

**Why brief flash then off**: Always-on LED drains battery and is distracting during bedtime use. Tonies does the same — show status briefly, then dark.

### Figurines (3D Printed)
- Height: 60-80mm
- Base: flat, ~40mm diameter (houses NFC sticker)
- Filament per figurine: ~15-25g (KSh 42-70)
- NFC sticker: KSh 10
- **Total per figurine: KSh 50-80**
- Sell at KSh 500 = **85%+ margin**

## Content

### Story Categories
1. **African Folktales** — Anansi, Hare & Hyena, Why Mosquitoes Buzz, Mwindo
2. **CBC Curriculum Stories** — aligned to Kenya's Competency Based Curriculum
3. **Bedtime Stories** — calming narratives, lullabies
4. **Moral Stories** — sharing, kindness, bravery (universal themes, local settings)
5. **Animal Adventures** — safari animals, farm animals, ocean creatures

### Languages (Priority Order)
1. English (launch)
2. Swahili (launch)
3. Kikuyu (Phase 2)
4. Luo (Phase 2)
5. Kalenjin (Phase 3)
6. Somali (Phase 3 — reuse KidConnect audio infrastructure)

### Audio Production
- Record with native speakers (local voice actors, teachers, storytellers)
- 5-15 minutes per story
- MP3 format on SD card
- File mapping: `map_<lang>.json` (figurine NFC ID → audio filename)
- Same mapping system as KidConnect — code reuse

## Power Design — No Switch (Tonies Model)

**Decision**: No physical power switch. The figurine IS the switch.

### How Tonies Does It
- No buttons, no switch — entire cube is soft fabric
- Placing a figurine activates playback via NFC
- Removing the figurine pauses → timeout → deep sleep
- Ears squeeze for volume. Tap sides to skip.
- 12-month-olds can use it. Zero learning curve.

### How Yoto Does It
- Has a power button (targets 3+, so fine for them)
- Inserting a card starts playback
- Twist dial for volume, press to pause/play
- Pixel display shows card artwork

### Tiki Tales Power Design
- **PN532 IRQ pin** wired to ATmega328P external interrupt (INT0 or INT1)
- ATmega328P sleeps in `POWER_DOWN` mode (~0.1μA)
- PN532 stays in low-power tag detection mode (~100μA standby)
- Figurine placed → PN532 IRQ fires → ATmega328P wakes → reads NFC UID → plays audio
- Figurine removed → pause → 10 min timeout → deep sleep
- **Total standby draw**: <1mA → 2000mAh battery lasts months in standby
- Optional: internal slide switch as "shipping lock" (prevents drain in transit/storage), not user-facing

### Why No Switch
| Factor | No Switch | Slide Switch | Soft Latch Button |
|--------|-----------|-------------|-------------------|
| Toddler-friendly | Yes (1+) | No | Maybe (3+) |
| Battery life | Great (~0.1mA standby) | Best (0mA off) | Good |
| Parts cost | KSh 0 | KSh 10-20 | KSh 50-100 |
| Failure points | None | Switch wears out | More components |
| Parent experience | "Just works" | "Is it on? Why dead?" | "How do I turn off?" |

---

## Firmware (ATmega328P + Arduino)
```
Power on → init peripherals → enter POWER_DOWN sleep

[Figurine placed — PN532 IRQ triggers INT0]
  Wake → read NFC UID via SPI
  → lookup UID in mapping table (PROGMEM or SD)
  → send play command to DFPlayer Mini (Serial TX/RX)

[Figurine removed — NFC read returns no tag]
  → send pause command to DFPlayer
  → start 10-minute inactivity timer

[Timeout — no figurine for 10 min]
  → enter POWER_DOWN sleep (waiting for next IRQ)

[Different figurine placed]
  → stop current track → play new track

[Same figurine re-placed]
  → resume playback
```

Same firmware pattern as KidConnect v2: detect input → lookup → command DFPlayer. The only difference is PN532 SPI reads instead of TCRT5000 comparator reads. DFPlayer serial protocol is identical. Sleep/wake via PN532 IRQ is the key addition.
