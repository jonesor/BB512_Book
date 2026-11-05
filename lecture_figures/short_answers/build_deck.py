"""Build the short-answer practical deck ("Writing short answers") from BB512_Theme.pptx.
Run from this folder:  python3 build_deck.py <path/to/BB512_Theme.pptx> <out.pptx>
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

def new(layout, fields=None, notes=None, pictures=None, number=False, hidden=False):
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
        add_slide_number(slide)  # off by default: slide numbers not wanted on these slides
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


F = "figures/"

QUESTION_HD = ("Compare how haploid and diploid genetic systems affect the response to selection. "
               "Give an example of a trait under selection in each, and explain how the genetic "
               "system affects the speed of evolutionary change.")
PARAS = [
    ["Haploid systems respond to selection more quickly than diploid systems, because in a diploid an allele can be hidden from selection in heterozygotes.",
     "In a haploid organism every allele is expressed, so selection acts on a new advantageous mutation as soon as it appears.",
     "For example, drug resistance in *Mycobacterium tuberculosis*, a haploid bacterium, can evolve within a single patient, helped by short generation times and very large population sizes.",
     "In a haploid, then, the speed of change is set by the strength of selection and the supply of new mutations, not by dominance."],
    ["In a diploid, the speed of change depends on dominance, and a favoured dominant allele spreads fastest while it is rare.",
     "This is because it is expressed in heterozygotes, which carry almost all the copies of a rare allele: the dominant *carbonaria* allele of the peppered moth rose from about 1% to 99% of moths near Manchester in about 50 generations, which needs selection of about *s* = 0.3 against the pale form.",
     "However, a dominant allele slows down near fixation, because the last copies of the recessive allele hide in heterozygotes."],
    ["A favoured recessive allele shows the opposite pattern.",
     "While it is rare it occurs almost only in heterozygotes, where it is not expressed, so it can take thousands of generations to start spreading, but once it is common it goes to fixation quickly.",
     "Dominance therefore decides whether change in a diploid is slow at the start or at the end, a delay that haploids never have."],
]
def roles(n):
    return ["topic"] + ["support"] * (n - 2) + ["concl"]

def paragraph_slide(title, highlight, notes, size=15):
    s = new("Title Only", {100: title}, notes=notes)
    tb = s.shapes.add_textbox(Inches(0.8), Inches(1.95), Inches(11.73), Inches(4.7))
    tf = tb.text_frame; tf.word_wrap = True
    for pi, sents in enumerate(PARAS):
        par = tf.paragraphs[0] if pi == 0 else tf.add_paragraph()
        par.line_spacing = 1.08
        par.space_after = Pt(8)
        for i, (txt, role) in enumerate(zip(sents, roles(len(sents)))):
            hl = highlight is None or role == highlight
            col = (INK if highlight is None else CLAY) if hl else GREY
            add_runs(par, txt + (" " if i < len(sents) - 1 else ""), size=size, color=col,
                     bold=(highlight is not None and hl))
        for r in par.runs:
            r.font.name = FONT
    return s

# ---------------------------------------------------------------- 1 Title
new("Title", {103: "Writing short answers",
              104: "How do you show the examiner what you know?"},
    pictures={100: F + "01_title_paragraph.png"},
    notes="""
(0.5 min) Practical for Day 13, after the lecture on haploid and zygotic selection. Practice for the short-answer part of the exam (the other part is multiple choice).
Plan for 40 minutes (leaving 5 minutes of slack in a 45-minute slot): about 9 minutes of slides, 10 minutes marking three example answers, 15 minutes writing an answer and 5 minutes peer-marking. Slides 3 (Key Concept) and 7 (2-minute pairs activity) are skipped to save time; unskip them if the group is quick.
Everything here is also in the course book chapter "Writing Short Answers", The examiner's marks and the model answer are NOT in the course book (it is public): the marks are on the slide after the marking activity, and a full write-up is a PDF in itslearning Resources > Practice Exams, set to appear after the session.
Title image: schematic of a paragraph (topic sentence, supporting sentences, concluding sentence), scripts/01_paragraph_graphics.R. Not data.
""")

# ---------------------------------------------------------------- 2 Objectives
new("Agenda", {101: "Writing short answers",
               103: ["Break a question into its parts, and use its verbs to decide what each part needs",
                     "Plan an answer before writing it",
                     "Write paragraphs with a topic sentence, support and a conclusion",
                     "Use precise terms and specific examples",
                     "Mark an answer against a rubric, and use the rubric to improve your own"]},
    notes="""
