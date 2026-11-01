"""Build 'BB512 - 17 - Behaviour, altruism and limiting aggression' from BB512_Theme.pptx.
Run from the lecture folder:  python3 build_deck.py <path/to/BB512_Theme.pptx> <out.pptx>
Inline markup in text: *italic*, **bold**, ~subscript~, ^superscript^.
Helpers copied from ../haploid_zygotic_selection/build_deck.py.
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

TOKEN = re.compile(r"(\*\*.+?\*\*|\*(?!\s).+?(?<!\s)\*|~.+?~|\^.+?\^)")  # '*' followed by a space (e.g. p* = ...) is literal

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

def new(layout, fields=None, notes=None, pictures=None, number=True):
    slide = prs.slides.add_slide(LAYOUT[layout])
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
        par.space_after = Pt(9)
        for r in par.runs:
            r.font.name = FONT
            if italic: r.font.italic = True
    return tb

F = "figures/"; I = "images/"

# ---------------------------------------------------------------- 1 Title
new("Title", {103: ("Behaviour, altruism and limiting aggression", 42),
              104: "Why do animals help others and hold back in fights?"},
    pictures={100: I + "title_meerkats.jpg"},
    notes="""
(1 min) Meerkats (*Suricata suricatta*) take turns as sentinels while the group forages. It looks like self-sacrifice. Hold the question: by the end we will have three answers (relatives, the payoffs of fighting, and checking whether the cost is real).
Caution worth mentioning later: Clutton-Brock et al. (1999, Science 284: 1640–1644) found meerkat sentinels are usually well fed and among the first to reach safety, so sentinel duty may be largely selfish. Always ask whether an 'altruistic' act really costs the actor.
Image: carried over from the previous version (Wikimedia Commons file 1024px-Meerkat_(Suricata_suricatta)…); author and licence to confirm. Cropped.
""")

# ---------------------------------------------------------------- 2 Objectives
new("Agenda", {101: "Behaviour, altruism and aggression",
               103: (["Explain, with evidence, how behaviour evolves when its variation is partly heritable",
                      "Explain why altruism is an evolutionary puzzle, and why group selection rarely solves it",
                      "Use relatedness, Hamilton's rule and inclusive fitness to predict when helping evolves",
                      "Use a payoff matrix to find the evolutionarily stable strategy, and explain why fights are usually limited"], 20)},
    notes="""
(1 min) One objective per section. They are written as general skills; rovers and sitters, pied kingfishers, mole-rats and the Hawk–Dove game are the evidence we use to practise them.
Reading: Neal (2004) Chapter 19, 'Animal behaviour, natural selection and altruistic traits'. The course schedule lists this as 'Neal 21'; check which edition students have and give the matching chapter.
The practical after this lecture is the Hawk–Dove card game (last slide).
""")

# ---------------------------------------------------------------- Section 01
new("Section", {102: "01", 103: "Behaviour evolves"},
    notes="(10 s) For selection to shape behaviour, behaviour must vary, the variation must affect fitness, and it must be at least partly heritable (Darwin; Neal chapter introduction).")

new("Figure & Bullets", {100: "Rovers and sitters: a one-gene behaviour",
                         102: ["*Drosophila melanogaster* larvae: rovers move far while feeding; sitters stay put",
                               "Cross pure lines: F1 all rovers; F2 3 rovers : 1 sitter",
                               "A single Mendelian gene, *foraging*; the rover allele is dominant"]},
    pictures={101: F + "01_rover_sitter.png"},
    notes="""
(3 min) de Belle & Sokolowski (1987), Neal section 19.1. Ask the class to predict the F1 and F2 before revealing: they know Mendelian crosses.
The gene is *foraging* (*for*), which encodes a cGMP-dependent protein kinase (Osborne et al. 1997, Science). R and S here stand for the alleles *for*^R^ and *for*^s^.
Link forward: in wild populations about 70% of larvae are rovers. Both types persist because each does better when it is rare (negative frequency-dependent selection; Fitzpatrick et al. 2007, Nature 447: 210–212). We will meet the same logic in the Hawk–Dove game.
The photo on the previous version was removed: its source was unknown, and the file name (OPM_SWD13) suggests a spotted-wing drosophila (*D. suzukii*) larva, not *D. melanogaster*.
Optional extra (Neal Fig. 19.1): hygienic behaviour in honeybees, where uncapping and removal of dead brood behaved like two recessive genes (Rothenbuhler 1964); later QTL studies found more loci.
Schematic, script 01_rover_sitter.R.
""")

new("Title, Bullets & Photo", {100: "Selection on a continuous behaviour",
                               103: "TAKEAWAY",
                               105: ("Four generations of selection split zebrafish into lines whose escape thresholds differed more than 1,000-fold: the variation was heritable.", 20)},
    pictures={101: F + "02_zebrafish_selection.png"},
    notes="""
