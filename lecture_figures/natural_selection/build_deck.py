"""Build 'BB512 - 02 - Understanding Natural Selection' from BB512_Theme.pptx.
Run from the lecture folder:  python3 build_deck.py <path/to/BB512_Theme.pptx> <out.pptx>
Inline markup in text: *italic*, **bold**, ~subscript~, ^superscript^.
"""
import re, sys, copy
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.oxml.ns import qn

THEME, OUT = sys.argv[1], sys.argv[2]
FOREST = RGBColor(0x1F, 0x4D, 0x3F); INK = RGBColor(0x1F, 0x26, 0x23)
PALE = RGBColor(0xEF, 0xEE, 0xE6); BG = RGBColor(0xFB, 0xFA, 0xF6)
GREY = RGBColor(0x6E, 0x6F, 0x68); CLAY = RGBColor(0xA4, 0x50, 0x3A); GOLD = RGBColor(0xC0, 0x8A, 0x2E)
FONT = "Avenir Next"

prs = Presentation(THEME)
# Remove the theme's example slides
sldIdLst = prs.slides._sldIdLst
for sldId in list(sldIdLst):
    prs.part.drop_rel(sldId.rId); sldIdLst.remove(sldId)
LAYOUT = {l.name: l for l in prs.slide_layouts}

TOKEN = re.compile(r"(\*\*.+?\*\*|\*.+?\*|~.+?~|\^.+?\^)")

def add_runs(par, text, size=None, color=None, bold=None):
    for part in TOKEN.split(text):
        if not part:
            continue
        r = par.add_run()
        fmt = {}
        if part.startswith("**"):
            part = part[2:-2]; fmt["bold"] = True
        elif part.startswith("*"):
            part = part[1:-1]; fmt["italic"] = True
        elif part.startswith("~"):
            part = part[1:-1]; fmt["baseline"] = "-25000"
        elif part.startswith("^"):
            part = part[1:-1]; fmt["baseline"] = "30000"
        r.text = part
        if fmt.get("bold"): r.font.bold = True
        elif bold is not None: r.font.bold = bold
        if fmt.get("italic"): r.font.italic = True
        if "baseline" in fmt: r._r.get_or_add_rPr().set("baseline", fmt["baseline"])
        if size: r.font.size = Pt(size)
        if color is not None: r.font.color.rgb = color

def set_text(shape, lines, size=None, color=None):
    tf = shape.text_frame
    if isinstance(lines, str):
        lines = [lines]
    # clear existing paragraphs but keep the first paragraph's properties
    for p in list(tf.paragraphs)[1:]:
        p._p.getparent().remove(p._p)
    first = tf.paragraphs[0]
    for r in list(first.runs):
        r._r.getparent().remove(r._r)
    for i, line in enumerate(lines):
        par = first if i == 0 else tf.add_paragraph()
        level = 0
        while line.startswith("  "):
            level += 1; line = line[2:]
        par.level = level
        add_runs(par, line, size=size, color=color)

def ph(slide, idx):
    for s in slide.placeholders:
        if s.placeholder_format.idx == idx:
            return s
    raise KeyError(f"placeholder idx {idx} not on layout {slide.slide_layout.name}")

def add_slide_number(slide):
    for lph in slide.slide_layout.placeholders:
        if lph.placeholder_format.type is not None and "SLIDE_NUMBER" in str(lph.placeholder_format.type):
            el = copy.deepcopy(lph._element)
            slide.shapes._spTree.append(el)
            # make sure it contains a slidenum field
            txBody = el.find(qn("p:txBody"))
            if txBody is not None and not txBody.findall(".//" + qn("a:fld")):
                pass
            return

def new(layout, fields=None, notes=None, pictures=None, number=True, hidden=False):
    slide = prs.slides.add_slide(LAYOUT[layout])
    if hidden:
        slide._element.set("show", "0")
    for idx, val in (fields or {}).items():
        if isinstance(val, tuple):
            set_text(ph(slide, idx), val[0], size=val[1])
        else:
            set_text(ph(slide, idx), val)
    for idx, path in (pictures or {}).items():
        ph(slide, idx).insert_picture(path)
    # remove unused empty placeholders (keeps the slide clean in Keynote)
    for s in list(slide.placeholders):
        if s.has_text_frame and not s.text_frame.text.strip() and s.placeholder_format.idx not in (fields or {}):
            s._element.getparent().remove(s._element)
    if number and layout not in ("Title", "Photo"):
        add_slide_number(slide)
    if notes:
        slide.notes_slide.notes_text_frame.text = notes.strip()
    return slide

