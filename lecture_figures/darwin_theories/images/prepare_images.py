"""Prepare photographs and composites at the exact aspect of their BB512 picture placeholders.
'fill' crops to fill; 'fit' letterboxes on the slide background colour (#FBFAF6).
Sources in images/source/ (most extracted from the previous version of the lecture; credits in CREDITS.md).
Run from the lecture folder: python3 images/prepare_images.py"""
import os
from PIL import Image, ImageDraw, ImageFont
BG = (0xFB, 0xFA, 0xF6); PANEL = (0xEF, 0xEE, 0xE6); INK = (0x1F, 0x26, 0x23); GREY = (0x6E, 0x6F, 0x68)
SIZES = {"title": (5.43, 7.5), "takeaway": (7.40, 4.25), "half": (5.57, 4.25), "full": (11.73, 3.95),
         "slide": (13.33, 7.5)}
DPI = 220
S = "images/source/"

def font(size_pt, bold=False):
    for f in (["/System/Library/Fonts/Avenir Next.ttc"] if os.path.exists("/System/Library/Fonts/Avenir Next.ttc") else []) + \
             ["/usr/share/fonts/opentype/inter/Inter-%s.otf" % ("Bold" if bold else "Regular")]:
        try:
            return ImageFont.truetype(f, int(size_pt * DPI / 72), index=(1 if bold else 0) if f.endswith(".ttc") else 0)
        except Exception:
            pass
    return ImageFont.load_default()