(3 min) Gandolfi (1972), Neal Fig. 19.2. Zebrafish, *Danio rerio* (Neal uses the older name *Brachydanio rerio*).
Context first: damaged fish skin releases an alarm substance; nearby fish flee. ED~50~ is the concentration that makes half the fish flee, so a **lower** value means a **more sensitive** fish.
Gandolfi bred from the most and least sensitive fish each generation. The lines diverged in both directions, so there was heritable (additive genetic) variation. A gradual response in a continuous trait is what we expect from many genes of small effect (quantitative genetics lecture), although a selection response alone does not count the genes.
Correction from the previous version: the title 'Most behaviour is polygenic' was stronger than this experiment shows; the response shows heritability.
Line means digitised from Neal's figure (about ±0.05 log units); error bars omitted. Empirical, script 02_zebrafish_selection.R. The zebrafish photo was dropped (source not recorded).
""")

new("Two Columns", {100: "Genes and environment act together",
                    101: "GENES", 103: ["Heritable variation lets behaviour evolve by selection and drift",
                                        "One major gene (rovers) or a continuous heritable trait (alarm response)"],
                    104: "ENVIRONMENT", 106: ["Rovers and sitters differ only on food; on a bare surface they move alike",
                                              "Hygienic honeybees remove dead brood only when disease is present"]},
    notes="""
(2 min) Neal section 19.1, end. 'Genetic determinism' is the idea that behaviour is fixed by genes alone. It has been used to justify racism and inequality (Neal discusses race and IQ, and apartheid education policy), so it matters that we are precise: showing a genetic basis to **variation** in behaviour does not mean the behaviour is fixed or unchangeable.
Our reason for establishing a genetic basis is narrower: it shows behaviour can evolve by natural selection.
Environment examples: rover and sitter larvae differ in behaviour on food but not on non-nutritive substrates (Sokolowski & Hansell 1992, Genetica 85: 205–209). Hygienic behaviour in honeybees (uncapping cells and removing pupae killed by American foulbrood; Rothenbuhler 1964, Neal Fig. 19.1) is expressed only when brood is infected.
Correction from v2: v2 said rovers and sitters 'both move less in cold or stiff food'. That was Neal's hypothetical ('would probably move less'), not a finding; replaced with the measured result above. v2 also said the alarm response involves 'many' genes; a selection response shows heritability, not gene number (see previous slide).
Replaces the 'Genetic determinism?' slide; the stock nature/nurture signpost image was dropped.
""")

# ---------------------------------------------------------------- Section 02
new("Section", {102: "02", 103: "The puzzle of altruism"},
    notes="(10 s) Selection favours alleles that increase their own transmission. So how can it favour helping others?")

new("Key Concept", {102: "Altruism",
                    103: "A behaviour that benefits another individual at a cost to the survival or reproduction of the individual performing it.",
                    105: "Darwin's 'special difficulty': sterile worker ants and bees leave no offspring at all. How can selection favour that?"},
    notes="""
(2 min) Neal section 19.2. Darwin discussed sterile insect castes in *On the Origin of Species* and suspected the answer involved the family, not the individual. It took about 100 years to solve.
The previous version said selection is 'selfish' and asked why behaviour is often not selfish. More precisely: selection favours **alleles** that increase their own transmission. That does not require every individual to act selfishly, and that gap is where kin selection comes in.
Examples of apparent altruism: alarm calls, sentinels, helpers at the nest, sterile castes. Neal stresses an **apparent** cost: what looks costly may not be once all routes to fitness are counted.
""")

new("Title & Photo", {100: "Can group selection explain altruism?",
                      102: "Altruists help their group; selfish individuals take the benefit without paying the cost."},
    pictures={101: F + "03_group_selection.png"},
    notes="""
(3 min) Redrawn from the four build slides of the previous version. Walk through left to right.
1–2: the altruism allele costs its carrier, so selection within the group removes it.
3: in a tiny, isolated group, genetic drift (founder effect) can fix it by chance.
4: a group of altruists grows faster and founds new groups.
5: but selfish migrants arrive, take the benefits without paying, and out-reproduce the altruists.
Altruists are drawn as clay circles and selfish individuals as sage triangles (shape as well as colour, for colour-blind students).
Schematic, script 03_group_selection.R (seed 17).
""")

new("Title & Bullets", {100: "Why naive group selection fails",
                        101: (["Within every group, selfish individuals out-reproduce altruists, every generation",
                               "Drift fixes a costly allele only in tiny, isolated groups",
                               "Migration keeps bringing selfish alleles back",
                               "Groups found and go extinct far more slowly than individuals breed",
                               "Modern multilevel models do explain cooperation, but only when groups differ genetically: that is, when members are relatives"], 20)},
    notes="""
