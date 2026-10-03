# FINAL SELECTION — Rpg_new

Selección curada de assets listos para integrar en Godot. Generados con PixelLab MCP.

Criterio: un asset FINAL por familia/bioma; variantes alternativas se conservan en disco pero no se integran.
Direcciones: `8` = south, east, north, west + diagonales. Animaciones SOUTH-first (extensible vía animation_group_id).

## PLAYABLES (12)

Cada uno: sprites 8 direcciones en `playables/` + icono en `playables/icons/` + retrato en `playables/portraits/`. Animaciones en `animations/player/<nombre>/`.

| Nombre | Path | Dims | Direcciones | Familia/Bioma | Estado | Notas |
|---|---|---|---|---|---|---|
| playable_alien_adept | `playables/playable_alien_adept.png` | 96x96 | 8 | jugable | FINAL | anims: attack,dash,death,hurt,idle,walk |
| playable_beetle_cyborg | `playables/playable_beetle_cyborg.png` | 96x96 | 8 | jugable | FINAL | anims: attack,dash,death,hurt,idle,walk |
| playable_combat_android | `playables/playable_combat_android.png` | 96x96 | 8 | jugable | FINAL | anims: attack,dash,death,hurt,idle,walk |
| playable_human_ranger | `playables/playable_human_ranger.png` | 96x96 | 8 | jugable | FINAL | anims: attack,dash,death,hurt,idle,walk |
| playable_mutant_striker | `playables/playable_mutant_striker.png` | 96x96 | 8 | jugable | FINAL | anims: attack,dash,death,hurt,idle,walk |
| playable_rift_huntress | `playables/playable_rift_huntress.png` | 96x96 | 8 | jugable | FINAL | anims: attack,dash,death,hurt,idle,walk |
| playable_rogue_drone | `playables/playable_rogue_drone.png` | 96x96 | 8 | jugable | FINAL | anims: attack,dash,death,hurt,idle,walk |
| playable_skeleton_arcanist | `playables/playable_skeleton_arcanist.png` | 96x96 | 8 | jugable | FINAL | anims: attack,dash,death,hurt,idle,walk |
| playable_spore_survivor | `playables/playable_spore_survivor.png` | 96x96 | 8 | jugable | FINAL | anims: attack,dash,death,hurt,idle,walk |
| playable_swat_operative | `playables/playable_swat_operative.png` | 96x96 | 8 | jugable | FINAL | anims: attack,dash,death,hurt,idle,walk |
| playable_tech_monk | `playables/playable_tech_monk.png` | 96x96 | 8 | jugable | FINAL | anims: attack,dash,death,hurt,idle,walk |
| playable_void_entity | `playables/playable_void_entity.png` | 96x96 | 8 | jugable | FINAL | anims: attack,dash,death,hurt,idle,walk |

## ENEMIES (familias finales)

Cinco familias base. Elites homónimos en `enemies/elites/`. Animaciones en `enemies/enemies/...` -> `animations/enemies/`.

| Nombre | Path | Dims | Direcciones | Familia/Bioma | Estado | Notas |
|---|---|---|---|---|---|---|
| enemy_raptor_final | `enemies/enemy_raptor_final.png` | 96x96 | 8 | enemigo base | FINAL | especial: lunge_windup, lunge_attack; anims: attack,death,hurt,idle,lunge_attack,lunge_windup,move |
| enemy_bone_guard_final | `enemies/enemy_bone_guard_final.png` | 96x96 | 8 | enemigo base | FINAL | especial: shield_idle, shield_block, guard_fatigue; anims: attack,death,guard_fatigue,hurt,idle,move,shield_block,shield_idle |
| enemy_root_vine_final | `enemies/enemy_root_vine_final.png` | 96x96 | 8 | enemigo base | FINAL | especial: grab_windup, vine_grab, grab_pull; anims: attack,death,grab_pull,grab_windup,hurt,idle,move,vine_grab |
| enemy_beetle_final | `enemies/enemy_beetle_final.png` | 96x96 | 8 | enemigo base | FINAL | especial: roll_windup, roll, roll_impact, roll_recovery; anims: attack,death,hurt,idle,move,roll,roll_impact,roll_recovery,roll_windup |
| enemy_orb_stalker_final | `enemies/enemy_orb_stalker_final.png` | 96x96 | 8 | enemigo base | FINAL | especial: casting, projectile_attack, teleport; anims: attack,casting,death,hurt,idle,move,projectile_attack,teleport |

