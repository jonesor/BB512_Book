"""Prepare photographs and published figures at the exact aspect of their BB512 picture placeholders.
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
S = "images/source/"
make(S + "nicotiana_longiflora.jpg", "images/title_nicotiana.jpg", "title", focus=(0.45, 0.5))
make(S + "living_histogram_1975.jpg", "images/living_histogram.jpg", "takeaway", "fill", focus=(0.5, 0.75))
make(S + "wheat_white_red.png", "images/wheat.jpg", "half", "fit")
make(S + "nicotiana_longiflora.jpg", "images/nicotiana_half.jpg", "half", focus=(0.45, 0.5))
make(S + "east_histograms_neal_fig12_3.jpg", "images/east_histograms.jpg", "takeaway", "fit")
make(S + "finch_heritability_boag.png", "images/finch_heritability.jpg", "takeaway", "fit")
make(S + "horse_racing.png", "images/horse_racing.jpg", "takeaway", "fill")
make(S + "icy_road_signs.jpg", "images/icy_road_signs.jpg", "takeaway", "fill", focus=(0.6, 0.4))
make(S + "bosse2017_fig.png", "images/bosse2017.jpg", "takeaway", "fit")
# Coltman et al. (2003) Fig. 2: drop the caption (it is in the speaker notes); panels a-c share the year axis
_c = Image.open(S + "coltman2003_fig2.png"); _c.crop((0, 0, _c.width, int(_c.height * 0.775))).save(S + "coltman2003_fig2_nocap.png")
make(S + "coltman2003_fig2_nocap.png", "images/coltman2003.jpg", "half", "fit")
make(S + "bighorn_ram.jpg", "images/bighorn_ram.jpg", "half", "fill", focus=(0.5, 0.3))
