# Iteration 01 — Technical vertical slice

## Goal

Prove that the core game can be expanded without turning each new enemy, room or boss into a new architecture.

## Implemented

### Run structure
- deterministic seed-based dungeon graph;
- east/west main route plus north/south branches;
- start, combat, event, treasure, miniboss and final-boss room roles;
- reciprocal door validation and reachability tests;
- cleared-room persistence while backtracking.

### Combat foundation
- reusable health and projectile contracts;
- dash;
- short post-hit invulnerability;
- dash invulnerability;
- optional nearest-target aim assist for one-stick mobile play;
- deterministic encounter budgets and role caps.

### Distinct enemy families
- Raptor Scout: flank + telegraphed lunge.
- Root Vine: telegraphed grab, pull and dash escape.
- Orb Stalker: range control, teleport and projectiles.
- Bone Guard: directional shield that fatigues.
- Iron Beetle: armored roll followed by a vulnerable recovery window.

### Boss foundation
- shared BossBase and phase model;
- no generic phase invulnerability;
- shared boss HUD;
- T-Rex charges plus two explicit lever/breakable-wall set pieces;
- normal T-Rex charges do not alter dungeon geometry;
- Rift Warden dimensional cast with the original boss instance suspended and restored;
- themed pocket encounters preserve boss HP and phase.

### Mobile / Android
- native Godot 4.7 VirtualJoystick;
- multitouch attack, dash and interaction controls;
- contextual mobile RETRY;
- landscape layout;
- GL Compatibility renderer;
- Android AAB export preset targeting API 36;
- signing material excluded from Git.

### Failure flow
- player death ends the run;
- active room freezes;
- transient projectiles are cleared;
- desktop/mobile retry cleanly reloads the run.

## Automated validation

CI now performs:

1. project import/parse in Godot 4.7.2;
2. deterministic unit-style tests;
3. 500 procedural dungeon seeds;
4. 300 encounter seeds across budgets 1–20;
5. scene/InputMap/collision contract checks;
6. headless boot smoke for the dungeon run;
7. headless boot smoke for the T-Rex encounter;
8. headless boot smoke for the dimensional boss encounter.

## Intentionally deferred

These are not failures of Iteration 01; they are the next content/product gates:

- final PixelLab art and animation;
- weapon/loot/build system;
- meaningful treasure and event rooms;
- permanent progression/unlocks;
- audio/VFX polish;
- settings/pause/accessibility menus;
- local run save/resume;
- AdMob rewarded ads;
- physical Android-device profiling and signed Play Console bundle validation.

## Architecture rule going forward

Prefer new content as Resources + scenes + configuration. Add new core code only when a creature or room introduces genuinely new mechanics.
