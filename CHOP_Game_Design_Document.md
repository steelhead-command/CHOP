# CHOP
## Game Design Document
### Version 1.0

---

# Table of Contents

1. [Game Overview](#1-game-overview)
2. [Core Gameplay](#2-core-gameplay)
3. [Run Structure & Scoring](#3-run-structure--scoring)
4. [Economy System](#4-economy-system)
5. [Progression & Upgrades](#5-progression--upgrades)
6. [Mini-Activities](#6-mini-activities)
7. [Characters](#7-characters)
8. [Navigation & Screens](#8-navigation--screens)
9. [UI/UX Design](#9-uiux-design)
10. [Visual Art Direction](#10-visual-art-direction)
11. [Animation Direction](#11-animation-direction)
12. [Audio Direction](#12-audio-direction)
13. [iOS Features](#13-ios-features)
14. [Monetization](#14-monetization)
15. [Technical Specifications](#15-technical-specifications)
16. [Data Models](#16-data-models)

---

# 1. Game Overview

## Vision Statement

CHOP is a wood chopping game that combines the satisfying, easy-to-learn mechanics of Flappy Bird with the cozy homestead-building of idle games. It's a game of honest work and patient transformation — the antidote to infinite scroll.

**Core Experience:** Chop wood, burn wood, build your homestead.

## The Soul of the Game

Players should feel:
- **The satisfaction of honest work** — swinging an axe, watching wood pile up
- **Patient transformation** — feeding a fire, waiting for something to become something else
- **Harvest joy** — opening the furnace to find what you've made
- **Pride in building** — "I made this homestead"

## Platform

- **Primary:** iOS (iPhone)
- **Secondary:** iOS (iPad), potential Android expansion

## Target Audience

- Casual mobile gamers
- Fans of cozy games (Stardew Valley, Animal Crossing)
- Players who enjoy satisfying tactile mechanics
- Ages 10+ (broad appeal, realistic + cute aesthetic)

## Inspirations

| Game | What We Take |
|------|--------------|
| Flappy Bird | One input, infinite depth |
| Temple Run / Subway Surfers | Easy to learn, hard to master |
| Stardew Valley | Cozy aesthetic, satisfying loops |
| Skyrim / Witcher 3 | Weighty, satisfying chopping feel |
| Minecraft | Diamond axe concept, crafting progression |

---

# 2. Core Gameplay

## The Chopping Mechanic

### Gesture Detection

```
Valid Chop Gesture:
  Direction: DOWN (±30° tolerance)
  Minimum Distance: 80 screen points
  Maximum Duration: 400ms
  Start Zone: Upper 70% of screen
  End Zone: Lower 50% of screen
```

### Chop Quality

```
chop_power = base_power × speed_multiplier × accuracy_multiplier

Speed Multiplier:
  < 150ms: 1.2 (fast, decisive)
  150-300ms: 1.0 (normal)
  300-400ms: 0.9 (slow)

Accuracy Multiplier:
  ±10° of vertical: 1.1 (precise)
  ±20°: 1.0 (good)
  ±30°: 0.95 (acceptable)
```

## Wood Types

| Type | Color | Chops (Sharp) | Chops (Balanced) | Chops (Heavy) | Sell Price |
|------|-------|---------------|------------------|---------------|------------|
| Soft | Light (#A67C52) | 1 | 1 | 1-2 | 2 coins |
| Medium | Mid (#8B6914) | 1 | 1-2 | 2 | 4 coins |
| Hard | Dark (#5C4612) | 1-2 | 2 | 2 | 8 coins |

## Axe Types

### Sharp Axes
- Almost always one-chop
- Builds multiplier streaks easily
- Low durability (40-55 logs)
- **Identity:** "Streak hunter"

### Heavy Axes
- Usually two-chop (no penalty, just no multiplier bonus)
- Very durable (100-180 logs)
- **Identity:** "Survivor, distance runner"

### Balanced Axes
- Mixed behavior based on wood type
- Moderate durability (70-100 logs)
- **Identity:** "Adaptable, reads the wood"

### Diamond Axe (Premium - $2.99)
- Balanced stats
- **Never needs repair** (infinite durability)
- Minecraft-inspired crystalline appearance
- Ethical premium: convenience, not power

## Axe Tiers

| Tier | Sharp | Heavy | Balanced | Price |
|------|-------|-------|----------|-------|
| Basic | 40 dur | 100 dur | 70 dur | 150 coins |
| Mid (Keen/Forged/Tempered) | 45 dur | 120 dur | 80 dur | 400 coins |
| Premium (Razor/Ironclad/Forgemaster) | 50 dur | 150 dur | 90 dur | 800 coins |
| Master | 55 dur | 180 dur | 100 dur | 1,500 coins |

## The Knot Mechanic

Knots appear on medium and hard wood logs. They require 3 timed strikes to break.

### Strike Sequence

| Strike | Wait Period | Sweet Spot Window | Visual |
|--------|-------------|-------------------|--------|
| 1 | 400ms | 600ms | Crack appears, glows amber |
| 2 | 350ms | 500ms | Crack widens, pulses |
| 3 | 300ms | 450ms | Bright glow, tension peak |

### Outcomes

- **Success (3 timed hits):** Hard wood earned, multiplier maintained
- **Failure (miss timing window):** Log lost, +1 strike, multiplier resets

## The Strike System

- A **strike** is earned when a log takes 3+ chops
- 2-chop logs are fine (no penalty, just no multiplier bonus)
- **3 strikes = run ends**
- When you get a strike, screen flashes cartoon **"NOPE!"** popup
  - Rotating variations: "Nope!" / "Stubborn log!" / "That one fought back!"
  - Playful, not punishing

---

# 3. Run Structure & Scoring

## What is a "Run"?

A run is one continuous chopping session. Like a Flappy Bird attempt.

**Run ends when:**
- 3 strikes accumulated (logs that took 3+ chops)
- OR axe durability hits zero

## Difficulty Curve (Logarithmic)

| Phase | Logs | Knot Frequency | Feel |
|-------|------|----------------|------|
| Warm-Up | 1-15 | ~1 in 8 | Find your rhythm |
| Build | 16-40 | ~1 in 6 | Stakes rise |
| Push | 41-70 | ~1 in 4 | Every knot is a decision |
| Edge | 71+ | ~1 in 3 | Pure survival |

## Multiplier System

```
Consecutive one-chops:
  1 in a row: 1.0x
  2 in a row: 1.25x
  3 in a row: 1.5x
  4 in a row: 1.75x
  5+ in a row: 2.0x (cap)

Multiplier Behavior:
  - 2-chop log: Reset to 1.0x (no penalty, but streak breaks)
  - 3+ chop log (strike): Reset to 1.0x
  - Knot SUCCESS: MAINTAINS multiplier (skill rewarded)
  - Knot FAILURE: Reset to 1.0x
```

## Scoring

| Wood Type | Base Points | Knot Bonus |
|-----------|-------------|------------|
| Soft | 10 | — |
| Medium | 15 | — |
| Hard | 25 | +25 |

**Final Score = Sum of (base points × multiplier) for each log**

## Run End Moments

### Strike Death (3 strikes)
- Final "NOPE!" popup (largest, red)
- Gentle transition to results

### Axe Death (durability = 0)
- Axe head flies off, embeds in stump
- Feels honorable — the tool gave out, not you

### Results Screen Shows:
- Total logs chopped
- Wood breakdown (soft/medium/hard)
- Points earned
- Amber found (if any)
- High score comparison
- Repair options

---

# 4. Economy System

## Currency

| Currency | Earned By | Used For |
|----------|-----------|----------|
| **Coins** | Selling wood, selling products, selling smoked fish | Axes, repairs, plants, materials, furnace upgrades |
| **Amber** | Found in wood (~1 in 50 logs), purchased | Instant repairs, cosmetic axes, convenience |

## Wood Prices

| Wood Type | Sell Price |
|-----------|------------|
| Soft | 2 coins |
| Medium | 4 coins |
| Hard | 8 coins |

## Input Prices (Hardware Store)

| Item | Price |
|------|-------|
| Raw Fish | 40 coins |
| Nuts (10) | 30 coins |
| Berries (10) | 25 coins |
| Herbs (5) | 40 coins |
| Flour | 20 coins |
| Sugar | 25 coins |
| Maple Sap | 60 coins |
| Premium Meat | 100 coins |

## Furnace Products

| Product | Inputs | Time | Sell Price | Gathered Profit | Bought Profit |
|---------|--------|------|------------|-----------------|---------------|
| Roasted Nuts | 10 nuts | 15 min | 50 | 50 (100%) | 20 (40%) |
| Smoked Fish | 1 fish + hard wood | 30 min | 100 | 100 (100%) | 52 (52%) |
| Dried Herbs | 5 herbs | 20 min | 80 | 80 (100%) | 40 (50%) |
| Baked Bread | 1 flour | 25 min | 60 | 40 (67%) | 40 (67%) |
| Preserves | 10 berries + 1 sugar | 1 hr | 150 | 125 (83%) | 100 (67%) |
| Maple Syrup | 1 sap bucket | 2 hrs | 250 | 250 (100%) | 190 (76%) |
| Smoked Meats | 1 meat + 2 hard wood | 4 hrs | 400 | — | 284 (71%) |
| Charcoal | 10 any wood | 45 min | 50 | 30 (60%) | — |

**Key Insight:** Gatherers earn ~2x more per product. Buyers still profit.

## Repair Costs

| Damage Level | Cost (% of axe price) |
|--------------|-----------------------|
| Light (75%+) | 10% |
| Medium (50-75%) | 15% |
| Heavy (25-50%) | 25% |
| Critical (0-25%) | 35% |
| Broken (0%) | 50% |

**Amber Repair:** 25 amber = full instant repair (any axe)

## Player Progression

| Milestone | Daily Earnings | Can Afford |
|-----------|----------------|------------|
| Day 1 | 400-600 coins | First axe, some bait |
| Day 3 | 750-1,200/day | 2-3 axes, first plants |
| Week 1 | 1,100-1,800/day | Mid-tier axes, furnace upgrade |
| Month 1 | 1,900-3,200/day | Master axes, full orchard, Great Forge |

---

# 5. Progression & Upgrades

## Furnace Tiers

| Tier | Name | Cost | Unlock Requirement | Slots |
|------|------|------|-------------------|-------|
| 1 | Stone Hearth | Free | Start | 1 |
| 2 | Brick Furnace | 500 coins | 100 logs chopped | 2 |
| 3 | Iron-Clad | 1,500 + 5 charcoal | 500 logs | 2 |
| 4 | Great Forge | 4,000 + 20 charcoal | 2,000 logs | 3 |

## Plants (Saplings & Bushes)

| Plant | Price | Mature Time | Daily Yield | Daily Value | Break-even |
|-------|-------|-------------|-------------|-------------|------------|
| Blueberry Bush | 200 | 1 day | 15 berries | ~35 coins | 6 days |
| Hazel Sapling | 300 | 2 days | 10 nuts | ~50 coins | 6 days |
| Raspberry Bush | 350 | 2 days | 20 berries | ~50 coins | 7 days |
| Herb Garden | 400 | 2 days | 8 herbs | ~65 coins | 6 days |
| Walnut Sapling | 500 | 3 days | 15 nuts | ~75 coins | 7 days |
| Maple Sapling | 800 | 5 days | 1 sap | ~125 coins | 6-7 days |

---

# 6. Mini-Activities

## Overview

| Activity | Unlock | Duration | Yield | Cooldown | Mechanic |
|----------|--------|----------|-------|----------|----------|
| Fishing | Start | 1-2 min | 5 fish | 4 hours | Timing tap |
| Berries | Start | 30-60 sec | 15 berries | 6 hours | Tap collect |
| Nut Grove | Start | 45-60 sec | 10 nuts | 8 hours | Shake + tap |
| Herb Meadow | Tier 2 Furnace | 10-20 sec | 8 herbs | 8 hours | Swipe collect |

## Fishing Hole

1. Line casts automatically
2. Wait 2-6 seconds (random)
3. Bobber dips sharply (haptic + audio cue)
4. Player taps within 800ms window
5. Success: Fish caught, recasts
6. After 5 fish: Session complete

## Berry Fields

- 15 berries scattered on screen
- Tap each to collect
- Berries pop into basket with animation
- Collect all 15 to complete

## Nut Grove

- Large tree with visible nuts
- Swipe left-right to shake tree
- 3-4 shakes dislodges 2-3 nuts
- Tap fallen nuts to collect
- Repeat until 10 collected

## Herb Meadow (Unlocks with Tier 2 Furnace)

- 8 herb clusters scattered
- Swipe across herbs to pick
- Multi-pick possible (up to 3 per swipe)
- Collect all 8 to complete

---

# 7. Characters

## Rosie — The Shopkeeper

### Personality
- Warm, genuinely delighted to see you
- Practical, no-nonsense about tools
- Generous, always offering a bite of something
- Slightly grandmotherly, but spry and active
- **Known for:** Cinnamon rolls and pies

### Appearance
- Late 50s to early 60s
- Silver-streaked hair in practical bun
- Rosy cheeks (her namesake)
- CHOP orange apron with flour dust
- Sturdy work boots

### Key Expressions
- Neutral-Warm (default)
- Greeting (eyes crinkle, bigger smile)
- Delighted (hands clasped, broad smile)
- Thinking (hand on chin)

### Example Lines
- "Morning! Set these aside, thought you might like 'em."
- "Your axe is looking tired. Repair special today."
- "That maple sapling's been waiting for the right person."

## Harold the Heron — Game Mascot

### Personality
- Curious, watches everything with interest
- Dignified, moves with purpose
- Occasionally silly, breaks his own seriousness
- Patient, happy to wait

### Appearance
- Great Blue Heron, stylized cute
- Larger head/eyes than realistic
- Expressive crest feathers (like eyebrows)
- Blue-gray body, yellow beak, bright yellow eyes

### Behaviors by Screen

| Screen | Location | Behavior |
|--------|----------|----------|
| Homestead | Near furnace or on roof | Idle, watching, preening |
| Forest | On nearby stump or branch | Watches chops, reacts |
| Hardware Store | Outside window | Visible, watching |
| Fishing Hole | Edge of pond | Hunting stance |
| Berry Fields | In a bush | Pecking at berries |
| Results | Next to score | Celebrating or consoling |

### Reactions
- **Perfect chop:** Hops, wings half-spread, celebrating
- **Failed knot:** Winces, head turns away, sympathetic
- **High score:** Full celebration dance

---

# 8. Navigation & Screens

## Screen Map

```
                    ┌─────────────┐
                    │   FOREST    │
                    │  (Chopping) │
                    └──────▲──────┘
                           │ swipe up
                           │
┌──────────┐  swipe   ┌────┴────┐  swipe   ┌──────────┐
│ HARDWARE │◄────────►│HOMESTEAD│◄────────►│ GATHERING│
│  STORE   │  right   │ (Home)  │  left    │   HUB    │
└──────────┘          └────┬────┘          └─────┬────┘
                           │                     │
                      tap furnace           tap activity
                           │                     │
                    ┌──────▼──────┐        ┌─────▼─────┐
                    │   FURNACE   │        │  FISHING  │
                    │   DETAIL    │        │  BERRIES  │
                    └─────────────┘        │   NUTS    │
                                           │   HERBS   │
                    ┌─────────────┐        └───────────┘
                    │   RESULTS   │
                    │  (Post-Run) │
                    └─────────────┘
```

## Navigation Table

| From | To | Gesture/Action |
|------|-----|----------------|
| Homestead | Forest | Swipe up / Tap forest icon |
| Homestead | Hardware Store | Swipe left |
| Homestead | Gathering Hub | Swipe right |
| Homestead | Furnace Detail | Tap furnace |
| Homestead | Axe Selection | Tap axe rack |
| Forest | Results | Automatic on run end |
| Results | Forest | Tap "Chop Again" |
| Results | Homestead | Tap "Home" |
| Hardware Store | Homestead | Swipe right |
| Gathering Hub | Homestead | Swipe left |

## Key Screens

### Homestead (Central Hub)
- Coins/Amber display (top)
- Forest icon (tap to chop)
- Wood pile (shows inventory)
- Furnace (tap for detail)
- Axe rack (tap to select)
- Smoker (tap for detail)
- Orchard indicator
- High score display (bottom)

### Forest (Chopping)
- Score (top left)
- Streak multiplier (top center)
- Strike counter (top right) — ●●○
- Log on chopping block (center)
- Axe coming from bottom (POV)
- Durability bar (bottom)
- Transparent "clear wood" button (corner)

### Hardware Store
- Daily Deals (prominent)
- Categories: Axes, Plants, Materials, Inputs, Cosmetics
- Rosie visible at counter
- Amber Shop button

---

# 9. UI/UX Design

## Design Philosophy

UI exists in a distinct layer but feels harmonious with the 3D world. Like carved wooden signs, not floating digital interfaces.

## Button Styles

### Primary Button
- Fill: #E87C3A (CHOP orange)
- Border: #C4602A (darker, 2pt)
- Text: #F5ECD7 (cream)
- Corner radius: 12pt
- Pressed: Darker, slight scale down

### Secondary Button
- Fill: Transparent
- Border: #4A7C59 (forest green, 2pt)
- Text: #4A7C59

### Amber Button (Premium)
- Fill: Gradient #FFD700 → #FFB347
- Subtle shimmer animation
- Text: #3D3229 (dark)

## Typography

### Recommended Fonts
- **Primary:** Nunito, Varela Round, or Quicksand (Google Fonts)
- **Accents:** Pacifico (script, for logo)

### Type Scale
| Use | Size | Weight |
|-----|------|--------|
| Display | 48-72pt | Bold |
| Headline | 28-32pt | Bold |
| Title | 20-24pt | SemiBold |
| Body | 16-18pt | Regular |
| Caption | 12-14pt | Regular |

### Text Colors
- Primary: #3D3229 (charcoal brown)
- Secondary: #6B4423 (warm brown)
- On dark: #F5ECD7 (cream)
- Links: #4A7C59 (forest green)
- Error: #C73E1D (warm red)

## HUD (During Chopping)

- **Score:** Top left, large, pops on increase
- **Streak:** Next to score, gold at 2.0x
- **Strikes:** Top right, three circles (●●○)
- **Durability:** Bottom bar, color-coded (green → yellow → red)
- **Clear button:** Transparent, corner, appears when wood piles up

---

# 10. Visual Art Direction

## Style Summary

**"Handcrafted Comfort with Satisfying Heft"**

- Stardew Valley vibrancy + Low-poly 3D form
- Flat vector UI integrated with 3D world
- Everything feels "whittled" — like wooden toys
- Skyrim/Witcher weight in animations

## Polygon Philosophy

| Element | Triangle Budget |
|---------|-----------------|
| Characters (face/body) | 500-900 |
| Small props | 50-150 |
| Medium props | 150-400 |
| Trees | 100-300 |
| Buildings | 500-1500 |

**Style:** Deliberately visible facets, beveled edges, hand-carved feeling

## Color Palette

### Brand Colors

| Name | Hex | Use |
|------|-----|-----|
| CHOP Orange | #E87C3A | Primary brand, buttons |
| Forest Green | #4A7C59 | Secondary, nature |
| Cream White | #F5ECD7 | Backgrounds |
| Charcoal Brown | #3D3229 | Text, outlines |
| Amber Gold | #FFB347 | Premium, rewards |

### Environmental Colors

**Forest:**
- Sky: #87CEEB
- Foliage: #5D8A66 → #3D5A43
- Grass: #7BA05B
- Tree trunks: #6B4423

**Homestead:**
- Cabin walls: #8B6914
- Roof: #6B4423
- Furnace stone: #7D7D7D
- Brick: #8B4513

**Hardware Store:**
- Walls: #D4C4A8
- Shelving: #8B6914
- Floor: #A67C52

## Glow Effects

| Type | Color | When |
|------|-------|------|
| Furnace warm | #FF6B35 | Low-medium heat |
| Furnace hot | #FF4500 | High heat |
| Amber found | #FFD700 | In split wood |
| Timing window | #FFB347 → #FFD700 | Knot sweet spot |
| Diamond Axe | #87CEEB | Always (subtle) |
| Success flash | #90EE90 | Perfect moments |
| Warning | #C73E1D | Low durability/fuel |

---

# 11. Animation Direction

## Philosophy: "Bumbling Cute"

Like Aardman (Wallace & Gromit) meets Nintendo (Animal Crossing):
- Everything has weight
- Anticipate → Act → Overshoot → Settle
- Secondary motion everywhere
- Never robotic, never too smooth

## The Weight of Chopping

### The Perfect Chop (600ms total)

| Phase | Duration | What Happens |
|-------|----------|--------------|
| Wind-up | 50ms | Axe lifts slightly |
| Swing | 150ms | Axe arcs down |
| Impact | 16ms | Contact frame |
| **Hit Stop** | **30-50ms** | **Brief freeze (the secret)** |
| Split | 200ms | Wood separates |
| Settle | 300ms | Pieces fall, settle |

### Hit Stop (The Secret Ingredient)

- Brief pause at impact moment
- Gives weight and consequence
- Screen shake: 2-3 pixels
- Sound continues through pause
- Haptic plays through pause

### The Knot Break (Victory Moment)

- Extended hit stop (80ms)
- Dramatic split with force
- Golden flash + particles
- Harold celebrates in background

## Haptic Patterns

| Event | Pattern | Feel |
|-------|---------|------|
| Clean split (soft) | Light crisp tap | "Butter" |
| Clean split (hard) | Heavy impact + resonance | "Earned it" |
| Knot strike | Heavy thud + buzz | "That's stuck" |
| Knot break | Heavy + triple celebration tap | "Victory" |
| Knot failed | Weak unsatisfying tap | "Oops" |
| Strike (NOPE) | Error buzz | "Womp womp" |
| Amber found | 5 quick taps ascending | "Magical shimmer" |

---

# 12. Audio Direction

## Sound Categories

### Chopping Sounds

| Event | Description |
|-------|-------------|
| Soft wood split | Light, clean crack |
| Medium wood split | Solid, satisfying crack |
| Hard wood split | Deep, resonant crack |
| Knot strike | Solid thud, stuck sound |
| Knot creak | Wood straining, fibers stretching |
| Knot break | Deep crack + triumphant tone |
| Axe miss/fail | Dull thunk |
| Axe break | Metallic crack, snap |

### Ambient

| Location | Sounds |
|----------|--------|
| Homestead | Fire crackle, birds, gentle breeze |
| Forest | Wind through leaves, distant birds, occasional animal |
| Hardware Store | Interior quiet, occasional creak, Rosie humming |
| Fishing Hole | Water lapping, frogs, splash |
| Berry Fields | Bees, rustling, birdsong |

### UI Sounds

- Button tap: Soft wood knock
- Coin earned: Cheerful clink
- Amber found: Magical shimmer/chime
- Purchase: Cash register "cha-ching"
- Product ready: Warm "ding"
- Strike earned: Comedic "bonk" or slide-whistle

### Music

- **Style:** Acoustic, warm, folk-inspired
- **Homestead:** Gentle guitar or ukulele, cozy
- **Chopping:** Rhythmic, can sync with chops, builds intensity
- **Results:** Triumphant version of theme
- **Store:** Casual, background, homey

---

# 13. iOS Features

## Widgets

### Home Screen Widget

**Small (2×2):**
- Furnace icon with glow state
- Temperature or fuel remaining
- Tap to open app

**Medium (4×2):**
- Furnace with temperature + fuel timer
- Current processing item + progress
- Tap to open app

### Widget Animation (Timeline-Based)

Widgets refresh on schedule. Each refresh shows different "frame":
- Flames shift position
- Smoke moves
- Creates "living stillness" effect

### Live Activities (Lock Screen)

**When Active:**
- Furnace glow indicator
- Temperature: "847°"
- Fuel countdown: "2:34:17 remaining"
- Current product: "Maple Syrup — 67%"

**Dynamic Island:**
- Compact: Furnace icon + temp
- Expanded: Full furnace status
- Pulses amber when fuel is low

## Game Center

### Leaderboards
- **Personal Best:** High score tracking
- **All-Time Logs Chopped:** Lifetime stat
- **Longest Streak:** Consecutive one-chops

### Achievements
(To be defined — milestone-based, unlocking cosmetics)

---

# 14. Monetization

## Philosophy

CHOP respects its players. The store enhances experience, not extracts money. Free players can enjoy everything. Paying players feel good about it.

## Amber Pricing Tiers

| Price | Base | Bonus | Total | Value vs. Base |
|------:|-----:|------:|------:|---------------:|
| $0.99 | 100 | — | 100 | Baseline |
| $2.99 | 300 | +15 | 315 | +4% |
| $4.99 | 500 | +50 | 550 | +9% |
| $9.99 | 1,000 | +200 | 1,200 | +19% ★ Popular |
| $14.99 | 1,500 | +450 | 1,950 | +29% |
| $24.99 | 2,500 | +1,000 | 3,500 | +39% |
| $49.99 | 5,000 | +2,750 | 7,750 | +53% ★ Best Value |

**Package Names:** Pouch → Jar → Sack → Crate → Chest → Treasury → Vault

## Amber Costs (In-Game)

| Use | Cost |
|-----|------|
| Instant repair (any axe) | 25 amber |
| Basic cosmetic axe skin | 150 amber |
| Premium cosmetic skin | 400 amber |
| Rare/Limited cosmetic | 800 amber |
| Legendary cosmetic | 1,500 amber |

## Diamond Axe

- **Price:** $2.99 (one-time)
- **Benefit:** Never needs repair (infinite durability)
- **Stats:** Balanced (not overpowered)
- **Philosophy:** Pay for convenience, not power

## Daily Deals

### Structure
- 3 deals per day (Supply, Equipment, Special)
- Refresh at local midnight
- Stay ALL DAY — no countdown timers
- 15-25% discounts on normal items

### Example Deals
- **Supply:** Forager's Bundle (15 nuts + 15 berries) — 45 coins
- **Equipment:** Keen Edge Axe — 340 coins (was 400)
- **Special:** Maple Sapling — 680 coins (was 800)

### Anti-FOMO Design
- "Deals refresh tomorrow. No rush."
- NO push notifications for deals
- NO guilt messaging
- Rosie's friendly presentation

## Ethical Checklist

Every monetization element must pass:
1. Could a player feel tricked? → No
2. Could a player feel pressured? → No
3. Could a player feel punished for not buying? → No
4. Would we be proud to explain this publicly? → Yes

---

# 15. Technical Specifications

## Gesture Detection

```swift
struct ChopGesture {
    let direction: CGVector      // Must be primarily downward
    let distance: CGFloat        // Minimum 80pt
    let duration: TimeInterval   // Maximum 400ms
    let startPoint: CGPoint      // Upper 70% of screen
    let endPoint: CGPoint        // Lower 50% of screen

    var isValid: Bool {
        let angle = atan2(direction.dy, direction.dx)
        let tolerance = 30 * (.pi / 180)  // ±30 degrees
        let targetAngle = -.pi / 2         // Straight down

        return distance >= 80 &&
               duration <= 0.4 &&
               abs(angle - targetAngle) <= tolerance
    }
}
```

## Log Generation Algorithm

```swift
func generateNextLog(logsChopped: Int, lastLogWasFailedKnot: Bool) -> Log {

    // Mercy rule: no knots after failed knot
    if lastLogWasFailedKnot {
        return Log(woodType: .soft, hasKnot: false)
    }

    // Logarithmic difficulty
    let difficultyFactor = log10(Double(logsChopped + 10)) / 3.0

    // Wood type distribution (shifts with progress)
    let softChance = max(0.2, 0.6 - difficultyFactor * 0.4)
    let mediumChance = 0.3
    let hardChance = 1.0 - softChance - mediumChance

    // Knot probability (increases, caps at 25%)
    let knotChance = min(0.25, 0.05 + difficultyFactor * 0.15)

    let woodType = weightedRandom(soft: softChance, medium: mediumChance, hard: hardChance)
    let hasKnot = woodType != .soft && random() < knotChance

    return Log(woodType: woodType, hasKnot: hasKnot)
}
```

## Timing Window State Machine

```swift
enum KnotState {
    case awaitingStrike(number: Int)           // 1, 2, or 3
    case waitPeriod(strike: Int, remaining: TimeInterval)
    case windowOpen(strike: Int, remaining: TimeInterval)
    case success
    case failed
}

// Timing parameters
let waitPeriods: [Int: TimeInterval] = [1: 0.4, 2: 0.35, 3: 0.3]
let windowDurations: [Int: TimeInterval] = [1: 0.6, 2: 0.5, 3: 0.45]
```

## Save Triggers

Save game state when:
1. Run ends (results calculated)
2. Purchase completed
3. Product collected from furnace
4. Plant harvested
5. Gathering activity completed
6. App enters background
7. Every 60 seconds during active play (auto-save)

---

# 16. Data Models

## Player State

```swift
struct PlayerState: Codable {
    var coins: Int
    var amber: Int
    var totalLogsChopped: Int
    var highScore: Int
    var hapticEnabled: Bool
    var soundEnabled: Bool
    var musicEnabled: Bool
    var lastPlayedAt: Date
    var accountCreatedAt: Date
    var hasDiamondAxe: Bool
}
```

## Inventory

```swift
struct Inventory: Codable {
    // Wood
    var softWood: Int
    var mediumWood: Int
    var hardWood: Int

    // Gathered materials
    var rawFish: Int
    var rawNuts: Int
    var rawBerries: Int
    var rawHerbs: Int

    // Purchased ingredients
    var flour: Int
    var sugar: Int
    var mapleSap: Int
    var premiumMeat: Int

    // Crafting materials
    var charcoal: Int
    var whetstones: Int
    var ironScrap: Int

    // Finished products
    var smokedFish: Int
    var roastedNuts: Int
    var driedHerbs: Int
    var bakedBread: Int
    var preserves: Int
    var mapleSyrup: Int
    var smokedMeats: Int
}
```

## Owned Axe

```swift
struct OwnedAxe: Codable, Identifiable {
    let id: UUID
    let type: AxeType           // sharp, balanced, heavy, diamond
    let tier: AxeTier           // basic, mid, premium, master
    var currentDurability: Int
    var maxDurability: Int
    var cosmeticSkin: AxeSkin?
    var isEquipped: Bool
}
```

## Furnace State

```swift
struct FurnaceState: Codable {
    var tier: FurnaceTier       // stoneHearth, brickFurnace, ironClad, greatForge
    var currentTemperature: Int
    var fuelRemaining: TimeInterval
    var lastUpdatedAt: Date
    var processingSlots: [ProcessingSlot]
    var completedProducts: [CompletedProduct]
}

struct ProcessingSlot: Codable, Identifiable {
    let id: UUID
    var recipe: Recipe?
    var startedAt: Date?

    var progress: Double? { /* calculated from recipe time and startedAt */ }
    var isComplete: Bool { progress == 1.0 }
}
```

## Planted Items

```swift
struct PlantedItem: Codable, Identifiable {
    let id: UUID
    let type: PlantType
    let plantedAt: Date
    var lastHarvestedAt: Date?

    var isMatured: Bool { Date() >= plantedAt.addingTimeInterval(type.matureTime) }
    var harvestReady: Bool { isMatured && canHarvestAgain }
}
```

## Gathering State

```swift
struct GatheringState: Codable {
    var fishingLastCompleted: Date?
    var berriesLastCompleted: Date?
    var nutsLastCompleted: Date?
    var herbsLastCompleted: Date?

    func isReady(_ activity: GatheringActivity) -> Bool {
        guard let last = lastCompleted(activity) else { return true }
        return Date() >= last.addingTimeInterval(activity.cooldown)
    }
}
```

## Statistics

```swift
struct Statistics: Codable {
    var totalRuns: Int
    var highScore: Int
    var totalLogsChopped: Int
    var longestStreak: Int

    var softWoodChopped: Int
    var mediumWoodChopped: Int
    var hardWoodChopped: Int

    var knotsEncountered: Int
    var knotsBroken: Int
    var knotsFailed: Int

    var totalCoinsEarned: Int
    var totalCoinsSpent: Int
    var fishCaught: Int
    var axesBroken: Int
}
```

## Run State (Transient)

```swift
struct RunState {
    var score: Int
    var logsChopped: Int
    var strikes: Int                    // 0, 1, or 2
    var currentMultiplier: Double
    var consecutiveOneChops: Int

    var equippedAxe: OwnedAxe
    var currentDurability: Int

    var currentLog: Log
    var logQueue: [Log]

    var woodHarvested: [WoodType: Int]
    var amberFound: Int

    var knotState: KnotState?
}
```

## Initial Game State

```swift
func createNewGame() -> GameSave {
    let startingAxe = OwnedAxe(
        id: UUID(),
        type: .balanced,
        tier: .basic,
        currentDurability: 50,    // Slightly worn
        maxDurability: 70,
        cosmeticSkin: nil,
        isEquipped: true
    )

    return GameSave(
        playerState: PlayerState(coins: 0, amber: 0, ...),
        inventory: Inventory(/* all zeros */),
        ownedAxes: [startingAxe],
        plants: [],
        furnaceState: FurnaceState(tier: .stoneHearth, ...),
        gatheringState: GatheringState(),
        statistics: Statistics(/* all zeros */),
        dailyDeals: generateNewDeals()
    )
}
```

---

# Appendix A: Asset Checklist

## Characters
- [ ] Rosie: 5 expressions, idle/greeting/presenting poses
- [ ] Harold: Idle, flying, celebrating, wincing, sleeping poses

## Axes (12 base + Diamond + cosmetics)
- [ ] Basic Sharp, Keen Edge, Razor, Master's Razor
- [ ] Basic Heavy, Forged Heavy, Ironclad, Unbreakable
- [ ] Basic Balanced, Tempered, Forgemaster, Master's Axe
- [ ] Diamond Axe (special crystalline)

## Furnaces (4 tiers × 3+ glow states)
- [ ] Stone Hearth
- [ ] Brick Furnace
- [ ] Iron-Clad
- [ ] Great Forge

## Environments
- [ ] Homestead (hub scene)
- [ ] Forest (chopping area)
- [ ] Hardware Store (interior)
- [ ] Fishing Hole
- [ ] Berry Fields
- [ ] Nut Grove
- [ ] Herb Meadow

## Props
- [ ] Chopping block
- [ ] Logs (3 wood types × normal + knot variants)
- [ ] Wood pile (5 fill states)
- [ ] Axe rack
- [ ] Smoker
- [ ] Plants (7 types, immature + mature states)

## UI
- [ ] Buttons (primary, secondary, amber, ghost)
- [ ] Icons (all inventory items, navigation)
- [ ] NOPE! popup (with variations)
- [ ] Panels and modals

## Effects
- [ ] Glow sprites (furnace, amber, timing, success)
- [ ] Particles (wood chips, sparks, sparkles)
- [ ] Screen shake

---

# Appendix B: Sound Checklist

## Chopping
- [ ] Soft wood split
- [ ] Medium wood split
- [ ] Hard wood split
- [ ] Knot strike
- [ ] Knot creak
- [ ] Knot break (triumphant)
- [ ] Axe miss
- [ ] Axe break

## Ambient
- [ ] Homestead loop
- [ ] Forest loop
- [ ] Hardware Store loop
- [ ] Fishing Hole loop
- [ ] Berry Fields loop

## UI
- [ ] Button tap
- [ ] Coin earned
- [ ] Amber found
- [ ] Purchase complete
- [ ] Product ready
- [ ] Strike/NOPE sound

## Music
- [ ] Main theme
- [ ] Homestead (cozy)
- [ ] Chopping (rhythmic, builds)
- [ ] Results (triumphant)
- [ ] Store (casual)

---

# Appendix C: Questions for Future Design

1. **Seasonal content** — How do seasons affect gameplay? Visual-only or mechanical?
2. **Social features** — Friends' homesteads? Trading? Leaderboards beyond Game Center?
3. **Events** — Limited-time challenges? Seasonal cosmetics?
4. **Achievements** — What milestones unlock? Cosmetic rewards?
5. **Tutorial** — Currently "drop in, learn by doing." Need any guidance?
6. **Accessibility** — Visual alternatives to color-coded info? Haptic customization?
7. **Localization** — What languages? Rosie's dialogue translation?

---

*Document Version 1.0*
*Last Updated: January 2026*
*Game: CHOP*
