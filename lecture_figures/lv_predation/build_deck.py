"""Build 'BB512 - Lotka Volterra Predator Prey Practical v2' from BB512_Theme.pptx.
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

F = "figures/"
import os

def code_line(slide, text, top, size=20, left=0.8):
    tb = slide.shapes.add_textbox(Inches(left), Inches(top), Inches(11.8), Inches(0.5))
    tb.text_frame.word_wrap = True
    p0 = tb.text_frame.paragraphs[0]; p0.alignment = PP_ALIGN.LEFT
    r0 = p0.add_run(); r0.text = text
    r0.font.name = "Menlo"; r0.font.size = Pt(size); r0.font.color.rgb = FOREST
    return tb

# ---------------------------------------------------------------- 1 Title
new("Title", {103: ("Lotka-Volterra predator-prey dynamics", 40),
              104: "Why do predators and prey cycle, and what stops them?"},
    notes="""
Leave this up while students settle, then go straight to the next slide. The deck is reference only: no lecture (they have had Thomas's Predation 1 and 2). Students work from the online book; the slides show what they should see.
No title photo yet: drop a licensed photo (e.g. lynx and snowshoe hare) into the picture placeholder and record the credit here.
""")

# ---------------------------------------------------------------- 2 The task
new("Activity", {101: "2 SESSIONS · PAIRS",
                 102: "Work through the Lotka-Volterra predator-prey practical in the online book",
                 103: (["Session 1: Part 1 (build the model) and Part 2 (explore it)",
                        "Session 2: Part 3 (prey carrying capacity), Part 4 (prey refuge) and Part 5 (the questions)",
                        "Predict before you change anything",
                        "Check your work against the next slides"], 22)},
    notes="""
Leave this slide up while students work. Everything they need is in the book chapter: the worksheet download, the prey formula for B12, the Part 2 tasks, Parts 3 and 4 and the questions.
Part 1 (about 10 min): predator formula in C12 is =MAX(0,C11+$F$8*($F$6*B11*C11-$F$7*C11)); copy to row 3011; check t = 1 gives (1050, 19.6). Common errors: missing $ signs; using a instead of c for predator births; forgetting dt.
Part 2 (about 25 min), answers: prey peak first, predators about a quarter of a cycle later, anticlockwise; equilibrium (1250, 25); dt = 1 prey extinct at t = 220, dt = 0.5 still grows, dt = 0.1 almost closed; doubling r, a, c, d moves P* to 50, 12.5 and H* to 625, 2500. Make sure every pair tries dt = 0.1.
Session 2: Part 3 formula =MAX(0,B11+$F$8*($F$4*B11*(1-B11/$F$9)-$F$5*B11*C11)), check t = 1 gives H = 925. Keep dt = 1.
""")

I = os.path.join(os.path.dirname(os.path.abspath(__file__)), "images")

new("Title & Photo", {100: "Your worksheet",
                      102: "Yellow: your formulas (B12, C12). Orange: the parameters you change."},
    pictures={101: os.path.join(I, "pp_worksheet_blank.png")},
    notes="""
Screenshot of the student worksheet as downloaded (Excel, Mac), sheet Part 1 Basic model, A1:L12, padded to the picture frame. Show it with the task slide so students can find their way around: the two yellow cells are the only ones they type in for Part 1; after that they change only the orange cells (and, for the equilibrium task, the starting numbers in B11 and C11). The isocline block (B4:C8) feeds the phase graph; the two graphs sit side by side from D13.
""")

new("Title & Photo", {100: "Check your sheet",
                      102: "t = 1: H = 1050, P = 19.6. With dt = 1 the cycles grow, and the prey hit zero at t = 220."},
    pictures={101: os.path.join(I, "pp_check_graphs.png")},
    notes="""
(1 min) Screenshot of the completed worksheet in Excel (D13:O28, default values, dt = 1), so students compare like with like. t = 2 gives H = 1106.7, P = 19.286. The cycles grow until the prey hit zero at t = 220 (they almost do at t = 167, when only about 2 prey are left); the predators then dwindle. In the phase plane the trajectory spirals out from the isocline crossing at (1250, 25).
The R version of this figure (02_check_sheet.R) is kept in figures/ but no longer used in the deck.
""")

new("Figure & Bullets", {100: "What your phase graph can show",
                         102: (["Prey isocline: P = r/a",
                                "Predator isocline: H = d/c",
                                "+ and − show which way each population changes",
                                "Equilibrium where the lines cross: (1250, 25)"], 19)},
    pictures={101: F + "01_isoclines.png"},
    notes="""
Reference for Part 2 (put it up if pairs are stuck on the direction of the cycles). Right, up, left, down: anticlockwise with prey on the x-axis. Predators peak about a quarter of a cycle after the prey.
Drawn with the worksheet values (r/a = 25, d/c = 1250). Analytical schematic, script 01_isoclines.R.
""")

new("Section", {102: "", 103: "Answers: try first"},
    notes="Show at the end of each session (Part 2 answers after session 1; Parts 3 and 4 after session 2). The numbers match the book's solutions.")

new("Title, Bullets & Photo", {100: "Predators lag a quarter of a cycle",
                               103: "WHY",
                               105: ("Prey grow while predators are scarce; predators then grow on the plentiful prey, push the prey down, and starve. One cycle is about 40 time units (2π/√(rd) = 39.7).", 18)},
    pictures={101: F + "04_answer_cycles.png"},
    notes="""
(2 min) Task 1. With dt = 0.1 (close to the continuous model): prey peaks at t = 13.8, 54.0, 94.2; predator peaks at 22.4, 62.5, 102.7. With dt = 1 the peaks are at 15, 56, 99 and 23, 64, 106.
Phase plane: anticlockwise (slide on the isoclines).
Task 2: starting exactly at (1250, 25) nothing changes.
Deterministic simulation, script 04_answer_cycles.R.
""")

new("Title & Photo", {100: "The time step makes the cycles grow",
                      102: "300 time units; right panel zoomed in. dt = 1: prey extinct at t = 220. dt = 0.1: cycles hardly change size."},
    pictures={101: F + "03_time_step.png"},
    notes="""
(3 min) Task 3. Each step uses the numbers at the start of the step, so each population reacts too late and overshoots a little more every cycle. Near the equilibrium the distance from it grows by about √(1 + dt²rd) per step: 1.012 (1.2 %) with dt = 1, and almost nothing with dt = 0.1.
dt = 0.5: still grows, no extinction within 300 time units (prey 26 to 5786). dt = 0.1: prey 668 to 2123 over 300 time units.
The continuous model (lecture) has neutrally stable cycles: their size is set by the starting numbers. A small dt is just a more accurate way of calculating it.
Deterministic simulations, script 03_time_step.R.
""")

new("Title & Photo", {100: "Each parameter moves one isocline",
                      102: "Grey: worksheet values. r and a set the prey isocline (P* = r/a); c and d set the predator isocline (H* = d/c)."},
    pictures={101: F + "05_answer_isoclines.png"},
    notes="""
(2 min) Task 4. Doubling r: P* 25 to 50. Doubling a: P* 25 to 12.5. Doubling c: H* 1250 to 625. Doubling d: H* 1250 to 2500.
Because the start (1000, 20) is then a different distance from the new equilibrium, the cycles also change size.
Optional task 5 (Volterra's principle): r = 0.2 and d = 0.12 move the equilibrium to H* = 1500 (more prey) and P* = 20 (fewer predators).
Analytical schematic, script 05_answer_isoclines.R.
""")

new("Title, Bullets & Photo", {100: "Carrying capacity damps the cycles",
                               103: "WHY",
                               105: ("With K = 2000 the populations settle at H = 1250, P = 9.4, where the sloping prey isocline meets H = d/c. Prey self-limitation removes the overshoot.", 18)},
    pictures={101: F + "06_prey_K.png"},
    notes="""
(2 min) P* = (r/a)(1 − H*/K) = 25 × (1 − 1250/2000) = 9.375. Within 1 % of the equilibrium by about t = 66. This happens even with dt = 1.
Deterministic simulation, script 06_prey_K.R.
""")

new("Title & Photo", {100: "Richer prey environments are less stable",
                      102: "K below d/c: the predators cannot persist. Larger K: more predators at equilibrium, and slower damping."},
    pictures={101: F + "07_K_values.png"},
    notes="""
(2 min) K = 1000 < 1250: the prey can never reach the 1250 the predators need; predators fall to about 0.6 by t = 100 and the prey settle at K.
K = 5000: P* = 18.75, settled by about t = 123. K = 10000: P* = 21.875, still cycling slightly at t = 300. Part of this slow settling comes from dt = 1 (with dt = 0.1 it settles faster), but the direction holds in the continuous model too: the larger K, the weaker the damping. H* stays at 1250: enrichment helps the predators, not the prey.
This is the idea behind the paradox of enrichment (Neal), which is much stronger with a Type II functional response (Thomas's lecture).
Deterministic simulations, script 07_K_values.R.
""")

new("Title & Photo", {100: "Refuges stop extinction and damp cycles",
                      102: "Prey (log scale), dt = 1. H~r~ = 0: extinct at t = 220; 100: cycles, no extinction; 400: settles at (1650, 33)."},
    pictures={101: F + "08_refuge.png"},
    notes="""
(2 min) The predators need d/c = 1250 catchable prey, so the predator isocline moves to H = H~r~ + d/c. The prey isocline becomes P = rH/(a(H − H~r~)), rising steeply near H~r~.
H~r~ = 200: cycles shrink (prey 1210 to 1732 in the last 100 time units), equilibrium (1450, 29). H~r~ = 400: within 1 % of (1650, 33) by t = 186.
Deterministic simulations, script 08_refuge.R.
""")

# Safety: no slide numbers (BB512 rule)
prs.save(OUT)
print("saved", OUT, len(prs.slides), "slides")
