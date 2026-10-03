#!/bin/zsh
# Genera FINAL_SELECTION.md a partir de los assets finales en assets/generated/
set -e
cd "$(dirname "$0")/.."

python3 - <<'PY'
import os, glob, struct, json
from collections import OrderedDict

ROOT = os.path.join(os.getcwd(), "generated")

def png_size(p):
    try:
        with open(p,'rb') as f:
            head = f.read(26)
        if head[:8] != b'\x89PNG\r\n\x1a\n': return None
        w,h = struct.unpack('>II', head[16:24])
        return (w,h)
    except Exception:
        return None

def dirs_for(base):
    """devuelve direcciones disponibles para un base name en su carpeta"""
    return None

def row(path, name, family, notes="", dirs=""):
    sz = png_size(path)
    dim = f"{sz[0]}x{sz[1]}" if sz else "?"
    return f"| {name} | `{os.path.relpath(path, ROOT)}` | {dim} | {dirs} | {family} | FINAL | {notes} |"

def section(title, header_note=""):
    out = [f"\n## {title}\n"]
    if header_note: out.append(header_note+"\n")
    out.append("| Nombre | Path | Dims | Direcciones | Familia/Bioma | Estado | Notas |")
    out.append("|---|---|---|---|---|---|---|")
    return out

lines = []
lines.append("# FINAL SELECTION — Rpg_new")
lines.append("")
lines.append("Selección curada de assets listos para integrar en Godot. Generados con PixelLab MCP.")
lines.append("")
lines.append("Criterio: un asset FINAL por familia/bioma; variantes alternativas se conservan en disco pero no se integran.")
lines.append("Direcciones: `8` = south, east, north, west + diagonales. Animaciones SOUTH-first (extensible vía animation_group_id).")

# PLAYABLES
lines += section("PLAYABLES (12)", "Cada uno: sprites 8 direcciones en `playables/` + icono en `playables/icons/` + retrato en `playables/portraits/`. Animaciones en `animations/player/<nombre>/`.")
for p in sorted(glob.glob(os.path.join(ROOT,"playables","playable_*.png"))):
    b = os.path.basename(p)[:-4]
    if any(b.endswith("_"+d) for d in ["south","north","east","west","south-east","south-west","north-east","north-west"]): continue
    anim_dir = os.path.join(ROOT,"animations","player",b)
    anims = ",".join(sorted(os.listdir(anim_dir))) if os.path.isdir(anim_dir) else "-"
    lines.append(row(p, b, "jugable", dirs="8", notes=f"anims: {anims}"))

# ENEMIES
lines += section("ENEMIES (familias finales)", "Cinco familias base. Elites homónimos en `enemies/elites/`. Animaciones en `enemies/enemies/...` -> `animations/enemies/`.")
fam_notes = {
 "enemy_raptor": "especial: lunge_windup, lunge_attack",
 "enemy_bone_guard": "especial: shield_idle, shield_block, guard_fatigue",
 "enemy_root_vine": "especial: grab_windup, vine_grab, grab_pull",
 "enemy_iron_beetle": "especial: roll_windup, roll, roll_impact, roll_recovery",
 "enemy_orb_stalker": "especial: casting, projectile_attack, teleport",
}
fam_map = {
 "enemy_raptor": ("enemy_raptor_final", "especial: lunge_windup, lunge_attack"),
 "enemy_bone_guard": ("enemy_bone_guard_final", "especial: shield_idle, shield_block, guard_fatigue"),
 "enemy_root_vine": ("enemy_root_vine_final", "especial: grab_windup, vine_grab, grab_pull"),
 "enemy_iron_beetle": ("enemy_beetle_final", "especial: roll_windup, roll, roll_impact, roll_recovery"),
 "enemy_orb_stalker": ("enemy_orb_stalker_final", "especial: casting, projectile_attack, teleport"),
}
for aname, (fname, note) in fam_map.items():
    p = os.path.join(ROOT,"enemies", fname+".png")
    if not os.path.exists(p): continue
    anim_dir = os.path.join(ROOT,"animations","enemies",aname)
    anims = ",".join(sorted(os.listdir(anim_dir))) if os.path.isdir(anim_dir) else "-"
    lines.append(row(p, fname, "enemigo base", dirs="8", notes=f"{note}; anims: {anims}"))

# ELITES
lines += section("ELITES")
for p in sorted(glob.glob(os.path.join(ROOT,"enemies","elites","enemy_elite_*_final.png"))):
    b = os.path.basename(p)[:-4]
    lines.append(row(p, b, "elite", dirs="8", notes="variante potenciada de la familia base"))