(2 min) Correction from the previous version: 'Group selection, therefore, cannot explain altruism' is too strong. What fails is the naive 'for the good of the species' argument (Wynne-Edwards 1962; criticised by Maynard Smith 1964 and Williams 1966). Modern multilevel selection models can explain cooperation, and they usually turn out to be equivalent to kin selection, because between-group differences arise when group members are related.
Also corrected: 'Genetic drift will only fix alleles in small populations'. Drift can fix alleles in a population of any finite size, but the chance that it fixes an allele that selection acts against becomes negligible unless the population is small (drift lecture).
The last bullet is the bridge to kin selection.
""")

# ---------------------------------------------------------------- Section 03
new("Section", {102: "03", 103: "Kin selection"},
    notes="(10 s) Relatives carry copies of the same alleles. Helping them can spread an allele just as having offspring does.")

new("Quote", {101: "“I would lay down my life for two brothers or eight cousins.”",
              103: "J.B.S. HALDANE (ATTRIBUTED)"},
    notes="""
(1 min) The story, in various versions, has Haldane doing sums on the back of an envelope in a pub. It is probably apocryphal, but Haldane did make the argument in print (usually cited as Haldane 1955, New Biology 18: 34–51; Neal gives 1953).
Neal's version: with a 1-in-10 chance of drowning while saving his child, he would save five copies of the 'rescue' genes for each copy lost (0.5 / 0.1).
Ask: why two and eight? Answer on the next two slides.
""")

new("Figure & Bullets", {100: "Relatedness: genes shared by descent",
                         102: (["r = probability that an allele in you is also in a relative, inherited from a recent common ancestor",
                                "Each parent–offspring link halves it: r = Σ (½)^n^, where n = links on each route",
                                "Sister: two routes, via mother and via father: 2 × (½)² = 0.5",
                                "Cousin: two routes of four links: 2 × (½)^4^ = 0.125"], 20)},
    pictures={101: F + "04_relatedness_pedigree.png"},
    notes="""