(0.5 min) The first four objectives are sections 01 and 02; the last is section 03, where students mark three answers and then each other's.
""")

# ---------------------------------------------------------------- 3 Key concept
new("Key Concept", hidden=True, fields={102: "Short-answer question",
                    103: "A question answered in a paragraph or two of your own writing. It tests whether you understand the key terms and concepts, and whether you can explain them clearly.",
                    105: "Knowing is not enough: you need to show the examiner that you know."},
    notes="""
(1 min) From the original deck's "What are they?" slide. Examiners can only mark what is on the page: a correct idea that is never stated earns nothing.
""")

# ---------------------------------------------------------------- 01
new("Section", {102: "01", 103: "What examiners look for"},
    notes="(10 s)")

new("Title & Bullets", {100: "What examiners look for",
                        101: (["**Read the question twice.** Underline each part, and answer every part",
                              "**Look at the verbs.** *Define*, *describe*, *explain*, *compare* and *contrast* each ask for something different",
                              "**Plan first.** Two minutes listing your points beats a brain-dump",
                              "**Answer first.** Your first sentence should answer the question",
                              "**Be precise:** the right terms, and specific examples (a named organism, and what was found)",
                              "**Keep to time.** A long answer to one question can cost you another"], 20)},
    notes="""
(1.5 min) Revised from the original "General strategies" slide ("RTFQ" written out; "answer the specific question" folded into reading the question and planning).
Verbs: define = precise meaning; describe = what happens; explain = why or how it happens; compare = similarities and differences, side by side; contrast = differences only.
Answer first: students often spend the first paragraph on background; the examiner should not have to hunt for the point.
Specific example: "a bird" is not specific; "copper-tolerant common bent grass on a small copper mine in Wales" is. The lecture and textbook examples are ideal because students know what was found.
""")

new("Two Columns", {100: "Precise terms show what you know",
                    101: "PRECISE",
                    103: (["Gene flow is the movement of alleles from one population into the gene pool of another, through immigrants that breed there or gametes, such as pollen, that fertilise there.",
                          "*Defines the term, states the condition (they must breed), and covers plants.*"], 20),
                    104: "VAGUE",
                    106: (["Gene flow is when animals move to a new place and take their genes with them.",
                          "*Describes migration, misses the need to breed, and leaves out plants.*"], 20)},
    notes="""
(1 min) Replaces the original yeast example ("facultatively anaerobic") with a definition from the course: the migration lecture's key concept, "migration is not gene flow". It also previews the question students mark in section 03.
Ask: which of these would you rather mark? What exactly is missing from the right-hand one?
""")

new("Activity", hidden=True, fields={101: "2 MIN · PAIRS",
                 102: ("What does each part of this question ask you to do?", 34),
                 103: (["“Define gene flow and explain how it differs from migration. Explain how gene flow can both help and hinder a population's adaptation to local conditions, giving a specific example. Explain why very few migrants per generation are enough to stop populations diverging by genetic drift, but many more are needed to swamp local adaptation.”",
                       "Underline the verbs. How many parts are there? What would a complete answer need?"], 20)},
    notes="""
(2 min) Answer: three parts (some would say five tasks). (1) Define gene flow AND explain the difference from migration. (2) Explain how gene flow helps AND hinders local adaptation, with a specific example. (3) Explain WHY a few migrants stop drift but many more are needed to swamp selection.
A complete answer needs something for every verb. The "both help and hinder" and "why" are where most marks are lost.
This is the question students mark in section 03 (course book chapter "Writing Short Answers"). Content from the migration lecture: Nm ≈ 1 versus m ≈ s; copper-tolerant grass; genetic rescue.
""")

# ---------------------------------------------------------------- 02
new("Section", {102: "02", 103: "Paragraph structure"},
    notes="(10 s)")

s = new("Figure & Bullets", {100: "Anatomy of a paragraph",
                             102: (["**Topic sentence:** states the main idea; read alone, the topic sentences outline the answer",
                                   "**Supporting sentences:** explain and give evidence; each one backs up the topic sentence",
                                   "**Concluding sentence:** says what follows, qualifies, or links on; never just a repeat",
                                   "One main point per paragraph, and no longer than it needs to be"], 20)},
        pictures={101: F + "02_paragraph_anatomy.png"},
        notes="""
