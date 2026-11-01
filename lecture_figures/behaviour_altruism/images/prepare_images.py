"""Prepare photographs at the exact aspect of their BB512 picture placeholders.
'fill' crops to fill; 'fit' letterboxes on the slide background colour (#FBFAF6).
Run from the lecture folder: python3 images/prepare_images.py"""
from PIL import Image
BG = (0xFB, 0xFA, 0xF6)
SIZES = {"title": (5.43, 7.5), "takeaway": (7.40, 4.25), "half": (5.57, 4.25), "full": (11.73, 3.95)}
def make(src, out, layout, mode="fill", focus=(0.5, 0.5), dpi=220):
    W, H = [int(v * dpi) for v in SIZES[layout]]
    im = Image.open(src).convert("RGB")
    if mode == "fill":
        r = max(W / im.width, H / im.height)
        im = im.resize((round(im.width * r), round(im.height * r)), Image.LANCZOS)
        x = int((im.width - W) * focus[0]); y = int((im.height - H) * focus[1])
        im = im.crop((x, y, x + W, y + H))
    else:
        r = min(W / im.width, H / im.height)
        im = im.resize((round(im.width * r), round(im.height * r)), Image.LANCZOS)
        canvas = Image.new("RGB", (W, H), BG)
        canvas.paste(im, ((W - im.width) // 2, (H - im.height) // 2)); im = canvas
    im.save(out, quality=92)
def pair(a, b, out, layout, dpi=220, gap=0.15, vertical=False):
    W, H = [int(v * dpi) for v in SIZES[layout]]
    g = int(gap * dpi)
    canvas = Image.new("RGB", (W, H), BG)
    for i, src in enumerate([a, b]):
        im = Image.open(src).convert("RGB")
        w, h = (W, (H - g) // 2) if vertical else ((W - g) // 2, H)
        r = min(w / im.width, h / im.height)
        im = im.resize((round(im.width * r), round(im.height * r)), Image.LANCZOS)
        if vertical:
            canvas.paste(im, ((W - im.width) // 2, i * (h + g) + (h - im.height) // 2))
        else:
            canvas.paste(im, (i * (w + g) + (w - im.width) // 2, (H - im.height) // 2))
    canvas.save(out, quality=92)
S = "images/source/"
make(S + "meerkats.jpg", "images/title_meerkats.jpg", "title", focus=(0.42, 0.5))
make(S + "babbler.jpg", "images/babbler.jpg", "half", focus=(0.5, 0.3))
make(S + "mole_rat.jpg", "images/mole_rat.jpg", "half", "fit")      # CC BY-NC-ND: not cropped
make(S + "bighorn_rams.jpg", "images/ritual_fights.jpg", "takeaway", "fit")  # lions dropped: shows an escalated fight
pair(S + "harris_hawk.jpg", S + "green_pigeon.jpg", "images/hawk_dove.jpg", "half", vertical=True)
make(S + "speckled_wood.jpg", "images/speckled_wood.jpg", "half", focus=(0.5, 0.5))
