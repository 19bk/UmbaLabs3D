# Tiki Tales — Figurine Interior Design & Safety Spec

## Cross-Section Anatomy

```
        ┌─────────┐
        │  HEAD   │  ← Solid PLA, chunky, no thin features
        │ (ears/  │     All features > 10mm thick
        │  horns) │
        ├─────────┤
        │         │
        │  BODY   │  ← 80-100% infill for weight + strength
        │         │     NFC tag can go here (~20mm above base)
        │         │     OR in the base (our RC522 reads close)
        ├─────────┤
        │  BASE   │  ← 40mm diameter flat disc, 5mm thick
        │ ┌─────┐ │
        │ │ NFC │ │  ← NTAG213 sticker (25mm dia) in recessed pocket
        │ └─────┘ │
        │ ┌─────┐ │
        │ │MAGNT│ │  ← 10x3mm neodymium magnet (optional, for grip)
        │ └─────┘ │
        │ ┌─────┐ │
        │ │COIN │ │  ← M8 washer or coin for weight (optional)
        │ └─────┘ │
        │ [FELT]  │  ← Adhesive felt pad covers the bottom
        └─────────┘
```

## Base Design (All Figurines Share This)

The base is the universal platform — every figurine gets the same 40mm base with cavities for NFC + weight.

### Base Cavity Layout (bottom view)

```
     ┌──────────────────────┐
     │                      │
     │    ┌──────────┐      │
     │    │ NFC TAG  │      │  ← 26mm dia, 0.8mm deep pocket
     │    │ (25mm ∅) │      │     NTAG213 sticker sits here
     │    └──────────┘      │
     │                      │
     │      ○ MAGNET        │  ← 10mm dia, 3.5mm deep hole
     │      (10x3mm)        │     Neodymium disc magnet press-fits
     │                      │
     │    ○○ WEIGHT         │  ← 16mm dia, 2mm deep pocket
     │    (coins/washers)   │     M8 washer or KSh 1 coin
     │                      │
     └──────────────────────┘
     [───── 40mm ─────]
```

### Base Dimensions

| Feature | Diameter | Depth | Purpose |
|---------|----------|-------|---------|
| Base disc | 40mm | 5mm total | Flat bottom for stability |
| NFC pocket | 26mm | 0.8mm | Houses NTAG213 sticker |
| Magnet hole | 10.2mm | 3.2mm | Press-fit for 10x3mm neodymium |
| Weight pocket | 16mm | 2mm | Coins, washers, or steel balls |
| Felt pad recess | 38mm | 0.5mm | Adhesive felt covers everything |

### Print-Pause-Insert Method (Recommended)

1. **Print base normally** up to z = 1.5mm (felt recess + bottom skin)
2. **Pause print** at z = 1.5mm
3. **Insert**: NFC sticker (face down), magnet, coin/washer
4. **Resume print** — top layers seal everything inside
5. **Apply felt pad** on bottom after print completes

This eliminates the need for glue or a two-part base.

---

## NFC Tag Placement

### Why Base Placement Works for Us

The official Toniebox places the chip at ~20mm height because their reader (ISO 15693, 13.56MHz) has a ~50mm read range and the tag needs to be in the field sweet spot.

**Our setup is different:**
- **RC522 reads ISO 14443** (NTAG213) — shorter range (~30mm max)
- **RC522 sits directly under the lid** top wall (1.6mm PLA gap)
- **Figurine base sits directly on the lid**
- **Total distance: NFC sticker → RC522 antenna = ~7mm** (1.6mm lid + 5mm base)

This is well within the RC522's reliable read range. **Base placement works perfectly.**

### If Read Distance Is Borderline

Move the NFC sticker higher — print a small pocket at ~15-20mm height inside the figurine body instead. But test base placement first — it's simpler.

---

## Weight Strategy

### Why Add Weight