def table(slide, header, rows, col_w, top=2.15, row_h=0.52, size=15, first_col_bold=True, left=0.8,
          highlight_rows=()):
    nrows, ncols = len(rows) + 1, len(header)
    shape = slide.shapes.add_table(nrows, ncols, Inches(left), Inches(top), Inches(sum(col_w)), Inches(row_h * nrows))
    tbl = shape.table
    # strip the default table style banding
    tblPr = tbl._tbl.tblPr
    tblPr.set("firstRow", "0"); tblPr.set("bandRow", "0")
    for j, w in enumerate(col_w):
        tbl.columns[j].width = Inches(w)
    for i in range(nrows):
        tbl.rows[i].height = Inches(row_h)
        for j in range(ncols):
            cell = tbl.cell(i, j)
            text = header[j] if i == 0 else rows[i - 1][j]
            cell.text = ""
            par = cell.text_frame.paragraphs[0]
            par.alignment = PP_ALIGN.LEFT if j == 0 else PP_ALIGN.CENTER
            if i == 0:
                add_runs(par, text, size=size, color=RGBColor(0xFF, 0xFF, 0xFF), bold=True)
                cell.fill.solid(); cell.fill.fore_color.rgb = FOREST
            else:
                hl = (i - 1) in highlight_rows
                add_runs(par, text, size=size, color=CLAY if hl and j > 0 else INK,
                         bold=(j == 0 and first_col_bold) or hl)
                cell.fill.solid(); cell.fill.fore_color.rgb = PALE if i % 2 == 1 else BG
            for r in par.runs:
                r.font.name = FONT
            cell.vertical_anchor = MSO_ANCHOR.MIDDLE
            cell.margin_left = cell.margin_right = Inches(0.08)
            cell.margin_top = cell.margin_bottom = Inches(0.03)
    return tbl

def textbox(slide, text, left, top, width, height, size=16, color=GREY, italic=False, align=PP_ALIGN.LEFT):
    tb = slide.shapes.add_textbox(Inches(left), Inches(top), Inches(width), Inches(height))
    tf = tb.text_frame; tf.word_wrap = True
    lines = text if isinstance(text, list) else [text]
    for i, line in enumerate(lines):
        par = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        par.alignment = align
        add_runs(par, line, size=size, color=color)
        for r in par.runs:
            r.font.name = FONT
            if italic: r.font.italic = True
    return tb


def pic(slide, path, left, top, width, height):
    return slide.shapes.add_picture(path, Inches(left), Inches(top), Inches(width), Inches(height))

def panel(slide, left, top, width, height, text, size=14):
    box = slide.shapes.add_shape(1, Inches(left), Inches(top), Inches(width), Inches(height))
    box.fill.solid(); box.fill.fore_color.rgb = PALE; box.line.fill.background()
    tf = box.text_frame; tf.word_wrap = True; tf.vertical_anchor = MSO_ANCHOR.MIDDLE
    for m in ("margin_left", "margin_right"): setattr(tf, m, Inches(0.12))
    par = tf.paragraphs[0]; par.alignment = PP_ALIGN.CENTER
    add_runs(par, text, size=size, color=GREY)
    for r in par.runs: r.font.name = FONT
    return box

def three_up(slide, items, top=2.2, h=2.75):
    """items: list of (image, heading, text). Three pictures across the content width with native captions."""
    xs = [0.8, 4.8, 8.8]
    for x, (img, head, text) in zip(xs, items):
        pic(slide, img, x, top, 3.73, h)
        textbox(slide, f"**{head}**", x, top + h + 0.08, 3.73, 0.4, size=16, color=FOREST)
        textbox(slide, text, x, top + h + 0.48, 3.73, 1.0, size=14, color=INK)

F = "figures/"; I = "images/"

# ================================================================ Opening
new("Title", {103: "Understanding natural selection",
              104: "How can a blind process build eyes, wings and camouflage?"},
    pictures={100: I + "title_archaeopteryx.jpg"},
    notes="""
(1 min) Guiding question for today. Natural selection has no goal and no foresight, yet it produces structures that look designed. Today we see how, and also where it falls short of perfection.
Image: the Berlin specimen of *Archaeopteryx lithographica*, one of the earliest known birds (photo H. Raab, CC BY-SA 3.0, Wikimedia Commons; carried over from the previous version). We come back to it in section 02.
""")

new("Agenda", {101: ("Understanding natural selection", 32),
               103: (["State the conditions for evolution by natural selection, and spot them in an example",
                      "Explain how cumulative selection builds complex structures",
                      "Explain why the direction and speed of selection depend on the environment",
                      "Explain why natural selection does not produce perfect organisms",
                      "Explain how traits that reduce survival, or even reproduction, can be favoured"], 20)},
    notes="""
(1 min) Five objectives, one per section. They are general skills; eyes, wings, guppies, peppered moths, sickle-cell haemoglobin and meerkats are the evidence we use to practise them.
Reading: Neal (2004), chapter "Understanding natural selection". This afternoon's practical (Bug hunt camouflage) practises objectives 1 and 3.
""")

new("Figure & Bullets", {100: "Last time: Darwin and Wallace",
                         102: (["All species descend from one, or a few, common ancestors",
                               "Individuals vary, and much of that variation is inherited",
                               "More offspring are born than can survive",
                               "Variants better able to survive and reproduce leave more descendants",
                               "Evolution has no goal or direction"], 18)},
    pictures={101: I + "darwin_wallace.jpg"},
    notes="""
(1.5 min) Recap of the previous lecture, using Neal's six statements in shortened form. Charles Darwin (left, portrait by John Collier, 1883) and Alfred Russel Wallace (right) presented natural selection jointly in 1858; Darwin's *On the Origin of Species* followed in 1859.
Changes from the previous version: (1) "All life is descended from LUCA" is a modern term; Darwin wrote that all organisms probably descended "from some one primordial form". (2) Darwin and Wallace are now named (Wallace's portrait had no label). (3) Overproduction of offspring was missing and is the engine of the argument: it leads to the "struggle for existence".
Stress "better able to": a favoured variant has a better *chance* of leaving offspring, not a guarantee. Selection is probabilistic (John Herschel called it "the law of higgledy-piggledy"; Neal).
""")