## ELITES

| Nombre | Path | Dims | Direcciones | Familia/Bioma | Estado | Notas |
|---|---|---|---|---|---|---|
| enemy_elite_bone_guard_final | `enemies/elites/enemy_elite_bone_guard_final.png` | 128x128 | 8 | elite | FINAL | variante potenciada de la familia base |
| enemy_elite_iron_beetle_final | `enemies/elites/enemy_elite_iron_beetle_final.png` | 128x128 | 8 | elite | FINAL | variante potenciada de la familia base |
| enemy_elite_orb_stalker_final | `enemies/elites/enemy_elite_orb_stalker_final.png` | 128x128 | 8 | elite | FINAL | variante potenciada de la familia base |
| enemy_elite_raptor_final | `enemies/elites/enemy_elite_raptor_final.png` | 128x128 | 8 | elite | FINAL | variante potenciada de la familia base |
| enemy_elite_root_vine_final | `enemies/elites/enemy_elite_root_vine_final.png` | 128x128 | 8 | elite | FINAL | variante potenciada de la familia base |

## MINIBOSESSES

| Nombre | Path | Dims | Direcciones | Familia/Bioma | Estado | Notas |
|---|---|---|---|---|---|---|
| miniboss_trex_final | `bosses/minibosses/miniboss_trex_final.png` | 128x128 | 8 | miniboss | FINAL |  |
| miniboss_beetle_juggernaut_final | `bosses/minibosses/miniboss_beetle_juggernaut_final.png` | 160x160 | 8 | miniboss | FINAL |  |
| miniboss_thorn_maw_final | `bosses/minibosses/miniboss_thorn_maw_final.png` | 160x160 | 8 | miniboss | FINAL |  |
| miniboss_alien_sentinel | `bosses/minibosses/miniboss_alien_sentinel.png` | 160x160 | 8 | miniboss | FINAL |  |
| miniboss_swat_juggernaut | `bosses/minibosses/miniboss_swat_juggernaut.png` | 160x160 | 8 | miniboss | FINAL |  |
| miniboss_zombie_abomination | `bosses/minibosses/miniboss_zombie_abomination.png` | 160x160 | 8 | miniboss | FINAL |  |
| miniboss_trex_v2_final | `bosses/minibosses/trex/miniboss_trex_v2_final.png` | 176x176 | 8 | miniboss (alt) | FINAL | alternativa descartable |

## BOSSES

| Nombre | Path | Dims | Direcciones | Familia/Bioma | Estado | Notas |
|---|---|---|---|---|---|---|
| boss_corrupted_commander | `bosses/final/boss_corrupted_commander.png` | 192x192 | 8 | boss | FINAL | anims: attack,death,hurt,idle,move,phase,special |
| boss_alien_overmind | `bosses/final/boss_alien_overmind.png` | 192x192 | 8 | boss | FINAL | anims: attack,death,hurt,idle,move,phase,special |
| boss_hive_sovereign | `bosses/final/boss_hive_sovereign.png` | 192x192 | 8 | boss | FINAL | anims: attack,death,hurt,idle,move,phase,special |
| boss_bone_monarch | `bosses/final/boss_bone_monarch.png` | 192x192 | 8 | boss | FINAL | anims: attack,death,hurt,idle,move,phase,special |
| boss_elder_thornheart | `bosses/final/boss_elder_thornheart.png` | 192x192 | 8 | boss | FINAL | anims: attack,death,hurt,idle,move,phase,special |
| warden_final_192 (Rift Warden) | `bosses/final/warden_final_192.png` | 192x192 | 8 | boss | FINAL | anims: cast,death,dimensional_cast,hurt,idle_float,phase_transition,projectile_cast,summon,teleport |
| miniboss_trex_final (T-Rex 128) | `bosses/minibosses/miniboss_trex_final.png` | 128x128 | 8 | boss | FINAL | anims: bite,charge,charge_windup,death,heavy_walk,hurt,idle,impact,roar,stunned_recovery |
| miniboss_trex_v2_final (T-Rex grande 176) | `bosses/minibosses/trex/miniboss_trex_v2_final.png` | 176x176 | 8 | boss | FINAL | anims: bite,charge,charge_windup,death,heavy_walk,hurt,idle,impact,roar,stunned_recovery |

