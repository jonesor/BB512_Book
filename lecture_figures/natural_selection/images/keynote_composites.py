"""Composite images for slides that the PPTX builds from several pictures and text boxes, so that each
becomes ONE picture in a "Title & Photo" placeholder (11.73 x 3.95 in) when the deck is rebuilt in
Keynote for iCloud (where placing many objects by hand is slow). Labels are drawn into the image.
Run from the lecture folder after images/prepare_images.py:  python3 images/keynote_composites.py
Uses Avenir Next if available (Mac), otherwise Inter.
Outputs: images/kn_adaptations.jpg, images/kn_mollusc_eyes.jpg, images/kn_half_wing.jpg"""
import os
from PIL import Image, ImageDraw, ImageFont
DPI = 200
BG = (0xFB, 0xFA, 0xF6); INK = (0x1F, 0x26, 0x23); FOREST = (0x1F, 0x4D, 0x3F)
GREY = (0x6E, 0x6F, 0x68); PALE = (0xEF, 0xEE, 0xE6)
W, H = int(11.73 * DPI), int(3.95 * DPI)
I = "images/"

def font(weight, pt, italic=False):
    size = int(pt / 72 * DPI)
    cands = []
    av = "/System/Library/Fonts/Avenir Next.ttc"
    if os.path.exists(av):  # index: 0 Bold, 7 Regular, 8 Italic (typical order on macOS)
        idx = {"bold": 0, "regular": 7, "italic": 8}["italic" if italic else weight]
        try:
            return ImageFont.truetype(av, size, index=idx)
        except Exception:
            pass
    d = "/usr/share/fonts/opentype/inter/"
    name = "Inter-Italic.otf" if italic else ("Inter-Bold.otf" if weight == "bold" else "Inter-Regular.otf")
    return ImageFont.truetype(d + name, size)

def px(v): return int(v * DPI)