- Figurines feel **cheap and hollow** if too light
- Kids expect toys to have **heft** (subconscious quality signal)
- Weight helps figurines **stay seated** on the base unit
- Target: **25-40g total** per figurine (feels substantial in a toddler's hand)

### Weight Budget

| Component | Weight |
|-----------|--------|
| PLA body (80% infill, 60-80mm tall) | 15-25g |
| 10x3mm neodymium magnet | 1.8g |
| M8 washer (stainless) | 3-4g |
| NTAG213 sticker | <1g |
| **Total** | **~22-32g** |

If more weight needed, stack 2 washers or use a larger coin (KSh 5 coin ≈ 5g, 20mm dia).

---

## Safety: Non-Choking Hazard Design

### The Rule (16 CFR 1501 / CPSIA)

> If an object fits entirely inside a cylinder **31.7mm diameter × 57.15mm deep**, it is a choking hazard for children under 3.

**Quick home test**: If it fits through a toilet paper roll inner tube (~32mm), it's too small.

### Our Figurines Pass ✅

- **Minimum dimension**: 40mm (base diameter) — exceeds 31.7mm
- **Height**: 60-80mm — exceeds 57.15mm
- **No detachable small parts** — printed as one solid piece

### Design Rules for Safety

| Rule | Implementation |
|------|---------------|
| **No thin features** | All limbs, ears, tails ≥ 10mm thick |
| **No detachable parts** | One-piece print, no assemblies |
| **No sharp edges** | All edges filleted ≥ 1mm radius |
| **High infill** | 80-100% — prevents brittle fracture |
| **Drop test** | Must survive 1m drop onto hard floor without breaking |
| **Bite test** | No pieces should break off when bitten by a child |
| **Material** | PLA or PETG from reputable brands (eSUN, Polymaker) |
| **No toxic colorants** | Use natural/white PLA, paint with non-toxic acrylic if needed |
| **Sealed internals** | NFC tag and magnet fully encapsulated — can't be accessed |
| **No magnets externally** | Magnet is inside sealed base — child can't extract it |
| **Min overall size** | Every dimension > 35mm (exceeds 31.7mm test cylinder) |

### Post-Processing for Safety

1. **Sand any sharp layer lines** — especially on edges and corners
2. **Seal with non-toxic clear coat** (water-based polyurethane) if kids will mouth it
3. **Apply felt pad** on bottom — soft touch, covers any base roughness
4. **Test**: Twist ears/tail hard. Drop on tile. Let a toddler play with it for 10 min. Inspect for cracks.

---

## Cute Figurine Sources (Free STLs to Adapt)

### Best Match: Toby3D "Cute Mini Animals" (Printables) ⭐

Chunky kawaii style, flat bases, print without supports, perfect for scaling to 60-80mm:
- [Edition 1](https://www.printables.com/model/1369232-cute-mini-animals) — turtle, fox, whale, koala
- [Edition 2](https://www.printables.com/model/1385342-cute-mini-animals-edition-2)
- [Edition 3](https://www.printables.com/model/1385880-cute-mini-animals-edition-3)
- [Edition 4](https://www.printables.com/model/1401774-cute-mini-animals-edition-4)
- [Cute Mini Dinosaurs](https://www.printables.com/model/1401795-cute-mini-dinosaurs)
- [Cute Mini Dogs](https://www.printables.com/model/1391046-cute-mini-dogs-many-breeds)

### Good Match: GlennovitS "Minimals" (Printables)

Safari animals, tiny but scalable:
- [Safari Pack](https://www.printables.com/model/882023-minimals-safari-pack-cute-tiny-animal-figures-elep) — elephant, lion, monkey, crocodile
- [Savanna Pack](https://www.printables.com/model/912729-minimals-savanna-pack-zebra-giraffe-cheetah-rhino) — zebra, giraffe, cheetah

### Paid Options (Cults3D)

If you want super polished designs:
- [Kawaii Cat](https://cults3d.com/en/3d-model/home/kawaii-cat-stl-cute-3d-printable-cartoon-kitty-figurine-for-cat-lovers)
- [Cute Fox](https://cults3d.com/en/3d-model/art/cute-fox-stl-file-3d-printable-kawaii-animal-figurine-for-desk-decor-or-kids)
- [Chibi Lion](https://cults3d.com/en/3d-model/art/cute-chibi-lion-stl-sitting-cartoon-lion-3d-model-for-printing-kawaii-animal/similar-designs)
- [Baby Giraffe](https://cults3d.com/en/3d-model/art/adorable-baby-giraffe-3d-printed-figurine-stl-kawaii-jungle-animal-model-for-k)

### TonUINO NFC Base Pucks (Reference)

- [Tonie Base with magnet (Printables)](https://www.printables.com/model/787452-custom-tonie-tag-with-20x3mm-magnet-for-toniebox)
- [Parameterized NFC Base (MakerWorld)](https://makerworld.com/en/models/200466-nfc-case-with-magnet-tonie-base-parameterized)

### Adaptation Workflow

1. Download STL from Printables/Cults3D
2. Import into Blender or TinkerCAD
3. Scale to 60-80mm tall
4. Boolean-subtract: flatten the bottom to create a 40mm flat base
5. Add cavities: NFC pocket (26mm dia, 0.8mm deep), magnet hole (10.2mm, 3.2mm deep)
6. Add felt recess (38mm dia, 0.5mm deep) on very bottom
7. Export as STL
8. Print with 80-100% infill, 0.2mm layers, no supports

---

## Shopping List (Per Figurine)

| Item | Qty | Cost (KSh) | Source |
|------|-----|-----------|--------|
| NTAG213 NFC sticker (25mm) | 1 | 50 | Pixel Electric |
| 10x3mm neodymium magnet | 1 | 20 | Nerokas / AliExpress |
| M8 stainless washer | 1 | 5 | Hardware store |
| PLA filament (~20g) | 1 | 56 | Existing spool |
| Adhesive felt pad (40mm) | 1 | 10 | Craft store |
| **Total per figurine** | | **~141** | |
| **Sell price** | | **500** | |
| **Margin** | | **72%** | |
