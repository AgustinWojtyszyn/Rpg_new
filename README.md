# Rpg_new

Mobile-first 2D action roguelite built with Godot 4.7.2.

## Current playable loop

A new game creates or resumes a deterministic dungeon run.

- Connected procedural room graph with main route and side branches.
- Guaranteed treasure and event decisions every run.
- Five enemy families with distinct combat behavior.
- T-Rex miniboss with lever-controlled breakable set pieces.
- Rift Warden final boss with temporary dimensional combat arenas.
- Bosses remain damageable through phase changes.
- Five mechanically distinct weapons.
- Six build-changing run modifiers.
- Deterministic treasure/event choices.
- Essence rewards and permanent weapon unlocks.
- Local profile progression.
- Safe checkpoint autosave and automatic run resume.
- Native Godot mobile controls, auto-aim assistance and retry flow.
- Android Play AAB preset targeting API 36.

## Weapons

- Rift Sidearm — baseline precision.
- Raptor Scatter — close-range spread.
- Bone Rail — piercing high-speed shot.
- Spore Repeater — burst weapon.
- Beetle Core — explosive area weapon.

## Run modifiers

Predator Sigil, Mycelial Heart, Alien Lens, Beetle Carapace, Chrono Tendon and Void Capacitor can combine with any weapon.

## Desktop controls

- Arrow keys: move
- Space / Enter: attack
- Shift: dash
- E: interact
- R: restart after victory/defeat

Touch devices use Godot's native virtual joystick plus attack, dash, interact and contextual retry buttons.

## Persistence

Two local files are intentionally separate:

- permanent profile progression;
- current run checkpoint.

Closing the game mid-run restores the last safe room checkpoint. Victory or defeat clears only the active run.

No backend is required for the core game.

## Validation

CI imports the project with Godot 4.7.2, runs deterministic suites and headless smoke boots.

Current automated coverage includes procedural topology, encounter budgets, hundreds of dungeon seeds, thousands of encounter combinations, build/reward determinism, progression thresholds, scene contracts and boss prototypes.

## Documentation

See docs/ARCHITECTURE.md, docs/ART_DIRECTION.md, docs/ANDROID_BUILD.md, docs/ITERATION_01.md, docs/ITERATION_02.md and docs/THIRD_PARTY.md.

Final art, audio, settings/accessibility, expanded content and monetization are intentionally separate future gates.
