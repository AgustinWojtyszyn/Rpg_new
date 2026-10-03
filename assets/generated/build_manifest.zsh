#!/usr/bin/env zsh
# Regenera ASSET_MANIFEST.md a partir del contenido real de assets/generated/.
# Uso: zsh assets/generated/build_manifest.zsh
set -e
ROOT="${0:A:h}"
OUT="$ROOT/ASSET_MANIFEST.md"

DIRS=(
  "playables:Personajes jugables:create_character (8dir)"
  "playables/portraits:Retratos de personajes:create_portrait_character"
  "player:Player de referencia:create_character (8dir)"
  "enemies:Enemigos base:create_character (8dir)"
  "enemies/elites:Elites:create_character (8dir, 128px)"
  "enemies/zombies:Zombies:create_character (8dir)"
  "enemies/plants:Plantas:create_character (8dir)"
  "enemies/swat:SWAT / tactical:create_character (8dir)"
  "enemies/aliens:Aliens:create_character (8dir)"
  "enemies/insects:Insectoides:create_character (8dir)"
  "enemies/undead:Undead:create_character (8dir)"
  "bosses/minibosses:Minibosses:create_character (8dir, 160-176px)"
  "bosses/final:Bosses:create_character (8dir, 128-192px)"
  "props/chests:Cofres:create_map_object"
  "props/containers:Contenedores:create_map_object"
  "props/lighting:Iluminación:create_map_object"
  "props/structures:Estructuras:create_map_object"
  "props/rubble:Escombros:create_map_object"
  "props/organic:Props orgánicos:create_map_object"
  "props/crystals:Cristales:create_map_object"
  "props/pickups:Pickups:create_map_object"
  "props/traps:Trampas:create_map_object"
  "props/story:Storytelling:create_map_object"
  "props/dungeon:Props de mazmorra:create_map_object"
  "props/lab:Props de laboratorio:create_map_object"
  "props/rift:Props de rift:create_map_object"
  "weapons:Armas:create_map_object"
  "weapons/held:Armas en mano:create_map_object"
  "weapons/icons:Iconos de armas:create_image_pixflux"
  "weapons/pickups:Armas world pickup:create_map_object"
  "tiles/stone:Bioma dungeon stone:create_topdown_tileset"
  "tiles/root:Bioma root/overgrown:create_topdown_tileset"
  "tiles/lab:Bioma lab sci-fi:create_topdown_tileset"
  "tiles/rift:Bioma rift:create_topdown_tileset"
  "tiles/walls:Paredes y variaciones:create_topdown_tileset"
  "rooms:Room kits:create_map_object"
  "ui/hud:HUD:create_image_pixflux"
  "ui/icons:Iconos UI:create_image_pixflux"
  "ui/menu:Menús y frames:create_image_pixflux"
  "ui/mobile:Controles móviles:create_image_pixflux"
  "vfx/combat:VFX combate:create_image_pixflux"
  "vfx/weapons:VFX armas:create_image_pixflux"
  "vfx/magic:VFX magia:create_image_pixflux"
  "vfx/movement:VFX movimiento:create_image_pixflux"
  "vfx/bosses:VFX bosses:create_image_pixflux"
  "vfx/rewards:VFX recompensas:create_image_pixflux"
)

ANIM_DIRS=(
  "animations/player:Animaciones jugables"
  "animations/enemies:Animaciones enemigos"
  "animations/bosses:Animaciones bosses"
)

DIRPAT='_(north-west|north-east|south-west|south-east|north|south|east|west)\.png$'

emit_group() {
  local dir="$1" label="$2" tool="$3"
  local abs="$ROOT/$dir"
  local n st nd dims
  [[ -d "$abs" ]] || return 0
  local -a bases
  # archivos base = los que NO son una dirección
  bases=($(cd "$abs" && ls *.png 2>/dev/null | grep -vE "$DIRPAT" | sed 's/\.png$//' | sort))
  (( ${#bases} == 0 )) && return 0
  echo ""
  echo "### $label"
  echo ""
  echo "Dir: \`assets/generated/$dir/\` · Herramienta: $tool"
  echo ""
  echo "| asset | categoría | herramienta | dims | direcciones | path | status |"
  echo "|---|---|---|---|---|---|---|"
  for b in "${bases[@]}"; do
    n=0
    for d in north-west north-east south-west south-east north south east west; do
      if [[ -f "$abs/${b}_${d}.png" ]]; then n=$((n+1)); fi
    done
    dims=$(file -b "$abs/${b}.png" 2>/dev/null | grep -oE '[0-9]+ ?x ?[0-9]+' | head -1 | tr -d ' ')
    st="complete"
    if [[ "$n" -gt 0 && "$n" -lt 8 ]]; then
      st="partial ($n/8 dirs)"
    fi
    nd="$n"
    if [[ "$n" -eq 0 ]]; then nd="-"; fi
    printf '| %s | %s | %s | %s | %s | `assets/generated/%s/%s.png` | %s |\n' \
      "$b" "$label" "$tool" "${dims:-?}" "$nd" "$dir" "$b" "$st"
  done
}

emit_anim() {
  local dir="$1" label="$2"
  local abs="$ROOT/$dir"
  [[ -d "$abs" ]] || return 0
  local -a chars
  chars=($(cd "$abs" 2>/dev/null && ls -d */ 2>/dev/null | tr -d '/' | sort))
  (( ${#chars} == 0 )) && return 0
  echo ""
  echo "### $label"
  echo ""
  echo "Dir: \`assets/generated/$dir/\` · Herramienta: animate_character (template + v3)"
  echo ""
  echo "| asset | categoría | herramienta | anims | frames | direcciones | path | status |"
  echo "|---|---|---|---|---|---|---|---|"
  for c in "${chars[@]}"; do
    local anims nf dirs
    anims=$(ls -1 "$abs/$c" 2>/dev/null | tr '\n' ',' | sed 's/,$//')
    nf=$(find "$abs/$c" -name 'frame_*.png' 2>/dev/null | wc -l | tr -d ' ')
    dirs=$(find "$abs/$c" -mindepth 2 -maxdepth 2 -type d 2>/dev/null | xargs -r -n1 basename | sort -u | tr '\n' ',' | sed 's/,$//')
    printf '| %s | %s | animate_character | %s | %s | %s | `assets/generated/%s/%s/` | complete |\n' \
      "$c" "$label" "$anims" "$nf" "${dirs:-south}" "$dir" "$c"
  done
}

{
  echo "# ASSET MANIFEST — Rpg_new"
  echo ""
  echo "Generado automáticamente por \`assets/generated/build_manifest.zsh\`."
  echo "Estilo: premium pixel-art dark fantasy sci-fi roguelite, top-down / 3/4, mobile-first."
  echo ""
  echo "Última actualización: $(date '+%Y-%m-%d %H:%M')"
  for entry in "${DIRS[@]}"; do
    IFS=':' read -r d l t <<< "$entry"
    emit_group "$d" "$l" "$t"
  done
  for entry in "${ANIM_DIRS[@]}"; do
    IFS=':' read -r d l <<< "$entry"
    emit_anim "$d" "$l"
  done
} > "$OUT"

echo "escrito $OUT ($(grep -c '^| ' "$OUT") filas)"
