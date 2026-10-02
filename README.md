# Rpg_new

Mobile-first 2D action roguelite built with Godot 4.

## Product pillars

- Short, replayable dungeon runs with handcrafted rooms assembled procedurally.
- Distinct enemy families: dinosaurs, alien creatures, carnivorous plants, skeletons and insects.
- Bosses remain damageable: difficulty comes from patterns, arena interactions and enemy composition, not forced invulnerability.
- Interactive boss arenas: levers, scripted breakable set pieces and special charge interactions.
- A dimensional final boss can move the player into temporary combat arenas, then return to the same boss fight with state preserved.
- Offline-first. No backend is required for the core game.
- Mobile-first controls and performance from the beginning.
- Data-driven content so new enemies, rooms and encounters can be added without rewriting core systems.

## Development rule

Every system is integrated in small, testable gates. External dependencies are added only when they remove more complexity than they introduce.