(3 min) Neal Table 19.1 and section 19.2.1. n is the number of parent–offspring links along each route from you to the relative through a common ancestor; add up the routes. Cousin: two routes of four links, 2 × 1/16 = 0.125.
Correction from the previous version: the table gave grandparent–grandchild r = 0.2; it is 0.25 (0.5 × 0.5).
'Shares 50% of your genes' is a simplification: you share almost all of your genome with any human. r concerns alleles that are identical by descent, over and above what unrelated members of the population share.
Link to the inbreeding lecture: identity by descent again. The inbreeding coefficient F of an offspring equals the coancestry (kinship) of its two parents, which is r/2 when the parents are not themselves inbred. So the offspring of full siblings (r = 0.5) have F = 0.25. Inbreeding raises r between relatives (naked mole-rats, later). (Correction from v2, which repeated Neal's looser wording.)
Assumes an outbred family; schematic, script 04_relatedness_pedigree.R.
""")

new("Check Question (4 options)", {101: ("What is your relatedness to your half-sister's daughter?", 30),
                                   105: "0.5", 109: "0.25", 113: "0.125", 117: "0.0625"},
    notes="""
(1 min) Answer C, 0.125. Half-sister: one shared parent, so one route of two links, r = (½)² = 0.25. Her daughter adds one more link: one route of three links, (½)³ = 0.125.
Common wrong answer: 0.25 (treating a half-sister as a full sister, then halving).
""")

new("Key Concept", {102: "Hamilton's rule:  rb > c",
                    103: "Helping spreads when rb > c.  r = your relatedness to the individual you help;  b = the offspring (or lives) it gains;  c = the offspring (or lives) you lose.",
                    105: "Haldane: saving 2 brothers costs your life: 0.5 × 2 = 1 = c, the break-even point. So does saving 8 cousins: 0.125 × 8 = 1."},
    notes="""
(2 min) Hamilton (1964) J. Theor. Biol. 7: 1–52. Neal develops the same idea through inclusive fitness (next slide) without naming the rule.
Lower-case b and c are used deliberately: later today B and C mean something different in the Hawk–Dove game.
The common error to pre-empt: r is your relatedness to the individual you **help** (your sister, 0.5), not to her offspring (0.25). Example: give up 1 own offspring so your sister raises 3 extra: rb = 0.5 × 3 = 1.5 > c = 1, so help.
Neal's inclusive-fitness bookkeeping (next slide) multiplies every offspring by your relatedness to that offspring: 3 × 0.25 = 0.75 versus 1 × 0.5 = 0.5. Both sides are simply halved, so the answer is the same; the next slide says so explicitly. (Correction from v2: v2 used the two conventions on consecutive slides without reconciling them on the slides.)
""")

new("Figure & Bullets", {100: "Inclusive fitness",
                         102: (["Neal counts everything in copies of your genes: each offspring × your r to it",
                                "**Direct fitness:** own offspring × 0.5",
                                "**Indirect fitness:** extra offspring of relatives, caused by your help, × your r to them",
                                "**Inclusive fitness** = direct + indirect; same answer as rb > c",
                                "Pictured: chestnut-crowned babblers, whose nest helpers are mostly relatives"], 19)},
    pictures={101: I + "babbler.jpg"},
    notes="""
(2 min) Neal Expressions 19.1–19.3: direct = N~1~ × r; indirect = (N~2~ × r) + (N~3~ × r)…; inclusive = direct + indirect. Multiplying by r puts all offspring into the same units (gene copies), so they can be added.
Neal multiplies your own offspring by 0.5 too. Many other texts count own offspring as 1; the comparisons between options come out the same.
The commonest student mistake: counting all of the relative's offspring rather than only the **extra** ones caused by the help.
The chestnut-crowned babbler (*Pomatostomus ruficeps*, Australia) is a cooperative breeder: breeding pairs are helped with feeding the young, mostly by relatives.
Photo: Aviceda, Wikimedia Commons, CC BY-SA 3.0 (carried over; cropped). The acorn woodpecker photo was dropped: it is © Marie Read, not openly licensed.
""")

new("Activity", {101: "3 MIN · PAIRS",
                 102: "Breed yourself, or help your sister?",
                 103: (["Option 1: raise one offspring of your own, and help no one",
                       "Option 2: raise none, but help your sister raise 3 extra offspring",
                       "Calculate direct, indirect and inclusive fitness for each. Which does selection favour?",
                       "Break-even: how many extra nieces or nephews equal one own offspring?"], 22)},
    notes="""
(3 min) Answers (from the previous version's worked example, Neal's convention):
Option 1: direct = 1 × 0.5 = 0.5; indirect = 0; inclusive = 0.5.
Option 2: direct = 0; indirect = 3 × 0.25 = 0.75; inclusive = 0.75. Helping wins.
Break-even: 2 extra nieces or nephews per own offspring forgone (0.5 / 0.25).
The next slide shows the answers, so students reviewing the PDF have them.
""")

new("Two Columns", {100: "Answer: helping wins",
                    101: "OPTION 1: BREED", 103: ["Direct: 1 × 0.5 = 0.5", "Indirect: 0", "Inclusive fitness: **0.5**"],
                    104: "OPTION 2: HELP YOUR SISTER", 106: ["Direct: 0", "Indirect: 3 × 0.25 = 0.75", "Inclusive fitness: **0.75**",
                                                             "Hamilton: 0.5 × 3 = 1.5 > 1",
                                                             "Break-even: 2 nieces or nephews per own offspring"]},
    notes="""
(1 min) Both methods agree: Neal's gene-copy counting (0.75 > 0.5) and Hamilton's rule (1.5 > 1) differ only by a factor of 0.5 on both sides.
Real data next: does this happen in nature?
""")

new("Title, Bullets & Photo", {100: "Pied kingfishers: helping beats waiting",
                               103: "TAKEAWAY",
                               105: ("Few yearlings can breed. Primary helpers have lower direct fitness than secondary helpers, but their indirect fitness (0.65) more than makes up for it. Any helping beats waiting.", 19)},
    pictures={101: F + "05_kingfisher_fitness.png"},
    notes="""
(3 min) Pied kingfisher, *Ceryle rudis*, East Africa: Reyer (1984, 1990), Neal Tables 19.2 and 19.3. Males outnumber females, so only about 5% of yearling males get a mate.
The rest: primary helpers feed their own parents' young (average r = 0.32, a mix of full and half siblings); secondary helpers feed unrelated pairs and often mate with the female they helped the following year; delayers do nothing and try again next year.
Breeding is best (1.76) but rarely available; helpers switch to breeding when a female becomes free. Primary helpers have lower direct fitness than secondary helpers (lower survival, and they avoid mating with their mother), but indirect fitness more than makes up the difference.
Neal's point: if indirect fitness can outweigh lost direct fitness, then even a gene for sterility could spread. That leads to sterile castes.
The figure now labels breeders as only ~5% of yearlings (Neal: about 4.7%), so the tallest bar is not read as an option open to most males.
Neal prints 1.09 as the primary helper's total; the components (0.42 + 0.65) sum to 1.07, which is plotted. Empirical, script 05_kingfisher_fitness.R. A photograph of a pied kingfisher could be added later.
""")

new("Figure & Bullets", {100: "Sterile workers: the haplodiploidy idea",
                         102: (["Ants, bees and wasps: males are haploid, females diploid",
                                "With a once-mated queen, sisters share r = 0.75: more than a worker's own daughters (0.5)",
                                "But brothers share only 0.25, and many queens mate repeatedly",
                                "Better supported: eusociality arose where queens mated only once"], 20)},
    pictures={101: F + "06_haplodiploidy.png"},
    notes="""
(3 min) Neal section 19.2.2. Sisters share all of their father's genes (he is haploid) and on average half of their mother's: 0.5 × 1 + 0.5 × 0.5 = 0.75.
Why it is not the whole answer: averaged over sisters (0.75) and brothers (0.25), relatedness to siblings is 0.5, the same as to offspring (assuming equal investment in the two sexes; workers can tip the balance by favouring sisters, cf. Trivers & Hare 1976). If the queen mated with k males, sister r = ¼ + 1/(2k) (0.30 for k = 10). Termites and naked mole-rats are eusocial but diploid, and many haplodiploid species are not eusocial.
Better supported: every eusocial ant, bee and wasp lineage examined descended from ancestors whose queens mated once (Hughes et al. 2008, Science 320: 1213–1216). High relatedness matters; haplodiploidy is not required.
This is new to the lecture (it was in Neal but not in the previous slides). Analytical, script 06_haplodiploidy.R.
""")

new("Figure & Bullets", {100: "Naked mole-rats: a eusocial mammal",
                         102: (["Colonies of about 70–80 (up to ~300) live underground in East Africa",
                                "One queen and 1–3 males breed; the rest dig, forage and defend",
                                "In four wild colonies, inbreeding raised relatedness to r ≈ 0.81 (full siblings: 0.5); some individuals do disperse and outbreed",
                                "Food is patchy and digging costly, so leaving to breed alone rarely succeeds"], 20)},
    pictures={101: I + "mole_rat.jpg"},
    notes="""
(3 min) *Heterocephalus glaber*. Long-lived for a rodent (over 30 years). When the queen dies, larger females fight to replace her.
Reeve et al. (1990, PNAS 87: 2496–2500), DNA fingerprinting of four wild colonies: inbreeding coefficient F = 0.45 ± 0.18, within-colony r = 0.81 ± 0.10. Most individuals have zero direct fitness, but high indirect fitness.
Caveats (both sides of the story): later work found wild colonies also produce dispersers that outbreed (Braude 2000, Behav. Ecol.), and the related Damaraland mole-rat is eusocial with ordinary family relatedness (Burland et al. 2002). Relatedness makes helping pay; harsh ecology (arid soils, patchy tubers) makes independent breeding nearly impossible. Both matter.
Corrections from the previous version: 'caste system… larger workers are soldiers' is softened; roles change with size and age and are less fixed than in insects. 'The evolution of cooperation is driven by kin selection' is right but incomplete without ecology.
Photo: Smithsonian's National Zoo, Flickr, CC BY-NC-ND (not cropped, because the licence forbids derivatives). The second mole-rat photo was dropped.
""")

# ---------------------------------------------------------------- Section 04
new("Section", {102: "04", 103: "Limiting aggression"},
    notes="(10 s) A second kind of apparent altruism: holding back from hurting a rival.")

new("Title, Bullets & Photo", {100: "Most fights are ritualised",
                               103: "TAKEAWAY",
                               105: ("Rivals display, push and wrestle; the loser retreats and the winner rarely presses home. Why hold back?", 20)},
    pictures={101: I + "ritual_fights.jpg"},
    notes="""
(2 min) Neal section 19.2.3. Animals with lethal weapons usually settle contests by trials of strength.
Until the 1960s (Neal) this was explained as 'for the good of the species': group selection again (e.g. Lorenz). Maynard Smith and Price (1973) showed that restraint can benefit the **individual**.
Rivals assess each other first: roaring rate in red deer, croak pitch in toads and frogs, parallel walks in bison and sable antelope. A clearly weaker animal withdraws; contests escalate mainly between evenly matched rivals. When they do, costs are real: on Rum, about 23% of red deer stags were injured during the rut and up to 6% permanently (Neal; the study is Clutton-Brock, Albon, Gibson & Guinness 1979, Animal Behaviour 27: 211–225).
Photo carried over from the previous version: bighorn rams (J. Savage); source and licence to confirm. The lion photo was dropped in v3: it shows an escalated fight, which undercuts the slide's point.
""")

new("Figure & Bullets", {100: "Game theory: the Hawk–Dove game",
                         102: (["The payoff of a strategy depends on what opponents do",
                                "**Hawk:** escalate; fight until injured or the opponent flees",
                                "**Dove:** display; retreat if the opponent escalates",
                                "Strategies are heritable; payoff = fitness",
                                "Two strategies within one species: the birds are only labels"], 20)},
    pictures={101: I + "hawk_dove.jpg"},
    notes="""
(2 min) Maynard Smith & Price (1973) Nature 246: 15–18; Neal 'The basic Hawk–Dove model'.
Stress: Hawk and Dove are two **strategies** that individuals of one species could follow, not two species. The birds are just labels (Harris's hawk, top; pink-necked green pigeon, bottom).
Payoffs are in units of fitness. We assume each individual's strategy is inherited, so the strategy that earns more spreads.
Photos carried over from the previous version: Harris's hawk (source to confirm) and *Treron vernans* (Wikimedia Commons, licence to confirm).
""")

s = new("Title Only", {100: "The payoff matrix"},
    notes="""
(3 min) Neal Table 19.4. Read each cell as 'what the row player gets when it meets the column player'.
Hawk vs Hawk: evenly matched, each wins B half the time and is injured (−C) half the time: (B − C)/2.
Hawk vs Dove: the Dove retreats; Hawk takes B, Dove gets 0.
Dove vs Dove: both display (cost D), each wins half the time: B/2 − D.
Why is C halved but D not? Only the loser of a Hawk fight is injured; both Doves pay for displaying.
The practical uses the classic version with no display cost (D = 0).
""")
table(s, ["Payoff to (row) against (column)", "Hawk", "Dove"],
      [["Hawk", "(B − C) / 2", "B"],
       ["Dove", "0", "B/2 − D"]],
      col_w=[4.6, 3.0, 3.0], row_h=0.75, size=22, top=2.3)
textbox(s, ["**B** = value of the resource     **C** = cost of injury     **D** = cost of displaying",
            "Hawk vs Hawk: evenly matched, so each wins half the time and is injured half the time",
            "Dove vs Dove: both display, and each wins half the time"],
        0.8, 4.75, 11.7, 1.6, size=20, color=INK)

new("Key Concept", {102: ("Evolutionarily stable strategy (ESS)", 36),
                    103: "A strategy that, once almost everyone uses it, cannot be invaded by any rare alternative strategy.",
                    105: "Test: add one rare mutant. If it earns less than the residents, they are stable. If it earns the same, the residents must do better than the mutant once it becomes common. Stable does not mean best."},
    notes="""
(2 min) Maynard Smith & Price (1973). Formally, strategy I is an ESS if, for every alternative J, either E(I,I) > E(J,I), or E(I,I) = E(J,I) and E(I,J) > E(J,J).
The second condition matters today: at the mixed ESS (7/12 Hawks), a rare pure Hawk or pure Dove earns exactly the same as the residents (6.25), and stability comes from the second condition. (Correction from v2, which gave only the first condition.)
Corrections from the previous version: the title 'The best strategy = Evolutionary Stable Strategy' implied the ESS is the best strategy; it is the strategy that cannot be beaten by a rare alternative, which is different (we will see the population can be worse off at the ESS). 'Evolutionary' is now 'Evolutionarily'. The 'best quality' stamp was removed for the same reason.
""")

s = new("Title Only", {100: "Cheap injuries (C < B): Hawk is the ESS"},
    notes="""
(3 min) Neal Example 19.1: B = 50, C = 25, D = 10.
A population of Doves earns more (15 each) than a population of Hawks (12.5), yet Doves are not stable: a rare Hawk among Doves earns 50. A rare Dove among Hawks earns 0, less than the residents' 12.5. Hawk is the ESS.
Point to stress: everyone would be better off as Doves, but that is not what selection on individuals produces. (This is the Prisoner's Dilemma structure students meet in the practical.)
Arithmetic in scripts/00_check_numbers.R.
""")
table(s, ["B = 50, C = 25, D = 10", "vs Hawk", "vs Dove"],
      [["Hawk", "12.5", "50"],
       ["Dove", "0", "15"]],
      col_w=[4.0, 2.4, 2.4], row_h=0.7, size=22, top=2.3)
textbox(s, ["A rare Hawk among Doves earns **50 > 15**: Hawks invade",
            "A rare Dove among Hawks earns **0 < 12.5**: Doves cannot invade",
            "**Hawk is the ESS**, although a population of Doves would do better (15 vs 12.5)"],
        0.8, 4.55, 11.7, 1.7, size=21, color=INK)

new("Check Question (2 options)", {101: ("Now injury is costly: C = 100 (B = 50, D = 10). Can a rare Dove invade a population of Hawks?", 30),
                                   105: "Yes", 109: "No"},
    notes="""
(1 min) Answer: Yes. Hawk vs Hawk now pays (50 − 100)/2 = −25. A Dove that meets a Hawk retreats and gets 0, which is better than −25.
""")

s = new("Title Only", {100: "Costly injuries (C > B): no pure ESS"},
    notes="""
(2 min) Neal Example 19.2: B = 50, C = 100, D = 10.
Hawks invade Doves (50 > 15) and Doves invade Hawks (0 > −25). Each strategy does best when it is rare, so the population settles at a mix.
""")
table(s, ["B = 50, C = 100, D = 10", "vs Hawk", "vs Dove"],
      [["Hawk", "−25", "50"],
       ["Dove", "0", "15"]],
      col_w=[4.0, 2.4, 2.4], row_h=0.7, size=22, top=2.3)
textbox(s, ["A rare Hawk among Doves earns **50 > 15**: Hawks invade",
            "A rare Dove among Hawks earns **0 > −25**: Doves invade",
            "Each does best when rare, so the stable state is a **mix** of Hawks and Doves"],
        0.8, 4.55, 11.7, 1.7, size=21, color=INK)

new("Title & Bullets", {100: "Finding the mixed ESS",
                        101: (["Let p = frequency of Hawks, so 1 − p = frequency of Doves",
                               "Hawk earns:  W~H~ = −25p + 50(1 − p) = 50 − 75p",
                               "Dove earns:  W~D~ = 0p + 15(1 − p) = 15 − 15p",
                               "Both earn the same when 50 − 75p = 15 − 15p, so p* = 35/60 = 7/12 ≈ 0.58",
                               "Read as 7 Hawks : 5 Doves, or each individual playing Hawk with probability 7/12",
                               "In general p* = (B/2 + D) / (C/2 + D); with no display cost, p* = B/C"], 20)},
    notes="""
(3 min) Neal Example 19.2. Each strategy's average payoff is its payoff against each opponent type, weighted by how common that type is.
If Hawks earned more, Hawks would increase until they no longer did; at equilibrium the two payoffs are equal.
Two readings of p* = 7/12 (Neal): 7 Hawks for every 5 Doves, or every individual plays Hawk with probability 7/12 (a mixed strategy). The previous version's annotation 'think of this as a probability' fits the second.
General result: p* = (B/2 + D)/(C/2 + D); with no display cost (D = 0, the classic version) p* = B/C. Checked in 00_check_numbers.R.
""")

new("Title & Photo", {100: "Selection finds the ESS",
                      102: "Left: each strategy does better when rare. Right: fixed Hawks and Doves converge on 7 : 5 from any start."},
    pictures={101: F + "07_hawk_dove_dynamics.png"},
    notes="""
(2 min) Left: the lines cross at p* = 7/12. Below p*, Hawks earn more and increase; above it, Doves earn more. This is **negative frequency-dependent selection**, the same process that keeps rovers and sitters in fruit flies.
Right: four populations starting from 2%, 25%, 90% and 99% Hawks all converge on 58%. Strictly, this model has individuals that are pure Hawks or pure Doves, so it shows a stable 7 : 5 polymorphism; a population in which everyone plays Hawk with probability 7/12 behaves the same way here.
Model: deterministic replicator dynamics with non-overlapping generations, random encounters and strategies inherited exactly; baseline fitness 50 is added so that fitness stays positive (this sets the speed, not the end point). Analytical and deterministic iteration, script 07_hawk_dove_dynamics.R.
""")

new("Big Fact", {100: "6.25",
                 102: "Average payoff at the ESS, against 15 in a population of Doves. Selection on individuals does not maximise the good of the group."},
    notes="""
(1 min) At p* = 7/12 both strategies earn 15 − 15 × 7/12 = 6.25. A population of pure Doves would earn 15 each, but cannot resist invasion by Hawks.
Link back to group selection: 'good for the group' does not mean 'favoured by selection'.
Note: restraint is not total at this ESS. With 7/12 Hawks, (7/12)² ≈ 34% of encounters are escalated Hawk–Hawk fights.
""")

s = new("Title Only", {100: "Hawk–Dove–Bourgeois"},
    notes="""
(3 min) Neal Table 19.5 and the worked matrix (B = 50, C = 100, D = 10). Added because the speckled wood example on the next slide relies on it (the previous version used it without introducing it).
Bourgeois plays Hawk when it owns the resource and Dove when it is the intruder; each individual is an owner half the time, and both contestants always agree who the owner is (the model assumes roles are never confused). Cells: a, b, c, d from the Hawk–Dove matrix, averaged over the two roles, e.g. Hawk vs Bourgeois = (a + b)/2 = 12.5. Two Bourgeois never fight: the owner takes B and the intruder gets 0, average 25.
Neither Hawk (12.5) nor Dove (7.5) can invade a Bourgeois population (25), so Bourgeois is an ESS. In general it is an ESS whenever C > B, and contests are then settled without escalation.
Neal's printed matrix shows 32 for Bourgeois vs Dove; (b + d)/2 = 32.5 (his text gives 32.5).
""")
table(s, ["B = 50, C = 100, D = 10", "vs Hawk", "vs Dove", "vs Bourgeois"],
      [["Hawk", "−25", "50", "12.5"],
       ["Dove", "0", "15", "7.5"],
       ["Bourgeois", "−12.5", "32.5", "25"]],
      col_w=[3.9, 2.4, 2.4, 2.4], row_h=0.62, size=20, highlight_rows=(2,), top=2.3)
textbox(s, ["**Bourgeois:** Hawk as owner, Dove as intruder (each role half the time)",
            "Cells average the two roles: Hawk vs Bourgeois = (−25 + 50) / 2 = 12.5",
            "Rare Hawks earn 12.5, rare Doves 7.5, residents 25: **Bourgeois is an ESS** (C > B)"],
        0.8, 5.0, 11.7, 1.6, size=19, color=INK)

new("Figure & Bullets", {100: "Speckled wood butterflies",
                         102: (["Males defend sunspots on the forest floor; contests are spiral flights",
                                "England: sunspots are plentiful; the resident always wins, as in Bourgeois",
                                "Sweden: sunspots are scarce; contests last longer and the resident does not always win",
                                "Interpretation: a scarcer, more valuable resource (higher B) favours escalation"], 20)},
    pictures={101: I + "speckled_wood.jpg"},
    notes="""
(3 min) *Pararge aegeria*. England: Davies (1978); Sweden: Wickman & Wiklund (1983, Animal Behaviour 31: 1206–1216). Neal: in England B is low relative to C, favouring Bourgeois; in Sweden B is high relative to C, favouring Hawk-like escalation.
Correction from the previous version: it said English residents 'adopt a hawk strategy, while intruders act as doves'. That is the Bourgeois strategy, so it is now named and introduced on the previous slide.
Science moves on: later work suggests the resident's advantage reflects real asymmetries (motivation, or fighting and flying ability) rather than an arbitrary convention (e.g. Kemp & Wiklund 2004, Proc. R. Soc. B). In a 2018 interview (Hari Sridhar, 'Reflections on Papers Past': Revisiting Davies 1978), Davies said he 'jumped on' the arbitrary-asymmetry interpretation too quickly.
Correction from v2: 'residents often lose' in Sweden overstated Wickman & Wiklund; Neal says only that the resident was not always the winner, and displaced owners often won their territory back. 'High B' is an interpretation, not a measurement, so the slide now says so. Good discussion point: models simplify; the qualitative prediction (escalate when B is high relative to C) still holds.
Photo: Alvesgaspar, Wikimedia Commons, CC BY-SA 3.0 (carried over; cropped).
""")

new("Title & Bullets", {100: "Common misconceptions",
                        101: (["**Hawk and Dove are strategies,** not species or personalities",
                               "**An ESS is stable, not best:** the population can do worse than with restraint (6.25 vs 15)",
                               "**Pure Dove is never stable** in this model: restraint persists as a mix, or as a conditional rule such as Bourgeois",
                               "**The ESS depends on B and C:** change the ecology and the ESS changes"], 21)},
    notes="""
(2 min) Correction from the previous version: 'non-aggressive (Dove) strategies can be stable and prevalent' is not right for the basic model: a population of pure Doves can always be invaded by Hawks (B > B/2 − D). Doves persist only as part of a mixed ESS when C > B; restraint is stable as a conditional strategy (Bourgeois).
Also: individuals need not be fixed Hawks or Doves. A mixed strategy (play Hawk with probability 7/12) or a conditional one (Bourgeois) is often more realistic, and the same maths applies.
An ESS is not the end of evolution: it is stable only under current conditions and against the strategies considered.
""")

new("Activity", {101: "NEXT · PRACTICAL",
                 102: "Hawks and Doves: predict before you play",
                 103: ["Today's game: B = 4, C = 3, and no display cost (D = 0)",
                       "If partners meet only once, which strategy is the ESS?",
                       "Predict: will you play differently against the same partner 15 times? Why?"]},
    notes="""
(1 min) Preview of the practical, the 'Game theory: Hawks and doves' chapter of the BB512 book (https://jonesor.github.io/BB512_Book). The numbers here match the practical.
Answers to hold back until after the game: with B > C, Hawk is the ESS in a one-off encounter (Hawk vs Dove 4 > 2; Hawk vs Hawk 0.5 > 0). With a repeated partner, retaliation and reciprocity can make mutual Dove (2 each) pay better than mutual Hawk (0.5 each). The lecture does not teach reciprocity; the second question is deliberately an open prediction that the practical then tests. Hedge if asked: in a game of known, fixed length, defecting in the last round always pays, so cooperation is not guaranteed in theory; in practice people often cooperate anyway.
""")

new("Summary", {101: "Key points",
                102: (["Behaviour evolves when its variation is heritable, though genes act with the environment",
                       "Apparent altruism: first check the cost is real; 'good of the group' arguments rarely work",
                       "Kin selection: help when rb > c; inclusive fitness explains helpers and, with ecology, sterile castes",
                       "When injury costs exceed the prize, restraint persists: as a Hawk–Dove mix, or through rules such as ownership"], 18),
                106: (["**Read:** Neal (2004), Chapter 19",
                       "**Practical:** Hawks and Doves card game (BB512 book)"], 16)},
    notes="""
(1 min) One point per learning objective. Return to the opening meerkats: three ways to explain apparent altruism (relatives, payoffs that make restraint pay, and checking that the cost is real; meerkat sentinels may be largely selfish, Clutton-Brock et al. 1999).
Correction from v2: v2 said 'fights stay limited when injury costs exceed the prize', but at the mixed ESS about a third of encounters are still escalated fights.
""")

prs.save(OUT)
print("saved", OUT, len(prs.slides), "slides")
