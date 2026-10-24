"""Prepare photographs at the exact aspect of their BB512 picture placeholders.
'fill' crops to fill; 'fit' letterboxes on the slide background colour (#FBFAF6).
Run from the lecture folder: python3 images/prepare_images.py"""
from PIL import Image, ImageDraw
BG = (0xFB, 0xFA, 0xF6); FOREST = (0x1F, 0x4D, 0x3F)
SIZES = {"title": (5.43, 7.5), "takeaway": (7.40, 4.25), "half": (5.57, 4.25), "full": (11.73, 3.95)}
DPI = 220
S = "images/source/"

def fill(im, W, H, focus=(0.5, 0.5)):
    r = max(W / im.width, H / im.height)
    im = im.resize((round(im.width * r), round(im.height * r)), Image.LANCZOS)
    x = int((im.width - W) * focus[0]); y = int((im.height - H) * focus[1])
    return im.crop((x, y, x + W, y + H))

def make(src, out, layout, mode="fill", focus=(0.5, 0.5)):
    W, H = [int(v * DPI) for v in SIZES[layout]]
    im = Image.open(src).convert("RGB")
    if mode == "fill":
        im = fill(im, W, H, focus)
    else:
        r = min(W / im.width, H / im.height)
        im = im.resize((round(im.width * r), round(im.height * r)), Image.LANCZOS)
        canvas = Image.new("RGB", (W, H), BG)
        canvas.paste(im, ((W - im.width) // 2, (H - im.height) // 2)); im = canvas
    im.save(out, quality=92)

def panels(srcs, out, layout, gap=0.12, arrow=False, focus=None):
    """Side-by-side photos filling the placeholder, separated by a gap (optionally an arrow)."""
    W, H = [int(v * DPI) for v in SIZES[layout]]
    g = int(gap * DPI) if not arrow else int(0.9 * DPI)
    n = len(srcs); w = (W - g * (n - 1)) // n
    canvas = Image.new("RGB", (W, H), BG)
    for i, s in enumerate(srcs):
        f = focus[i] if focus else (0.5, 0.5)
        canvas.paste(fill(Image.open(s).convert("RGB"), w, H, f), (i * (w + g), 0))
    if arrow:
        d = ImageDraw.Draw(canvas); y = H // 2; x0 = w + int(0.15 * DPI); x1 = w + g - int(0.15 * DPI)
        d.line([(x0, y), (x1 - 40, y)], fill=FOREST, width=18)
        d.polygon([(x1, y), (x1 - 60, y - 40), (x1 - 60, y + 40)], fill=FOREST)
    canvas.save(out, quality=92)

make(S + "leatherback_hatchling.jpg", "images/title_hatchling.jpg", "title", focus=(0.6, 0.5))
make(S + "ages_illustration.jpg", "images/ages.jpg", "takeaway", "fit")
panels([S + "leatherback_hatchling.jpg", S + "leatherback_adult.jpg"], "images/turtle_stages.jpg",
       "takeaway", arrow=True, focus=[(0.6, 0.55), (0.35, 0.5)])
panels([S + "mpm_turtle.tif", S + "mpm_treefern.tif", S + "mpm_cod.tif"], "images/mpm_examples.jpg",
       "takeaway", focus=[(0.3, 0.5), (0.5, 0.5), (0.35, 0.5)])
make(S + "puerto_rican_parrot.png", "images/parrot.jpg", "half", focus=(0.5, 0.3))
make(S + "loggerhead.jpg", "images/loggerhead_takeaway.jpg", "takeaway", focus=(0.75, 0.4))
make(S + "loggerhead.jpg", "images/loggerhead_half.jpg", "half", focus=(0.8, 0.4))
