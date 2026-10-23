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
def pair(a, b, out, layout, dpi=220, gap=0.15):
    W, H = [int(v * dpi) for v in SIZES[layout]]
    g = int(gap * dpi); w = (W - g) // 2
    canvas = Image.new("RGB", (W, H), BG)
    for i, src in enumerate([a, b]):
        im = Image.open(src).convert("RGB")
        r = min(w / im.width, H / im.height)
        im = im.resize((round(im.width * r), round(im.height * r)), Image.LANCZOS)
        canvas.paste(im, (i * (w + g) + (w - im.width) // 2, (H - im.height) // 2))
    canvas.save(out, quality=92)
S = "images/source/"
make(S + "birch_typica.jpg", "images/title_birch_typica.jpg", "title", focus=(0.5, 0.35))
make(S + "birch_typica.jpg", "images/spot_the_moth.jpg", "takeaway", "fit")
pair(S + "typica.jpg", S + "carbonaria.jpg", "images/morphs_pair.jpg", "takeaway")
make(S + "sickle_cells.jpg", "images/sickle_cells.jpg", "half", focus=(0.5, 0.45))
make(S + "hbs_malaria_map.png", "images/hbs_malaria_map.jpg", "half", "fit")
make(S + "eugenics_poster.jpg", "images/eugenics_poster.jpg", "half", "fit")
make(S + "mtb_sem.png", "images/mtb_sem.jpg", "half", "fill")
make(S + "morphs_on_bark.jpg", "images/morphs_on_bark.jpg", "half", "fit")
make(S + "uk_morph_map.jpg", "images/uk_morph_map.jpg", "half", "fit")

# Reveal: circle the typica moth on the birch photo (moth centre at about 32% across, 32% down).
def reveal(src, out, layout, cx=0.32, cy=0.325, r=0.11, dpi=220):
    from PIL import ImageDraw
    W, H = [int(v * dpi) for v in SIZES[layout]]
    im = Image.open(src).convert("RGB")
    d = ImageDraw.Draw(im)
    R = r * im.width; x, y = cx * im.width, cy * im.height
    d.ellipse([x - R, y - 1.5 * R, x + R, y + 1.5 * R], outline=(0xC0, 0x8A, 0x2E), width=max(4, im.width // 120))
    k = min(W / im.width, H / im.height)
    im = im.resize((round(im.width * k), round(im.height * k)), Image.LANCZOS)
    canvas = Image.new("RGB", (W, H), BG); canvas.paste(im, ((W - im.width) // 2, (H - im.height) // 2))
    canvas.save(out, quality=92)

# HbS map: place panel (a) HbS frequency and panel (b) malarial zone side by side, full width.
def map_split(src, out, dpi=220, gap=0.3):
    W, H = [int(v * dpi) for v in SIZES["full"]]
    im = Image.open(src).convert("RGB")
    a = im.crop((0, 0, 487, 362)); b = im.crop((104, 370, 416, 562))
    h = int(H * 0.97); g = int(gap * dpi)
    a = a.resize((round(a.width * h / a.height), h), Image.LANCZOS)
    b = b.resize((round(b.width * h / b.height), h), Image.LANCZOS)
    scale = min(1, (W - g) / (a.width + b.width))
    if scale < 1:
        a = a.resize((round(a.width * scale), round(a.height * scale)), Image.LANCZOS)
        b = b.resize((round(b.width * scale), round(b.height * scale)), Image.LANCZOS)
    canvas = Image.new("RGB", (W, H), BG)
    x0 = (W - (a.width + g + b.width)) // 2
    canvas.paste(a, (x0, (H - a.height) // 2)); canvas.paste(b, (x0 + a.width + g, (H - b.height) // 2))
    canvas.save(out, quality=92)

reveal(S + "birch_typica.jpg", "images/spot_the_moth_reveal.jpg", "takeaway")
map_split(S + "hbs_malaria_map.png", "images/hbs_malaria_map_wide.jpg")