## TILES / BIOMAS

Tilesets Wang (PNG+JSON) 32px. Cortar por `bounding_box` del metadata.

| Nombre | Path | Dims | Direcciones | Familia/Bioma | Estado | Notas |
|---|---|---|---|---|---|---|
| lab_contaminated_floor_tileset | `tiles/lab/lab_contaminated_floor_tileset.png` | 128x128 | 16-25 tiles | Ruined Sci-Fi Lab | FINAL | tile 32x32 |
| lab_hazard_floor_tileset | `tiles/lab/lab_hazard_floor_tileset.png` | 128x128 | 16-25 tiles | Ruined Sci-Fi Lab | FINAL | tile 32x32 |
| ruined_lab_tileset | `tiles/lab/ruined_lab_tileset.png` | 128x128 | 16-25 tiles | Ruined Sci-Fi Lab | FINAL | tile 32x32 |
| rift_boss_arena_tileset | `tiles/rift/rift_boss_arena_tileset.png` | 128x128 | 16-25 tiles | Rift Dimension | FINAL | tile 32x32 |
| rift_cyan_floor_tileset | `tiles/rift/rift_cyan_floor_tileset.png` | 128x128 | 16-25 tiles | Rift Dimension | FINAL | tile 32x32 |
| rift_dimension_tileset | `tiles/rift/rift_dimension_tileset.png` | 128x128 | 16-25 tiles | Rift Dimension | FINAL | tile 32x32 |
| rift_violet_floor_tileset | `tiles/rift/rift_violet_floor_tileset.png` | 128x128 | 16-25 tiles | Rift Dimension | FINAL | tile 32x32 |
| root_boss_arena_tileset | `tiles/root/root_boss_arena_tileset.png` | 128x128 | 16-25 tiles | Root / Overgrown Dungeon | FINAL | tile 32x32 |
| root_fungal_floor_tileset | `tiles/root/root_fungal_floor_tileset.png` | 128x128 | 16-25 tiles | Root / Overgrown Dungeon | FINAL | tile 32x32 |
| root_overgrown_tileset | `tiles/root/root_overgrown_tileset.png` | 128x128 | 16-25 tiles | Root / Overgrown Dungeon | FINAL | tile 32x32 |
| root_toxic_floor_tileset | `tiles/root/root_toxic_floor_tileset.png` | 128x128 | 16-25 tiles | Root / Overgrown Dungeon | FINAL | tile 32x32 |
| stone_blood_floor_tileset | `tiles/stone/stone_blood_floor_tileset.png` | 128x128 | 16-25 tiles | Ancient Stone Dungeon | FINAL | tile 32x32 |
| stone_boss_arena_tileset | `tiles/stone/stone_boss_arena_tileset.png` | 128x128 | 16-25 tiles | Ancient Stone Dungeon | FINAL | tile 32x32 |
| stone_dungeon_tileset | `tiles/stone/stone_dungeon_tileset.png` | 128x128 | 16-25 tiles | Ancient Stone Dungeon | FINAL | tile 32x32 |
| stone_moss_floor_tileset | `tiles/stone/stone_moss_floor_tileset.png` | 128x128 | 16-25 tiles | Ancient Stone Dungeon | FINAL | tile 32x32 |
| damaged_walls_tileset | `tiles/walls/damaged_walls_tileset.png` | 128x128 | 16-25 tiles | Structures | FINAL | tile 32x32 |

## ROOM KITS

Piezas modulares por tipo de sala (no son capturas; son piezas reutilizables).

