"""Build 'BB512 - Lotka Volterra Competition Practical v2' from BB512_Theme.pptx.
Run from the lecture folder:  python3 build_deck.py <path/to/BB512_Theme.pptx> <out.pptx>
Inline markup in text: *italic*, **bold**, ~subscript~, ^superscript^.
Helpers copied from ../behaviour_altruism/build_deck.py. No slide numbers (BB512 rule).
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

def new(layout, fields=None, notes=None, pictures=None, number=False):
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
import os
TITLE_IMG = I + "title_tribolium.jpg"

# ---------------------------------------------------------------- 1 Title
new("Title", {103: ("Lotka-Volterra competition", 42),
              104: "When can two competing species live together?"},
    pictures={100: TITLE_IMG} if os.path.exists(TITLE_IMG) else None,
    notes="""
(1 min) Practical over two sessions: session 1 builds the model in Excel, session 2 uses it to answer four questions.
Photo: red flour beetle, *Tribolium castaneum*, one of Park's competing species (we meet them again at the end). If the picture placeholder is empty, drop in the photo listed in images/CREDITS.md.
""")

# ---------------------------------------------------------------- 2 Objectives
new("Agenda", {101: "Lotka-Volterra competition",
               103: (["Explain what the competition coefficients α and β measure",
                      "Draw the zero isoclines from K~1~, K~1~/α, K~2~ and K~2~/β, and use them to predict the outcome of competition",
                      "Build a discrete-time competition model in Excel and use it to test your predictions",
                      "Explain why coexistence needs each species to limit itself more than it limits its competitor"], 20)},
    notes="""
(1 min) One objective per part of the practical. Reading: Neal, chapter *Interspecific Competition*. Notation follows Neal (α, β), the online book and the Excel worksheet. The worksheet is the book chapter itself (no PDF any more).
""")

# ---------------------------------------------------------------- Section 01
new("Section", {102: "01", 103: "The model"},
    notes="(10 s) Logistic growth for each species, plus a term for the competitor.")

new("Title & Bullets", {100: "From one species to two",
                        101: (["Logistic growth:   dN/dt = rN (K − N)/K",
                               "Species 1 with a competitor:   dN~1~/dt = r~1~N~1~ (K~1~ − N~1~ − αN~2~)/K~1~",
                               "Species 2 with a competitor:   dN~2~/dt = r~2~N~2~ (K~2~ − N~2~ − βN~1~)/K~2~",
                               "Each species still limits itself (the −N term), and now also limits the other",
                               "Each individual of species 2 uses up α of species 1's carrying capacity"], 22)},
    notes="""
(3 min) Build up from the logistic: (K − N)/K is the fraction of the carrying capacity still free, so growth slows as N approaches K. With a competitor, the free fraction for species 1 is (K~1~ − N~1~ − αN~2~)/K~1~.
Common misconception (corrected from the old deck): competition does not change K. K~1~ is still species 1's carrying capacity on its own; species 2 simply occupies part of it.
The Excel sheet uses a discrete-time version (slide 10); the isoclines and outcomes are the same.
""")

new("Key Concept", {102: "Competition coefficients",
                    103: "α is the effect of one individual of species 2 on the growth of species 1, relative to the effect of one individual of species 1 on itself. β is the same for species 1 acting on species 2.",
                    105: "Example: α = 0.5 means two individuals of species 2 compete with species 1 as strongly as one individual of species 1."},
    notes="""
(2 min) Neal: α converts individuals of species 2 into species-1 equivalents. α < 1: a species-2 individual competes less than a conspecific; α > 1: more.
Warn now (it returns in Q1 and Q2): whether α or β is bigger than 1 does not by itself decide who wins; the carrying capacities matter too.
""")

new("Figure & Bullets", {100: "Zero isocline: where a species stops growing",
                         102: (["Species 1 stops growing when N~1~ = K~1~ − αN~2~",
                                "A straight line from K~1~ (no species 2) to K~1~/α (so much species 2 that species 1 cannot grow)",
                                "To the left of the line species 1 grows; to the right it declines",
                                "Species 2 has its own isocline, from K~2~ to K~2~/β"], 19)},
    pictures={101: F + "01_one_isocline.png"},
    notes="""
(3 min) Set dN~1~/dt = 0: apart from N~1~ = 0, this happens when K~1~ − N~1~ − αN~2~ = 0. Put N~2~ = 0 to get the x-intercept K~1~; put N~1~ = 0 to get the y-intercept K~1~/α.
The arrows are horizontal because this isocline only tells us about N~1~ (the x-axis). Species 2's isocline gives vertical arrows.
Drawn with the worksheet's default values (K~1~ = 1200, α = 0.75, so K~1~/α = 1600). Analytical schematic, script 01_one_isocline.R.
""")

new("Title & Photo", {100: "Four ways the isoclines can lie",
                      102: "Solid: species 1 (K~1~, K~1~/α). Dashed: species 2 (K~2~, K~2~/β). Filled circle: stable equilibrium. Open circle: unstable."},
    pictures={101: F + "03_four_outcomes.png"},
    notes="""