# ================================================================ Section 01
new("Section", {102: "01", 103: "Natural selection in a nutshell"},
    notes="(10 s) First, the logic: what has to be true for natural selection to happen?")

new("Statement", {101: ("If individuals **vary** in a trait, the trait affects **reproductive success**, and the trait is **inherited**, the population will evolve.", 34),
                  103: "Evolution by natural selection, in one sentence"},
    notes="""
(1.5 min) Kept from the previous version ("In a single sentence"), reworded. The next four slides take the conditions one at a time: (1) variation in the trait, (2) variation in reproductive success, (3) a relationship between the two, (4) inheritance.
Conditions 1 to 3 are natural selection: some variants do better than others within a generation. Condition 4 turns selection into evolution: the next generation resembles the successful parents. (This framing follows Endler 1986, *Natural Selection in the Wild*.)
The previous wording ended "Natural selection leads to adaptive evolution". True, but the slide now says what selection actually needs; adaptation is the outcome we see at the end of the section.
Logic note for students who meet the "tautology" criticism ("survival of the fittest; the fittest are those that survive"): the argument is a set of testable facts and a deduction from them. Each condition could have been false, and each has been tested (Neal, "Is natural selection a valid scientific theory?").
""")

new("Title, Bullets & Photo", {100: "Condition 1: individuals vary",
                               103: "TAKEAWAY",
                               105: ("Students sorted by height: most traits vary continuously among individuals.", 20)},
    pictures={101: I + "living_histogram.jpg"},
    notes="""
(1 min) A "living histogram": students lined up by height (photo carried over from the previous version; the same image appears in the quantitative genetics lecture, where we ask how much of this variation is genetic).
Variation is the raw material. Without it, there is nothing for selection to sort.
New variation arises by mutation each generation and is reshuffled by sex (mutation lecture later in the course). Mutation is random with respect to need: organisms do not produce the variants they need (Neal).
""")

new("Title & Photo", {100: "Condition 2: reproductive success varies",
                      102: "Most leave few or no offspring. Great tits (*Parus major*), SDU nest boxes; Soay sheep (*Ovis aries*), St Kilda."},
    pictures={101: F + "01_rs_variation.png"},
    notes="""
(1.5 min) Our own data. Great tits: clutch size in one season (the first bar includes boxes with 0 or 1 egg; these counts were digitised from the histogram in the previous version of the slide, so replace with the raw data if available). Soay sheep: the number of offspring produced over a whole lifetime. The lifetime distribution is extremely skewed: most sheep leave no offspring at all.
This is Darwin's overproduction and struggle for existence in data. A pair of great tits lays 7 to 10 eggs a year, but on average only about two offspring per pair need to survive to breed for the population to stay the same size.
Correction to the previous notes: across species, high fecundity goes with high mortality (a positive relationship), otherwise we would be "buried in mice and small birds".
Optional (previous version): the old slide also had photos of the nest box, a great tit in the hand, a nest with eggs, and Soay sheep being caught. They are in images/source/ if you want to add them back.
""")

new("Title & Photo", {100: "Condition 3: the trait affects reproduction",
                      102: "Simulated data. Real example: taller West Point graduates had more children (Mueller & Mazur 2001)."},
    pictures={101: F + "02_trait_rs.png"},
    notes="""
(2 min) Merges two slides from the previous version: the three trait-versus-reproductive-success sketches, and "Adaptive evolution is part of a continuum".
Left and centre: the trait predicts reproductive success, so selection acts, in opposite directions. The steeper the relationship, the stronger the selection. Right: no relationship. The trait can still change from generation to generation, but only by chance (genetic drift, a later lecture). This is neutral evolution. Most real traits lie somewhere on this continuum, and drift and selection act at the same time.
The example: Mueller & Mazur (2001) followed men from the West Point class of 1950. Taller men had more children, mainly because they were more likely to remarry (an example of selection on a human trait; the cultural context matters).
Simulated data, script 02_trait_rs.R (Poisson reproductive success; slopes +0.6, −0.6 and 0; seed 512).
""")

new("Title, Bullets & Photo", {100: "Condition 4: offspring resemble parents",
                               103: "TAKEAWAY",
                               105: ("Selection changes the next generation only if the trait is heritable: passed on in the genes.", 20)},
    pictures={101: I + "stormtroopers.jpg"},
    notes="""
(1 min) Kept from the previous version. Name the concept: **heritability**, the proportion of the variation in a trait that is due to genes passed from parents to offspring (quantitative genetics lecture).
Resemblance alone is not enough: offspring can resemble parents because they share an environment (food, territory, culture). Selection on a trait with no genetic basis changes nothing in the next generation.
Image: toy stormtroopers, Flickr (file 6088362947, carried over; author and licence to confirm).
""")

new("Check Question (4 options)", {101: ("Which statement is correct?", 30),
                                   105: "Giraffes stretched their necks, and their offspring inherited longer necks",
                                   109: "Bacteria produce resistance mutations because they need them",
                                   113: "The fittest individual always survives",
                                   117: "Heritable variants that leave more offspring on average become more common"},
    notes="""
(1.5 min) Answer D. Ask for a show of hands first.
A: inheritance of acquired characteristics (Lamarck). Individuals do not evolve; populations do. (The Bug hunt practical asks the same: do individual bugs change colour?)
B: mutation is random with respect to need: resistance mutations arise whether or not the antibiotic is present (the Luria–Delbrück experiment in the mutation lecture shows this). The antibiotic then selects them.
C: selection is probabilistic. "Better able to" survive means a better chance, not a certainty. Averaged over many individuals and generations, the bias becomes predictable.
""")

