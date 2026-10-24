"""Prepare photographs and published figures at the exact aspect of their BB512 picture placeholders.
'fill' crops to fill; 'fit' letterboxes on the slide background colour (#FBFAF6).
Run from the lecture folder: python3 images/prepare_images.py"""
from PIL import Image
BG = (0xFB, 0xFA, 0xF6)
SIZES = {"title": (5.43, 7.5), "takeaway": (7.40, 4.25), "half": (5.57, 4.25),
         "full": (11.73, 3.95), "tall": (11.73, 4.35)}
def make(src, out, layout, mode="fill", focus=(0.5, 0.5), dpi=220):
    W, H = [int(v * dpi) for v in SIZES[layout]]
    im = Image.open(src).convert("RGB") if isinstance(src, str) else src
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
S = "images/source/"
# Title: African elephant calves (cropped from the photo used on the old "R0 is not lambda" slide)
make(S + "elephants.jpg", "images/title_elephants.jpg", "title", focus=(0.62, 0.5))
# Jones et al. (2014) "match the pairs" panel, carried over from the old deck
# Drop the "MATCH THE PAIRS!" band and white space so the species and panels can be larger
_j = Image.open(S + "jones2014_match.png").convert("RGB")
_top, _bot = _j.crop((0, 0, _j.width, 395)), _j.crop((0, 740, _j.width, _j.height))
_jc = Image.new("RGB", (_j.width, _top.height + 30 + _bot.height), (255, 255, 255))
_jc.paste(_top, (0, 0)); _jc.paste(_bot, (0, _top.height + 30))
make(_jc, "images/jones2014_match.jpg", "tall", "fit")
# Cohort lifespans (lollipop), carried over from the old deck
make(S + "cohort_lollipop.png", "images/cohort_lollipop.jpg", "half", "fit")
# Harvest mice and elephants side by side: fast and slow life histories
def side_by_side(a, b, out, layout="takeaway", dpi=220, gap=0.12):
    W, H = [int(v * dpi) for v in SIZES[layout]]
    g = int(gap * dpi); w = (W - g) // 2
    canvas = Image.new("RGB", (W, H), BG)
    for k, (src, fx) in enumerate([a, b]):
        im = Image.open(src).convert("RGB")
        r = max(w / im.width, H / im.height)
        im = im.resize((round(im.width * r), round(im.height * r)), Image.LANCZOS)
        x = int((im.width - w) * fx); y = (im.height - H) // 2
        canvas.paste(im.crop((x, y, x + w, y + H)), (k * (w + g), 0))
    canvas.save(out, quality=92)
side_by_side((S + "harvest_mice.jpg", 0.45), (S + "elephants.jpg", 0.6), "images/mice_elephants.jpg")
