# Tiki Tales — Competitor Hardware & UX Analysis

*Date: 2026-03-08*

---

## How Tonies Works (Power & Activation)

**No power switch at all.** The Toniebox uses an accelerometer + tilt detection:

1. **Ears are the controls** — squeeze one ear for volume up, the other for volume down. Tap a side to skip forward/back.
2. **Placing a figurine on top activates playback** — the NFC reader detects the Tonie, wakes the device, starts playing.
3. **Removing the figurine pauses/stops** — if you take the Tonie off, it pauses. After a timeout, it sleeps.
4. **No buttons, no switches** — the whole cube is soft-padded fabric. A toddler can't break anything.
5. **Sleep timeout** — after ~10 minutes of inactivity (no figurine, no interaction), it enters deep sleep. You "wake" it by placing a figurine.
6. **Charging** — sits on a magnetic charging dock. Always trickle-charging when docked.

**Key insight**: Tonies eliminated the power switch entirely. The figurine IS the switch. This is why 12-month-olds can use it — zero buttons to understand.

---

## How Yoto Works (Power & Activation)

**Has a physical power button**, but it's minimal:

1. **Single button press** powers on/off (top of device)
2. **Inserting a card starts playback** — push a card into the slot, audio plays automatically
3. **Removing the card stops playback**
4. **Dial on top** — twist for volume, press to pause/play
5. **Pixel display** — shows artwork for each card
6. **Sleep timer** — parents can set via app (critical for bedtime use)
7. **USB-C charging**

**Key insight**: Yoto targets ages 3+, so a button is fine. But even Yoto made the card the primary trigger, not the button.

---

## What This Means for Tiki Tales

Both devices share the same principle: **the content object (figurine/card) activates playback**. The NFC read event is effectively the "on switch."

### Option 1: No Switch (Tonies Model) — CHOSEN

- NFC figurine placement wakes the ATmega328P from sleep
- Remove figurine → pause → sleep timeout → deep sleep (~10μA)
- **Pros**: Toddler-proof, elegant, fewer failure points, ages 1+
- **Cons**: Need to implement proper ATmega328P sleep/wake via interrupt (PN532 has an IRQ pin for this)
- **How it works technically**: PN532 IRQ pin triggers an external interrupt on the ATmega328P, waking it from `SLEEP_MODE_PWR_DOWN`

### Option 2: Slide Switch (Simple) — REJECTED

- SPDT slide switch between battery and circuit
- **Pros**: Dead simple, zero standby drain, cheapest (~KSh 10-20)
- **Cons**: Kids forget to turn off → dead battery. Parents annoyed. Not toddler-friendly.

### Option 3: Soft Latch Power Button — REJECTED

- Momentary push button with a soft-latch circuit (e.g., using a MOSFET + flip-flop)
- Press to turn on, long-press to turn off
- **Pros**: Clean UX, familiar
- **Cons**: More components, kids might not understand long-press, adds ~KSh 50-100

---

## Switch Comparison

| Factor | No Switch | Slide Switch | Soft Latch Button |
|--------|-----------|-------------|-------------------|
| Toddler-friendly | Yes (1+) | No | Maybe (3+) |
| Battery life | Great (sleep mode ~10μA) | Best (0μA when off) | Good |
| Parts cost | KSh 0 | KSh 10-20 | KSh 50-100 |
| Failure points | None | Switch wears out | More components |
| Parent experience | "Just works" | "Is it on? Why dead?" | "How do I turn off?" |

---

## Technical Implementation (No-Switch Design)

The PN532 module has an **IRQ pin** that goes LOW when a tag is detected. Wire that to ATmega328P INT0 or INT1 for free wake-from-sleep.

### Firmware Flow
```
Power on → init → sleep
  ↓ (figurine placed, IRQ fires)
Wake → read NFC UID → map to SD folder → DFPlayer play
  ↓ (figurine removed or track ends)
Wait 10min → sleep
```

### Power Budget
- ATmega328P in `POWER_DOWN` mode: ~0.1μA (datasheet)
- PN532 in standby/tag detection: ~100μA
- **Total standby draw**: <1mA → 2000mAh battery lasts months in standby
- Optional: internal slide switch as "shipping lock" (prevents drain in transit), not user-facing

---

## Open-Source Reference Designs (STLs)

### TonUINO (Best match — Arduino + DFPlayer Mini + RFID)