# MINIBOSSES
lines += section("MINIBOSESSES")
mb = [os.path.join(ROOT,"bosses","minibosses",n+".png") for n in
      ["miniboss_trex_final","miniboss_beetle_juggernaut_final","miniboss_thorn_maw_final",
       "miniboss_alien_sentinel","miniboss_swat_juggernaut","miniboss_zombie_abomination"]]
for p in mb:
    if os.path.exists(p):
        lines.append(row(p, os.path.basename(p)[:-4], "miniboss", dirs="8", notes=""))
extra = os.path.join(ROOT,"bosses","minibosses","trex")
if os.path.isdir(extra):
    for p in sorted(glob.glob(os.path.join(extra,"miniboss_trex_v2_final.png"))):
        lines.append(row(p, "miniboss_trex_v2_final", "miniboss (alt)", dirs="8", notes="alternativa descartable"))

# BOSSES
lines += section("BOSSES")
boss_files = [
 ("boss_corrupted_commander", "bosses/final/boss_corrupted_commander.png", "bosses/boss_corrupted_commander"),
 ("boss_alien_overmind", "bosses/final/boss_alien_overmind.png", "bosses/boss_alien_overmind"),
 ("boss_hive_sovereign", "bosses/final/boss_hive_sovereign.png", "bosses/boss_hive_sovereign"),
 ("boss_bone_monarch", "bosses/final/boss_bone_monarch.png", "bosses/boss_bone_monarch"),
 ("boss_elder_thornheart", "bosses/final/boss_elder_thornheart.png", "bosses/boss_elder_thornheart"),
 ("warden_final_192 (Rift Warden)", "bosses/final/warden_final_192.png", "bosses/boss_rift_warden"),
 ("miniboss_trex_final (T-Rex 128)", "bosses/minibosses/miniboss_trex_final.png", "bosses/boss_trex"),
 ("miniboss_trex_v2_final (T-Rex grande 176)", "bosses/minibosses/trex/miniboss_trex_v2_final.png", "bosses/boss_trex_grande"),
]
for name, rel, anim_rel in boss_files:
    p = os.path.join(ROOT, rel)
    if not os.path.exists(p): continue
    anim_dir = os.path.join(ROOT,"animations",anim_rel)
    anims = ",".join(sorted(os.listdir(anim_dir))) if os.path.isdir(anim_dir) else "-"
    lines.append(row(p, name, "boss", dirs="8", notes=f"anims: {anims}"))

# TILES
lines += section("TILES / BIOMAS", "Tilesets Wang (PNG+JSON) 32px. Cortar por `bounding_box` del metadata.")
biome = {"stone":"Ancient Stone Dungeon","root":"Root / Overgrown Dungeon","lab":"Ruined Sci-Fi Lab","rift":"Rift Dimension","walls":"Structures"}
for d in sorted(os.listdir(os.path.join(ROOT,"tiles"))):
    dp = os.path.join(ROOT,"tiles",d)
    if not os.path.isdir(dp): continue
    for p in sorted(glob.glob(os.path.join(dp,"*.png"))):
        b = os.path.basename(p)[:-4]
        js = p[:-4]+".json"
        ntiles = "?"
        if os.path.exists(js):
            try:
                m = json.load(open(js))
                ts = m.get("tile_size",{}); ntiles = f"tile {ts.get('width')}x{ts.get('height')}"
            except Exception: pass
        lines.append(row(p, b, biome.get(d,d), dirs="16-25 tiles", notes=ntiles))

# ROOMS
lines += section("ROOM KITS", "Piezas modulares por tipo de sala (no son capturas; son piezas reutilizables).")
room_notes = {
 "starting_waystone":"Starting Room","entrance_archway":"Starting/Entrance",
 "combat_blood_decal":"Standard Combat","combat_scorch_decal":"Standard Combat",
 "elite_dais":"Elite Room","elite_floor_marker":"Elite Room",
 "treasure_gold_pile":"Treasure Room","treasure_floor_accent":"Treasure Room",
 "event_rune_circle":"Event Room","event_artifact_stone":"Event Room",
 "challenge_obelisk":"Challenge Room","challenge_rune_plate":"Challenge Room",
 "trap_pressure_plate":"Trap Room","secret_wall_switch":"Secret Room","secret_false_wall":"Secret Room",
 "miniboss_arena_seal":"Miniboss Arena","boss_arena_seal":"Boss Arena","boss_arena_pillar":"Boss Arena",
 "dimensional_pocket_anomaly":"Dimensional Pocket","pocket_float_platform":"Dimensional Pocket",
 "exit_portal":"Exit Room","exit_stairs":"Exit Room",
}
for p in sorted(glob.glob(os.path.join(ROOT,"rooms","*.png"))):
    b = os.path.basename(p)[:-4]
    lines.append(row(p, b, room_notes.get(b,"sala"), dirs="-", notes=""))