| Nombre | Path | Dims | Direcciones | Familia/Bioma | Estado | Notas |
|---|---|---|---|---|---|---|
| boss_arena_pillar | `rooms/boss_arena_pillar.png` | 128x192 | - | Boss Arena | FINAL |  |
| boss_arena_seal | `rooms/boss_arena_seal.png` | 96x96 | - | Boss Arena | FINAL |  |
| challenge_obelisk | `rooms/challenge_obelisk.png` | 48x80 | - | Challenge Room | FINAL |  |
| challenge_rune_plate | `rooms/challenge_rune_plate.png` | 128x128 | - | Challenge Room | FINAL |  |
| combat_blood_decal | `rooms/combat_blood_decal.png` | 96x96 | - | Standard Combat | FINAL |  |
| combat_scorch_decal | `rooms/combat_scorch_decal.png` | 96x96 | - | Standard Combat | FINAL |  |
| dimensional_pocket_anomaly | `rooms/dimensional_pocket_anomaly.png` | 96x96 | - | Dimensional Pocket | FINAL |  |
| elite_dais | `rooms/elite_dais.png` | 96x64 | - | Elite Room | FINAL |  |
| elite_floor_marker | `rooms/elite_floor_marker.png` | 96x96 | - | Elite Room | FINAL |  |
| entrance_archway | `rooms/entrance_archway.png` | 64x64 | - | Starting/Entrance | FINAL |  |
| event_artifact_stone | `rooms/event_artifact_stone.png` | 128x128 | - | Event Room | FINAL |  |
| event_rune_circle | `rooms/event_rune_circle.png` | 96x96 | - | Event Room | FINAL |  |
| exit_portal | `rooms/exit_portal.png` | 64x80 | - | Exit Room | FINAL |  |
| exit_stairs | `rooms/exit_stairs.png` | 128x128 | - | Exit Room | FINAL |  |
| miniboss_arena_seal | `rooms/miniboss_arena_seal.png` | 192x192 | - | Miniboss Arena | FINAL |  |
| pocket_float_platform | `rooms/pocket_float_platform.png` | 128x128 | - | Dimensional Pocket | FINAL |  |
| secret_false_wall | `rooms/secret_false_wall.png` | 128x128 | - | Secret Room | FINAL |  |
| secret_wall_switch | `rooms/secret_wall_switch.png` | 48x64 | - | Secret Room | FINAL |  |
| starting_waystone | `rooms/starting_waystone.png` | 128x128 | - | Starting Room | FINAL |  |
| trap_pressure_plate | `rooms/trap_pressure_plate.png` | 96x96 | - | Trap Room | FINAL |  |
| treasure_floor_accent | `rooms/treasure_floor_accent.png` | 128x128 | - | Treasure Room | FINAL |  |
| treasure_gold_pile | `rooms/treasure_gold_pile.png` | 64x64 | - | Treasure Room | FINAL |  |

## WEAPONS

28 pickups (mundo) + 28 iconos (inventario) + 14 held/equipped (prioridad).

| Nombre | Path | Dims | Direcciones | Familia/Bioma | Estado | Notas |
|---|---|---|---|---|---|---|

- **Pickups (mundo)**: 28 en `weapons/pickups/`
- **Iconos (inventario)**: 28 en `weapons/icons/`
- **Held/equipped**: 14 en `weapons/held/` -> alien_beam_rifle, arc_rifle, beetle_core, bone_cleaver, bone_rail, breach_shotgun, plasma_baton, pulse_smg, raptor_scatter, rift_sidearm, rift_spear, spore_repeater, swat_carbine, void_launcher
- Held pendientes (baja prioridad, resto del arsenal): beetle_cannon, bone_revolver, bone_scattergun, hive_launcher, living_spore_gun, mutant_claws, orb_projector, skull_caster, spore_smg, swat_compact, tactical_sidearm, toxic_mortar, toxic_scatter, void_pistol

## PROPS

| Nombre | Path | Dims | Direcciones | Familia/Bioma | Estado | Notas |
|---|---|---|---|---|---|---|

### chests (14)

`common_chest`, `common_chest_open`, `corrupted_chest`, `corrupted_chest_open`, `dimensional_chest`, `dimensional_chest_open`, `epic_chest`, `epic_chest_open`, `legendary_chest`, `legendary_chest_open`, `rare_chest`, `rare_chest_open`, `uncommon_chest`, `uncommon_chest_open`

### containers (4)

`barrel`, `broken_barrel`, `broken_crate`, `crate`

### crystals (2)

`cyan_crystal_cluster`, `violet_rift_crystal_cluster`

### dungeon (9)

`banner`, `bench`, `books_scroll`, `broken_statue`, `broken_table`, `candles`, `chains_shackles`, `corpse`, `torn_banner`

### lab (13)

`blast_door`, `broken_generator`, `cable_bundle`, `containment_unit`, `destroyed_terminal`, `electrical_box`, `gas_tanks`, `lab_sliding_door`, `med_equipment`, `pipes`, `security_gate`, `server_rack`, `warning_light`