def fitimg(im, W, H, mode="fill", focus=(0.5, 0.5), bg=BG):
    im = im.convert("RGB")
    if mode == "fill":
        r = max(W / im.width, H / im.height)
        im = im.resize((max(W, round(im.width * r)), max(H, round(im.height * r))), Image.LANCZOS)
        x = int((im.width - W) * focus[0]); y = int((im.height - H) * focus[1])
        return im.crop((x, y, x + W, y + H))
    r = min(W / im.width, H / im.height)
    im = im.resize((round(im.width * r), round(im.height * r)), Image.LANCZOS)
    c = Image.new("RGB", (W, H), bg); c.paste(im, ((W - im.width) // 2, (H - im.height) // 2)); return c

def make(src, out, layout, mode="fill", focus=(0.5, 0.5)):
    W, H = [int(v * DPI) for v in SIZES[layout]]
    fitimg(Image.open(src), W, H, mode, focus).save(out, quality=92)

def placeholder(W, H, text):
    c = Image.new("RGB", (W, H), PANEL); d = ImageDraw.Draw(c)
    d.multiline_text((W // 2, H // 2), text, fill=GREY, font=font(14), anchor="mm", align="center")
    return c

def grid(cells, out, layout, ncol, gap=0.06, labels=None, label_h=0.0, row_labels=None, row_label_w=0.0):
    """cells: list of (path or None, mode, focus, placeholder_text). Equal-size cells in a grid."""
    W, H = [int(v * DPI) for v in SIZES[layout]]
    g = int(gap * DPI); lh = int(label_h * DPI); rw = int(row_label_w * DPI)
    nrow = (len(cells) + ncol - 1) // ncol
    cw = (W - rw - g * (ncol - 1)) // ncol; ch = (H - g * (nrow - 1)) // nrow - lh
    c = Image.new("RGB", (W, H), BG); d = ImageDraw.Draw(c)
    for k, (path, mode, focus, ph) in enumerate(cells):
        i, j = divmod(k, ncol); x = rw + j * (cw + g); y = i * (ch + lh + g)
        tile = fitimg(Image.open(path), cw, ch, mode, focus) if path and os.path.exists(path) else placeholder(cw, ch, ph or "")
        c.paste(tile, (x, y))
        if labels and labels[k]:
            d.text((x, y + ch + lh // 2), labels[k], fill=INK, font=font(14), anchor="lm")
    if row_labels:
        for i, t in enumerate(row_labels):
            y = i * (ch + lh + g) + ch // 2
            d.text((0, y), t, fill=INK, font=font(16, True), anchor="lm")
    c.save(out, quality=92)

F = (0.5, 0.5)
# Title: Darwin's 1837 "I think" tree sketch (Notebook B)
make(S + "s01_1.png", "images/title_tree.jpg", "title", "fit")
# Course intro
grid([(S + "s05_1.png", "fill", F, None), (S + "s05_3.png", "fill", F, None), (S + "s05_4.png", "fill", F, None),
      (S + "s05_5.jpg", "fill", F, None), (S + "s05_6.png", "fill", (0.5, 0.3), None), (S + "s05_7.png", "fill", F, None),
      (S + "s05_8.jpg", "fill", F, None), (S + "s05_2.png", "fit", F, None)],
     "images/research.jpg", "full", 4)
make(S + "s06_1.png", "images/neal_cover.jpg", "half", "fit")
make(S + "s07_1.png", "images/website.jpg", "full", "fit")
# Diversity of life
grid([(S + "s09_%d.png" % i, "fill", F, None) for i in (1, 2, 3, 4, 5, 6)], "images/diversity.jpg", "full", 6,
     labels=["Leafy seadragon", "Peacock", "Galápagos finches", "Redback spider", "Slug caterpillar", "Tarsier"], label_h=0.3)
# Darwin's path
make(S + "s11_1.jpg", "images/sharples.jpg", "half", "fill", (0.5, 0.25))
make(S + "s12_1.jpg", "images/strata.jpg", "half", "fill", (0.3, 0.5))
make(S + "s13_1.jpg", "images/moler.jpg", "full", "fill", (0.5, 0.5))
make(S + "s15_2.png", "images/beagle_route.jpg", "takeaway", "fit")
make(S + "s14_1.jpg", "images/beagle_ship.jpg", "half", "fill")
_m = Image.open(S + "s17_1.png"); _m.crop((int(_m.width * 0.47), 0, _m.width, _m.height)).save(S + "s17_1_plates.png")
make(S + "s17_1_plates.png", "images/mockingbirds.jpg", "half", "fit")
make(S + "s16_1.jpg", "images/finches.jpg", "half", "fit")
grid([(S + "s18_1.png", "fit", F, None), (S + "s18_2.png", "fit", F, None)], "images/tortoises.jpg", "full", 2)
# Fossils: two pairs (fossil, living relative)
grid([(S + "s19_1.jpg", "fit", F, None), (S + "s19_4.jpg", "fill", F, None),
      (S + "bb512darwin_glyptodon.jpg", "fit", F, "Glyptodon\n(bb512darwin_glyptodon.jpg)"),
      (S + "bb512darwin_armadillo.jpg", "fill", F, "Nine-banded armadillo\n(bb512darwin_armadillo.jpg)")],
     "images/fossils.jpg", "full", 4,
     labels=["Scelidotherium (extinct)", "Living sloth", "Glyptodon (extinct)", "Living armadillo"], label_h=0.32)
grid([(S + "s20_1.jpg", "fill", (0.5, 0.4), None), (S + "bb512darwin_lamarck.jpg", "fill", (0.5, 0.2), None)],
     "images/predecessors.jpg", "half", 2, labels=["al-Jāḥiẓ, 9th c.", "Lamarck"], label_h=0.32)
# Artificial selection: rock dove plus nine breeds
grid([(S + "image3.tif", "fill", F, None)] + [(S + "s23_%d.png" % i, "fit", F, None) for i in range(1, 10)],
     "images/pigeons.jpg", "takeaway", 5)
grid([(S + "s25_1.jpg", "fill", F, None), (S + "s25_2.jpg", "fill", F, None)], "images/struggle.jpg", "half", 1)
make(S + "s26_1.png", "images/origin_diagram.jpg", "half", "fit")
# Nested similarity: four groups of three
grid([(S + f, "fill", F, None) for f in ["image4.tif", "image5.tif", "image6.tif",
                                          "image11.tif", "image13.tif", "image10.tif",
                                          "image7.tif", "image8.tif", "image12.tif",
                                          "image9.tif", "s27_1.jpg", "s27_2.jpg"]],
     "images/nested.jpg", "full", 6,
     row_labels=None)
make(S + "s33_1.jpg", "images/panama.jpg", "half", "fill")
grid([(S + "s34_2.jpg", "fill", F, None), (S + "s34_1.jpg", "fill", F, None)], "images/islands.jpg", "half", 1)
make(S + "s35_1.png", "images/forelimbs.jpg", "half", "fit")
make(S + "s31_1.jpg", "images/watch.jpg", "half", "fill")
grid([(S + "s32_1.jpg", "fill", F, None), (S + "s32_2.jpg", "fill", F, None)], "images/dogs.jpg", "half", 1)
make(S + "s36_1.png", "images/wallace.jpg", "half", "fill")
make(S + "s37_2.png", "images/linnean.jpg", "half", "fill", (0.5, 0.0))
print("done")