| Design | Platform | Link |
|--------|----------|------|
| Case for Tonuino (screwless) | Printables | [printables.com/model/98130](https://www.printables.com/model/98130-case-for-tonuino-the-toniebox-replica) |
| TonUINO Box Compact (97×75×72mm) | Cults3D | [cults3d.com/tonuino-box](https://cults3d.com/en/3d-model/gadget/tonuino-box-kompaktes-gehaeuse) |
| TonUINO 999 Housing | Printables | [printables.com/model/341908](https://www.printables.com/model/341908-tonuino-999-housing-for-the-rfid-music-box-tonuino) |
| Walkuino (portable) | Printables | [printables.com/model/333993](https://www.printables.com/model/333993-walkuino-tonuino-to-go) |
| TonUINO with battery pack | Thingiverse | [thingiverse.com/thing:4083500](https://www.thingiverse.com/thing:4083500) |
| TonUINO AiO+ Music Box | Printables | [printables.com/model/478010](https://www.printables.com/model/478010-tonuino-aio-music-box) |

### ESP32-Based NFC Players

| Design | Platform | Link |
|--------|----------|------|
| NFC Jukebox (ESP32 + DFPlayer + RC522) | MakerWorld | [makerworld.com/models/1316944](https://makerworld.com/en/models/1316944-nfc-jukebox-with-esp32-dfplayer-mini-and-rc522) |
| Ultimate Kids Musicbox | Instructables | [instructables.com](https://www.instructables.com/Ultimate-Kids-Musicbox-ESP32-Based/) |

### Complete Open-Source Projects (hardware + firmware + STLs)

| Project | Description | Link |
|---------|-------------|------|
| **Marta Musik Maschine** | KiCad PCB + STLs + code, RFID figures with magnets | [github.com/martamusikmaschine](https://github.com/martamusikmaschine/mmm) |
| **Phoniebox** | Raspberry Pi + RFID, huge community | [github.com/MiczFlor/RPi-Jukebox-RFID](https://github.com/MiczFlor/RPi-Jukebox-RFID) |
| **MuPiBox** | RPi + touchscreen + optional RFID | [github.com/splitti/MuPiBox](https://github.com/splitti/MuPiBox) |

### Browse More

- [Printables — "tonuino" tag](https://www.printables.com/tag/tonuino)
- [Yeggi — Toniebox search](https://www.yeggi.com/q/toniebox/)
- [Cults3D — Toniebox free models](https://cults3d.com/en/tags/toniebox?only_free=true)

### Key Takeaway

**TonUINO is Tiki Tales' closest cousin** — same Arduino + DFPlayer Mini + RFID stack. Their enclosure designs are directly adaptable. Main difference: they use RC522 (MIFARE), we chose PN532 (supports both MIFARE and NTAG213 — a superset). **Marta Musik Maschine** has magnetic snap-on figurines with RFID inside — essentially our figurine concept with KiCad PCB files for future reference.

---

## WiFi Setup — How Screenless Devices Configure WiFi

### Tonies — Phone App + Bluetooth

1. Download the **Tonies app** (iOS/Android)
2. Create a **Tonies account** (email + password)
3. Turn on Toniebox — enters pairing mode (LED flashes blue)
4. App finds the Toniebox via **Bluetooth Low Energy (BLE)**
5. App sends WiFi credentials (SSID + password) to the Toniebox over BLE
6. Toniebox connects to WiFi, confirms in app, LED turns green

**Parent complaints (from Reddit):**
- *"Took 45 minutes to set up"*
- *"WiFi setup failed 3 times before it worked"*
- *"Why does a children's toy need my WiFi?"*
- *"Grandma bought one, couldn't set it up without help"*

### Yoto — Phone App + Temporary Hotspot

1. Download **Yoto app**
2. Create account
3. Yoto Player broadcasts its own **temporary WiFi hotspot** (like a printer setup)
4. Phone connects to Yoto's hotspot
5. App sends home WiFi credentials to the Player
6. Player switches to home WiFi, app reconnects

Also supports manual setup: hold button combo → pixel display shows WiFi icon → enter credentials via app.

### Why They Need WiFi

| Reason | Tonies | Yoto |
|--------|--------|------|
| Download audio for new figurines/cards | Yes | Yes |
| Sync custom content (Creative Tonie / MYO cards) | Yes | Yes |
| Firmware updates | Yes | Yes |
| Usage analytics / parental controls | Yes | Yes |
| Subscription content | No | Yes (Yoto Club) |
| **Required for basic playback?** | **No** (after first sync) | **No** (after first sync) |

The irony: both devices work **fully offline after setup**. WiFi is only needed to load new content. But that first-time setup is a friction point every buyer hits.

---

## Why Tiki Tales Skips WiFi/BLE/App Entirely

### Cost Savings

| Component | Tonies/Yoto | Tiki Tales |
|-----------|------------|------------|
| WiFi module | ~$3-5 | **KSh 0** |
| BLE module | ~$2-3 | **KSh 0** |
| App development | iOS + Android (~$50K+) | **KSh 0** |
| Cloud servers | AWS/GCP (monthly cost) | **KSh 0** |
| User accounts | Required | **Not needed** |

### UX Comparison

| | Tonies | Yoto | Tiki Tales |
|--|--------|------|------------|
| Setup time | 5-45 minutes | 5-15 minutes | **Zero** |
| Works out of the box | No (WiFi setup first) | No (WiFi setup first) | **Yes** |
| Works without internet | After first sync | After first sync | **Always** |
| Grandma can gift it | Needs tech help to set up | Needs tech help | **Open box → it plays** |

### Our "Setup" Experience
1. Open box
2. Figurine is already on top
3. It plays

No app download, no account creation, no WiFi password, no BLE pairing, no firmware update prompt. A grandma in rural Kisumu can gift this and the kid is listening to stories in 10 seconds.

### How We Deliver New Content Without WiFi

Audio lives on the **MicroSD card**, not in the cloud:

| Method | How It Works | Cost |
|--------|-------------|------|
| **Pre-loaded at purchase** | Each figurine comes with a download link (WhatsApp/SMS) for audio files, or bundled with SD card | Included |
| **Creative figurine** | Parent copies MP3s to SD card folder via phone/laptop USB | Free |
| **SD card packs** | Sell pre-loaded SD cards with themed story collections (swap and play) | KSh 500 |
| **Future: USB drag-and-drop** | Plug base into laptop via USB-C, mounts as drive, drag audio into folders | Free |

### Why This Is Actually Better for Kenya

- No reliable home WiFi needed — works in rural areas
- Parents already understand SD cards from phones — sideloading content is normal here
- No ongoing server costs — Tonies' cloud infrastructure is a recurring expense that scales with users. Our marginal cost per new user is zero.
- No DRM needed — original African folktales, not Disney. No licensing infrastructure required.
- Gift economy win — a gift that requires WiFi setup sits in a drawer. A gift that plays immediately = magic.
