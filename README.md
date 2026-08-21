# Second Hand

A wave-survival roguelite where the enemies are vapers, smokers and one cigar-smoking boss.

You never aim. You move. Your weapons fire themselves.
Your health bar is **breath**, and the only thing that takes it is the air.

**Status:** vertical slice. Placeholder art (circles). Five waves. Not fun yet — that's the job.

---

## Run it

Godot **4.7** or newer. No addons, no imports, no build step.

1. Open Godot → Import → pick `project.godot` in this folder
2. Press **F5**

If it behaves like an older version of itself, the editor is holding a stale script cache: `Ctrl+Shift+R` to reload, or close and reopen the project.

## Controls

| Input | Does |
|---|---|
| **WASD** / arrows | move. That is the entire control scheme. |
| `1` `2` `3` | pick an upgrade between waves |

---

## The one idea

Smoke is drawn **on top of** enemies ([`scripts/Cloud.gd`](scripts/Cloud.gd), `z_index = 10` vs the enemy's `5`).

So you can't see what's in it. Clouds have two independent properties:

- **`opacity`** — how much it *blinds* you
- **`density`** — how much it *chokes* you

Vape smoke is all opacity and **zero density**. It cannot kill you. It makes you walk into something that can.

That's the game: **the vaper hides the junkie, and you run into what you can't see.**

## Enemies — one job each

| Enemy | Job | Hurts you? |
|---|---|---|
| **Vaper** | blinds you | no. zero damage. |
| **Cloud-chaser** | blinds you bigger | no. zero damage. |
| **Bong junkie** | sits on the floor, never moves | 22 on contact |
| **THE DON** (cigar) | fogs the room, *or* shoots | conditional — see below |

**The Don has two states and you pick which one you fight.**
Lit, he pumps a huge cloud over the arena and never shoots. Knock the cigar out with your fan and the fog stops — but he opens fire. Relights after 6 seconds.

Blind, or shot at. Your call, repeatedly.

## Weapons — two families

- **KILL** — hits people. Auto-targets the nearest enemy.
- **CLEAR** — moves air. Kills nothing. Starts as a pathetic hand fan.

`HAND FAN → DESK FAN → BOX FAN → LEAF BLOWER → EXTRACTOR`

Go all-KILL and you win every fight but drown in leftover smoke. Go all-CLEAR and you see everything and kill nothing. That tension is the shop.

---

## Code layout

No physics bodies, no collision layers, no scene tree to speak of — everything is instantiated in code and collision is plain distance math. It's meant to be readable end to end in about ten minutes.

| File | Owns |
|---|---|
| `scripts/Main.gd` | wires everything together, draws the floor |
| `scripts/Player.gd` | movement, breath, auto-fire, the fan |
| `scripts/Enemy.gd` | all four enemy types; stats live in `setup()` |
| `scripts/Cloud.gd` | the smoke |
| `scripts/WaveManager.gd` | spawning, waves, the shop |
| `scripts/HUD.gd` | breath bar, wave counter, shop screen |

**Tuning:** every enemy number is in `Enemy.setup()`. Every player number is at the top of `Player.gd`. Change a number, press F5, feel the difference.

---

## Known open question

Nothing chases you any more. Vapers and cloud-chasers are harmless, and bongs never move — so the only pressure is the arena slowly filling with people you can't see.

**If you can kite in a corner for 30 seconds and survive, the design isn't working yet.** Bongs need to spawn faster, or smoke needs to linger longer. This is the next thing to playtest.
