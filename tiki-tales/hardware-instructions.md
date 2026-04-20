# Tiki Tales — Hardware Instructions for EE

*Date: 2026-03-08*

---

## What We're Building

A kids' audio storytelling device. Kid places a 3D-printed figurine on a speaker base → NFC chip in figurine is read → plays an audio story from SD card. Like a Toniebox but offline, no app, no WiFi, made in Kenya.

---

## The Shortcut

**We're reusing the KidConnect v2 PCB.** The ATmega328P, DFPlayer Mini, BQ24075 charger, 3.3V regulator, USB-C — it's all there. We just need to:

1. Wire a PN532 NFC reader to the SPI pins
2. Write new firmware (~60 lines)
3. That's it

---

## Step-by-Step

### Step 1: Prepare KidConnect v2 PCB

Take a KidConnect v2 board. **Do NOT populate these components** (leave empty):

| Skip These | Why |
|------------|-----|
| U5-U12 (8× TCRT5000 sensors) | Replaced by PN532 |
| U3, U4 (2× LM339 comparators) | Not needed |
| R18-R25 (IR LED resistors) | Not needed |
| D2-D9 (threshold diodes) | Not needed |

**DO populate everything else** — ATmega328P (U1), DFPlayer (U2), BQ24075 (U13), 3.3V regulator (U15), USB-C (J1), crystal, caps, all power components.

### Step 2: Wire PN532 NFC Module (7 wires)

Connect the PN532 module to the KidConnect PCB's SPI pins:

```
KidConnect PCB                    PN532 Module
──────────────                    ────────────
Pin 11 (MOSI / PB3) ───────────→ MOSI
Pin 12 (MISO / PB4) ───────────→ MISO
Pin 13 (SCK  / PB5) ───────────→ SCK
Pin 10 (SS   / PB2) ───────────→ SS
Pin 4  (D2   / PD2) ───────────→ IRQ        ← THIS IS CRITICAL (wake from sleep)
3.3V                 ───────────→ VCC
GND                  ───────────→ GND
```

**Important:**
- PN532 must run on **3.3V** (not 5V)
- Set PN532 DIP switches to **SPI mode** (check module — usually switch 1=OFF, switch 2=ON)
- IRQ wire goes to D2 (INT0) — this is what wakes the ATmega from deep sleep when a figurine is placed

### Step 3: Add Battery Level Indicator (optional for MVP, nice to have)

**RGB LED** (common cathode):

```
ATmega Pin D3 ──[220Ω]──→ RED   pin of RGB LED
ATmega Pin D5 ──[220Ω]──→ GREEN pin of RGB LED
ATmega Pin D6 ──[220Ω]──→ BLUE  pin of RGB LED
                          GND   pin of RGB LED → GND
```

**Voltage divider** for battery sensing:

```
Battery+ ──[100KΩ]──┬──[100KΩ]── GND
                     │
                     └──→ ATmega Pin A0
```

This lets firmware read battery voltage and flash the LED green/orange/red for 2 seconds when a figurine is placed.

### Step 4: Connect Speaker + Battery

- **Speaker** (40mm, 8Ω 2W): plug into J11 (speaker connector on KidConnect PCB)
- **Battery** (3.7V 2000mAh Li-Po, JST-PH): plug into J10 (battery connector)
- Both connectors already exist on the KidConnect PCB

### Step 5: Verify Hardware Before Firmware

Power on (connect battery or USB-C) and check:

- [ ] 3.3V on regulator output
- [ ] ATmega328P alive (can upload blink sketch via USB)
- [ ] PN532 responds on SPI (run I2C/SPI scanner sketch)
- [ ] DFPlayer plays test MP3 from SD card (send serial play command)
- [ ] Battery charges via USB-C (BQ24075 STAT LEDs)

---

## Firmware Spec

### Overview

```
Power on → init PN532 + DFPlayer → attach INT0 interrupt → POWER_DOWN sleep

[PN532 IRQ fires — figurine placed on base]
  → Wake from sleep
  → Read NTAG213 UID via SPI
  → Flash RGB LED for 2 sec (green >3.8V / orange 3.5-3.8V / red <3.5V)
  → Lookup UID in mapping array (PROGMEM)
  → Send play command to DFPlayer (serial)

[PN532 reads no tag — figurine removed]
  → Send pause command to DFPlayer
  → Start 10-minute inactivity timer

[10 min timeout — no figurine]
  → Enter POWER_DOWN sleep (waiting for next IRQ)

[Different figurine placed]
  → Stop current → play new track

[Same figurine re-placed]
  → Resume playback
```

### Libraries Needed

