# Rpg_new

Mobile-first 2D action roguelite built with Godot 4.7.2.

## Product pillars

- Short, replayable dungeon runs built from handcrafted rooms assembled procedurally.
- Distinct enemy families: dinosaurs, alien creatures, carnivorous plants, skeletons and insects.
- Bosses remain damageable. Difficulty comes from patterns, arena interactions and enemy composition, not forced invulnerability.
- Interactive boss arenas support levers, scripted breakable set pieces and charge interactions.
- Dimensional boss mechanics can temporarily move the player to another arena and then restore the original fight without rebuilding the boss.
- Offline-first. No backend is required for the core game.
- Mobile-first controls and performance.
- Data-driven content so new enemies and encounters can be added without rewriting the core.

## Current state

The first engineering slice establishes deterministic dungeon graphs, budget-based encounters, reusable combat components, five placeholder enemy families, headless tests and CI.

All visuals are intentionally programmer art until the gameplay contracts are stable.

## Desktop prototype controls

- Arrow keys: move
- Enter / Space: fire in the last movement direction

## Development rule

Every system is integrated in small, testable gates. External dependencies are added only when they remove more complexity than they introduce.
