"""Prepare photographs and published figures at the exact aspect of their BB512 picture placeholders
(or of the picture frames placed by build_deck.py). 'fill' crops to fill; 'fit' letterboxes on the
slide background colour (#FBFAF6). Run from the lecture folder: python3 images/prepare_images.py"""
from PIL import Image
BG = (0xFB, 0xFA, 0xF6)
SIZES = {"title": (5.43, 7.5), "takeaway": (7.40, 4.25), "half": (5.57, 4.25), "full": (11.73, 3.95),
         "eye_diagram": (2.2, 1.75), "eye_photo": (2.2, 1.45), "wing": (3.73, 2.75), "portrait_pair": (2.74, 4.25),
         "half_strip": (5.57, 2.08)}
S = "images/source/"

def load(src):
    im = Image.open(src)
    if im.mode in ("RGBA", "LA", "P"):
        im = im.convert("RGBA"); canvas = Image.new("RGBA", im.size, BG + (255,))
        canvas.alpha_composite(im); im = canvas
    return im.convert("RGB")

def shape(im, layout, mode="fill", focus=(0.5, 0.5), dpi=220):
    W, H = [int(v * dpi) for v in SIZES[layout]]
    if mode == "fill":
        r = max(W / im.width, H / im.height)
        im = im.resize((round(im.width * r), round(im.height * r)), Image.LANCZOS)
        x = int((im.width - W) * focus[0]); y = int((im.height - H) * focus[1])
        return im.crop((x, y, x + W, y + H))
    r = min(W / im.width, H / im.height)
    im = im.resize((round(im.width * r), round(im.height * r)), Image.LANCZOS)
    canvas = Image.new("RGB", (W, H), BG)
    canvas.paste(im, ((W - im.width) // 2, (H - im.height) // 2))
    return canvas

def make(src, out, layout, mode="fill", focus=(0.5, 0.5), crop=None):
    im = load(S + src)
    if crop: im = im.crop(crop)
    shape(im, layout, mode, focus).save("images/" + out, quality=92)

# Title and recap
make("archaeopteryx_berlin.jpg", "title_archaeopteryx.jpg", "title", focus=(0.5, 0.4))
pair = Image.new("RGB", (int(5.57 * 220), int(4.25 * 220)), BG)
pair.paste(shape(load(S + "darwin_collier.jpg"), "portrait_pair", focus=(0.5, 0.2)), (0, 0))
pair.paste(shape(load(S + "wallace.jpg"), "portrait_pair", focus=(0.5, 0.2)), (int(2.83 * 220), 0))
pair.save("images/darwin_wallace.jpg", quality=92)
# Section 01
make("stormtroopers.png", "stormtroopers.jpg", "takeaway", focus=(0.5, 0.6))
make("living_histogram_takeaway.jpg", "living_histogram.jpg", "takeaway")
make("dead_leaf_butterfly.png", "adapt_leaf_butterfly.jpg", "half", focus=(0.5, 0.5), crop=(0, 0, 896, 560))
make("hoverflies.jpg", "adapt_hoverflies.jpg", "half")
make("black_smoker.png", "adapt_black_smoker.jpg", "half", focus=(0.5, 0.3))
# Section 02: mollusc eyes (Neal 2004 Fig. 3.4 panels a-e) and photographs
for key, box in {"a": (420, 58, 1060, 215), "b": (0, 270, 480, 645), "c": (488, 270, 1100, 700),
                 "d": (10, 740, 560, 1215), "e": (580, 740, 1100, 1247)}.items():
    make("neal_fig3_4_mollusc_eyes.jpg", f"eye_{key}.jpg", "eye_diagram", "fit", crop=box)
make("limpets.jpg", "eye_photo_limpets.jpg", "eye_photo")
make("nautilus.jpg", "eye_photo_nautilus.jpg", "eye_photo")
make("helix_pomatia.jpg", "eye_photo_snail.jpg", "eye_photo")
make("cuttlefish.jpg", "eye_photo_cuttlefish.jpg", "eye_photo", focus=(0.75, 0.5))
make("evolution_eye_svg.png", "vertebrate_octopus_eye.jpg", "half", "fit")
make("archaeopteryx_berlin.jpg", "archaeopteryx_half.jpg", "half", "fit")
make("flying_squirrel.jpg", "wing_glide.jpg", "wing")
make("microraptor.jpg", "wing_microraptor.jpg", "wing")
make("wair_chukar_video.png", "wing_wair.jpg", "wing", crop=(0, 0, 470, 330), focus=(0.45, 0.4))
# Four-panel version of the half-a-wing slide (2.76 x 2.45 in per panel)
SIZES["wing4"] = (2.76, 2.45)
make("microraptor.jpg", "wing_microraptor_q.jpg", "wing4", focus=(0.5, 0.4))
make("wair_chukar_video.png", "wing_wair_q.jpg", "wing4", crop=(0, 0, 470, 330), focus=(0.5, 0.4))
import os
if os.path.exists(S + "fowler2011_fig1_RPR.png"):  # Fowler et al. 2011 PLoS ONE Fig. 1, Creative Commons Attribution licence
    make("fowler2011_fig1_RPR.png", "wing_deinonychus.jpg", "wing4", "fit")
if os.path.exists(S + "red_tailed_hawk_mantling_8191228707.jpg"):  # Reago & McClarren, CC BY 2.0
    make("red_tailed_hawk_mantling_8191228707.jpg", "wing_hawk.jpg", "wing4", focus=(0.45, 0.5))
# Section 03
make("guppies.png", "guppies.jpg", "half")
make("morphs_pair.jpg", "peppered_morphs.jpg", "takeaway")
# Peppered moths against backgrounds: pale form on lichen (left), both forms on pale birch bark (right)
pm = Image.new("RGB", (int(7.40 * 220), int(4.25 * 220)), BG)
SIZES["moth_panel"] = (3.62, 4.25)
pm.paste(shape(load(S + "peppered_moth_old.jpg"), "moth_panel", focus=(0.42, 0.5)), (0, 0))
pm.paste(shape(load(S + "morphs_on_bark.jpg"), "moth_panel", focus=(0.5, 0.5)), (int(3.78 * 220), 0))
pm.save("images/peppered_backgrounds.jpg", quality=92)
make("antibiotics.jpg", "antibiotics.jpg", "half", "fit")
# Section 04
make("sickle_cells.jpg", "sickle_cells.jpg", "half")
make("pronghorn.png", "pronghorn.jpg", "takeaway", focus=(0.5, 0.6))
# Section 05
can = Image.new("RGB", (int(5.57 * 220), int(4.25 * 220)), BG)
can.paste(shape(load(S + "mantis_cannibalism.png"), "half_strip"), (0, 0))
can.paste(shape(load(S + "stegodyphus.png"), "half_strip", focus=(0.5, 0.45)), (0, int(2.17 * 220)))
can.save("images/cannibalism.jpg", quality=92)
make("meerkats.jpg", "meerkats.jpg", "takeaway", focus=(0.55, 0.45))
make("owen_and_son.jpg", "owen_and_son.jpg", "takeaway", focus=(0.6, 0.35))