- **PN532 SPI**: [Adafruit-PN532](https://github.com/adafruit/Adafruit-PN532) (SPI mode)
- **DFPlayer**: [DFRobotDFPlayerMini](https://github.com/DFRobot/DFRobotDFPlayerMini) — same library as KidConnect v2
- **Sleep**: `<avr/sleep.h>` + `<avr/interrupt.h>` (built-in AVR)

### NFC-to-Audio Mapping

Store in PROGMEM (ATmega has 32KB flash, mapping takes ~100 bytes):

```cpp
struct FigurineMap {
  uint32_t uid;
  uint8_t folder;   // DFPlayer folder number
  uint8_t track;    // Track number in folder
};

const FigurineMap figurines[] PROGMEM = {
  {0xA1B2C3D4, 1, 1},  // Hare → folder 01, track 001
  {0xE5F6A7B8, 2, 1},  // Lion → folder 02, track 001
  {0x11223344, 3, 1},  // Tortoise → folder 03, track 001
  {0x55667788, 4, 1},  // Mama/Sleepy → folder 04, track 001
  {0x99AABBCC, 5, 0},  // Creative → folder 05, play all files
};
```

The actual UIDs get filled in after you scan each NFC sticker. Each sticker has a unique factory-programmed UID.

### SD Card Folder Structure (for DFPlayer)

```
SD Card Root/
├── 01/           ← Hare stories
│   ├── 001.mp3   ← "Hare and the Well"
│   ├── 002.mp3   ← "Hare and Hyena" (add later)
│   └── ...
├── 02/           ← Lion stories
│   ├── 001.mp3
│   └── ...
├── 03/           ← Tortoise stories
│   ├── 001.mp3
│   └── ...
├── 04/           ← Mama/Sleepy (lullabies)
│   ├── 001.mp3
│   └── ...
└── 05/           ← Creative (parent drops MP3s here)
    ├── 001.mp3
    └── ...
```

DFPlayer uses numbered folders (01-99) and numbered tracks (001-255). Same convention as KidConnect.

### Sleep/Wake Detail

```cpp
#include <avr/sleep.h>
#include <avr/interrupt.h>

#define PN532_IRQ_PIN 2  // INT0

volatile bool figurineDetected = false;

ISR(INT0_vect) {
  figurineDetected = true;
}

void enterSleep() {
  set_sleep_mode(SLEEP_MODE_PWR_DOWN);
  attachInterrupt(digitalPinToInterrupt(PN532_IRQ_PIN), wakeISR, LOW);
  sleep_enable();
  sleep_cpu();
  // ...wakes here when IRQ fires...
  sleep_disable();
}
```

**Power consumption in sleep:**
- ATmega328P POWER_DOWN: ~0.1μA
- PN532 standby (tag polling): ~100μA
- Total: <1mA → 2000mAh battery lasts months idle

### Volume Control (for later)

Not needed for MVP. Options for later:
- Two buttons (vol up / vol down) — simplest
- Capacitive touch pads (like Tonies ears) — fancier
- Rotary encoder (like Yoto dial) — overkill for now

---

## Parts I'm Ordering (You Don't Need to Buy These)

| Part | Qty | Source |
|------|-----|--------|
| PN532 NFC module | 1 | Pixel Electric |
| NTAG213 NFC stickers | 10 | Pixel Electric |
| RGB LED (common cathode) | 2 | Nerokas |
| 220Ω resistors | 6 | Nerokas |
| 100KΩ resistors | 4 | Nerokas |
| 40mm 8Ω 2W speaker | 1 | Nerokas |
| 3.7V 2000mAh Li-Po | 1 | Nerokas (or reuse KidConnect spare) |
| MicroSD 16GB | 1 | Jumia (or reuse) |

---

## What I'm Doing (Your Side)

- Designing + 3D printing the speaker base enclosure
- Designing + 3D printing 5 figurines (Hare, Lion, Tortoise, Mama, Creative)
- Sticking NFC tags on figurine bases
- Recording audio stories + lullabies
- Loading SD card with MP3 files in correct folder structure

---

## Timeline

| Week | You (EE) | Me (3D / Audio) |
|------|----------|-----------------|
| **1** | Wire PN532 to KidConnect PCB. Flash test firmware (read NFC UID → serial). | Design + print base enclosure. Buy parts from Pixel Electric. |
| **2** | Write full firmware (NFC → DFPlayer, sleep/wake, battery LED). | Print 5 figurines. Record 3 stories + lullabies. Load SD card. |
| **3** | Bug fixes. Help with kid testing. | Test with 3-5 kids. Film reactions. Bedtime test with parent. |
| **4** | Add Swahili language switch. Polish firmware. | Record Swahili stories. Second round of testing. |

---

## Success Criteria

After Week 3, we should be able to answer YES to all of these:

- [ ] Figurine placed → story plays within 2 seconds
- [ ] Figurine removed → audio pauses
- [ ] Different figurine → different story
- [ ] Device sleeps after 10 min idle
- [ ] Battery lasts 4+ hours of continuous playback
- [ ] A 3-year-old can use it without any instruction
- [ ] Creative figurine plays parent-loaded MP3s
- [ ] Battery LED flashes correct color

---

## Questions for You

1. Do we have a spare KidConnect v2 PCB ready to use, or do we need to order/assemble one?
2. Is the KidConnect DFPlayer firmware in a git repo I can reference for the serial protocol code?
3. Do you have a spare Li-Po battery + speaker from KidConnect, or should I buy new?