(4 min) Neal's four cases. Read each by asking which line is further out on each axis.
1. Species 1's isocline is outside species 2's everywhere: K~1~ > K~2~/β and K~1~/α > K~2~. Species 1 wins.
2. The reverse: species 2 wins.
3. They cross, with K~1~ < K~2~/β and K~2~ < K~1~/α: stable coexistence where they cross.
4. They cross the other way: the crossing point is unstable, and whichever side the populations start on decides the winner.
Neal's fifth case (the lines lie exactly on top of each other) comes at the end of session 2.
Illustrative values, analytical schematic, script 03_four_outcomes.R.
""")

new("Key Concept", {102: "Can each species invade?",
                    103: "Species 1 can invade species 2 sitting at K~2~ if α < K~1~/K~2~. Species 2 can invade species 1 at K~1~ if β < K~2~/K~1~.",
                    105: "Both can invade: coexistence. Only one can: it wins. Neither can: the starting numbers decide."},
    notes="""
(3 min) Same conditions as the isocline cases, written another way. A rare species 1 meeting species 2 at K~2~ feels crowding equal to αK~2~ of its own individuals; it grows if that is less than K~1~.
This is the scaled sense in which 'each species limits itself more than the other'. Comparing α or β with 1 is enough only when K~1~ = K~2~.
""")

new("Check Question (4 options)", {101: ("K~1~ = 3000, α = 1.25, K~2~ = 1000, β = 0.5. What happens?", 30),
                                   105: "Species 1 wins", 109: "Species 2 wins", 113: "They coexist", 117: "It depends on the starting numbers"},
    notes="""
(2 min) Answer A, species 1 wins. Species 1 can invade (α = 1.25 < K~1~/K~2~ = 3); species 2 cannot (β = 0.5 > K~2~/K~1~ = 0.33).
Common wrong answer: B, 'species 2 has the bigger effect (α > 1), so it wins'. This is the parameter set of Q1 in session 2, so students will see it run.
""")

sl = new("Title & Bullets", {100: "From equation to Excel",
                        101: (["Excel moves in time steps:   N~1,t+1~ = N~1,t~ + R~1~N~1,t~ (K~1~ − N~1,t~ − αN~2,t~)/K~1~",
                               "R = growth per time step; keep it at 1 or below",
                               "Same isoclines and outcomes as the continuous model",
                               "In the worksheet, cell B12 holds species 1's next time step:"], 22)},
    notes="""
(2 min) Walk through the formula once, term by term: B11 is N~1,t~, C11 is N~2,t~, $F$4 is R~1~, $F$5 is K~1~, $F$6 is α. The $ signs keep the parameter references fixed when the formula is copied down.
Students type this formula themselves and then write the species 2 version (C12) without help; the answer is in the book's solutions.
R > 1 adds the oscillations and chaos of the discrete logistic (Deeper into logistic growth), which have nothing to do with competition.
""")
tb = sl.shapes.add_textbox(Inches(0.85), Inches(4.8), Inches(11.5), Inches(0.6))
p0 = tb.text_frame.paragraphs[0]; p0.alignment = PP_ALIGN.LEFT; r0 = p0.add_run(); r0.text = "=B11+$F$4*B11*($F$5-B11-$F$6*C11)/$F$5"
r0.font.name = "Menlo"; r0.font.size = Pt(22); r0.font.color.rgb = FOREST

# ---------------------------------------------------------------- Section 02
new("Section", {102: "02", 103: "Session 1: build the model"},
    notes="(10 s) Hand over to the students.")

new("Activity", {101: "30 MIN · PAIRS",
                 102: "Can you build a two-species competition model in Excel?",
                 103: (["Download the Excel worksheet (online book, Part 1)",
                        "Type the species 1 formula in B12; write species 2's in C12",
                        "Copy down to row 211; check it settles at (720, 640)",
                        "Explore (Part 2): change α, β and R one at a time"], 22)},
    notes="""
(30 min) About 15 minutes to type the formulas and check the sheet, then about 15 minutes for the Part 2 exploration prompts in the book (α = β = 0; increasing α; R~1~ = 0.2; labelling the intercepts).
The worksheet already has the parameters, the time column to t = 200, the isocline ends and both graphs. Only B12 and C12 (yellow) are empty.
Common errors: missing $ signs (the parameters drift when copied down), and dividing species 2's growth by K~1~.
""")

new("Title, Bullets & Photo", {100: "Check your sheet",
                               103: "CHECK",
                               105: ("With the worksheet's starting values (R~1~ = R~2~ = 1, K~1~ = 1200, α = 0.75, K~2~ = 1000, β = 0.5, start 100 and 50), both species settle at N~1~ = 720 and N~2~ = 640.", 19)},
    pictures={101: F + "02_check_sheet.png"},
    notes="""