s = new("Title Only", {100: "The result: adaptation"},
    notes="""
(1 min) If the four conditions hold, generation after generation, the result is adaptation: traits that fit the organism to its current environment. The previous version had six images on an untitled slide; three are kept.
Left: dead-leaf butterfly (*Kallima*), camouflage. Neal describes a grasshopper in Zimbabwe that mimics a dead leaf, and even times its adult stage to the dry season, when dead leaves are common.
Centre: hoverflies (family Syrphidae), harmless flies that mimic stinging wasps and bees (Batesian mimicry). Typo in the previous notes: "overflies".
Right: a black smoker hydrothermal vent. Its animals and microbes are adapted to high temperature, pressure and toxic chemicals.
Dropped: tiger and snowy owl (camouflage again) and the cheetah chasing a gazelle (used later as the pronghorn's "ghost").
Image sources to confirm (see images/CREDITS.md).
""")
three_up(s, [(I + "adapt_leaf_butterfly.jpg", "Camouflage", "Dead-leaf butterfly, *Kallima*"),
             (I + "adapt_hoverflies.jpg", "Mimicry", "Hoverflies that look like wasps and bees"),
             (I + "adapt_black_smoker.jpg", "Physiology", "Life at deep-sea hydrothermal vents")], h=2.85)

# ================================================================ Section 02
new("Section", {102: "02", 103: "Explaining the “impossible”"},
    notes="(10 s) The oldest objection: some structures seem too perfect, or too complex, to have evolved step by step.")

new("Quote", {101: "To suppose that the eye … could have been formed by natural selection, seems, I freely confess, absurd in the highest possible degree.",
              103: "CHARLES DARWIN, ON THE ORIGIN OF SPECIES, 1859"},
    notes="""
(1 min) Replaces the "The eye" slide, whose quotation had no source. Darwin raised the objection himself, then answered it in the next sentences: if numerous gradations from a simple to a complex eye can be shown to exist, "each grade being useful to its possessor", the difficulty "can hardly be considered real".
The objection is the **argument from design**: William Paley (1802, *Natural Theology*) argued that a watch found on a heath implies a watchmaker, and an eye implies a designer. Students met this in the Blind Watchmaker practical.
Neal's answer is the plan for this section: (1) complex structures are not built in one step; (2) every intermediate stage must be useful in its own right.
""")

new("Title, Bullets & Photo", {100: "Cumulative selection beats chance",
                               103: "TAKEAWAY",
                               105: ("Typing METHINKS IT IS LIKE A WEASEL at random: 1 chance in 10^40^. Keeping each correct letter: about 100 generations.", 20)},
    pictures={101: F + "03_cumulative_selection.png"},
    notes="""
(1.5 min) Dawkins (1986, *The Blind Watchmaker*), as described by Neal. 27 characters (26 letters and a space) and 28 positions: (1/27)^28 ≈ 1 in 1.2 × 10^40 per attempt.
Cumulative selection keeps each improvement, so success builds on success. In this run it took 99 generations (it varies between runs; Dawkins's version, which breeds many copies each generation and keeps the closest, took 43).
This is the algorithm from Monday's Blind Watchmaker practical.
Limitation, and the link to the next slides: the program has a target, and evolution does not. In real evolution each intermediate must be useful now. So we need to ask "what good is half an eye?"
Simulated, script 03_cumulative_selection.R (seed 512).
""")

s = new("Title Only", {100: "Working eyes at every stage: molluscs"},
    notes="""
(2 min) Neal (2004) Fig. 3.4, from Strickberger (1990), redrawn layout of the previous slide. Each stage is a working eye used by living molluscs today:
(a) light spot: light versus dark, enough for a slow-moving or sessile animal; (b) cup: shading by the cup gives the direction of light (limpets, *Patella*); (c) pinhole: a dim image (*Nautilus*, which has no lens); (d) closed eye with lens: a focused image (e.g. snails); (e) cornea, lens and adjustable iris (cuttlefish, squid, octopus).
Key point (misconception): these are **modern species**, not ancestors of one another. They show that every stage works, not the actual path any lineage took.
Correction: the previous version used a jellyfish photo for (a). Jellyfish are cnidarians, not molluscs, and box jellyfish even have lens eyes. Note also that Neal's text describes six stages (a to f) but his figure shows five; the figure's (d) and (e) correspond to the text's (e) and (f).
Light-sensitive organs have evolved independently many times: Neal says at least 40 times, probably more than 60 (Salvini-Plawen & Mayr 1977; Land 1992).
Photos carried over from the previous version (Wikimedia Commons; see images/CREDITS.md). Roman snail (*Helix pomatia*) occurs in Denmark.
""")
cols = [("a", "Light spot", "Light or dark", None, ""),
        ("b", "Cup", "Direction of light", "eye_photo_limpets.jpg", "Limpets"),
        ("c", "Pinhole", "Dim image", "eye_photo_nautilus.jpg", "*Nautilus*"),
        ("d", "Closed, with lens", "Focused image", "eye_photo_snail.jpg", "Roman snail"),
        ("e", "Lens, cornea, iris", "Sharp image", "eye_photo_cuttlefish.jpg", "Cuttlefish")]