### lighting (11)

`brazier`, `broken_street_lamp`, `dark_street_lamp`, `emergency_sci_light`, `iron_lamp`, `large_brazier`, `magic_lamp_cyan`, `standing_torch`, `torch_bracket_pair`, `torch_wall`, `violet_rift_lamp`

### organic (11)

`alien_growth`, `cocoon`, `egg_sac`, `giant_root`, `glowing_mushroom_cluster`, `organic_doorway`, `plant_nest`, `poison_pool`, `spore_pods`, `thorny_vegetation`, `toxic_vines`

### pickups (3)

`coin_stack`, `essence_shard`, `health_orb`

### rift (7)

`arcane_device`, `dimensional_fragment`, `dimensional_gate`, `floating_crystals`, `floating_pillar`, `rift_anchor`, `void_debris`

### rubble (3)

`bone_debris`, `skull_pile`, `stone_rubble`

### story (4)

`guardian_statue`, `power_generator`, `sci_fi_terminal`, `stone_altar_relic`

### structures (9)

`boss_gate`, `broken_column`, `event_pedestal`, `lever`, `ruined_arch`, `stone_arch`, `stone_column`, `stone_dungeon_door`, `treasure_pedestal`

### traps (2)

`spike_trap`, `swinging_blade_trap`

## UI / HUD

| Nombre | Path | Dims | Direcciones | Familia/Bioma | Estado | Notas |
|---|---|---|---|---|---|---|

### ui/hud (12)

- `hud_ammo_indicator` (32x32)
- `hud_boss_health_frame` (600x192)
- `hud_boss_name_frame` (384x192)
- `hud_essence_counter_frame` (384x192)
- `hud_health_fill` (128x32)
- `hud_health_frame` (384x192)
- `hud_relic_slot` (32x32)
- `hud_secondary_weapon_slot` (192x192)
- `hud_secondary_weapon_slot_sheet` (192x192)
- `hud_shield_frame` (384x192)
- `hud_weapon_slot` (32x32)
- `ui_slot_frame` (256x256)

### ui/mobile (9)

- `ui_btn_ability` (32x32)
- `ui_btn_dash` (32x32)
- `ui_btn_fire` (32x32)
- `ui_btn_interact` (32x32)
- `ui_btn_melee` (32x32)
- `ui_btn_swap` (32x32)
- `ui_joystick_knob` (32x32)
- `ui_mobile_action_button` (192x192)
- `ui_mobile_joystick` (256x256)

### ui/menu (12)

- `ui_button_states` (384x384)
- `ui_character_card_frame` (192x288)
- `ui_inventory_window` (448x336)
- `ui_minimap_frame` (256x256)
- `ui_popup_frame` (384x288)
- `ui_portrait_frame` (256x256)
- `ui_relic_card` (256x384)
- `ui_reward_card_frame` (448x600)
- `ui_slot_locked` (32x32)
- `ui_slot_selected` (32x32)
- `ui_tooltip_frame` (256x192)
- `ui_weapon_card` (256x384)

### ui/icons (17)

- `icon_ammo` (32x32)
- `icon_currency` (32x32)
- `icon_essence` (32x32)
- `icon_health` (32x32)
- `icon_relic` (32x32)
- `icon_shield` (32x32)
- `mm_player` (32x32)
- `mm_room` (32x32)
- `mm_room_boss` (32x32)
- `mm_room_elite` (32x32)
- `mm_room_event` (32x32)
- `mm_room_exit` (32x32)
- `mm_room_miniboss` (32x32)
- `mm_room_secret` (32x32)
- `mm_room_treasure` (32x32)
- `mm_room_unexplored` (32x32)
- `mm_room_visited` (32x32)

## VFX

| Nombre | Path | Dims | Direcciones | Familia/Bioma | Estado | Notas |
|---|---|---|---|---|---|---|

### bosses (7)

`arena_warning`, `boss_attack_warning`, `boss_death`, `boss_phase_change`, `boss_spawn`, `rift_opening`, `summon_effect`

### combat (12)

`armor_hit`, `blood_hit`, `bullet_impact`, `critical_hit`, `electric_arc`, `energy_impact`, `explosion_fire`, `heavy_explosion`, `hit_spark`, `poison_cloud`, `shield_hit`, `spore_burst`

