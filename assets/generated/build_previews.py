#!/usr/bin/env python3
"""Genera previews de contacto bajo assets/generated/previews/final/ (solo compone assets existentes)."""
import os, glob
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)))
GEN = os.path.join(ROOT)  # assets/generated
OUT = os.path.join(GEN, "previews", "final")
os.makedirs(OUT, exist_ok=True)

BG = (18, 18, 24, 255)
CELL_PAD = 10
LABEL_H = 14
COLS = 6
CELL = 160

def font(size=11):
    for p in ["/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
              "/usr/share/fonts/dejavu/DejaVuSans.ttf"]:
        if os.path.exists(p):
            try: return ImageFont.truetype(p, size)
            except Exception: pass
    return ImageFont.load_default()

F = font(11)
FT = font(16)

def sheet(items, out_name, title, cols=COLS, cell=CELL, bg=BG):
    """items: list of (label, path)"""
    items = [(l, p) for l, p in items if os.path.exists(p)]
    if not items:
        print("skip", out_name); return
    rows = (len(items) + cols - 1) // cols
    w = cols * (cell + CELL_PAD) + CELL_PAD
    h = rows * (cell + CELL_PAD + LABEL_H) + CELL_PAD + 30
    img = Image.new("RGBA", (w, h), bg)
    d = ImageDraw.Draw(img)
    d.text((CELL_PAD, 6), title, font=FT, fill=(120, 230, 255, 255))
    for i, (label, path) in enumerate(items):
        r, c = divmod(i, cols)
        x = CELL_PAD + c * (cell + CELL_PAD)
        y = 30 + CELL_PAD + r * (cell + CELL_PAD + LABEL_H)
        # casilla de fondo ligeramente más clara
        d.rectangle([x, y, x + cell, y + cell], fill=(30, 30, 40, 255))
        try:
            im = Image.open(path).convert("RGBA")
            im.thumbnail((cell - 8, cell - 8), Image.LANCZOS)
            img.alpha_composite(im, (x + (cell - im.width)//2, y + (cell - im.height)//2))
        except Exception as e:
            d.text((x+4, y+4), "err", font=F, fill=(255,80,80,255))
        d.text((x+2, y+cell+1), label[:24], font=F, fill=(200, 200, 210, 255))
    img.save(os.path.join(OUT, out_name))
    print("ok", out_name, img.size)

def named(base_dir, names, suffix=""):
    out = []
    for n in names:
        p = os.path.join(base_dir, n + suffix + ".png")
        out.append((n + suffix, p))
    return out

# 1) PLAYABLES
playables = sorted(os.path.basename(p)[:-4] for p in glob.glob(os.path.join(GEN,"playables","playable_*.png")))
playables = [p for p in playables if not any(p.endswith("_"+d) for d in ["south","north","east","west","south-east","south-west","north-east","north-west"])]
sheet([(p, os.path.join(GEN,"playables",p+".png")) for p in playables],
      "playable_roster.png", "PLAYABLE ROSTER (12) - south", cols=6)

# 2) ENEMIGOS + ELITES
en = sorted(os.path.basename(p)[:-4] for p in glob.glob(os.path.join(GEN,"enemies","enemy_*_final.png")))
en = [e for e in en if not any(e.endswith("_"+d) for d in ["south","north","east","west","south-east","south-west","north-east","north-west"])]
el = sorted(os.path.basename(p)[:-4] for p in glob.glob(os.path.join(GEN,"enemies","elites","*.png")))
el = [e for e in el if not any(e.endswith("_"+d) for d in ["south","north","east","west","south-east","south-west","north-east","north-west"])]
items = [(e, os.path.join(GEN,"enemies",e+".png")) for e in en] + [(e, os.path.join(GEN,"enemies","elites",e+".png")) for e in el]
sheet(items, "enemy_roster.png", "ENEMIES + ELITES - south", cols=6)

# 3) BOSSES + MINIBOSSES
bosses = ["boss_corrupted_commander","boss_alien_overmind","boss_hive_sovereign","boss_bone_monarch","boss_elder_thornheart","warden_final_192"]
items = [(b, os.path.join(GEN,"bosses","final",b+".png")) for b in bosses]
mb = ["miniboss_trex_final","miniboss_beetle_juggernaut_final","miniboss_thorn_maw_final","miniboss_alien_sentinel","miniboss_swat_juggernaut","miniboss_zombie_abomination"]
items += [(m, os.path.join(GEN,"bosses","minibosses",m+".png")) for m in mb]
items.append(("miniboss_trex_v2_final (grande)", os.path.join(GEN,"bosses","minibosses","trex","miniboss_trex_v2_final.png")))
sheet(items, "bosses.png", "BOSSES + MINIBOSSES - south", cols=6, cell=180)

# 4) ARMAS (iconos)
icons = sorted(os.path.basename(p)[:-4] for p in glob.glob(os.path.join(GEN,"weapons","icons","*.png")))
sheet([(i, os.path.join(GEN,"weapons","icons",i+".png")) for i in icons],
      "weapons_icons.png", "WEAPON ICONS (28)", cols=7, cell=96)
held = sorted(os.path.basename(p)[:-4] for p in glob.glob(os.path.join(GEN,"weapons","held","*.png")))
sheet([(i, os.path.join(GEN,"weapons","held",i+".png")) for i in held],
      "weapons_held.png", "WEAPONS HELD (14)", cols=7, cell=110)

# 5) TILESETS POR BIOMA
for biome, title in [("stone","STONE DUNGEON"),("root","ROOT DUNGEON"),("lab","RUINED SCI-FI LAB"),("rift","RIFT DIMENSION"),("walls","WALLS")]:
    ps = sorted(glob.glob(os.path.join(GEN,"tiles",biome,"*.png")))
    sheet([(os.path.basename(p)[:-4], p) for p in ps], f"tiles_{biome}.png", title + " TILESETS", cols=3, cell=220)

# 6) ROOMS
rooms = sorted(os.path.basename(p)[:-4] for p in glob.glob(os.path.join(GEN,"rooms","*.png")))
sheet([(r, os.path.join(GEN,"rooms",r+".png")) for r in rooms],
      "room_types.png", "ROOM KIT PIECES", cols=6, cell=130)

# 7) UI: HUD / MOBILE / MENU
hud = sorted(os.path.basename(p)[:-4] for p in glob.glob(os.path.join(GEN,"ui","hud","*.png")))
sheet([(r, os.path.join(GEN,"ui","hud",r+".png")) for r in hud], "hud.png", "HUD", cols=5, cell=170)
mob = sorted(os.path.basename(p)[:-4] for p in glob.glob(os.path.join(GEN,"ui","mobile","*.png")))
sheet([(r, os.path.join(GEN,"ui","mobile",r+".png")) for r in mob], "mobile_controls.png", "MOBILE CONTROLS", cols=5, cell=120)
menu = sorted(os.path.basename(p)[:-4] for p in glob.glob(os.path.join(GEN,"ui","menu","*.png")))
sheet([(r, os.path.join(GEN,"ui","menu",r+".png")) for r in menu], "menus.png", "MENUS / CARDS", cols=5, cell=170)
ic = sorted(os.path.basename(p)[:-4] for p in glob.glob(os.path.join(GEN,"ui","icons","*.png")))
sheet([(r, os.path.join(GEN,"ui","icons",r+".png")) for r in ic], "ui_icons.png", "UI / MINIMAP ICONS", cols=6, cell=72)

# 8) VFX (fondo oscuro para ver transparencias)
for sub in sorted(os.listdir(os.path.join(GEN,"vfx"))):
    dp = os.path.join(GEN,"vfx",sub)
    if not os.path.isdir(dp): continue
    ps = sorted(glob.glob(os.path.join(dp,"*.png")))
    sheet([(os.path.basename(p)[:-4], p) for p in ps], f"vfx_{sub}.png", f"VFX - {sub.upper()}", cols=7, cell=80)

# 9) PROPS (por subcarpeta, fondo oscuro)
for sub in sorted(os.listdir(os.path.join(GEN,"props"))):
    dp = os.path.join(GEN,"props",sub)
    if not os.path.isdir(dp): continue
    ps = sorted(glob.glob(os.path.join(dp,"*.png")))
    if not ps: continue
    sheet([(os.path.basename(p)[:-4], p) for p in ps], f"props_{sub}.png", f"PROPS - {sub.upper()}", cols=7, cell=110)

# 10) ANIMATIONS: tira de frames de idle de un playable y de un boss
def strip(char_path, anim, direction, out_name, title, n=8):
    fs = sorted(glob.glob(os.path.join(char_path, anim, direction, "frame_*.png")))[:n]
    if not fs: return
    ims = [Image.open(f).convert("RGBA") for f in fs]
    cw = max(i.width for i in ims); ch = max(i.height for i in ims)
    w = len(ims)*(cw+6)+6; h = ch+34
    img = Image.new("RGBA",(w,h),BG); d=ImageDraw.Draw(img)
    d.text((6,6), title, font=F, fill=(120,230,255,255))
    for k,im in enumerate(ims):
        img.alpha_composite(im,(6+k*(cw+6), 24+ (ch-im.height)))
    img.save(os.path.join(OUT,out_name)); print("ok",out_name,img.size)

strip(os.path.join(GEN,"animations","player","playable_human_ranger"), "walk", "south", "anim_player_walk.png", "player_human_ranger walk south")
strip(os.path.join(GEN,"animations","player","playable_human_ranger"), "attack", "south", "anim_player_attack.png", "player_human_ranger attack south")
strip(os.path.join(GEN,"animations","bosses","boss_trex"), "roar", "south", "anim_trex_roar.png", "boss_trex roar south")
strip(os.path.join(GEN,"animations","bosses","boss_corrupted_commander"), "special", "south", "anim_boss_special.png", "boss_corrupted_commander special south")
strip(os.path.join(GEN,"animations","enemies","enemy_raptor"), "lunge_attack", "south", "anim_raptor_lunge.png", "enemy_raptor lunge_attack south")

print("previews ->", OUT)
