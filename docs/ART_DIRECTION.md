# Art direction contract

This document protects the visual direction approved for the game before final assets replace programmer art.

## Core look

- 2D top-down action with a slight three-quarter feeling in characters and props.
- Stylized premium cartoon rendering rather than photorealism.
- Dark dungeon floors with saturated magical, biological and technological accents.
- Chunky readable silhouettes designed first for a phone screen.
- Strong contrast between actor, projectile, telegraph and floor.
- No tiny decorative detail that disappears at gameplay scale.

## Gameplay readability wins over illustration

Attack telegraphs, danger areas, interaction rings and boss mechanics remain code-driven overlays. They should not be baked permanently into sprites.

A player should identify, at a glance:

- what can hurt them;
- what can be interacted with;
- which enemy family they are facing;
- whether an enemy is winding up, attacking or recovering;
- what reward category a pedestal represents.

## Scale targets

At the 960x540 reference viewport:

- Player visual footprint: roughly 32–52 px.
- Standard enemy: roughly 42–72 px.
- Heavy enemy: roughly 64–90 px.
- T-Rex boss: roughly 140–190 px.
- Rift Warden: roughly 110–160 px.
- Primary room rhythm: 48 px.

Collision shapes should remain smaller and simpler than decorative silhouettes.

## Family identity

### Dinosaurs
- muscular forward silhouettes;
- strong tails and heads;
- warm organic greens, ochres and warning reds;
- aggressive motion arcs.

### Plants
- radial silhouettes;
- roots and vines visibly communicate grab range;
- toxic greens with sickly yellow highlights.

### Aliens
- smooth or impossible geometry;
- violet and cyan energy;
- obvious teleport and ranged cues.

### Skeletons
- readable ivory bone shapes;
- heavy shield language;
- less visual noise than exotic families so they work as pacing anchors.

### Insects
- layered armor plates;
- orange and amber shell highlights;
- clear closed-shell versus vulnerable recovery states.

## Boss language

Bosses should be visually larger, but their danger comes from readable mechanics rather than screen-filling clutter.

- T-Rex: physical mass, momentum, dust and charge lane.
- Rift Warden: floating core, orbiting fragments and dimensional color shifts.

Bosses never need an invulnerability visual because phase changes do not grant generic immunity.

## Rooms

Room identity maps to the current code palette:

- Start: cyan and blue.
- Combat: steel blue.
- Event: violet.
- Treasure: gold.
- Miniboss: orange and red.
- Final boss: magenta and violet.

Final tiles can become much richer, but those information colors should remain recognizable.

## Reward language

- Weapon pedestal: orange.
- Modifier/relic pedestal: violet.
- Utility/essence/event effect: green.

## Asset replacement strategy

Final art should replace one family at a time:

1. player;
2. projectiles and weapons;
3. five base enemies;
4. T-Rex;
5. Rift Warden;
6. room tiles and props;
7. reward props;
8. VFX.

Do not replace everything simultaneously. Each replacement gate must keep collisions, telegraphs and Android readability unchanged.
