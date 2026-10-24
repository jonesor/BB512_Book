"""Build "BB512 - 01 - Darwin and his theories" from BB512_Theme.pptx.
Run from the lecture folder:  python3 build_deck.py <path/to/BB512_Theme.pptx> <out.pptx>
Inline markup in text: *italic*, **bold**, ~subscript~, ^superscript^, `code`.
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
# Paragraph and run formatting (bullets, spacing, colours) live on the theme's sample slides, not on the
# layouts, so copy them from the sample slide for each layout and placeholder.
STYLE = {}
for _s in prs.slides:
    for _ph in _s.placeholders:
        if not _ph.has_text_frame: continue
        for _p in _ph.text_frame.paragraphs:
            if _p.runs:
                _rpr = copy.deepcopy(_p.runs[0]._r.find(qn("a:rPr")))
                for _a in ("sz", "dirty", "lang"):
                    if _rpr is not None and _a in _rpr.attrib: del _rpr.attrib[_a]
                STYLE[(_s.slide_layout.name, _ph.placeholder_format.idx)] = (copy.deepcopy(_p._p.pPr), _rpr)
                break
# Remove the theme's example slides
sldIdLst = prs.slides._sldIdLst
for sldId in list(sldIdLst):
    prs.part.drop_rel(sldId.rId); sldIdLst.remove(sldId)
LAYOUT = {l.name: l for l in prs.slide_layouts}

TOKEN = re.compile(r"(`.+?`|\*\*.+?\*\*|\*.+?\*|~.+?~|\^.+?\^)")

def add_runs(par, text, size=None, color=None, bold=None, base_rpr=None):
    for part in TOKEN.split(text):
        if not part:
            continue
        r = par.add_run()
        if base_rpr is not None:
            r._r.insert(0, copy.deepcopy(base_rpr))
        fmt = {}
        if part.startswith("`"):
            part = part[1:-1]; fmt["code"] = True
        elif part.startswith("**"):
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
        if fmt.get("code"): r.font.name = "Menlo"
        if "baseline" in fmt: r._r.get_or_add_rPr().set("baseline", fmt["baseline"])
        if size: r.font.size = Pt(size)
        if color is not None: r.font.color.rgb = color

def set_text(shape, lines, size=None, color=None, style=None):
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
        if style is not None and style[0] is not None:
            old = par._p.find(qn("a:pPr"))
            if old is not None: par._p.remove(old)
            par._p.insert(0, copy.deepcopy(style[0]))
        add_runs(par, line, size=size, color=color, base_rpr=style[1] if style else None)

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
        st = STYLE.get((layout, idx))
        if layout == "Two Columns" and idx in (103, 106) and not isinstance(val, tuple):
            val = (val, 19)
        if isinstance(val, tuple):
            set_text(ph(slide, idx), val[0], size=val[1], style=st)
        else:
            set_text(ph(slide, idx), val, style=st)
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



import os
F = "figures/"; I = "images/"
PRACTICAL = "https://jonesor.github.io/BB512_Book/the-blind-watchmaker.html"

def picture(slide, path, left, top, height=None, width=None):
    kw = {}
    if height: kw["height"] = Inches(height)
    if width: kw["width"] = Inches(width)
    return slide.shapes.add_picture(path, Inches(left), Inches(top), **kw)

# ================================================================ 1 Title
new("Title", {103: ("Darwin and his theories", 40),
              104: "What is evolution, and how did Darwin convince the world that it happens?"},
    pictures={100: I + "title_tree.jpg"},
    notes="""
(30 s) Welcome. Today: what evolution is, how Darwin arrived at his two great theories, and the evidence he used.
Image: Darwin's "I think" sketch of a branching tree of descent, Notebook B (1837), p. 36. Public domain (Cambridge University Library, via Darwin Online). It is the first tree of life he drew, a year before he read Malthus and had a mechanism.
""")

# ================================================================ Course introduction
new("Section", {102: "00", 103: "About the course"},
    notes="(10 s) First, a few minutes on how BB512 works. About 8 minutes in total for this section.")

new("Two Columns", {100: "Two broad themes",
                    101: "POPULATION BIOLOGY",
                    103: ["How populations change in size, and how they interact with their environment and each other",
                          "Part 2: Population growth models",
                          "Part 4: Interactions between species and community structure"],
                    104: "EVOLUTION",
                    106: ["How organisms have changed from earlier forms over the history of the earth",
                          "Part 1: Evolution by natural selection",
                          "Part 3: Population genetics and evolution",
                          "Part 5: Behaviour, altruism and sexual selection"]},
    notes="""
(1 min) The two themes are linked throughout: population dynamics determine who survives and reproduces, which is what natural selection acts on.
The five parts match the course book and the schedule.
""")

s = new("Title Only", {100: "The teachers"},
        notes="""
(30 s) Owen Jones (lectures and practicals) and Thomas Bjørneboe Berg (population growth and species interaction lectures).
Photos carried over from the previous version.
""")
picture(s, I + "../images/source/s04_1.png", 0.8, 2.2, height=3.3)
picture(s, I + "../images/source/s04_2.jpg", 6.97, 2.2, height=3.3)
textbox(s, ["**Owen Jones**", "jones@biology.sdu.dk", "Associate Professor, SDU",
            "Comparative life-history evolution and demography"], 3.6, 2.3, 3.2, 3.0, size=16, color=INK)
textbox(s, ["**Thomas Bjørneboe Berg**", "thomas@naturama.dk", "Senior scientist, Naturama",
            "Population biology and species management, especially dormice"], 9.75, 2.3, 3.0, 3.0, size=16, color=INK)

new("Title & Photo", {100: "My own research",
                      102: "Comparative demography and life-history evolution across plants and animals. www.sdu.dk/staff/jones"},
    pictures={101: I + "research.jpg"},
    notes="""
