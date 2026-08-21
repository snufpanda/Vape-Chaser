# Art & Sound

Everything on screen right now is a coloured circle drawn in code. Nothing is final, but some things **are** decided, and knowing which is which saves redrawing work.

---

## What's locked

**Camera:** top-down, fixed. No scrolling, no rotation. The whole arena is on screen at once.

**Arena:** 1152 × 648. The window is that size and the game does not scroll, so nothing needs to tile or repeat.

**Sizes.** Every entity has a collision radius in code. Art has to match these, because the radius is what the game actually uses for hits — if the sprite is bigger than the radius, it looks like attacks miss.

| Thing | Radius in code | Suggested sprite |
|---|---|---|
| Player | 14 | 32 × 32 |
| Vaper | 12 | 32 × 32 |
| Cloud-chaser | 14 | 32 × 32 |
| Bong junkie | 18 | 48 × 48 |
| **THE DON** | 26 | 64 × 64 |
| Bullet | 3 | 8 × 8 |

Centre the character in the frame — the sprite's origin sits exactly on the entity's position.

**Palette.** These are the actual values in the scripts today, not a proposal:

| Role | Hex |
|---|---|
| Floor | `#10141a` |
| Floor grid | `#1b222b` |
| Player | `#e9f6f3` |
| Player accent / all CLEAR things | `#7fe3d4` |
| Vaper | `#c25e57` |
| Cloud-chaser | `#9a6f52` |
| Bong junkie | `#7d2f2a` |
| The Don | `#4a2b22` |
| Lit cigar | `#ff8a3d` |
| Enemy fire / danger | `#ff5a4a` |
| Your bullets | `#ffe9a8` |
| Smoke | `rgb(222, 232, 237)` at low alpha |
| HUD text | `#e9eef1` / muted `#8f9ba5` |
| Oxygen / warning amber | `#f2a33c` |

The one rule that matters: **teal is always "air/clearing", red-browns are always "smoker", amber is always "burning".** A player should be able to read a screenshot without a legend.

---

## What is NOT decided

**The art style.** Nobody has picked one. Pixel art, flat vector, silhouettes, hand-drawn — all still open, and it's Fahad's call before anyone spends a weekend on sprites.

Worth deciding early, because it changes everything downstream: pixel art means committing to a resolution and never scaling; vector means the sizes above are suggestions rather than rules.

Do not start final art until this is settled.

---

## Where files go

```
assets/
  sprites/      # player.png, vaper.png, bong.png, don.png
  fx/           # smoke, muzzle flashes
  ui/           # icons, bar frames
  sfx/          # short one-shots
  music/
```

The folder doesn't exist yet — first person to add art makes it.

---

## Swapping a circle for a sprite

Every entity draws itself in a `_draw()` function. To use real art instead, delete the `draw_circle` calls and add a `Sprite2D` child in `_ready()`:

```gdscript
var s := Sprite2D.new()
s.texture = preload("res://assets/sprites/vaper.png")
add_child(s)
```

Leave the `radius` values alone — they're gameplay, not visuals. Change them only to change the game's balance, never to fit a drawing.

---

## Sound

Nothing has audio yet. Every one of these events already exists in code and needs a sound:

| Event | Where it fires | Feel |
|---|---|---|
| Your weapon | `Player._fire()` | dry, short, fires 3×/sec — must not get annoying |
| Enemy dies | `Enemy.hurt()` | small pop of relief |
| The fan | continuous while near smoke | soft, airy, loopable |
| Choking | breath dropping | the panic cue. Most important sound in the game. |
| Bong hit | contact damage | heavy, sudden, hurts |
| Cigar knocked out | `Enemy.knock_cigar()` | satisfying. This is the boss's turning point. |
| The Don shoots | boss firing | threatening, distinct from your own gun |
| Wave ends | `WaveManager._end_wave()` | release |

**Formats:** `.wav` for short one-shots (no decode delay), `.ogg` for music and long loops. Keep one-shots under half a second. Mono is fine for SFX.

The breath/choking sound carries the whole game. If a player can tell they're suffocating with their eyes shut, it's working.

---

## Before you draw anything

The game isn't proven yet. It has never been playtested, and there's an open question in the README about whether the core pressure even works — nothing chases you any more, so it's possible you can just kite in a corner and win.

**Art made before that's answered may be art for a game that changes shape.** Play it first.