# WEAPONS
lines += section("WEAPONS", "28 pickups (mundo) + 28 iconos (inventario) + 14 held/equipped (prioridad).")
icons = sorted(os.path.basename(p)[:-4] for p in glob.glob(os.path.join(ROOT,"weapons","icons","*.png")))
pickups = sorted(os.path.basename(p)[:-4] for p in glob.glob(os.path.join(ROOT,"weapons","pickups","*.png")))
held = sorted(os.path.basename(p)[:-4] for p in glob.glob(os.path.join(ROOT,"weapons","held","*.png")))
lines.append(f"\n- **Pickups (mundo)**: {len(pickups)} en `weapons/pickups/`")
lines.append(f"- **Iconos (inventario)**: {len(icons)} en `weapons/icons/`")
lines.append(f"- **Held/equipped**: {len(held)} en `weapons/held/` -> {', '.join(held)}")
missing_held = [i for i in icons if i not in held]
lines.append(f"- Held pendientes (baja prioridad, resto del arsenal): {', '.join(missing_held) if missing_held else 'ninguno'}")

# PROPS
lines += section("PROPS")
for d in sorted(os.listdir(os.path.join(ROOT,"props"))):
    dp = os.path.join(ROOT,"props",d)
    if not os.path.isdir(dp): continue
    files = sorted(os.path.basename(p)[:-4] for p in glob.glob(os.path.join(dp,"*.png")))
    lines.append(f"\n### {d} ({len(files)})\n")
    lines.append(", ".join(f"`{f}`" for f in files))

# UI
lines += section("UI / HUD")
for d in ["hud","mobile","menu","icons"]:
    dp = os.path.join(ROOT,"ui",d)
    if not os.path.isdir(dp): continue
    files = sorted(os.path.basename(p)[:-4] for p in glob.glob(os.path.join(dp,"*.png")))
    lines.append(f"\n### ui/{d} ({len(files)})\n")
    for f in files:
        p = os.path.join(dp,f+".png")
        sz = png_size(p); dim = f"{sz[0]}x{sz[1]}" if sz else "?"
        lines.append(f"- `{f}` ({dim})")

# VFX
lines += section("VFX")
for d in sorted(os.listdir(os.path.join(ROOT,"vfx"))):
    dp = os.path.join(ROOT,"vfx",d)
    if not os.path.isdir(dp): continue
    files = sorted(os.path.basename(p)[:-4] for p in glob.glob(os.path.join(dp,"*.png")))
    lines.append(f"\n### {d} ({len(files)})\n")
    lines.append(", ".join(f"`{f}`" for f in files))

# ANIMATIONS
lines += section("ANIMATIONS", "Frames PNG por animación/dirección. Base: asset FINAL, sin rediseño. Todas south-first (direcciones extra añadibles).")
for cat in ["player","enemies","bosses"]:
    base = os.path.join(ROOT,"animations",cat)
    if not os.path.isdir(base): continue
    lines.append(f"\n### {cat}\n")
    lines.append("| Personaje | Animaciones | Frames |")
    lines.append("|---|---|---|")
    for name in sorted(os.listdir(base)):
        nd = os.path.join(base,name)
        if not os.path.isdir(nd): continue
        anims = sorted(os.listdir(nd))
        nf = sum(len(glob.glob(os.path.join(nd,a,"*","frame_*.png"))) for a in anims)
        lines.append(f"| {name} | {', '.join(anims)} | {nf} |")

# PENDIENTES
lines += ["\n## PENDIENTES / NOTAS\n", """- Animaciones en SOUTH-first (4 direcciones solo en `walk`/`attack` de human_ranger). Ampliar con `animate_character(..., animation_group_id=..., directions=[...])`.
- Elites y minibosses sin animar (solo familias base + bosses).
- Held variants para el resto del arsenal (14/28 prioridad).
- Previews de contacto en `previews/final/` (rosters, biomas, HUD, VFX, rooms, anims).
- UI: slot secundario de arma añadido (`ui/hud/hud_secondary_weapon_slot`); el "treasure reward card" reutiliza `ui_reward_card_frame`.
- Props de arquitectura por bioma añadidos (arches, puertas lab, pool, root, rift).
"""]

out = os.path.join(ROOT,"FINAL_SELECTION.md")
open(out,"w").write("\n".join(lines)+"\n")
print("written", out, len(lines), "lines")
PY