### magic (4)

`cyan_magic_burst`, `fire`, `rift_energy_burst`, `violet_magic_burst`

### movement (4)

`dash_streak`, `player_spawn`, `speed_streak`, `teleport`

### rewards (8)

`chest_sparkle`, `essence_collect`, `heal`, `loot_glow_epic`, `loot_glow_legendary`, `loot_glow_rare`, `loot_sparkle`, `relic_pickup`

### weapons (4)

`muzzle_flash`, `muzzle_flash_rifle`, `muzzle_flash_shotgun`, `projectile_trail`

## ANIMATIONS

Frames PNG por animación/dirección. Base: asset FINAL, sin rediseño. Todas south-first (direcciones extra añadibles).

| Nombre | Path | Dims | Direcciones | Familia/Bioma | Estado | Notas |
|---|---|---|---|---|---|---|

### player

| Personaje | Animaciones | Frames |
|---|---|---|
| playable_alien_adept | attack, dash, death, hurt, idle, walk | 44 |
| playable_beetle_cyborg | attack, dash, death, hurt, idle, walk | 42 |
| playable_combat_android | attack, dash, death, hurt, idle, walk | 42 |
| playable_human_ranger | attack, dash, death, hurt, idle, walk | 124 |
| playable_mutant_striker | attack, dash, death, hurt, idle, walk | 42 |
| playable_rift_huntress | attack, dash, death, hurt, idle, walk | 42 |
| playable_rogue_drone | attack, dash, death, hurt, idle, walk | 54 |
| playable_skeleton_arcanist | attack, dash, death, hurt, idle, walk | 42 |
| playable_spore_survivor | attack, dash, death, hurt, idle, walk | 42 |
| playable_swat_operative | attack, dash, death, hurt, idle, walk | 42 |
| playable_tech_monk | attack, dash, death, hurt, idle, walk | 42 |
| playable_void_entity | attack, dash, death, hurt, idle, walk | 42 |

### enemies

| Personaje | Animaciones | Frames |
|---|---|---|
| enemy_bone_guard | attack, death, guard_fatigue, hurt, idle, move, shield_block, shield_idle | 56 |
| enemy_iron_beetle | attack, death, hurt, idle, move, roll, roll_impact, roll_recovery, roll_windup | 63 |
| enemy_orb_stalker | attack, casting, death, hurt, idle, move, projectile_attack, teleport | 56 |
| enemy_raptor | attack, death, hurt, idle, lunge_attack, lunge_windup, move | 49 |
| enemy_root_vine | attack, death, grab_pull, grab_windup, hurt, idle, move, vine_grab | 56 |

### bosses

| Personaje | Animaciones | Frames |
|---|---|---|
| boss_alien_overmind | attack, death, hurt, idle, move, phase, special | 49 |
| boss_bone_monarch | attack, death, hurt, idle, move, phase, special | 49 |
| boss_corrupted_commander | attack, death, hurt, idle, move, phase, special | 49 |
| boss_elder_thornheart | attack, death, hurt, idle, move, phase, special | 49 |
| boss_hive_sovereign | attack, death, hurt, idle, move, phase, special | 49 |
| boss_rift_warden | cast, death, dimensional_cast, hurt, idle_float, phase_transition, projectile_cast, summon, teleport | 63 |
| boss_trex | bite, charge, charge_windup, death, heavy_walk, hurt, idle, impact, roar, stunned_recovery | 70 |
| boss_trex_grande | bite, charge, charge_windup, death, heavy_walk, hurt, idle, impact, roar, stunned_recovery | 70 |

## PENDIENTES / NOTAS

- Animaciones en SOUTH-first (4 direcciones solo en `walk`/`attack` de human_ranger). Ampliar con `animate_character(..., animation_group_id=..., directions=[...])`.
- Elites y minibosses sin animar (solo familias base + bosses).
- Held variants para el resto del arsenal (14/28 prioridad).
- Previews de contacto en `previews/final/` (rosters, biomas, HUD, VFX, rooms, anims).
- UI: slot secundario de arma añadido (`ui/hud/hud_secondary_weapon_slot`); el "treasure reward card" reutiliza `ui_reward_card_frame`.
- Props de arquitectura por bioma añadidos (arches, puertas lab, pool, root, rift).

