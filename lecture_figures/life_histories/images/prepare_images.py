"""Prepare photographs and published figures at the exact aspect of their BB512 picture placeholders.
'fill' crops to fill; 'fit' letterboxes on the slide background colour (#FBFAF6).
Run from the lecture folder: python3 images/prepare_images.py"""
from PIL import Image
BG = (0xFB, 0xFA, 0xF6)
SIZES = {"title": (5.43, 7.5), "takeaway": (7.40, 4.25), "half": (5.57, 4.25), "full": (11.73, 3.95),
         "third": (3.64, 5.30)}
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
S = "images/source/"
make(S + "blue_whale.png", "images/title_blue_whale.jpg", "title", focus=(0.45, 0.5))
# Variation: size and lifespan
make(S + "bumblebee_bat.jpg", "images/third_bumblebee_bat.jpg", "third", focus=(0.3, 0.5))
make(S + "blue_whale.png", "images/third_blue_whale.jpg", "third", focus=(0.5, 0.5))
make(S + "bristlecone_pine.png", "images/third_bristlecone.jpg", "third", focus=(0.5, 0.5))
# Variation: offspring
make(S + "kiwi_xray.png", "images/third_kiwi.jpg", "third", "fit")
make(S + "atlantic_cod.png", "images/third_cod.jpg", "third", "fit")
make(S + "orchid.png", "images/third_orchid.jpg", "third", focus=(0.5, 0.4))
# Examples
make(S + "us_infant_mortality_2006.png", "images/infant_mortality.jpg", "half", "fit")
make(S + "nestbox_clutch.png", "images/nestbox.jpg", "half", focus=(0.5, 0.5))
make(S + "kestrel.png", "images/kestrel.jpg", "half", focus=(0.5, 0.5))
make(S + "noctule_bat.png", "images/bat.jpg", "half", focus=(0.45, 0.5))
make(S + "killer_whale.png", "images/killer_whale.jpg", "half", focus=(0.5, 0.5))