(2 min) If a sheet does not settle at (720, 640): check the $ signs in the formulas, and that each formula uses its own species' K in the denominator.
Equilibrium by hand: N~1~* = (K~1~ − αK~2~)/(1 − αβ) = (1200 − 750)/0.625 = 720; N~2~* = (K~2~ − βK~1~)/(1 − αβ) = (1000 − 600)/0.625 = 640.
Deterministic simulation of the worksheet model, script 02_check_sheet.R; numbers printed by 00_check_numbers.R.
""")

# ---------------------------------------------------------------- Section 03
new("Section", {102: "03", 103: "Session 2: use the model"},
    notes="(10 s) Session 2 starts here. Briefly recap the isocline cases (slide 7) and the invasion rule (slide 8).")

new("Activity", {101: "30 MIN · PAIRS",
                 102: "Which values give each outcome, and why?",
                 103: (["Q1: species 1 excludes species 2",
                        "Q2: species 2 excludes species 1",
                        "Q3: the two species coexist stably",
                        "Q4: the outcome depends on the starting numbers or growth rates",
                        "For each: sketch the isoclines and predict first, then run your sheet"], 22)},
    notes="""
(30 min) For each outcome, students also explain what the values mean in ecological terms. The same four questions as the book (Part 3). Insist on the prediction before running: that is where the learning happens.
Optional extra (Q5 in the book): Neal's flour beetles; see the last answer slide.
""")

new("Section", {102: "04", 103: "Answers: try first"},
    notes="(10 s) The answers use the parameter values of the book's solutions chapter, so students reviewing the slides afterwards see the same numbers.")

new("Title, Bullets & Photo", {100: "Q1: species 1 excludes species 2",
                               103: "WHY",
                               105: ("Species 1 can invade (α = 1.25 < K~1~/K~2~ = 3); species 2 cannot (β = 0.5 > K~2~/K~1~ = 0.33). Species 1 wins even though species 2 grows faster, starts larger and α > 1.", 18)},
    pictures={101: F + "04_answer_q1.png"},
    notes="""
(3 min) R~1~ = 0.25, K~1~ = 3000, α = 1.25; R~2~ = 0.5, K~2~ = 1000, β = 0.5; start N~1~ = 50, N~2~ = 100. After 50 time steps the sheet shows about (2979, 2.4); by 200, (3000, 0).
Changing R or the starting numbers does not change the outcome.
Ecological meaning: species 1 can keep growing even when species 2 is at its own carrying capacity, but not the other way round.
Deterministic simulation, script 04_answer_q1.R.
""")

new("Title, Bullets & Photo", {100: "Q2: species 2 excludes species 1",
                               103: "WHY",
                               105: ("Species 2 can invade (β = 0.25 < K~2~/K~1~ = 0.67); species 1 cannot (α = 2.25 > K~1~/K~2~ = 1.5). Species 2 wins although K~1~ > K~2~.", 18)},
    pictures={101: F + "05_answer_q2.png"},
    notes="""
(2 min) R~1~ = R~2~ = 0.25, K~1~ = 3000, α = 2.25; K~2~ = 2000, β = 0.25; start 50 and 50.
The phase plot's axes are not to the same scale: K~2~/β = 8000 is far out on the N~1~ axis.
Ecological meaning: species 2 hardly notices species 1 (small β), while species 1 is strongly suppressed by species 2 (large α), for example through interference.
Deterministic simulation, script 05_answer_q2.R.
""")

new("Title, Bullets & Photo", {100: "Q3: stable coexistence",
                               103: "WHY",
                               105: ("Both can invade (α = 0.75 < 1.25; β = 0.5 < 0.8). From every start the populations return to (1600, 1200).", 19)},
    pictures={101: F + "06_answer_q3.png"},
    notes="""
(3 min) R~1~ = 0.75, K~1~ = 2500, α = 0.75; R~2~ = 0.5, K~2~ = 2000, β = 0.5. Time series from (50, 50); the phase plot adds the five other starts from the book: (1000, 1), (1, 1000), (500, 2500), (1000, 3000), (250, 3000).
From (1000, 1) and (1, 1000) it takes more than 50 time steps to settle (at t = 50, (1000, 1) is still at about (1760, 1037)): this is why the sheet needs 200 rows.
Equilibrium: N~1~* = (2500 − 0.75 × 2000)/(1 − 0.375) = 1600; N~2~* = (2000 − 0.5 × 2500)/0.625 = 1200.
Ecological meaning: each species limits itself more than it limits its competitor (in the scaled sense), for example because they partly use different resources.
Deterministic simulation, script 06_answer_q3.R.
""")

new("Title, Bullets & Photo", {100: "Q4: the start decides",
                               103: "WHY",
                               105: ("Neither can invade (α = β = 1.25 > 1). The equilibrium at (444, 444) is unstable: from (100, 50) species 1 wins; from (50, 100) species 2 wins.", 19)},
    pictures={101: F + "07_answer_q4.png"},
    notes="""