(1 min) Examples from my research: great tits in nest boxes (long-term population monitoring), wandering albatross, bristlecone pine (very long-lived), octopus (dies after breeding once), mayflies (short adult life), ducklings, harbour seals, and matrix population models, which you will meet in Part 2.
Photos carried over from the previous version.
""")

new("Figure & Bullets", {100: "How the course works",
                         102: (["Each session: a lecture, then a practical exercise",
                                "Between sessions: reading (and thinking), quizzes",
                                "Final exam: multiple choice and short answer",
                                "Textbook: Neal (2018) *Introduction to Population Biology*, 2nd edn, Cambridge University Press",
                                "Further literature: cited in lectures, linked on itslearning"], 18)},
    pictures={101: I + "neal_cover.jpg"},
    notes="""
(1 min) Neal (2018), ISBN 978-1107605121. Today's reading: Neal chapters 1 and 2 (in the first edition, 2004: "Darwin concludes that organisms evolve" and "Darwin's theories of evolution").
Literature cited in lectures is available via itslearning.
""")

new("Title & Photo", {100: "The course book",
                      102: "https://jonesor.github.io/BB512_Book/  (practicals, data, schedule and solutions)"},
    pictures={101: I + "website.jpg"},
    notes="(30 s) All practicals are in the online course book, with model answers in the Solutions chapter. Today's practical is chapter 2, The Blind Watchmaker.")

new("Statement", {101: "There will be maths. Don't be scared.",
                  103: "Keep in mind the processes the models try to capture, and remember that they are simplifications of real life."},
    notes="(30 s) Kept from the previous version. The maths in this course is mostly arithmetic, simple algebra and a little R. The models are tools for thinking.")

# ================================================================ Objectives and hook
new("Agenda", {101: "Darwin and his theories",
               103: (["Define evolution, and separate the pattern (common descent) from the mechanism (natural selection)",
                      "Explain how Darwin's training and voyage led him to doubt that species are fixed",
                      "Build the argument for natural selection from observable facts",
                      "Evaluate evidence for common descent from fossils, geography and anatomy",
                      "Explain why inheritance was the missing piece in Darwin's theory",
                      "Explain why evolution was accepted quickly but natural selection was not"], 18)},
    notes="""
(1 min) One objective per section (01 to 06). The history is the vehicle; the general skills (defining evolution, building and testing an argument from evidence) are what you will be examined on.
Reading: Neal chapters 1 and 2. Next lecture: Understanding natural selection (Neal chapter 3).
""")

new("Title & Photo", {100: "Life is astonishingly diverse",
                      102: "What explains this diversity of form, colour, behaviour and distribution?"},
    pictures={101: I + "diversity.jpg"},
    notes="""
(1 min) Evolution explains the diversity of life in structure, appearance, behaviour and distribution.
Leafy seadragon (*Phycodurus eques*): camouflage. Peacock (*Pavo cristatus*): sexual selection (Part 5). Darwin's finches (*Geospiza*, Gould's drawings from the 1845 *Journal of Researches*): beaks suited to diet. Redback spider (*Latrodectus hasselti*): sexual cannibalism, the male offers himself to the female. Slug-moth caterpillar: warning colours. Tarsier: huge eyes for a nocturnal predator.
Photos carried over from the previous version. The original slide also had an aye-aye; it is in the old deck if wanted.
""")

# ================================================================ 01 What is evolution
new("Section", {102: "01", 103: "What is evolution?"},
    notes="(10 s) Before the history, let us be clear what we mean.")

new("Key Concept", {102: "Evolution",
                    103: "Change in the heritable characteristics of a population over successive generations.",
                    105: "Populations evolve; individuals do not. A giraffe that stretches its neck does not evolve, but a population of giraffes can, if long-necked parents leave more offspring and pass the trait on."},
    notes="""
(1.5 min) Three key words: heritable (passed from parent to offspring), population, generations.
The giraffe example contrasts Darwin with Lamarck (1809), who proposed that characteristics acquired during life (a stretched neck) are inherited. We now know acquired characteristics are not, in general, inherited.
This is the definition used in the rest of the course; in Part 3 we will make it precise as a change in allele frequencies.
""")

new("Two Columns", {100: "Darwin had two theories, not one",
                    101: "1. COMMON DESCENT (THE PATTERN)",
                    103: ["All organisms are related, descended from one or a few ancestors",
                          "Explains why species fall into groups within groups",
                          "Accepted by most scientists within about a decade of 1859"],
                    104: "2. NATURAL SELECTION (THE MECHANISM)",
                    106: ["Heritable variants that survive and reproduce better become more common",
                          "Explains adaptation: the fit between organism and environment",
                          "Widely accepted only in the 1930s–40s"]},
    notes="""
(1.5 min) Neal's organising idea for chapter 2: the *Origin* interleaves two theories, and it is easy to slip from one to the other without noticing. Keep them apart: you can accept common descent and doubt natural selection (many Victorians did).
Ernst Mayr (1982) splits Darwin's thinking into five theories: evolution itself, common descent, gradualism, population-level speciation, and natural selection. Two is enough for us.
The rest of the lecture follows this split: section 03 is the mechanism, section 04 is the evidence for the pattern.
""")

# ================================================================ 02 How Darwin got there
new("Section", {102: "02", 103: "How Darwin got there"},
    notes="(10 s) Why did a trainee clergyman come to doubt that species were created as they are? About 12 minutes.")

new("Title & Photo", {100: "Darwin's life and ideas",
                      102: "Key dates. Blue: the Beagle voyage. Gold: the 20 years between his key insight and publication."},
    pictures={101: F + "01_timeline.png"},
    notes="""