for k, (key, head, func, photo, sp) in enumerate(cols):
    x = 0.8 + k * (2.2 + 0.1825)
    pic(s, I + f"eye_{key}.jpg", x, 2.05, 2.2, 1.75)
    textbox(s, f"**{head}**", x, 3.82, 2.2, 0.38, size=15, color=FOREST, align=PP_ALIGN.CENTER)
    textbox(s, func, x, 4.17, 2.2, 0.36, size=14, color=GREY, align=PP_ALIGN.CENTER)
    if photo:
        pic(s, I + photo, x, 4.6, 2.2, 1.45)
        textbox(s, sp, x, 6.07, 2.2, 0.36, size=14, color=GREY, align=PP_ALIGN.CENTER)
    else:
        panel(s, x, 4.6, 2.2, 1.45, "Found in many animal groups")

new("Figure & Bullets", {100: "Two camera eyes, two histories",
                         102: (["**Left, vertebrate:** nerve fibres (2) run *in front of* the photoreceptors (1) and exit through the retina: a blind spot (4)",
                               "**Right, octopus:** fibres run behind the retina, so there is no blind spot",
                               "Same function, built differently: each eye carries its own history"], 18)},
    pictures={101: I + "vertebrate_octopus_eye.jpg"},
    notes="""
(1.5 min) Retitled: the previous title "Mollusc eyes" did not match the slide, which compares a vertebrate eye with a cephalopod eye. Diagram: Wikimedia Commons, "Evolution eye.svg" (licence to confirm). 1 = retina (photoreceptors), 2 = nerve fibres, 3 = optic nerve, 4 = blind spot.
The vertebrate retina is "inverted": light passes through nerve cells before reaching the photoreceptors. That is not what a designer starting from scratch would do; it is what you get by modifying what was there before (the vertebrate eye develops as an outgrowth of the brain, the cephalopod eye from an infolding of the skin). Camera eyes evolved independently in the two lineages (convergent evolution).
Nuance for curious students: the inverted design is not purely a defect. It keeps photoreceptors next to their blood supply and pigment layer, and glial cells may guide light through the retina.
Neal's parallel example of history showing through: our airway and food pipe cross, so we can choke, because lungs evolved as outgrowths of the gut in air-gulping fish.
""")

new("Big Fact", {100: "< 400,000",
                 102: "generations to turn a flat light-sensitive patch into a focused camera eye, assuming only 0.005% change per generation (Nilsson & Pelger 1994)"},
    notes="""
(1 min) Cut first if short of time. Numbers in context: Nilsson & Pelger (1994, *Proc. R. Soc. B* 256: 53–58) modelled the change from a flat patch of photoreceptors to a fish-like lens eye as 1,829 steps of 1% change in shape, each step improving image quality. With deliberately pessimistic assumptions (heritability 0.5, very weak selection), each generation changes the eye by only 0.005%, giving 363,992 generations.
For small animals with one generation a year, that is under half a million years: a geological blink. Eyes appear in the fossil record in the Cambrian, more than 500 million years ago.
This answers Darwin's "absurd in the highest possible degree": there is plenty of time.
""")

new("Figure & Bullets", {100: "What good is half a wing?",
                         102: ["Powered flight needs large wings, strong muscles and control",
                               "Each step towards it must already be useful",
                               "*Archaeopteryx*, about 150 million years old: feathered wings, teeth and a long bony tail",
                               "So what were early wings for?"]},
    pictures={101: I + "archaeopteryx_half.jpg"},
    notes="""
(0.5 min) Reworded from "What good is a non-functional wing?": the point of the section is that the intermediate stages were functional, just not (yet) for powered flight.
*Archaeopteryx lithographica*, Berlin specimen (photo H. Raab, CC BY-SA 3.0). Late Jurassic, about 150 million years ago: bird-like feathers combined with dinosaur features.
""")

s = new("Title Only", {100: "Three ideas for half a wing"},
    notes="""
(2 min) The three hypotheses from the previous version (one slide instead of four with the same bullets), with corrections.
Gliding (arboreal hypothesis): climbing animals that glide from trees save energy and escape predators, even without powered flight. The flying squirrel is a mammal, so it is an **analogue**: it shows that gliding works without flapping, not how birds evolved. Microraptor, a small four-winged dromaeosaur dinosaur, is usually cited as evidence for this idea.
Pouncing and pinning prey: predatory dinosaurs may have used feathered forelimbs to balance while pouncing and holding down prey ("pouncing proavis", Garner, Taylor & Thomas 1999; prey restraint in dromaeosaurs such as *Deinonychus*, Fowler et al. 2011). Correction: the previous version used Microraptor as the example of "riding prey"; that idea comes from larger dromaeosaurs.
Wing-assisted incline running (WAIR): chukar partridge chicks (*Alectoris chukar*) flap their small, partly feathered wings to run up steep slopes and tree trunks long before they can fly (Dial 2003, *Science*). Video: https://www.youtube.com/watch?v=VFUNhTdcNdk
These ideas are not mutually exclusive.
Images carried over from the previous version; sources to confirm.
""")
three_up(s, [(I + "wing_glide.jpg", "Gliding down", "Gliding works without powered flight: the flying squirrel is a mammal analogue"),
             (I + "wing_microraptor.jpg", "Pouncing on prey", "Feathered arms for balance while pouncing on and pinning prey"),
             (I + "wing_wair.jpg", "Running uphill", "Chukar chicks flap small wings to run up slopes (WAIR)")])