(3 min) R~1~ = R~2~ = 0.5, K~1~ = K~2~ = 1000, α = β = 1.25. Starting exactly at (50, 50) the populations go to (444, 444) and stay, but only because the model is deterministic: any disturbance tips them off.
Even (445, 444) ends at (1000, 0), but slowly: at t = 50 it is still at about (452, 437); it reaches (1000, 0) after about 150 steps.
Growth rates matter too: from (50, 50) with R~1~ = 0.8 and R~2~ = 0.4, species 1 wins; swap them and species 2 wins.
Ecological meaning: each species affects the other more than itself, for example through interference or mutual predation.
Deterministic simulation, script 07_answer_q4.R.
""")

new("Figure & Bullets", {100: "Starting larger is not enough",
                         102: (["K~1~ = K~2~ = 1000, α = 1.2, β = 1.3, R = 1",
                                "Species 2 starts larger in both runs",
                                "From (120, 160) species 1 wins; from (100, 160) species 2 wins",
                                "What matters is which side of the unstable equilibrium the start lies on"], 20)},
    pictures={101: F + "08_smaller_can_win.png"},
    notes="""
(2 min) Same type of outcome as Q4, but with unequal coefficients. The unstable equilibrium is at (357, 536). 'Whoever starts larger wins' is only true when the two species are identical apart from their numbers (as in Q4).
This case came from the old version of this deck.
Deterministic simulation, script 08_smaller_can_win.R.
""")

new("Figure & Bullets", {100: "Identical species do not exclude each other in the model",
                         102: (["α = β = 1 and K~1~ = K~2~: the two isoclines lie on top of each other",
                                "Every point on the line is an equilibrium; each run keeps its starting ratio",
                                "Yet Gause's *Paramecium* cultures did show exclusion",
                                "Neal: an extra source of mortality (a 'removal factor') is needed to explain it"], 19)},
    pictures={101: F + "09_identical_species.png"},
    notes="""
(2 min) Neal's fifth case: 'coexistence at a range of equilibrium densities'. With R~1~ = R~2~ = 0.5, (100, 300) ends at (250, 750) and (300, 100) at (750, 250).
So the competitive exclusion principle comes from experiments (Gause), not from the basic model. Gause removed a tenth of each culture daily to count it; with that extra mortality the faster-growing species wins (Neal, *Interspecific Competition*).
Deterministic simulation, script 09_identical_species.R.
""")

new("Figure & Bullets", {100: "Optional: flour beetles",
                         102: (["Park (1962): *Tribolium confusum* (K~1~ = 220) and *T. castaneum* (K~2~ = 340); α = 1, β = 2.2",
                                "Neither can invade, so the start decides",
                                "Park found the same, with an 'indeterminate zone' where either could win by chance",
                                "*Rhizopertha* and *Oryzaephilus*: both can invade, and they coexist at about (233, 412)"], 18)},
    pictures={101: F + "10_tribolium.png"},
    notes="""
(2 min) Book Q5. Parameters from Neal (24 °C, 70% relative humidity). The trajectories are a deterministic simulation with R~1~ = R~2~ = 0.5 (illustrative): (100, 20) goes to *T. confusum* at 220, (20, 100) to *T. castaneum* at 340. Unstable equilibrium at (100, 120).
Second pair (Crombie 1945): *Rhizopertha* K~1~ = 330, α = 0.235; *Oryzaephilus* K~2~ = 440, β = 0.12; equilibrium (233, 412). Their larvae feed in different places (inside versus on the grain surface), a niche difference.
Script 10_tribolium.R.
""")

new("Summary", {101: "Key points",
                102: (["The four intercepts K~1~, K~1~/α, K~2~ and K~2~/β predict the outcome",
                       "Coexistence needs α < K~1~/K~2~ and β < K~2~/K~1~: each species limits itself more than its competitor",
                       "Comparing α or β with 1 is enough only when K~1~ = K~2~",
                       "When neither species can invade, the starting numbers decide"], 18),
                106: (["**Reading:** Neal, *Interspecific Competition*",
                       "**Book:** Lotka-Volterra competition, and its solutions",
                       "**Next:** predator-prey practical"], 16)},
    notes="""
(1 min) One point per objective. Return to the opening question: two competitors can live together when each limits itself more than it limits the other.
""")

prs.save(OUT)
print("saved", OUT, len(prs.slides), "slides")
