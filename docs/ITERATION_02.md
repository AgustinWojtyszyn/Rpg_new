# Iteration 02 — Roguelite progression loop

## Goal

Turn the technical vertical slice into a run with meaningful choices, build identity, persistent progression and safe local resume.

## Weapons

The player now has five data-driven weapons. They share one projectile/firing architecture but differ mechanically:

- **Rift Sidearm** — stable single-shot baseline.
- **Raptor Scatter** — five-projectile close-range spread.
- **Bone Rail** — high-speed shot with two extra pierces.
- **Spore Repeater** — three-shot burst.
- **Beetle Core** — slow explosive projectile with area damage.

Weapon definitions control damage, cadence, speed, lifetime, salvo size, spread, burst, piercing, explosion radius, projectile size and presentation color.

## Run modifiers

Six unique modifiers can compose with any weapon:

- Predator Sigil — damage.
- Mycelial Heart — max health plus immediate heal.
- Alien Lens — additional projectile plus projectile speed.
- Beetle Carapace — health plus longer post-hit grace window.
- Chrono Tendon — fire rate, movement and dash recharge.
- Void Capacitor — projectile speed and explosion size.

Modifiers are unique per run; duplicates are rejected and converted to alternative event rewards where appropriate.

## Treasure and event rooms

Every generated run now guarantees at least:

- one treasure room;
- one event room;
- one T-Rex miniboss;
- one Rift Warden final boss.

Treasure rooms expose three deterministic choices generated from the run seed. They respect permanent weapon unlocks and never intentionally offer the currently equipped weapon.

Event rooms expose two deterministic decisions. Current event families include:

- Fossil Nest;
- Alien Console;
- Root Sanctuary;
- Carapace Forge;
- Time Fracture.

Choices can heal, grant essence, equip a weapon or grant a modifier.

## Essence and run progression

Combat rooms award essence based on depth. The T-Rex and final boss award larger amounts.

The HUD now shows:

- current weapon;
- modifier count;
- run essence;
- lifetime essence;
- completed runs;
- permanent weapon unlock count.

## Permanent progression

A local profile persists between runs.

Base weapons:

- Rift Sidearm;
- Raptor Scatter;
- Spore Repeater.

Permanent unlock rules:

- Bone Rail: 60 lifetime essence.
- Beetle Core: first completed run, or 140 lifetime essence.

Run essence is banked into lifetime progression whether the run ends in victory or defeat.

## Local save / resume

The game uses a separate run snapshot file.

Checkpoints are written on safe room boundaries and after room resolution. The snapshot stores:

- seed;
- current room;
- cleared rooms;
- rewarded rooms;
- equipped weapon;
- modifiers;
- run essence;
- player health;
- player position.

A mid-combat app close intentionally restores from the last safe checkpoint rather than serializing transient enemies or boss state.

Victory or defeat clears only the active run snapshot. Permanent profile progression remains.

## Presentation pass

The engineering visuals were upgraded without committing to final art:

- room-role color identities;
- deterministic floor/debris decoration;
- stronger borders and door corridors;
- clearer reward pedestals;
- weapon-colored player presentation;
- projectile trails;
- reward/essence toast feedback;
- consolidated top HUD and boss health styling.

These visuals are still placeholders and are designed to be replaced without changing gameplay code.

## Validation added

Iteration 02 adds tests for:

- unique weapon IDs;
- mechanically distinct weapon signatures;
- unique modifier IDs;
- build math;
- build serialization;
- deterministic treasure choices;
- reward uniqueness;
- locked-weapon filtering;
- maxed-build treasure fallback;
- event option count;
- permanent unlock thresholds;
- run snapshot validation;
- guaranteed treasure/event generation;
- new scene/HUD contracts.

## Deliberately deferred

- final generated/hand-authored character and environment art;
- sprite animation pipeline;
- audio and impact SFX;
- pause/settings/accessibility menu;
- shops and spendable meta currency;
- more weapon families/relics;
- more enemy families and bosses;
- signed physical-device Play build validation;
- AdMob/rewarded advertising.

Those are separate gates so monetization and content polish cannot destabilize the run foundation.