new("Key Concept", {102: "Exaptation",
                    103: "A trait that evolved for one function and was later taken over for another.",
                    105: "Feathers first evolved in dinosaurs that could not fly, probably for insulation and display. Only later were they used for flight."},
    notes="""
(1 min) New slide: the strongest answer to "what good is half a wing?" Feathers were useful long before flight. Simple filament-like feathers are found in non-flying dinosaurs such as *Sinosauropteryx* (described 1996).
Term from Gould & Vrba (1982). Neal makes the related point: each step on the path to a complex structure must have an immediate advantage, but that advantage need not be for the function we see today.
Connects back to Mount Improbable (Dawkins 1996, in Neal): the cliff face looks impossible to climb in one leap, but there is a gentle slope round the back, climbed one small step at a time.
""")

# ================================================================ Section 03
new("Section", {102: "03", 103: "Selection in action"},
    notes="(10 s) Selection is not only something that happened in the deep past. We can watch it, and even do experiments with it.")

new("Figure & Bullets", {100: "Guppies in Trinidad: a natural experiment",
                         102: (["Guppies (*Poecilia reticulata*) live in mountain streams",
                               "Below waterfalls: predatory fish eat adult guppies",
                               "Above waterfalls: few predators, mostly of small juveniles",
                               "Experiment: guppies moved from below a waterfall to a guppy-free stretch above it"], 18)},
    pictures={101: I + "guppies.jpg"},
    notes="""
(1.5 min) Context before data (the previous version showed the result without the set-up).
High-predation sites: pike cichlid (*Crenicichla alta*) and other predatory fish eat mainly large, adult guppies. Low-predation sites above waterfalls: only the killifish *Rivulus hartii* (now *Anablepsoides hartii*), which occasionally eats small guppies.
Endler (1980) and Reznick and colleagues moved guppies from high-predation sites to low-predation stretches of tributaries of the Aripo and El Cedro rivers (Reznick et al. 1990, *Nature*; 1997, *Science*). The waterfall stops guppies moving back.
Image: male guppies, carried over from the previous version (source to confirm). The previous version also showed experimental stream channels (images/source/guppy_stream.png); its source is unknown.
""")

new("Check Question (4 options)", {101: ("Adults are no longer eaten. After 11 years, how will age at maturity have evolved?", 28),
                                   105: "Earlier maturity", 109: "Later maturity",
                                   113: "No change: 11 years is too short", 117: "It depends on the guppy's needs"},
    notes="""
(1.5 min) Prediction before the data. Ask pairs to commit to an answer and a reason.
Answer B. Reasoning: where adults are likely to be eaten, it pays to reproduce early, before you are caught. Once adult mortality is low, it pays to grow larger first and reproduce later, producing fewer but larger offspring. (We return to this in the life-history lecture.)
D is the "need" misconception again: selection does not respond to need; it sorts the variation that exists.
""")

new("Title, Bullets & Photo", {100: "Guppies evolved in about 18 generations",
                               103: "TAKEAWAY",
                               105: ("Without adult predators, males and females matured later and larger, with fewer, larger offspring.", 20)},
    pictures={101: F + "04_guppy_life_history.png"},
    notes="""
(1.5 min) Real data: Reznick, Shaw, Rodd & Shaw (1997) *Science* 275: 1934–1937, Aripo River, 11 years after introduction (about 18 generations). Fish were reared in a common laboratory environment, so the differences are genetic, not plastic. All four differences are statistically significant.
Corrections from the previous version: (1) the old slides said the guppies were moved to streams *without* predators but then listed what evolved "with move to high predation". The traits listed (earlier maturation, smaller offspring, duller males) describe **high-predation** populations; the transplanted population evolved the opposite way. (2) "Life history changed quickly (<2–3 yrs)": life history took 4 years (males, El Cedro) to 11 years. The very fast change was male **colour**: transplanted males evolved more and brighter spots within about 15 generations (Endler 1980), because the main predator of colourful males was gone. (3) "more discrete displays" should be "more discreet".
Rates: thousands of darwins, several orders of magnitude faster than typical rates in the fossil record (Reznick et al. 1997).
Empirical, values hard-coded from the paper's Table 1; script 04_guppy_life_history.R.
""")

new("Title, Bullets & Photo", {100: "The environment decides which trait wins",
                               103: "TAKEAWAY",
                               105: ("Peppered moths: the dark form spread where soot blackened trees, then declined after clean-air laws.", 20)},
    pictures={101: I + "peppered_morphs.jpg"},
    notes="""
(1.5 min) Peppered moth (*Biston betularia*): pale *typica* (left) and dark *carbonaria* (right). Before the Industrial Revolution the pale form was common. Around Manchester the dark form rose from about 1% in 1848 to about 99% by 1898 (Haldane's round numbers, Neal), because birds took more of the conspicuous moths on soot-darkened, lichen-free bark. After the Clean Air Acts of the 1950s the dark form declined again.
The same allele was favoured in one place and time and disfavoured in another: the strength and even the direction of selection depend on the environment. The previous version stopped at "during the industrial revolution, dark morph common"; the reversal is the strongest evidence.
This is exactly what students do in this afternoon's Bug hunt practical when they switch backgrounds.
Details (Haldane's estimate of s, Kettlewell's experiments) come in the haploid and zygotic selection lecture.
Image: Olaf Leillinger, Wikimedia Commons, CC BY-SA 2.5 (as used in the selection lecture).
""")

