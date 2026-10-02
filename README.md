# Rpg_new

Mobile-first 2D action roguelite built with Godot 4.7.2.

## Product pillars

- Short, replayable dungeon runs built from handcrafted rooms assembled procedurally.
- Distinct enemy families: dinosaurs, alien creatures, carnivorous plants, skeletons and insects.
- Bosses remain damageable. Difficulty comes from patterns, arena interactions and enemy composition, not forced invulnerability.
- Interactive boss arenas support levers, scripted breakable set pieces and charge interactions.
- Dimensional boss mechanics temporarily move the player to another arena, then restore the original boss instance with its HP and phase preserved.
- Offline-first core. No backend required.
- Native Godot mobile controls and Play Store AAB configuration.
- Data-driven content so new enemies and encounters can be added without rewriting the core.

## Current playable engineering run

The startup scene now creates a deterministic dungeon from a seed.

- Main path uses east/west doors with north/south side branches.
- Combat doors stay locked until the room is cleared.
- Cleared rooms remain cleared when backtracking.
- Early encounters introduce skeletons, armored insects and raptors.
- Grabbing plants join from depth 2.
- Teleporting ranged aliens join from depth 4.
- The T-Rex is a miniboss with vulnerable phases, telegraphed charges and two optional lever/set-piece interactions.
- The Rift Warden is the final boss. Phase transitions can cast the player into themed pocket arenas; clearing the enemies returns to the same boss instance.
- No boss framework grants generic invulnerability.

All visuals are still intentional programmer art. PixelLab assets should replace placeholders only after the gameplay contracts are stable.

## Desktop controls

- Arrow keys: move
- Space or Enter: attack
- Shift: dash
- E: interact with levers

On touch devices, the project uses Godot 4.7's native virtual joystick plus touch attack/dash/interact buttons.

## Build

The versioned **Android Play AAB** export preset targets API 36. Signing credentials and keystores are intentionally excluded from Git.

## Development rule

Every system is integrated in small, testable gates. External dependencies are added only when they remove more complexity than they introduce.