(1.5 min) Combines the original "Paragraph structure" and "Anatomy of a paragraph" slides. The bars are a schematic paragraph: topic sentence (dark green), supporting sentences (blue), concluding sentence (gold); the label colours on the right match.
Concluding sentence: the common fault is repeating the topic sentence, which costs exam time and earns nothing. In a short paragraph it can be left out. "At least three sentences" is a rough guide, not a rule: padding to reach it does not help.
Figure: scripts/01_paragraph_graphics.R (schematic, not data).
""")
# colour the three labels to match the bars
body = ph(s, 102)
for par, col in zip(body.text_frame.paragraphs[:3], [FOREST, RGBColor(0x3E, 0x6E, 0x7E), GOLD]):
    par.runs[0].font.color.rgb = col

new("Statement", {101: (QUESTION_HD, 30), 103: "A worked example: three paragraphs, one point each"},
    notes="""
(0.5 min) Ask students to spot the verbs before moving on: compare; give an example of each; explain the effect on speed. The question matches the lecture on haploid and zygotic selection that precedes this practical.
""")

paragraph_slide("A worked answer", None, """
(1 min) Let students read it in silence first. Three paragraphs, one point each: haploids; dominant alleles in diploids; recessive alleles in diploids. The first sentence answers the question (haploids respond faster) and says why.
Rewritten from the original deck's example. Changes: the haploid example is now drug resistance in Mycobacterium tuberculosis (from the selection lecture) instead of unnamed "certain drugs" in yeast (yeast is often diploid); the diploid example is now the peppered moth (carbonaria dominant, about 1% to 99% in about 50 generations, s about 0.3 against typica, Haldane via Neal) instead of a hypothetical drought-resistance allele; and it now makes the lecture's key point that dominance sets the speed (a favoured dominant spreads fast while rare but slowly to fixation; a favoured recessive is slow while rare). The original concluding sentence ("a buffer... allowing for more complex interactions") was vague and is replaced.
""")

paragraph_slide("Topic sentence: the main idea", "topic", """
(0.5 min) Read only the three highlighted sentences: they outline the whole answer. The first also answers the question directly.
""")

paragraph_slide("Supporting sentences: the evidence", "support", """
(0.5 min) Each supporting sentence backs up its own topic sentence. Every general claim is followed by a specific example with numbers: tuberculosis for haploids; the peppered moth for a dominant allele.
""")

paragraph_slide("Concluding sentence: the take-home", "concl", """
(0.5 min) Each concluding sentence adds something rather than repeating its topic sentence: what follows (paragraph 1), a qualification (paragraph 2), and a link back to the comparison (paragraph 3).
""")

new("Title & Bullets", {100: "Why this answer works",
                        101: (["**It answers at once:** the first sentence says haploids respond faster, and why",
                              "**Every claim has a specific example,** with numbers: tuberculosis; *carbonaria*, 1% to 99% in about 50 generations",
                              "**It uses the right terms correctly:** haploid, diploid, dominant, recessive, heterozygote, fixation",
                              "**One point per paragraph:** the topic sentences alone outline the answer, so it is quick to mark"], 20)},
    notes="""
(0.5 min) A well-structured answer is easier to assess, which keeps the examiner happy (from the original model-answer page on itslearning).
""")

# ---------------------------------------------------------------- 03
new("Section", {102: "03", 103: "Practise"},
    notes="(10 s)")

new("Activity", {101: "10 MIN · ON YOUR OWN, THEN PAIRS",
                 102: ("Mark three answers to the gene flow question", 34),
                 103: ["Open the chapter *Writing Short Answers* in the course book",
                       "Mark answers A, B and C with the rubric, on your own",
                       "Agree marks with a partner. The examiner's marks come next",
                       "Where you disagree, find the rubric line that decides it"]},
    notes="""
(10 min, including the marks slide that follows) Examiner's marks: A 4/10 (mediocre), B 10/10 (model), C 1/10 (poor). Give pairs about 8 minutes, then show the next slide.
The commonest disagreement is the definition: an answer that only talks about individuals moving, and never about them breeding, has not defined gene flow.
Changes from the itslearning version: the speciation part of the question was replaced (the migration lecture does not cover speciation) with the lecture's guiding question about drift versus selection; the model answer uses lecture examples (salmon, copper-mine grass, Florida panther genetic rescue); the rubric's Mechanisms criterion was replaced by Differs from migration (the question never asked how gene flow happens), structure is marked separately from examples, and a factual error caps a criterion at 1.
Debrief prompt: B scores 10/10, but which paragraph could go without losing a mark? (The second, on how gene flow happens: not asked for.)
""")

new("Title & Bullets", {100: "The examiner's marks",
                        101: (["**Answer A: 4/10.** Describes animals moving, not alleles entering a gene pool; never says how gene flow differs from migration; only one side of local adaptation; the wrong reason for drift versus selection",
                              "**Answer B: 10/10.** Every part answered, with specific examples (salmon, Florida panther, copper-mine grass) and the reason: *Nm* ≈ 1 versus *m* ≈ *s*. But its paragraph on how gene flow happens earns nothing: the question did not ask for it",
                              "**Answer C: 1/10.** Treats gene flow as migration; the penguin example is about individuals, not allele frequencies; drift happens in all populations, not only small ones"], 18)},
    notes="""