new("Figure & Bullets", {100: "Antibiotic resistance: favoured or costly",
                         102: (["With the antibiotic: resistant bacteria survive and spread rapidly",
                               "Without it: resistance often carries a cost, and susceptible bacteria grow faster",
                               "The same mutation can be favoured or disfavoured, depending on the environment"], 18)},
    pictures={101: I + "antibiotics.jpg"},
    notes="""
(1 min) Cut if short of time. Correction from the previous version: it said resistance mutations are "neutral in the absence of an antibiotic". Often they are not: many resistance mutations reduce growth rate when no antibiotic is present (a fitness cost), although some are cost-free and costs are often reduced over time by compensatory mutations (Andersson & Hughes 2010, *Nature Reviews Microbiology*). That is why stopping antibiotic use does not reliably make resistance disappear.
Either way the teaching point is the same: fitness is a property of a genotype in an environment.
Image carried over from the previous version (source to confirm).
""")

# ================================================================ Section 04
new("Section", {102: "04", 103: "Why selection does not produce perfection"},
    notes="(10 s) If selection is so powerful, why are organisms not perfect? Four reasons.")

new("Title, Bullets & Photo", {100: "Fitness landscapes: stuck on a local peak",
                               103: "TAKEAWAY",
                               105: ("Selection only climbs uphill. A population can get stuck on a lower peak.", 20)},
    pictures={101: F + "05_fitness_landscape.png"},
    notes="""
(1.5 min) Sewall Wright's (1932) fitness landscape, drawn here in its phenotypic form: trait value along the bottom, mean fitness as height. In reality there are many trait dimensions, so landscapes are rugged with many peaks (the 3-D surface on the previous version).
Each generation there is some variation around the population mean, and selection moves the mean uphill. To reach the higher peak, the population would have to pass through the valley: worse intermediates. Selection alone cannot do this, because every step must be an improvement. Chance (genetic drift in small populations) or a change in the environment, which reshapes the landscape, can sometimes move populations across valleys.
This is the same idea as Mount Improbable, and one reason why "perfection" is unattainable.
Schematic, script 05_fitness_landscape.R.
""")

new("Title & Photo", {100: "Gene flow can swamp local adaptation",
                      102: "Schematic. The outcome depends on the migration rate relative to the strength of selection."},
    pictures={101: F + "06_gene_flow.png"},
    notes="""
(1.5 min) Gene flow is the movement of alleles between populations, by individuals moving or by gametes and seeds (sperm, eggs, pollen).
Left: no movement, so each habitat ends up dominated by the locally favoured form (local adaptation). Right: frequent migration keeps bringing in the wrong form, so neither population is well adapted.
Corrections from the previous version: (1) the bullets read as if gene flow "promotes genetic divergence or even allopatric speciation". It is the opposite: gene flow makes populations more similar; **barriers** to gene flow (mountains, rivers, roads) allow divergence and possibly allopatric speciation. (2) "Gene flow prevents adaptation" was too strong. The outcome depends on the balance between migration and selection (migration–selection balance), and gene flow can also bring in useful new variation.
Details in the lecture on migration, gene flow and differentiation of populations.
Schematic, redrawn from the previous version; script 06_gene_flow.R.
""")

new("Figure & Bullets", {100: "Sickle-cell: selection is not design",
                         102: (["One copy of the HbS allele (carriers): protected against severe malaria",
                               "Two copies: sickle-cell disease, often with a shortened life",
                               "Where malaria is common, selection keeps the allele common",
                               "No designer would protect some people by harming others"], 18)},
    pictures={101: I + "sickle_cells.jpg"},
    notes="""
(1.5 min) Neal uses this example against the argument from design: natural selection is blind to the cost it imposes on some individuals.
Critical correction from the previous version: it said "SCD is adaptive in malarial regions". The **disease** (two copies, HbSS) is never adaptive. It is the **allele** that is favoured, because heterozygous carriers (HbAS) are protected against severe malaria. This is heterozygote advantage, a form of balancing selection.
Also reworded: carriers are usually healthy; their red cells contain both normal and sickle haemoglobin and sickle mainly at low oxygen. Correct the grammar of "Sickle cell diseases is".
Quantitative version (equilibrium allele frequency of about 0.23 from Allison's fitness estimates) in the haploid and zygotic selection lecture.
Image: red blood cells including a sickled cell (OpenStax Anatomy and Physiology, CC BY 4.0, as used in the selection lecture).
""")

new("Title, Bullets & Photo", {100: "Ghosts of past selection",
                               103: "TAKEAWAY",
                               105: ("Pronghorn outrun every living North American predator. Their speed probably evolved for a predator that is now extinct.", 20)},
    pictures={101: I + "pronghorn.jpg"},
    notes="""
(1.5 min) Pronghorn (*Antilocapra americana*). Corrections from the previous notes: pronghorn are **not antelopes** (they are the last surviving member of their own family, Antilocapridae), and they are not "faster than cheetah over any distance". Cheetahs are faster in a sprint; pronghorn can sustain high speed (over about 80 km/h in bursts) for much longer than any living North American predator.
Hypothesis (Byers 1997, *American Pronghorn: Social Adaptations and the Ghosts of Predators Past*): their speed evolved under predation by the "American cheetah" *Miracinonyx*, which went extinct at the end of the Pleistocene, around 12,000 years ago. *Miracinonyx* was a cheetah-like relative of the puma rather than a true cheetah, and the idea is plausible but hard to test.
General point: traits reflect selection in past environments. A trait that makes little sense today may have made sense before (also called evolutionary lag).
Image: pronghorn running, USDA, Flickr (public domain, to confirm).
""")