(1 min) A map for the rest of the lecture. Point out the three dates in red: 1837 (Gould's identification of the Galápagos birds), 1838 (Malthus) and 1859 (the *Origin*). Then the long gap: section 06 asks why.
Darwin read the 6th edition (1826) of Malthus's *Essay* on 28 September 1838 (Notebook D). Mendel published in 1866; his work was rediscovered in 1900, 18 years after Darwin's death.
Script 01_timeline.R (historical dates, not data).
""")

new("Figure & Bullets", {100: "Charles Darwin: not a promising student",
                         102: (["Born 1809 in Shrewsbury, into a wealthy family of doctors",
                                "Aged 16, sent to Edinburgh to study medicine with his brother Erasmus",
                                "Hated it: dull lectures, and he fled an operation done without anaesthetic",
                                "Gave up in his second year, for shooting and collecting",
                                "Plan B: Cambridge (1828–31), to become a clergyman"], 18)},
    pictures={101: I + "sharples.jpg"},
    notes="""
(1.5 min) Restored from the previous version, with detail from Neal ch. 1. Darwin's father Robert and grandfather Erasmus were both physicians trained at Edinburgh, so Charles was expected to follow. He went in 1825, aged 16, with his older brother Erasmus ("Ras").
He found most of the medical lectures incredibly dull (the anatomy professor, Alexander Monro III, was rumoured to use his own grandfather's lecture notes), and he hated dissection. The final straw was surgery before general anaesthetics: he watched two operations and fled during the second, never to return to an operating theatre.
Not wasted time, though: he learned taxidermy from John Edmonstone, a freed slave from Guyana, joined the student Plinian Society, and collected marine invertebrates with Robert Grant, a sponge expert and convinced evolutionist (a follower of Lamarck). He left in April 1827, in his second year.
Grandfathers: Erasmus Darwin (physician, poet and early evolutionist) and Josiah Wedgwood (potter).
Painting: Ellen Sharples (1816), Charles (aged 7) with his sister Catherine. Public domain.
""")

new("Quote", {101: ("You care for nothing but shooting, dogs, and rat-catching, and you will be a disgrace to yourself and all your family.", 36),
              103: "ROBERT DARWIN TO HIS SON, AS RECALLED IN CHARLES'S AUTOBIOGRAPHY"},
    notes="""
(1 min) Kept from the previous version, and given its own slide. Pause on it: the student his father wrote off became the most influential biologist in history. A good moment to reassure anyone who is unsure about their own start at university.
Timing: Darwin's *Autobiography* (written 1876, published 1887) places the remark at the end of his schooling at Shrewsbury, before Edinburgh; Neal (and the previous version) puts it after Edinburgh. Biographies differ, so it is safest to say "his father told him".
What next: his father decided he should become a Church of England vicar, a respectable career that left time for natural history. At Cambridge Darwin nearly failed again, collecting beetles when he should have been studying, then crammed and passed in January 1831, tenth of 178. Correction to the previous version: natural history was not part of the degree. Darwin attended Henslow's botany lectures voluntarily, and Henslow became his mentor; in 1831 Adam Sedgwick also taught him field geology in north Wales. Henslow then recommended him for the Beagle.
""")

new("Figure & Bullets", {100: "Geology: how fast does the earth change?",
                         102: (["Rock is laid down in layers (strata), each with its own fossils",
                                "**Catastrophism** (Cuvier): sudden upheavals, a young earth, fossils that change in sequence",
                                "**Uniformitarianism** (Hutton, Lyell): the same slow processes as today, a very old earth",
                                "From Lyell, Darwin took **deep time** and **small changes adding up**"], 18)},
    pictures={101: I + "strata.jpg"},
    notes="""
(2 min) Correction to the previous version, which said that uniformitarianism "allows transmutation" while catastrophism allows only fixity. Neither was a theory of evolution. Lyell himself rejected the transmutation of species and called the replacement of extinct species the "mystery of mysteries". Cuvier's catastrophism, by contrast, recognised a progression in the fossil record (younger fossils more like living species), and Darwin accepted that part (Neal Table 1.1, after Mayr 1982).
What mattered for Darwin: from Lyell's *Principles of Geology* (volume 1 went with him on the Beagle), (1) the earth is extremely old, and (2) small, imperceptible changes accumulate into large ones. Natural selection has exactly the same structure.
Spelling: "uniformitarianism", not "uniformatism" (fixed from the previous version).
Image: geological column, carried over from the previous version; source and licence to confirm.
""")

new("Title & Photo", {100: "Small changes add up: folded rock in Denmark",
                      102: "Lower Eocene moler (diatomite), folded by glacier push, Limfjord area. Photo: Karsten Eig."},
    pictures={101: I + "moler.jpg"},
    notes="""
(30 s) A local example of slow, accumulated change. These layers of diatoms were laid down on a sea floor about 55 million years ago, then folded by ice sheets in the last glaciations.
Ask: how long did it take to lay down this many layers? Lyell's argument: measure the rate today, then multiply.
Photo carried over from the previous version.
""")

new("Title, Bullets & Photo", {100: "The Beagle voyage (1831–36)",
                               103: "MOSTLY A GEOLOGIST",
                               105: ("A naval survey of the South American coast. Darwin, the captain's unpaid companion, spent 39 months ashore and 18 at sea.", 17)},
    pictures={101: I + "beagle_route.jpg"},
    notes="""
(1.5 min) Henslow recommended Darwin as a gentleman companion for Captain Robert FitzRoy. His father refused; his uncle, Josiah Wedgwood II, persuaded him. Darwin was 22, FitzRoy 26.
Darwin was a wretched sailor and seasick throughout, but the time ashore was mostly because the survey took years and he made long inland journeys (Neal: 39 months on land, 18 at sea).
He was mostly a geologist: his geological notes are far longer than his zoological ones (often quoted as about 1,380 against 370 pages).
In Chile (1835) he saw an earthquake raise the beach at Concepción by about 2.4 m, and found shells 100 m above the sea: small uplifts, repeated, build mountains. Lyell was right.
Map: Sémhur, CC BY-SA 3.0, via Wikimedia Commons. The previous version's painting of the Beagle (Ron Scobie) has been dropped; its licence was unclear.
""")

new("Figure & Bullets", {100: "Galápagos mockingbirds: a different species on each island",
                         102: (["Darwin noticed the mockingbirds differed between islands, and labelled them by island",
                                "Gould (1837): three species, each on its own island, related to a mainland species",
                                "Why create different species, living the same way, on islands within sight of each other?",
                                "More likely: one colonist from South America, diverging on each island"], 18)},
    pictures={101: I + "mockingbirds.jpg"},
    notes="""
(2 min) In July 1836, sorting his notes on the way home, Darwin wrote that if the island differences were real, "such facts would undermine the stability of Species".
The question in the third bullet is Neal's paraphrase of Darwin's reasoning (the previous version showed it in quotation marks as if it were Darwin's words).
John Gould, the ornithologist at the Zoological Society of London (not the Natural History Museum, which did not yet exist as such), examined the birds in early 1837 and told Darwin the mockingbirds were three distinct species. Darwin started his first "transmutation" notebook that spring. Today four species of Galápagos mockingbird are recognised.
Image: Brinkhuizen & Nilsson (2020) *Birds and Mammals of the Galápagos*, Lynx Edicions. Teaching use only.
""")

new("Figure & Bullets", {100: "The famous finches came later",
                         102: (["Darwin thought they were a mix of wrens, blackbirds, grosbeaks and finches",
                                "Gould: one group of 13 finch species (about 17–18 recognised today)",
                                "Darwin rarely recorded which island each came from",
                                "In his *Journal of Researches* (1845), but never mentioned in *On the Origin of Species*"], 18)},
    pictures={101: I + "finches.jpg"},
    notes="""
(1 min) Correction to the previous version, which said Darwin never mentioned the finches in his books on evolution. He did discuss them, briefly, in the 1845 second edition of his *Journal of Researches*: "one might really fancy that from an original paucity of birds in this archipelago, one species had been taken and modified for different ends". But they do not appear in the *Origin*: his key example was the mockingbirds.
Gould reconstructed the islands of origin using specimens collected by FitzRoy and Darwin's servant, Syms Covington. The name "Darwin's finches" became popular after David Lack's 1947 book; Sulloway (1982) showed how the finch story grew into a legend.
The finches are now a classic case of natural selection in action (the Grants on Daphne Major), which we will meet later in the course.
Image: Gould's drawings from the *Journal of Researches* (1845), public domain.
""")

new("Title, Bullets & Photo", {100: "A missed clue: giant tortoises",
                               103: "IGNORED ADVICE",
                               105: ("The governor told Darwin he could tell a tortoise's island from its shell. Darwin thought they had been brought in, and did not record where his came from.", 17)},
    pictures={101: I + "tortoises.jpg"},
    notes="""
(1 min) The acting governor, Nicholas Lawson, told Darwin he could tell which island a tortoise came from by its shell. Darwin ignored it: he thought the tortoises had been brought from the Indian Ocean by buccaneers.
The crew did eat the evidence, sort of: FitzRoy recorded taking 18 small and 30 large tortoises on Chatham Island (San Cristóbal) for fresh meat; all were eaten crossing the Pacific and the remains, shells included, thrown overboard (Neal mentions only the 18). But they all came from one island, so they could not have shown differences between islands anyway.
The real missed clue was Darwin's: he dismissed Lawson and did not record where tortoises came from. He, FitzRoy and Covington brought back juveniles from James, Charles and Hood islands as pets, too young and poorly labelled to settle anything (Darwin's survives at the Natural History Museum as *Chelonoidis darwini*).
The tortoises were not irrelevant: his July 1836 note doubting the stability of species opens with the Spaniards telling a tortoise's island from its shell. But the mockingbirds, labelled by island, carried the argument.
Images: Sulloway (2009) *Journal of the History of Biology*. Saddle-backed shells are found on dry islands, where tortoises reach up to browse cactus; domed shells on wetter, higher islands.
""")

new("Title, Bullets & Photo", {100: "Fossils resemble the living species in the same place",
                               103: "WHY?",
                               105: ("Recent fossils in South America look like the sloths and armadillos living there today. Unless they are related, why?", 17)},
    pictures={101: I + "fossils.jpg"},
    notes="""
(1.5 min) In Argentina Darwin dug up fossils of giant ground sloths (*Megatherium*, *Scelidotherium*) and the armour of glyptodonts. Recent fossils in shallow deposits looked like the living sloths and armadillos of the same continent. Why would extinct and living species be similar in the same place, unless the living ones descended from the extinct ones (or from shared ancestors)?
Glyptodonts are now known, from ancient DNA, to be a branch of the armadillo family tree (Delsuc et al. 2016, *Current Biology*).
**Correction from the previous version:** Toxodon is not a giant rodent and is not related to the capybara. It is a notoungulate, an extinct South American hoofed mammal. Darwin and Richard Owen could not place it (it mixes features of rodents, elephants and even whales); collagen protein sequences show its closest living relatives are horses, rhinos and tapirs (Welker et al. 2015, *Nature*; Buckley 2015, *Proc. R. Soc. B*). A good story for students: a puzzle Darwin could not solve, solved by molecules 180 years later.
Credits: Scelidotherium art, Mauricio Antón; sloth photo, D. Maraschiello, CC BY-SA 4.0 (both carried over). The capybara photo has been removed. Glyptodon (Heinrich Harder, c. 1920, public domain) and armadillo (birdphotos.com, CC BY 3.0) from Wikimedia Commons.
""")

new("Figure & Bullets", {100: "The ideas were not totally new",
                         102: (["Al-Jāḥiẓ (9th c.): animals struggle to survive, shaped by environment",
                                "Robert Hooke (17th c.): fossils are extinct species",
                                "Erasmus Darwin (1794): animals from one “living filament”",
                                "Lamarck (1809): change by inheriting acquired characteristics"], 18)},
    pictures={101: I + "predecessors.jpg"},
    notes="""
(1.5 min) Darwin's contribution was not the idea that species change but (1) a mass of evidence that they had, and (2) a workable mechanism, natural selection.
Al-Jāḥiẓ, *Kitāb al-Ḥayawān* (Book of Animals), Basra, 9th century: often credited with early ideas about the struggle for existence and environmental influence. Historians debate how close these were to evolution. The previous version's quotation ("God invested matter with energy for development") could not be traced to a source and has been removed.
Erasmus Darwin, *Zoonomia* (1794). Lamarck, *Philosophie zoologique* (1809): the best-known evolutionary theory before Darwin (Neal ch. 1). Denis Diderot (18th century) also speculated about species arising by trial and survival.
Images: a giraffe from *Kitāb al-Ḥayawān* by al-Jāḥiẓ (public domain, carried over from the previous version); Jean-Baptiste Lamarck, portrait by Charles Thévenin (public domain, Wikimedia Commons).
""")

# ================================================================ 03 Natural selection
new("Section", {102: "03", 103: "The theory of natural selection"},
    notes="(10 s) Darwin was convinced species change. But how? About 9 minutes.")

new("Title, Bullets & Photo", {100: "Start with what breeders know",
                               103: "ARTIFICIAL SELECTION",
                               105: ("All these breeds descend from the rock dove, *Columba livia* (top left). Breeders select heritable variation. Could nature do the same?", 17)},
    pictures={101: I + "pigeons.jpg"},
    notes="""
(1.5 min) Chapter 1 of the *Origin*, "Variation under domestication". Darwin bred pigeons himself and joined London pigeon clubs. The breeds differ so much (carrier, pouter, fantail, tumblers, trumpeter, barb...) that a naturalist finding them wild would call them different species, even genera. Yet they interbreed freely and all descend from the rock dove.
The same for dogs (chihuahua to Great Dane) and for cabbage, kale, broccoli, cauliflower, Brussels sprouts and kohlrabi, all *Brassica oleracea*.
Two lessons: (1) variation exists and much of it is heritable; (2) selection can change a species a lot, in a short time.
Images: pigeon breeds and rock dove carried over from the previous version (Wikimedia Commons).
""")

new("Title, Bullets & Photo", {100: "Malthus: populations outrun their food",
                               103: "THE KEY IDEA",
                               105: (["Populations grow geometrically; food, at best, by a fixed amount",
                                      "So most offspring cannot survive",
                                      "Darwin read this in 1838 and applied it to all species"], 18)},
    pictures={101: F + "02_malthus.png"},
    notes="""
(1.5 min) Thomas Malthus, *An Essay on the Principle of Population* (first edition 1798; Darwin read the 6th edition, 1826, in September 1838). Correction from the previous version, which dated the essay 1826.
The figure uses Malthus's own example: population doubling every 25 years (1, 2, 4, 8 ... 256) against subsistence increasing by one unit per 25 years (1, 2, 3 ... 9). The gap must be closed by famine, disease and war (Malthus's "checks").
Darwin's leap: this applies "with manifold force" to all animals and plants, which cannot increase their food supply. Most offspring die before breeding. The question is which ones.
You will meet geometric growth properly in lecture 3 (Neal ch. 4) and the practical on geometric growth.
Figure: analytical illustration, script 02_malthus.R.
""")

new("Title & Photo", {100: "Natural selection is a logical argument",
                      102: "Darwin's argument as five facts and three inferences (Neal 2004, after Mayr 1982)."},
    pictures={101: F + "03_facts_inferences.png"},
    notes="""
(2.5 min) Build it up in words. Facts 3, 4 and 5 (from Malthus, and from observation): every species can produce far more offspring than replace the parents; resources are limited; yet populations stay roughly constant. Inference: most offspring die, so there is a struggle for existence.
Fact 1: individuals differ. Inference: survival and reproduction are not random; individuals with some variants do better. That is natural selection.
Fact 2: much of the variation is heritable. Inference: the favoured variants become more common in the next generation, and over many generations the population changes. That is evolution by natural selection.
Remove heritability and selection still happens within a generation, but nothing changes in the next. The previous version never mentioned heritability; it is essential.
Schematic, script 03_facts_inferences.R.
""")

new("Figure & Bullets", {100: "The struggle for existence",
                         102: (["Predation and competition produce winners and losers",
                                "Who wins is **not random**: it depends on their traits",
                                "If those traits are heritable, the population changes",
                                "“Struggle” is a metaphor: a desert plant struggles for water"], 18)},
    pictures={101: I + "struggle.jpg"},
    notes="""
(1 min) Top: predation. Lions select buffalo by size and condition; larger prey are safer. Bottom: competition for water among desert plants, Baja California.
Darwin was explicit that he used "struggle" in a "large and metaphorical sense", including dependence of one being on another and success in leaving offspring, not just fighting.
Photos: Diamond Glacier Adventures, CC BY-SA 2.0 (lioness and Cape buffalo); Tomas Castelazo, CC BY-SA 2.5 (Baja California desert). Wikimedia Commons, carried over.
""")

new("Check Question (4 options)", {101: ("Which is NOT needed for natural selection to cause evolution?", 30),
                                   105: "Individuals differ in a trait",
                                   109: "The differences are heritable",
                                   113: "The trait affects survival or reproduction",
                                   117: "Individuals try to adapt to their environment"},
    notes="""
(1.5 min) Answer: D. Selection needs variation (A), heritability (B) and differential survival or reproduction linked to the trait (C). Nothing needs to "try"; variation arises without regard to need (Neal: Darwin was clear that new variants are random with respect to need).
D is the Lamarckian intuition from the giraffe example. Watch for it in exam answers: "the birds needed bigger beaks, so they evolved them" loses marks.
""")

new("Figure & Bullets", {100: "From varieties to species: the tree of life",
                         102: (["Selection adapts populations to local conditions",
                                "Local varieties diverge: “incipient species”",
                                "Enough divergence: new species, then genera, families…",
                                "Many lines go extinct; some persist unchanged (F)",
                                "Extend it: all life related by descent. Whoa!"], 18)},
    pictures={101: I + "origin_diagram.jpg"},
    notes="""
(1.5 min) The only figure in the *Origin* (1859). Eleven species of a genus (A to L) at the bottom; each horizontal line (I to XIV) is, say, 1,000 generations. Species A gives rise to varieties that diverge, become species, and could eventually be grouped into separate genera. Species F persists unchanged: time alone does not cause change. Most of the others leave no descendants.
Darwin pointed out that the tree matches Linnaean classification: twigs are species, branches genera, and so on. That is the link to the evidence in section 04.
Darwin hedged on the root: life was "originally breathed into a few forms or into one". Today, shared biochemistry (the genetic code) points to one.
Image: Darwin (1859), public domain.
""")

new("Title & Photo", {100: "One species becomes two: allopatric speciation",
                      102: "Schematic. Separation (here, a falling lake level) lets populations diverge by selection and drift."},
    pictures={101: F + "05_speciation_pump.png"},
    notes="""
(1.5 min) Allopatric speciation ("other homeland"): a population is split by a barrier (mountains, sea, a drop in lake level), the parts evolve independently by different selection pressures and by random genetic drift (Part 3), and if they later meet they no longer interbreed.
Repeated cycles of separation and reconnection (glacial cycles, lake-level changes) can work as a "species pump": the lake ends up with several species.
This is a modern term. The previous version titled the slide "This is now called allopatric speciation", implying it was Darwin's mechanism; Darwin in fact emphasised divergence within an area (his "principle of divergence") and gave isolation a smaller role, which Moritz Wagner and later Ernst Mayr developed.
Examples (from the previous version's notes): glacial cycles as an allopatric speciation pump in north-eastern American freshwater fishes; the "Pleistocene species pump" in European butterflies and in alpine *Nebria* ground beetles; island connectivity cycles in Caribbean crickets (which drove divergence but not speciation).
Schematic, redrawn from the previous version's lake diagram: script 05_speciation_pump.R.
""")

# ================================================================ 04 Evidence for common descent
new("Section", {102: "04", 103: "Evidence for common descent"},
    notes="(10 s) If all species are related, what should we see? Darwin's chapters 9 to 13. About 6 minutes.")

new("Title & Photo", {100: "Species fall into groups within groups",
                      102: "Whales, cats, hoofed mammals and rodents: groups within groups, as a branching tree predicts."},
    pictures={101: I + "nested.jpg"},
    notes="""
(1 min) Ask: how would you sort these 12 animals? Almost everyone gives the same groups: whales (humpback, orca, sperm whale), cats (lion, tiger, cheetah), hoofed mammals (bongo, zebra, elk), rodents (hamster, jerboa, dormouse). Groups within groups: the Linnaean hierarchy (species, genus, family, order, class).
Special creation does not predict a nested pattern; descent with branching does. Note that the groups are not based on way of life: a killer whale and a lion are both top predators, but each resembles its relatives more.
Photos carried over from the previous version; sources to confirm.
""")

new("Figure & Bullets", {100: "Geography, not climate, predicts who is related",
                         102: (["Similar climates on different continents have unrelated species (American cacti, African euphorbias)",
                                "Barriers separate faunas: marine species either side of the Isthmus of Panama differ",
                                "Closest relatives usually live nearby"], 18)},
    pictures={101: I + "panama.jpg"},
    notes="""
(1.5 min) *Origin* chapters 11–12. If species were created to suit their conditions, similar conditions should have similar species. Instead, relatedness follows geography.
The Isthmus of Panama: only a few kilometres separate Atlantic and Pacific coastal faunas, in nearly identical conditions, yet the species differ: each is related to its own ocean. We now know the isthmus closed about 3 million years ago and split many marine populations (e.g. snapping shrimps), a natural experiment in allopatric speciation.
Cacti and euphorbias look alike (convergence) but belong to unrelated families.
Map image carried over from the previous version; source to confirm.
""")

new("Figure & Bullets", {100: "Islands: colonists and their descendants",
                         102: (["Island species resemble the nearest mainland, not islands with a similar climate",
                                "Oceanic islands lack frogs and land mammals, but have bats and birds",
                                "Australia's marsupials radiated into roles filled by placental mammals elsewhere"], 18)},
    pictures={101: I + "islands.jpg"},
    notes="""
(1.5 min) Galápagos species resemble South American ones; Cape Verde species resemble African ones, though the two archipelagos have similar volcanic landscapes and climates. Common ancestry plus colonisation is the best explanation.
Darwin noted that frogs (whose eggs are killed by sea water) and land mammals are absent from oceanic islands far from a continent, unless introduced by people, but bats, which can fly there, are present. Who is on an island depends on who could get there.
Australia is a continent, not an oceanic island; it illustrates the same logic at a larger scale (the previous version listed kangaroos as "island endemics").
Photos: eastern grey kangaroo, Lilly M, CC BY-SA 3.0; Galápagos marine iguana (*Amblyrhynchus cristatus*), RAF-YYC, CC BY-SA 2.0. Wikimedia Commons.
""")

new("Figure & Bullets", {100: "Same bones, different jobs",
                         102: (["Vertebrate forelimbs share one plan, used to grasp, run, swim and fly",
                                "Early embryos of related animals look alike: human embryos have pharyngeal arches and a tail",
                                "Vestigial organs: hip and leg bones in whales and some snakes",
                                "Today also in protein and DNA sequences"], 18)},
    pictures={101: I + "forelimbs.jpg"},
    notes="""
(1.5 min) *Origin* chapter 13. Humerus, radius and ulna, carpals and digits in human, cat, porpoise, bat and horse. A designer would not need the same bones for such different jobs; descent with modification explains it.
Title changed from "Embryology & development", because the figure shows comparative anatomy. Caution on embryos: early vertebrate embryos are similar but not identical; Haeckel's famous drawings exaggerated the similarity. Pharyngeal arches, which become gills in fish, become parts of the jaw, ear and throat in humans ("gill slits" is the old, misleading term).
Figure: forelimb homology, from Neal (2018) via Cambridge Core; teaching use only.
""")

new("Two Columns", {100: "Similar is not always related",
                    101: "HOMOLOGY",
                    103: ["Similarity inherited from a common ancestor",
                          "Bat wing and human arm: the same bones",
                          "Used to build evolutionary trees (phylogenies)"],
                    104: "HOMOPLASY (CONVERGENCE)",
                    106: ["Similarity that evolved independently",
                          "Bat wing and bird wing, *as wings*",
                          "Cacti and euphorbias: same shape, unrelated"]},
    notes="""
(1 min) The previous version used "homoplasious" without defining it. Homoplasy is similarity not due to common descent, usually because similar selection pressures produced similar solutions (convergent evolution).
The same structure can be both: bat and bird wings are homologous as forelimbs (shared bones from a four-legged ancestor) but convergent as wings (flight evolved separately).
Phylogenies must be built from homologous traits; convergence misleads.
""")

new("Check Question (4 options)", {101: ("Which observation is best explained by common descent, not by adaptation to local conditions?", 28),
                                   105: "Desert animals conserve water",
                                   109: "Cacti and euphorbias look alike",
                                   113: "Different marine species either side of Panama",
                                   117: "Arctic animals are often white"},
    notes="""
(1.5 min) Answer: C. The conditions on the two sides of the isthmus are nearly identical, so adaptation cannot explain the difference; separate ancestry can.
A and D are adaptations to local conditions. B is convergence: similarity despite unrelated ancestry.
""")

# ================================================================ 05 Difficulties
new("Section", {102: "05", 103: "Difficulties Darwin faced"},
    notes="""(10 s) Darwin devoted a whole chapter (6) to difficulties with his own theory. Another he noted: where are the intermediate fossils? His answer, that the fossil record is very incomplete, was right; many transitional forms (e.g. *Archaeopteryx*, 1861; early whales with legs) have since been found. About 5 minutes.""")

new("Title, Bullets & Photo", {100: "Darwin had no theory of inheritance",
                               103: "THE PROBLEM",
                               105: ("If offspring are a blend of their parents, variation halves every generation and selection soon runs out of material. Mendel's particles keep it.", 17)},
    pictures={101: F + "04_blending.png"},
    notes="""
(2 min) Darwin admitted "profound ignorance" about inheritance (*Origin* ch. 5). Like most of his contemporaries he assumed that offspring blend their parents' characteristics, and his own hypothesis of pangenesis (1868) implied blending. Fleeming Jenkin (1867) pointed out the consequence: a new favourable variant is diluted by half in each generation, so selection could hardly spread it.
The figure: with blending and random mating, the variance among offspring is half the parents' variance (the average of two independent values has half the variance), so after 8 generations less than 1% remains. With particulate inheritance, alleles are passed on intact, and the variance stays the same (the Hardy–Weinberg principle, Part 3).
Mendel's work on peas (1866) showed that inheritance is particulate. It was ignored until 1900, and the synthesis with Darwin's theory took until the 1930s–40s.
Neal also notes that Darwin was clear that new variants arise at random with respect to need.
Simulation: N = 2000, 20 additive loci for the particulate case; seed 512; script 04_blending.R.
""")

new("Figure & Bullets", {100: "Organs of extreme perfection",
                         102: (["William Paley (1802): a watch found on a heath implies a watchmaker; so does an eye",
                                "Darwin: every intermediate step must itself be useful",
                                "Living molluscs show the series: light-sensitive patch, cup, pinhole, lens eye",
                                "Today's practical: the Blind Watchmaker"], 18)},
    pictures={101: I + "watch.jpg"},
    notes="""
(1.5 min) Darwin admitted that the evolution of the eye by natural selection "seems, I freely confess, absurd in the highest possible degree", then argued that a series of small steps, each an improvement, could get there, because a graded series of simpler eyes exists in living animals. Living molluscs show such a series today: a light-sensitive patch (limpets), a cup, a pinhole eye (*Nautilus*) and a lens eye (octopus).
Paley's *Natural Theology* (1802) was set reading at Cambridge; Darwin found its logic irrefutable at the time. The argument from design is the topic of the next lecture (Neal ch. 3).
Link to today's practical: Dawkins (1986) *The Blind Watchmaker*. Random variation alone gets nowhere; random variation plus cumulative selection gets there fast.
Photo carried over from the previous version (stock image); check the licence covers the course.
""")

new("Figure & Bullets", {100: "Complex behaviour, and sterile workers",
                         102: (["Darwin himself raised cuckoos and slave-making ants as difficulties",
                                "Behaviour varies and is heritable: compare dog breeds",
                                "So instincts can evolve like any other trait",
                                "Hardest case: sterile worker insects, which leave no offspring"], 18)},
    pictures={101: I + "dogs.jpg"},
    notes="""
(1 min) *Origin* chapter 7, "Instinct". The previous version said "critics argued"; in fact Darwin chose these examples himself, to test his theory.
Pomeranian and Doberman: breeds selected for different temperaments as well as sizes.
Sterile castes: how can selection favour individuals that do not reproduce? Darwin suggested that selection acts on the family as well as the individual. He was on the right track; the full answer is kin selection (Hamilton 1964), in Part 5 of the course.
Photos carried over from the previous version; sources to confirm.
""")

# ================================================================ 06 Publication
new("Section", {102: "06", 103: "Publication and reception"},
    notes="(10 s) Back to the timeline: why the 20-year gap? About 4 minutes.")

new("Title & Bullets", {100: "Why wait 20 years?",
                        101: (["1842 sketch and 1844 essay: unpublished, with instructions to his wife to publish if he died",
                               "“It is like confessing a murder”: letter to Joseph Hooker, 1844",
                               "Eight years classifying barnacles (1846–54)",
                               "1856: began a huge book, with no hurry"], 20)},
    notes="""
(1.5 min) Darwin was cautious, conventional and concerned about his reputation; he knew transmutation was not respectable, and he wanted an overwhelming body of evidence first. His wife Emma was religious, and he was aware of how the theory would be received.
The barnacle work (*Cirripedia*) gave him first-hand expertise in variation and classification, and credibility as a taxonomist.
The quotation is from Darwin's letter to Hooker of 11 January 1844: "I am almost convinced ... that species are not (it is like confessing a murder) immutable."
""")

new("Figure & Bullets", {100: "The final push: Wallace",
                         102: (["Alfred Russel Wallace (1823–1913), collecting in the Malay Archipelago",
                                "June 1858: sent Darwin an essay describing natural selection",
                                "Lyell and Hooker arranged a joint reading at the Linnean Society, 1 July 1858",
                                "*On the Origin of Species* followed in November 1859"], 18)},
    pictures={101: I + "wallace.jpg"},
    notes="""
(1.5 min) Wallace, a professional collector, reached the same idea independently, also after reading Malthus, while ill with fever on Ternate (or Gilolo) in early 1858. His essay was "On the tendency of varieties to depart indefinitely from the original type".
Neither Darwin nor Wallace attended the Linnean Society meeting. Darwin's papers (an extract of the 1844 essay and an 1857 letter to Asa Gray) proved his priority. The joint paper was published in August 1858 and attracted little attention. Wallace generously acknowledged Darwin's precedence throughout his life, and titled his own book *Darwinism* (1889).
The *Origin* was an "abstract" of the big book; the first print run (1,250 copies) sold out to the trade on the day of publication, 24 November 1859.
Painting: Victor Evstafieff (1958), *Wallace in the Malay Archipelago*, Down House (English Heritage). Corrected from the previous version, which credited H.C. Richter. Teaching use only.
""")

new("Figure & Bullets", {100: "How the world reacted",
                         102: (["Common descent: accepted by most scientists within about a decade",
                                "Natural selection: doubted, even by supporters such as Thomas Huxley",
                                "Accepted only with the “Modern Synthesis” of Darwin and Mendel, 1930s–40s",
                                "That synthesis is the population genetics of this course"], 18)},
    pictures={101: I + "linnean.jpg"},
    notes="""
(1 min) Neal's point at the end of chapter 2: people were quickly convinced that evolution had occurred, but there was little acceptance of natural selection for almost a century. Reasons: no theory of inheritance (section 05), the apparent youth of the earth (Kelvin's estimates from cooling), and discomfort with an undirected process. The next lecture asks why natural selection is still contentious for some people.
The Modern Synthesis (Fisher, Haldane, Wright, then Dobzhansky, Mayr, Simpson and others) combined Mendelian genetics, population genetics and natural selection.
Image: first page of the joint Darwin–Wallace paper, *Journal of the Proceedings of the Linnean Society: Zoology* (1858), public domain.
""")

# ================================================================ Summary and practical
new("Summary (Key Points Only)", {101: "Key points",
                102: (["Evolution: heritable change in populations over generations",
                       "Two theories: common descent (the pattern) and natural selection (the mechanism)",
                       "Selection follows from variation, heritability and overproduction",
                       "Fossils, geography and anatomy support common descent",
                       "The missing piece was particulate (Mendelian) inheritance"], 20)},
    notes="""(1 min) One point per objective. Ask students which of the five they could explain to a friend without notes.
Before next time (no longer on the slide): read Neal chapters 1 and 2; do the Blind Watchmaker practical; next lecture is Understanding natural selection (Neal ch. 3).""")

new("Activity", {101: "PRACTICAL · R",
                 102: ("Can random typing plus selection write a sentence?", 32),
                 103: ["Run the code with `selection <- TRUE`, then with `selection <- FALSE`",
                       "How many generations does your phrase need? Try a longer phrase",
                       "In what ways is this unlike real natural selection?"]},
    notes="""
(30 s) Previews the practical "The Blind Watchmaker": """ + PRACTICAL + """
With 32 possible characters, typing the 14-character "I LOVE SCIENCE" at random has probability (1/32)^14 ≈ 8.5 × 10^-22 per attempt. With cumulative selection (correct letters kept), it takes about 100 generations (median 96; 90% of runs between about 50 and 175; checked by simulation).
Watch out: the practical's default phrase has 53 characters and nGenerations <- 100. With set.seed(123) the run ends with 49 of 53 letters correct, and only about 10% of runs would finish within 100 generations (median about 140). That is a useful discussion point for "Does the number of generations affect whether the target is reached?", but warn students so they do not think the code is broken.
Key discussion point for the last question: the program has a target phrase; natural selection has no target, only the current environment.
""")

prs.save(OUT)
print("saved", OUT, len(prs.slides), "slides")
