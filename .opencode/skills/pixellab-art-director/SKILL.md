---
name: pixellab-art-director
description: Generate consistent PixelLab assets for Rpg_new using the PixelLab MCP.
---

# Rpg_new Visual Direction

Use PixelLab MCP for all image generation.

Never manually draw or edit assets.

## Global style

Premium pixel-art dark fantasy sci-fi roguelite.
Top-down / 3/4 perspective.
Mobile-first readability.
Dark dungeon environments.
Warm torch lighting.
Cyan and violet magical accents.
Strong silhouettes.
Consistent pixel density.

All characters, monsters, bosses, props and VFX must look like they belong to the same game.

## Characters

Use transparent backgrounds.

Normal enemies:
- readable around 48–72 px
- clear silhouette
- same perspective
- same lighting

Bosses:
- larger scale
- stronger silhouette
- same visual language

## Enemy roster

- Raptor Scout
- Bone Guard
- Root Vine
- Iron Beetle
- Orb Stalker

## Bosses

- T-Rex
- Rift Warden

## Workflow

1. Generate several variants.
2. Compare them against the established visual anchor.
3. Select the most consistent candidate.
4. Use that candidate as reference for subsequent generations.
5. Generate required animations.
6. Do not redesign already approved characters unless explicitly requested.

## Required animations

Player:
- idle
- walk
- shoot
- dash
- hurt
- death

Enemies:
- idle
- move
- attack
- hurt
- death

## Restrictions

Do not edit Godot.
Do not edit source code.
Do not commit.
Do not push.
Do not use other image generators.
Use PixelLab MCP only.
