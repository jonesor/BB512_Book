"""Prepare photographs and published figures at the exact aspect of their BB512 picture placeholders.
'fill' crops to fill; 'fit' letterboxes on the slide background colour (#FBFAF6).
Run from the lecture folder: python3 images/prepare_images.py"""
from PIL import Image, ImageFilter
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
    elif mode == "extend":
        # Whole image kept. The space left over is filled with a smooth colour field sampled from the
        # image's own edge strip, and the join is feathered, so the subject is never cut off.
        k = max(3, round(0.03 * min(im.size)))            # trim thin borders and edge artefacts
        im = im.crop((k, k, im.width - k, im.height - k))
        r = min(W / im.width, H / im.height)
        fg = im.resize((round(im.width * r), round(im.height * r)), Image.LANCZOS)
        vertical = fg.width >= W - 1  # image fills the width: extend above and below
        bg = Image.new("RGB", (W, H))
        strip = max(4, (fg.height if vertical else fg.width) // 20)
        feather = max(2, (fg.height if vertical else fg.width) // 8)
        ov = feather + 2  # the colour field runs under the feathered edge
        if vertical:
            top = (H - fg.height) // 2; bottom = H - fg.height - top
            if top: bg.paste(fg.crop((0, 0, fg.width, strip)).resize((6, 1), Image.BOX).resize((W, top + ov), Image.BILINEAR), (0, 0))
            if bottom: bg.paste(fg.crop((0, fg.height - strip, fg.width, fg.height)).resize((6, 1), Image.BOX).resize((W, bottom + ov), Image.BILINEAR), (0, H - bottom - ov))
        else:
            left = (W - fg.width) // 2; right = W - fg.width - left
            if left: bg.paste(fg.crop((0, 0, strip, fg.height)).resize((1, 6), Image.BOX).resize((left + ov, H), Image.BILINEAR), (0, 0))
            if right: bg.paste(fg.crop((fg.width - strip, 0, fg.width, fg.height)).resize((1, 6), Image.BOX).resize((right + ov, H), Image.BILINEAR), (W - right - ov, 0))
        bg = bg.filter(ImageFilter.GaussianBlur(radius=max(4, W // 60)))
        mask = Image.new("L", fg.size, 255)
        for i in range(feather):
            v = int(255 * i / feather)
            if vertical:
                mask.paste(v, (0, i, fg.width, i + 1)); mask.paste(v, (0, fg.height - 1 - i, fg.width, fg.height - i))
            else:
                mask.paste(v, (i, 0, i + 1, fg.height)); mask.paste(v, (fg.width - 1 - i, 0, fg.width - i, fg.height))
        bg.paste(fg, ((W - fg.width) // 2, (H - fg.height) // 2), mask)
        im = bg
    elif mode == "pad":
        # Whole image kept on a plain background sampled from its left edge; a thin border is trimmed
        # first so rounded or white corners do not show
        k = max(2, round(0.015 * min(im.size)))
        im = im.crop((k, k, im.width - k, im.height - k))
        r = min(W / im.width, H / im.height)
        im = im.resize((round(im.width * r), round(im.height * r)), Image.LANCZOS)
        canvas = Image.new("RGB", (W, H), im.getpixel((3, im.height // 2)))
        canvas.paste(im, ((W - im.width) // 2, (H - im.height) // 2)); im = canvas
    else:
        r = min(W / im.width, H / im.height)
        im = im.resize((round(im.width * r), round(im.height * r)), Image.LANCZOS)
        canvas = Image.new("RGB", (W, H), BG)
        canvas.paste(im, ((W - im.width) // 2, (H - im.height) // 2)); im = canvas
    im.save(out, quality=92)
S = "images/source/"
make(S + "blue_whale.png", "images/title_blue_whale.jpg", "title", "extend")
# Variation: size and lifespan
make(S + "bumblebee_bat.jpg", "images/third_bumblebee_bat.jpg", "third", focus=(0.55, 0.5))
make(S + "blue_whale.png", "images/third_blue_whale.jpg", "third", "extend")
make(S + "bristlecone_pine.png", "images/third_bristlecone.jpg", "third", focus=(0.5, 0.5))
# Variation: offspring
make(S + "kiwi_xray.png", "images/third_kiwi.jpg", "third", "pad")
make(S + "atlantic_cod.png", "images/third_cod.jpg", "third", "pad")
make(S + "orchid.png", "images/third_orchid.jpg", "third", focus=(0.5, 0.4))
# Examples
make(S + "us_infant_mortality_2006.png", "images/infant_mortality.jpg", "half", "fit")
make(S + "nestbox_clutch.png", "images/nestbox.jpg", "half", focus=(0.5, 0.5))
make(S + "kestrel.png", "images/kestrel.jpg", "half", "extend")
make(S + "noctule_bat.png", "images/bat.jpg", "half", focus=(0.5, 0.5))
make(S + "killer_whale.png", "images/killer_whale.jpg", "half", focus=(0.5, 0.5))