(2 min, inside the 10 minutes for marking) Show once pairs have agreed their marks. Ask: who gave A more than 6, and why? Which paragraph could B lose without losing a mark? The commonest disagreement is the first two criteria: an answer that talks only about individuals moving, never about them breeding, has neither defined gene flow nor said how it differs from migration. The full explanation is in the itslearning PDF released after the session.
""")

new("Activity", {101: "15 MIN · ON YOUR OWN",
                 102: ("Explain how adaptive and neutral evolution differ, and give an example of each", 30),
                 103: ["Plan for 2 minutes, then write for 13 (about 250 words). No notes",
                       "Write in a document on your laptop. Nothing to hand in",
                       "Swap laptops with a neighbour, or email them your answer, and mark theirs with the rubric on screen (5 min)"]},
    notes="""
(15 min + 5 min) Full question and rubric are in the course book chapter. Students do not submit anything: the itslearning assignment is not used. The rubric has five criteria worth 2 points each, in the same format as the gene flow rubric: adaptive evolution; neutral evolution; where they differ; examples, explained; structure. Model answer, marked 10/10 against the same rubric, in the itslearning PDF released after the session: about 220 words in three paragraphs; each process defined by its cause; two differences (direction, outcome); peppered moth as adaptive; synonymous sites as neutral. The question asks for two differences only; s versus 1/(2Ne) is a good extra, not required.
Common ways to lose marks: treating "neutral" as "does not evolve"; using a trait with little heritable variation (fingerprint detail) as an example of neutral evolution; never saying where the two differ; examples without explanation.
Builds on Monday's practical (Neutral or Adaptive Evolution in Humans), which covers the definitions, s versus 1/(2Ne), synonymous sites and non-heritable traits such as fingerprint detail. Human examples from that practical (for example, lactase persistence) are good adaptive examples.
""")

new("Title & Bullets", {100: "Mark with this rubric",
                        101: (["**Adaptive evolution.** 2: change caused by selection, consistent in direction, makes adaptations · 1: vague, or no cause · 0: wrong",
                              "**Neutral evolution.** 2: change caused by drift, in variants with little effect on fitness, random in direction · 1: partly right, or no cause · 0: wrong",
                              "**Where they differ.** 2: at least two differences (direction, outcome, *s* vs 1/(2*N*~e~)) · 1: one, or only implied · 0: none",
                              "**Examples, explained.** 2: one of each, each explained · 1: named but not explained, or only one · 0: none suitable",
                              "**Structure.** 2: first sentence answers; one point per paragraph; right terms · 1: loose or repetitive · 0: disorganised",
                              "*A factual error caps a criterion at 1. Then add one sentence: the biggest fix.*"], 16)},
    notes="""
(Shown during the 5 minutes of peer marking, already counted on the previous slide.) Swap laptops with a neighbour, or email the answer; students who would rather not share mark their own answer. Leave this slide up while they mark. Full rubric in the course book chapter; model answer (10/10) in the itslearning PDF released after the session.
""")

new("Summary", {101: "Key points",
                102: ["Answer every part of the question, and let the verbs tell you what each part needs",
                      "Plan, then answer the question in your first sentence",
                      "One point per paragraph, ending on something new, not a repeat",
                      "Precise terms, backed by specific examples"],
                106: ["Course book: *Writing Short Answers*",
                      "itslearning, after the session: marks explained and a model answer"]},
    notes="""
(0.5 min) Further help (moved here from the original "Some resources" slide):
University of Melbourne Academic Skills, "Managing short answer exams: Writing short answer questions in the Sciences" (PDF): http://services.unimelb.edu.au/__data/assets/pdf_file/0010/489124/Managing_short_answer_exams_in_Science_Update_051112.pdf (checked 1 Nov 2026: available).
Not checked or no longer available: University of Melbourne "Building good paragraphs" page (returned an error on 1 Nov 2026); UW-La Crosse "Answering essay questions" (could not be checked); YouTube video GOV9EMm3e24 (not checked).
""")

prs.save(OUT)
print("saved", OUT, len(prs.slides), "slides")