def paste(canvas, path, x, y, w, h, fit=False):
    if path and os.path.exists(path):
        im = Image.open(path).convert("RGB")
        if fit:  # letterbox on the background colour instead of cropping
            r = min(px(w) / im.width, px(h) / im.height)
            im = im.resize((round(im.width * r), round(im.height * r)), Image.LANCZOS)
            canvas.paste(im, (px(x) + (px(w) - im.width) // 2, px(y) + (px(h) - im.height) // 2))
            return True
        r = max(px(w) / im.width, px(h) / im.height)
        im = im.resize((round(im.width * r), round(im.height * r)), Image.LANCZOS)
        cx, cy = (im.width - px(w)) // 2, (im.height - px(h)) // 2
        canvas.paste(im.crop((cx, cy, cx + px(w), cy + px(h))), (px(x), px(y)))
        return True
    return False

def placeholder(d, x, y, w, h, text):
    d.rectangle([px(x), px(y), px(x + w), px(y + h)], fill=PALE)
    f = font("regular", 13)
    for k, line in enumerate(text.split("\n")):
        tw = d.textlength(line, font=f)
        d.text((px(x + w / 2) - tw / 2, px(y + h / 2) - f.size + k * f.size * 1.25), line, font=f, fill=GREY)

def text_runs(d, x, y, runs, align="left", width=None):
    """runs: list of (text, font, colour); drawn on one line."""
    total = sum(d.textlength(t, font=f) for t, f, c in runs)
    cx = px(x) + (px(width) - total) / 2 if align == "center" else px(x)
    for t, f, c in runs:
        d.text((cx, px(y)), t, font=f, fill=c); cx += d.textlength(t, font=f)

def wrap(d, text, f, maxw):
    words, lines, cur = text.split(), [], ""
    for w_ in words:
        t = (cur + " " + w_).strip()
        if d.textlength(t, font=f) <= px(maxw): cur = t
        else: lines.append(cur); cur = w_
    lines.append(cur); return lines

# ---- Slide "The result: adaptation": three photos, captions on the slide's caption line
c = Image.new("RGB", (W, H), BG); d = ImageDraw.Draw(c)
w3, gap = (11.73 - 2 * 0.25) / 3, 0.25
for k, f_ in enumerate(["adapt_leaf_butterfly.jpg", "adapt_hoverflies.jpg", "adapt_black_smoker.jpg"]):
    x = k * (w3 + gap)
    paste(c, I + f_, x, 0, w3, 3.35)
    head = ["Camouflage", "Mimicry", "Physiology"][k]
    sub = ["dead-leaf butterfly", "hoverflies that look like wasps", "life at hydrothermal vents"][k]
    text_runs(d, x, 3.45, [(head, font("bold", 16), FOREST), ("  " + sub, font("regular", 14), INK)])
c.save(I + "kn_adaptations.jpg", quality=92)

# ---- Slide "Working eyes at every stage: molluscs"
c = Image.new("RGB", (W, H), BG); d = ImageDraw.Draw(c)
cols = [("a", "Light spot", "Light or dark", None, ""),
        ("b", "Cup", "Direction of light", "eye_photo_limpets.jpg", "Limpets"),
        ("c", "Pinhole", "Dim image", "eye_photo_nautilus.jpg", "Nautilus"),
        ("d", "Closed, with lens", "Focused image", "eye_photo_snail.jpg", "Roman snail"),
        ("e", "Lens, cornea, iris", "Sharp image", "eye_photo_cuttlefish.jpg", "Cuttlefish")]
cw, cg = 2.2, (11.73 - 5 * 2.2) / 4
for k, (key, head, func, photo, sp) in enumerate(cols):
    x = k * (cw + cg)
    paste(c, I + f"eye_{key}.jpg", x, 0, cw, 1.5, fit=True)
    text_runs(d, x, 1.55, [(head, font("bold", 15), FOREST)], "center", cw)
    text_runs(d, x, 1.84, [(func, font("regular", 14), GREY)], "center", cw)
    if photo:
        paste(c, I + photo, x, 2.15, cw, 1.45)
        text_runs(d, x, 3.63, [(sp, font("regular", 14, italic=(sp == "Nautilus")), GREY)], "center", cw)
    else:
        placeholder(d, x, 2.15, cw, 1.45, "Found in many\nanimal groups")
c.save(I + "kn_mollusc_eyes.jpg", quality=92)

# ---- Slide "Three ideas for half a wing": four panels (labelled placeholders if an image is missing)
c = Image.new("RGB", (W, H), BG); d = ImageDraw.Draw(c)
items = [("wing_microraptor_q.jpg", "Gliding down", "Microraptor: four feathered wings, probably a glider"),
         ("wing_deinonychus.jpg", "Pouncing on prey", "Dromaeosaurs may have flapped to stay on top of prey"),
         ("wing_hawk.jpg", "…as hawks do today", "A red-tailed hawk spreads its wings over its prey"),
         ("wing_wair_q.jpg", "Running uphill", "Chukar chicks flap small wings to run up slopes (WAIR)")]
pw, pg = 2.76, (11.73 - 4 * 2.76) / 3
for k, (img, head, txt) in enumerate(items):
    x = k * (pw + pg)
    if not paste(c, I + img, x, 0, pw, 2.45):
        placeholder(d, x, 0, pw, 2.45, "IMAGE NEEDED\n" + img)
    text_runs(d, x, 2.53, [(head, font("bold", 16), FOREST)])
    f = font("regular", 14)
    for j, line in enumerate(wrap(d, txt, f, pw)):
        if k == 0 and j == 0 and line.startswith("Microraptor:"):
            text_runs(d, x, 2.9, [("Microraptor", font("regular", 14, italic=True), INK), (line[len("Microraptor"):], f, INK)])
        else:
            text_runs(d, x, 2.9 + j * 0.27, [(line, f, INK)])
c.save(I + "kn_half_wing.jpg", quality=92)
print("composites written")
