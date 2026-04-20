# Tiki Tales — Production BOM
## 1 Set = 1 Toybox + 3 Figurines

> **Deadline: Ship by end of next week**
> All parts sourced locally in Nairobi. No AliExpress.
> Updated: 2026-03-12

---

## TOYBOX (Speaker Base Unit)

| # | Part | Spec | Qty | Source | KSh | SKU/Link |
|---|------|------|-----|--------|-----|----------|
| 1 | Arduino Pro Mini | 5V 16MHz | 1 | Nerokas | 550 | [SKU-1944](https://store.nerokas.co.ke/SKU-1944) |
| 2 | DFPlayer Mini | MP3-TF-16P | 1 | Nerokas | 450 | [SKU-3379](https://store.nerokas.co.ke/SKU-3379) |
| 3 | RC522 RFID Module | 13.56MHz ISO14443A | 1 | Nerokas | 500 | [SKU-841](https://store.nerokas.co.ke/SKU-841) |
| 4 | TP4056 USB-C | Charger + protection | 1 | Pixel Electric | 80 | [Link](https://www.pixelelectric.com/more-categories/batteries-accessories/battery-accessories/battery-chargers/tp4056-1a-lithium-charging-module/) |
| 5 | 18650 Battery | 3.7V 2600mAh genuine | 1 | Nerokas / Jumia | 350 | Get Samsung/LG cell |
| 6 | Speaker 40mm | 3W 4Ω | 1 | Nerokas | 200 | [SKU-3414](https://store.nerokas.co.ke/SKU-3414) |
| 7 | Slide Switch | SPDT mini | 1 | Nerokas | 30 | |
| 8 | MicroSD Card | 4GB+ | 1 | Phone shop Luthuli | 300 | Cheapest available |
| 9 | Steel Washer | M10 fender ~30-35mm OD, 1mm | 1 | Hardware store | 20 | For magnet grip plate under RC522 |
| 10 | Hookup Wire | 24-28 AWG assorted | 1 | Nerokas | 50 | |
| 11 | Solder + Hot Glue | | 1 | Nerokas | 50 | |
| 12 | PLA — Casing | ~100g (base + lid) | 1 | Existing spool | 280 | KSh 2,800/kg |
| | **TOYBOX TOTAL** | | | | **2,860** | |

---

## PER FIGURINE (×3)

| # | Part | Spec | Qty | Source | KSh | Notes |
|---|------|------|-----|--------|-----|-------|
| 13 | NFC Sticker | NTAG213 25mm | 1 | Pixel Electric | 50 | [Link](https://www.pixelelectric.com/rfid-tags-cards/nfc-sticker-ntag213-compatible-with-all-nfc-phones/) |
| 14 | Neodymium Magnet | 20x3mm N35 disc | 1 | Nerokas / Jumia | 150 | [Nerokas magnets](https://store.nerokas.co.ke/index.php?route=product/category&path=72). If 20mm unavailable, use 2× stacked 10x3mm |
| 15 | PLA — Figurine | ~12g hollow body | 1 | Existing spool | 34 | 15% infill, 2mm walls |
| 16 | PLA — Base | ~8g cup + lid | 1 | Existing spool | 22 | 100% infill |
| 17 | Felt Pad | 38mm self-adhesive | 1 | Hardware/craft | 15 | |
| 18 | Hot Glue | Bond figurine to lid | 1 | Existing | 5 | |
| | **PER FIGURINE** | | | | **276** | |
| | **×3 FIGURINES** | | | | **828** | |

---

## TOTAL — 1 COMPLETE SET

```
Toybox:          KSh 2,860
3 Figurines:     KSh   828
────────────────────────────
TOTAL:           KSh 3,688
```

---

## PRICING STRATEGY

| Package | Cost | Sell | Profit | Margin |
|---------|------|------|--------|--------|
| Toybox + 3 figurines | 3,688 | 6,500 | 2,812 | 43% |
| Extra figurine (add-on) | 276 | 500 | 224 | 45% |
| 3-figurine pack (add-on) | 828 | 1,200 | 372 | 31% |

---

## SHOPPING LIST — One Trip, One Day

### Stop 1: Nerokas (Luthuli Ave / online store.nerokas.co.ke)
- [ ] Arduino Pro Mini 5V ×1 — ~KSh 550
- [ ] DFPlayer Mini ×1 — ~KSh 450
- [ ] RC522 RFID Kit ×1 — ~KSh 500
- [ ] 18650 Battery ×1 — ~KSh 350
- [ ] Speaker 40mm ×1 — ~KSh 200
- [ ] Slide switch ×1 — ~KSh 30
- [ ] Neodymium magnets ×3 — ~KSh 450
- [ ] Hookup wire + solder — ~KSh 100
- **Nerokas subtotal: ~KSh 2,630**

### Stop 2: Pixel Electric (Nairobi)
- [ ] TP4056 USB-C charger ×1 — KSh 80
- [ ] NTAG213 NFC stickers ×3 — KSh 150
- **Pixel Electric subtotal: KSh 230**

### Stop 3: Phone Shop (Luthuli Ave)
- [ ] MicroSD card 4GB ×1 — ~KSh 300

### Stop 4: Hardware Store
- [ ] Fender washer M10/M12 ×1 — KSh 20
- [ ] Self-adhesive felt pads ×3 — KSh 45
- **Hardware subtotal: KSh 65**

### Already Have
- [x] PLA filament spool (~136g needed = KSh 381)
- [x] Hot glue gun + sticks
- [x] 3D printer (Bambu Lab)
- [x] Soldering iron

```
CASH NEEDED FOR SHOPPING: ~KSh 3,225
PLA FROM SPOOL:           ~KSh   381
HOT GLUE ETC:             ~KSh    82
────────────────────────────────────────
TOTAL PRODUCTION COST:     KSh 3,688
```

---

## PRINT QUEUE

Start printing BEFORE shopping — prints run while you're out buying parts.

| # | File | Est. Time | Settings |
|---|------|-----------|----------|
| 1 | `figurines/ready/base-print-plate.stl` (test fit) | 30 min | 100% infill, no supports |
| 2 | `casing/tiki-tales-base-bottom.stl` (toybox base) | 3-4 hrs | 60% infill, no supports |
| 3 | `casing/tiki-tales-base-lid.stl` (toybox lid) | 1-2 hrs | 60% infill, no supports |
| 4 | `figurines/ready/elephant-body.stl` | 2-3 hrs | 15% infill, supports ON |
| 5 | Figurine 2 body (TBD — download from Printables) | 2-3 hrs | 15% infill, supports ON |
| 6 | Figurine 3 body (TBD — download from Printables) | 2-3 hrs | 15% infill, supports ON |
| 7 | `figurines/ready/base-print-plate.stl` ×3 | 1 hr | 100% infill, no supports |
| **TOTAL** | | **~14-18 hrs** | Can run overnight |

---

## RISK ITEMS — Call Ahead

| Risk | Mitigation |
|------|-----------|
| Nerokas out of stock on magnets | Call +254 706 246 248 first. Backup: Jumia search "neodymium magnet 20mm" |
| Nerokas out of stock on NFC | Pixel Electric has NTAG213 stickers confirmed |
| Fake 18650 batteries on Luthuli | Buy from Nerokas (reputable). Test voltage with multimeter. |
| Fake MicroSD cards | Buy SanDisk from reputable phone shop. Test with H2testw. |
| 20mm magnets unavailable locally | Use 2× stacked 10x3mm magnets instead (widely available) |

---

## ASSEMBLY SEQUENCE (Day 2-3)

### Toybox Assembly
1. Flash Arduino Pro Mini with Tiki Tales firmware (USB-TTL adapter)
2. Load audio files onto MicroSD (3 folders: 001/, 002/, 003/)
3. Solder wiring: Arduino ↔ DFPlayer (TX/RX) ↔ RC522 (SPI) ↔ speaker ↔ TP4056 ↔ battery ↔ switch
4. Glue steel washer centered under RC522 in lid (below PCB)
5. Mount all electronics in toybox casing
6. Test: power on, verify NFC reads, audio plays
7. Close lid, secure with screws

### Figurine Assembly (×3)
1. Write unique ID to each NFC sticker (using RC522 + Arduino sketch)
2. Map: sticker 1 → audio folder 001, sticker 2 → 002, sticker 3 → 003
3. Stick NFC tag in base cup floor pocket (face up)
4. Drop 20x3mm magnet on top of NFC tag
5. Snap lid onto cup
6. Hot-glue figurine to lid top surface
7. Stick felt pad on cup bottom
8. Test: place on toybox → correct audio plays + magnetic snap holds

### Final QC
- [ ] All 3 figurines trigger correct audio
- [ ] Magnetic snap holds figurine at 45° tilt
- [ ] Volume adequate from speaker
- [ ] Battery lasts 2+ hours continuous play
- [ ] USB-C charging works
- [ ] On/off switch works
- [ ] No rattling or loose parts
- [ ] Felt pads prevent scratching

---

## VENDOR CONTACTS

| Vendor | Contact | Best for |
|--------|---------|----------|
| Nerokas | +254 706 246 248 / [store.nerokas.co.ke](https://store.nerokas.co.ke) | Arduino, DFPlayer, RC522, battery, speaker, magnets |
| Pixel Electric | [pixelelectric.com](https://www.pixelelectric.com/) | TP4056 (KSh 80), NFC stickers (KSh 50), PN532 (KSh 1,000) |
| Ktechnics | +254 712 799 123 / [ktechnics.com](https://ktechnics.com) | Backup for all components |

---
---

# V2 — Production Build (AliExpress Bulk, 10+ Units)

> **Architecture: ESP32-C3 + PN532 + DFPlayer Mini**
> No Arduino. No physical switch. PN532 IRQ wakes ESP32 from deep sleep.
> Placing figurine = ON. Removing figurine = OFF. Just like Toniebox.
> Updated: 2026-03-12

---

## Why PN532, not RC522

| | RC522 | PN532 |
|---|---|---|
| Tag detection | MCU must actively poll | **Autonomous polling + IRQ pin** |
| Wake from sleep | Cannot | **IRQ wakes ESP32 from deep sleep** |
| Power switch needed | Yes (always draining) | **No — figurine IS the switch** |
| Standby power | ~10mA (MCU awake polling) | **~100μA (PN532 polling alone)** |
| Price (AliExpress) | $0.40 | $1.20 |
| Tag support | MIFARE only | MIFARE, NTAG, FeliCa, ISO14443A/B |

PN532 costs $0.80 more but **eliminates the slide switch** and enables **days of standby** vs hours.

---

## V2 TOYBOX BOM (AliExpress bulk ×10)

| # | Part | Spec | USD/unit | KSh/unit |
|---|------|------|----------|----------|
| 1 | ESP32-C3 Super Mini | RISC-V 160MHz, WiFi, BLE, USB-C | 1.20 | 156 |
| 2 | DFPlayer Mini | MP3 decoder + 3W amp + SD slot | 0.85 | 111 |
| 3 | **PN532 NFC Module** | 13.56MHz, I2C/SPI/HSU, **IRQ pin** | 1.20 | 156 |
| 4 | TP4056 USB-C | Li-ion charger + protection | 0.20 | 26 |
| 5 | 18650 Battery | 3.7V 2600mAh | 0.80 | 104 |
| 6 | Speaker 40mm | 3W 4Ω | 0.60 | 78 |
| 7 | MicroSD Card | 4GB | 1.00 | 130 |
| 8 | Steel Washer | M10 fender, ~35mm OD | 0.04 | 5 |
| 9 | 1K Resistor + wires | DFPlayer RX divider + hookup | 0.15 | 20 |
| 10 | PLA — Casing | ~80g (optimized) | — | 224 |
| | **TOYBOX TOTAL** | | **$6.04** | **1,010** |

### What's eliminated vs V1
- ~~Arduino Pro Mini~~ → ESP32-C3 (cheaper, USB-C built in, WiFi)
- ~~RC522~~ → PN532 (IRQ wake, no switch needed)
- ~~Slide switch~~ → eliminated (figurine = switch)
- ~~FTDI programmer~~ → eliminated (ESP32-C3 has USB-C)

---

## V2 PER FIGURINE (×3)

| # | Part | Spec | USD/unit | KSh/unit |
|---|------|------|----------|----------|
| 11 | NFC Sticker | S50/NTAG213 25mm (from 100-pack) | 0.10 | 13 |
| 12 | Neodymium Magnet | 20x3mm N35 disc (from 50-pack) | 0.12 | 16 |
| 13 | PLA — Figurine | ~12g hollow body | — | 34 |
| 14 | PLA — Base | ~8g cup + lid | — | 22 |
| 15 | Felt Pad | 38mm self-adhesive | 0.04 | 5 |
| 16 | Hot Glue | Bond figurine to lid | — | 5 |
| | **PER FIGURINE** | | **$0.26** | **95** |
| | **×3 FIGURINES** | | **$0.78** | **285** |

---

## V2 TOTAL — 1 COMPLETE SET

```
Toybox:          KSh 1,010
3 Figurines:     KSh   285
────────────────────────────
TOTAL:           KSh 1,295 per set
```

---

## V2 PRICING

| Package | Cost | Sell | Profit | Margin |
|---------|------|------|--------|--------|
| Toybox + 3 figurines | 1,295 | 4,500 | 3,205 | 71% |
| Extra figurine (add-on) | 95 | 500 | 405 | 81% |
| 3-figurine pack (add-on) | 285 | 1,200 | 915 | 76% |

---

## V2 AliExpress ORDER LIST (10 units)

Place this order NOW — arrives in 3-4 weeks while you build V1 prototype with local parts.

| Item | Qty | Search term | Est. total USD |
|------|-----|-------------|---------------|
| ESP32-C3 Super Mini | 10 | "ESP32-C3 Super Mini USB-C" | $12.00 |
| DFPlayer Mini | 10 | "DFPlayer Mini MP3 TF-16P" | $8.50 |
| PN532 NFC Module | 10 | "PN532 NFC RFID module V3" | $12.00 |
| TP4056 USB-C | 10 | "TP4056 USB-C charger protection" | $2.00 |
| 18650 Battery | 10 | "18650 2600mAh battery" | $8.00 |
| Speaker 40mm 3W 4Ω | 10 | "40mm 3W 4ohm speaker" | $6.00 |
| MicroSD 4GB | 10 | "micro SD 4GB class 4" | $10.00 |
| NFC Stickers S50 25mm | 100 | "S50 NFC sticker 25mm 13.56MHz" | $5.00 |
| Neodymium magnets 20x3mm | 50 | "20x3mm neodymium disc magnet N35" | $6.00 |
| Felt pads 38mm | 30 | "38mm adhesive felt pads" | $2.00 |
| 1K resistors | 100 | "1K ohm resistor 1/4W" | $0.50 |
| **TOTAL ORDER** | | | **$72.00 (~KSh 9,360)** |

**Per unit: KSh 936 for parts + KSh 280 PLA + KSh 79 figurine PLA = KSh 1,295**

---

## V2 WIRING (6 wires between 3 modules)

```
ESP32-C3 Super Mini
  │
  ├── I2C ──→ PN532 NFC Module
  │   SDA (GPIO6)  → SDA
  │   SCL (GPIO7)  → SCL
  │   GPIO4        → IRQ (wake from deep sleep)
  │   3V3          → VCC
  │   GND          → GND
  │
  ├── UART ──→ DFPlayer Mini
  │   TX (GPIO21)  → RX (through 1K resistor)
  │   RX (GPIO20)  → TX
  │   GND          → GND
  │
  └── Power
      VIN ←── TP4056 OUT+ ←── 18650+ (via switch pad or direct)
      GND ←── TP4056 OUT- ←── 18650-

DFPlayer Mini
  SPK1 ──→ Speaker +
  SPK2 ──→ Speaker -
  VCC  ←── TP4056 OUT+ (or 5V from USB)
  GND  ←── GND
```

---

## V2 FIRMWARE BEHAVIOR

```
BOOT:
  ESP32 wakes from deep sleep (triggered by PN532 IRQ)
  Initialize I2C, read tag UID from PN532
  Map UID → folder number (stored in EEPROM/NVS)
  Send serial command to DFPlayer: play folder XX

PLAYING:
  Poll PN532 every 500ms — is tag still present?
  If tag removed → stop playback → deep sleep
  If tag changed → switch to new folder

DEEP SLEEP:
  ESP32 enters deep sleep (~10μA)
  PN532 continues autonomous polling (~100μA)
  Total standby: ~110μA → 18650 (2600mAh) lasts ~2.7 years standby
```

---

## ROADMAP

| Phase | Architecture | Cost/set | Timeline |
|-------|-------------|----------|----------|
| **V1 — Prototype** | Arduino Pro Mini + RC522 + DFPlayer (local parts) | KSh 3,688 | This week |
| **V2 — Production** | ESP32-C3 + PN532 + DFPlayer (AliExpress bulk) | KSh 1,295 | +4 weeks |
| **V3 — Scale** | Custom PCB (ESP32-C3 + MFRC522 + PAM8403) | ~KSh 500 | +8 weeks |