# ================================================================ Section 05
new("Section", {102: "05", 103: "Fitness is genes passed on, not survival"},
    notes="(10 s) “Survival of the fittest” is misleading. What counts is copies of genes in future generations.")

new("Figure & Bullets", {100: "Dying for reproduction",
                         102: ["Selection favours traits that increase reproductive success, even at the cost of survival",
                               "Sexual cannibalism: male redback spiders that are eaten during mating father more offspring",
                               "Matriphagy: *Stegodyphus* spider mothers are eaten by their young"]},
    pictures={101: I + "cannibalism.jpg"},
    notes="""
(1.5 min) Previously "Taken to an extreme: cannibalism", moved here because it shows that fitness means reproduction, not survival.
Redback spider (*Latrodectus hasselti*): the male somersaults his abdomen into the female's jaws during mating. Males that are eaten copulate for longer and fertilise more eggs, and most males would get only one chance to mate anyway (Andrade 1996, *Science* 271: 70–72).
Top image: European praying mantis (*Mantis religiosa*) during mating; sexual cannibalism also occurs in mantises, although it is less frequent in the wild than in captivity, and its benefit to males is debated. Correction: "preying mantis" should be "praying mantis". The previous version also showed a black widow photo while the text named the redback; that photo has been removed.
Bottom: *Stegodyphus* spiderlings feeding on their mother (in *S. dumicola* and *S. lineatus* the mother regurgitates food and is then eaten). The mother loses her life but increases the survival of her offspring, who carry her genes: this leads straight into kin selection.
Images carried over from the previous version (sources to confirm).
""")

new("Title, Bullets & Photo", {100: "Why help others breed?",
                               103: "TAKEAWAY",
                               105: ("Meerkat helpers raise pups that are not their own. Helping can spread genes if the pups are relatives.", 20)},
    pictures={101: I + "meerkats.jpg"},
    notes="""
(1 min) So far we have been individual-focused. Why would an individual give up breeding to help others (altruism)?
Examples: cooperative breeders such as meerkats (*Suricata suricatta*), where subordinate helpers babysit and feed pups; social insects, where workers do not reproduce and raise the queen's offspring.
Correction from the previous version: "parental care in general" was listed as an example. Caring for your own offspring increases your own (direct) reproductive success, so it does not need kin selection to explain it.
Image: meerkats at Tswalu, Wikimedia Commons (licence to confirm).
""")

new("Title, Bullets & Photo", {100: "Kin selection: relatives share genes",
                               103: "TAKEAWAY",
                               105: ("My son has a 50% chance of carrying a copy of any one of my alleles. Helping relatives can pass on my genes.", 20)},
    pictures={101: I + "owen_and_son.jpg"},
    notes="""
(1 min) Kept from the previous version, with a correction. "I share half my genes with my son" is a common misconception: any two humans share nearly all their genes. What is ½ is the **coefficient of relatedness**, r: the probability that a copy of one of my alleles is also in my son, inherited from me (identical by descent). r = ½ for parents and offspring and, on average, for full siblings; ¼ for half-siblings, grandparents and grandchildren; ⅛ for first cousins.
An allele for helping can therefore spread if the benefit to relatives, weighted by r, outweighs the cost to the helper. This is Hamilton's rule (rB > C), covered in the lecture on animal behaviour and altruism.
Neal: kin selection is the case where it helps to think of selection acting on genes rather than individuals. Group selection, the idea that traits evolve "for the good of the species", usually fails, because selfish individuals within the group out-reproduce the rest (Neal, "Some philosophical considerations").
""")

# ================================================================ Wrap-up
new("Activity", {101: "THIS AFTERNOON · NETLOGO",
                 102: ("You are the predator: can you make bugs evolve camouflage?", 34),
                 103: ["Bug hunt camouflage: hunt bugs on a background, then switch backgrounds",
                       "Watch how the bugs' colour and your hunting rate change",
                       "Find all four conditions in the model. Which one is mutation?"]},
    notes="""
(1 min) Preview of the practical (BB512 course book, chapter "Bug hunt camouflage (NetLogo)": https://jonesor.github.io/BB512_Book/ ; check the chapter link before posting).
It practises objectives 1 and 3: variation in colour, reproductive success that depends on colour (you eat conspicuous bugs), inheritance with small mutations ("max-mutation-step"), and context-dependence when the background changes (the peppered moth story).
Answer to the last prompt: mutation is the max-mutation-step slider; it creates the new variation each generation.
""")

new("Summary", {101: "Key points",
                102: (["Variation + reproductive success + inheritance = evolution",
                       "Cumulative selection builds complexity from working steps",
                       "Selection can be fast; the environment sets its direction",
                       "Local peaks, gene flow, trade-offs and history limit perfection",
                       "Fitness is genes passed on, via offspring or relatives"], 18),
                106: (["**Read:** Neal (2004), “Understanding natural selection”",
                       "**Practical:** Bug hunt camouflage",
                       "**Next:** Exponential growth"], 16)},
    notes="""
(1 min) One point per section, in the order of the objectives.
Reading: Neal (2004), chapter "Understanding natural selection" (sections on philosophical considerations, the argument from design, and explaining the seemingly impossible). The course uses a newer edition; the chapter title is the same.
The next lecture (exponential growth) turns Darwin's "more offspring than can survive" into numbers.
""")

prs.save(OUT)
print("saved", OUT, len(prs.slides), "slides")
