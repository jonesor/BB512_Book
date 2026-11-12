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
Leave this up while students settle, then go straight to the next slide. The deck is reference only: no lecture. Students work from the online book; the slides show what they should see.
Photo: red flour beetle, *Tribolium castaneum*, one of Park's competing species (we meet them again at the end). If the picture placeholder is empty, drop in the photo listed in images/CREDITS.md.
""")


# ---------------------------------------------------------------- 2 The task
new("Activity", {101: "2 SESSIONS · PAIRS",
                 102: "Work through the Lotka-Volterra competition practical in the online book",
                 103: (["Session 1: Part 1 (build the model) and Part 2 (explore it)",
                        "Session 2: Part 3 (Q1 to Q4; Q5 optional)",
                        "Sketch and predict before you run",
                        "Check your work against the next slides"], 22)},
    notes="""
Leave this slide up while students work. Everything they need is in the book chapter: the worksheet download, the formula for B12, the Part 2 prompts and the Part 3 questions.
Part 1 (about 15 min): type the species 1 formula in B12 (given), write species 2's in C12 (answer: =C11+$F$7*C11*($F$8-C11-$F$9*B11)/$F$8), copy to row 211. Common errors: missing $ signs, and dividing species 2's growth by K~1~.
Part 2 (about 15 min), answers: α = β = 0 gives (1200, 1000) and #DIV/0! in two isocline cells; species 1 is lost once α > K~1~/K~2~ = 1.2 (at α = 1 they coexist at (400, 800); at α = 1.3 species 1 is still about 5 after 50 steps); R~1~ = 0.2 still settles at (720, 640), only more slowly; intercepts 1200 and 2000 on the N~1~ axis, 1000 and 1600 on the N~2~ axis.
Part 3 (session 2): insist on the prediction before running, and on looking at all 200 time steps.
""")

new("Title & Photo", {100: "Your worksheet",
                      102: "Yellow: your formulas (B12, C12). Orange: the parameters you change. Blue: the invasion check (do not edit)."},
    pictures={101: os.path.join(os.path.dirname(os.path.abspath(__file__)), "images", "lv_worksheet_blank.png")},
    notes="""
Screenshot of the student worksheet as downloaded (Excel, Mac), rows 1-13. Show it with the task slide so students can find their way around: the two yellow cells are the only ones they type in for Part 1; in Parts 2 and 3 they change only the orange cells (and, for Q4 and Q5, the starting sizes in B11 and C11). The blue block puts K~1~/K~2~ next to α and K~2~/K~1~ next to β, so they can check the invasion rule directly.
""")

new("Title & Photo", {100: "Check your sheet",
                      102: "With the starting values, species 1 settles at N~1~ = 720 and species 2 at N~2~ = 640, where the two isoclines cross."},
    pictures={101: os.path.join(os.path.dirname(os.path.abspath(__file__)), "images", "lv_check_graphs.png")},
    notes="""
(2 min) Screenshot of the completed worksheet in Excel (D15:K30), so students compare like with like. If a sheet does not settle at (720, 640): check the $ signs in the formulas, and that each formula uses its own species' K in the denominator.
Equilibrium by hand: N~1~* = (K~1~ − αK~2~)/(1 − αβ) = (1200 − 750)/0.625 = 720; N~2~* = (K~2~ − βK~1~)/(1 − αβ) = (1000 − 600)/0.625 = 640.
The R version of this figure (02_check_sheet.R) is kept in figures/ but no longer used in the deck.
""")

new("Title & Photo", {100: "What your phase graph can show",
                      102: "Solid: species 1 (K~1~, K~1~/α). Dashed: species 2 (K~2~, K~2~/β). Filled circle: stable equilibrium. Open circle: unstable."},
    pictures={101: F + "03_four_outcomes.png"},
    notes="""
Reference for Part 3 (put it up if pairs are stuck). Read each case by asking which line is further out on each axis.
1. Species 1's isocline is outside species 2's everywhere: K~1~ > K~2~/β and K~1~/α > K~2~. Species 1 wins.
2. The reverse: species 2 wins.
3. They cross, with K~1~ < K~2~/β and K~2~ < K~1~/α: stable coexistence where they cross.
4. They cross the other way: the crossing point is unstable, and whichever side the populations start on decides the winner.
Illustrative values, analytical schematic, script 03_four_outcomes.R.
""")

new("Section", {102: "", 103: "Answers: try first"},
    notes="Show at the end of session 2. The answers use the parameter values of the book's solutions chapter, so students reviewing the slides afterwards see the same numbers.")

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

new("Figure & Bullets", {100: "Q5 (optional): flour beetles",
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

prs.save(OUT)
print("saved", OUT, len(prs.slides), "slides")
