# Architecture

## Goal

Keep the game small enough to ship while making content cheap to expand.

The project deliberately separates systems from content: systems are GDScript and change rarely; content is Resources/scenes and stays cheap to add; procedural generation chooses and combines authored content instead of inventing arbitrary geometry.

## Runtime layers

1. Run seed: one root seed per run, with separate derived RNG streams later for layout, encounters, loot and cosmetics.
2. Dungeon graph: abstract connected graph and room roles, not art or tiles.
3. Encounter director: budget plus enemy costs and role caps.
4. Actors: CharacterBody2D plus reusable health/attack contracts and EnemyDefinition resources.
5. Boss framework: no generic phase invulnerability; explicit arena set pieces; dimensional transitions suspend the original arena rather than rebuilding the boss.

## Dependency policy

Runtime dependencies start at zero. LimboAI, mobile joystick and AdMob are deferred until the relevant gate and must pass Android-export, maintenance and replacement-cost checks.
