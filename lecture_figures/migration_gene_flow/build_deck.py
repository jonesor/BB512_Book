"""Build BB512 Lecture 12 (Migration, gene flow and differentiation) from BB512_Theme.pptx.

Inline markup in slide text:
  _{x}  subscript     ^{x}  superscript     *x*  italic     **x**  bold
"""
import copy
import re
from pptx import Presentation
from pptx.util import Pt, Inches, Emu
from pptx.dml.color import RGBColor
from pptx.oxml.ns import qn

THEME = "BB512_Theme.pptx"
OUT = "BB512_12_Migration_and_gene_flow.pptx"
FIG = "/home/claude/work/BB512_Book/lecture_figures/migration_gene_flow/figures/"
MED = "/home/claude/work/orig/media/"

SLIDE_NUMBERS = False  # set True to show slide numbers

prs = Presentation(THEME)

# --- remove the theme's sample slides -------------------------------------
sldIdLst = prs.slides._sldIdLst
for sldId in list(sldIdLst):
    prs.part.drop_rel(sldId.rId)
    sldIdLst.remove(sldId)

L = {l.name: l for l in prs.slide_layouts}

TOKEN = re.compile(r"(\*\*.+?\*\*|_\{.+?\}|\^\{.+?\}|\*.+?\*)")


def add_runs(par, text, size=None, color=None):
    """Write text with the inline markup into paragraph `par`; '\n' = line break."""
    chunks = text.split("\n")
    for k, chunk in enumerate(chunks):
        if k:
            par.add_line_break()
        _add_runs(par, chunk, size, color)


def _add_runs(par, text, size=None, color=None):
    for part in TOKEN.split(text):
        if not part:
            continue
        r = par.add_run()
        if part.startswith("**"):
            r.text = part[2:-2]
            r.font.bold = True
        elif part.startswith("_{"):
            r.text = part[2:-1]
            r.font._rPr.set("baseline", "-25000")
        elif part.startswith("^{"):
            r.text = part[2:-1]
            r.font._rPr.set("baseline", "30000")
        elif part.startswith("*"):
            r.text = part[1:-1]
            r.font.italic = True
        else:
            r.text = part
        if size:
            r.font.size = Pt(size)
        if color:
            r.font.color.rgb = RGBColor.from_string(color)


def fill(ph, lines, size=None, level_map=None):
    if size is None and ph.placeholder_format.idx == 105 and ph.part.slide_layout.name == "Title, Bullets & Photo":
        size = 18
    """Fill a text placeholder. `lines` is a string or list; a leading '- ' makes level 1."""
    if isinstance(lines, str):
        lines = [lines]
    tf = ph.text_frame
    tf.clear()
    first = True
    for line in lines:
        par = tf.paragraphs[0] if first else tf.add_paragraph()
        first = False
        lvl = 0
        if line.startswith("- "):
            lvl, line = 1, line[2:]
        par.level = lvl
        add_runs(par, line, size=size)


def ph(slide, idx):
    for p in slide.placeholders:
        if p.placeholder_format.idx == idx:
            return p
    raise KeyError(idx)


def add_slide_number(slide):
    layout = slide.slide_layout
    for sp in layout.placeholders:
        if sp.placeholder_format.type is not None and "SLIDE_NUMBER" in str(sp.placeholder_format.type):
            slide.shapes._spTree.append(copy.deepcopy(sp._element))
            return


def notes(slide, text):
    slide.notes_slide.notes_text_frame.text = text


def new(layout_name):
    s = prs.slides.add_slide(L[layout_name])
    if SLIDE_NUMBERS:
        add_slide_number(s)
    return s


def picture(slide, idx, path):
    ph(slide, idx).insert_picture(path)


def textbox(slide, x, y, w, h, lines, size=16, color="1F2623", bold_first=False):
    tb = slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
    tf = tb.text_frame
    tf.word_wrap = True
    for i, line in enumerate(lines):
        par = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        par.space_after = Pt(6)
        add_runs(par, line, size=size, color=color)
    return tb


# ===========================================================================
# 1 Title
s = new("Title")
fill(ph(s, 103), "Migration, gene flow and the differentiation of populations", size=34)
fill(ph(s, 104), "Why do some populations stay genetically alike while others drift apart?")
picture(s, 100, MED + "s02_126.jpg")
notes(s, """~0.5 min.
Lecture 12 of BB512. Reading: Neal (2004) Chapter 9, plus section 8.4 (drift versus migration) from the previous chapter.
Guiding question (why do some populations stay genetically alike while others drift apart?), to come back to at the end: very few migrants are needed (roughly one per generation) to stop drift pulling populations apart, but far more are needed to swamp local adaptation.
Image: dandelion seed head (wind dispersal), carried over from the previous version of this lecture. Source and licence not recorded in the old deck: CHECK before sharing slides outside the course.""")

# 2 Learning objectives
s = new("Agenda")
fill(ph(s, 101), "Migration and gene flow")
fill(ph(s, 103), [
    "Distinguish migration from gene flow, and define the migration rate *m*.",
    "Use island models to predict how gene flow changes allele frequencies over time.",
    "Explain how gene flow limits divergence by drift and local adaptation by selection.",
    "Explain how clines form where gene flow meets spatially varying selection.",
    "Quantify population structure with F-statistics, and explain what F_{ST} can and cannot tell us about gene flow.",
], size=20)
notes(s, """~1 min.
Objective 1 = Section 01; objectives 2 and 3 = Section 02 (island models, migration-selection balance); objective 4 = Section 03 (stepping stones and clines); objective 5 and the drift part of objective 3 = Section 04.
The textbook chapter (Neal Ch. 9) covers sections 01-03. Section 04 (F-statistics, F_ST and N_e m) goes beyond Neal Ch. 9 but builds directly on the inbreeding coefficient F from the previous lecture (Neal 8.5) and on Neal 8.4.""")

# 3 Section 01
s = new("Section")
fill(ph(s, 102), "01")
fill(ph(s, 103), "Migration is not gene flow")
notes(s, "Transition. ~0.2 min.")

# 4 Globe skimmer
s = new("Figure & Bullets")
fill(ph(s, 100), "A dragonfly that crosses oceans")
picture(s, 101, "pantala_composite.jpg")
fill(ph(s, 102), [
    "The globe skimmer (*Pantala flavescens*) migrates thousands of kilometres, over several generations.",
    "Populations on different continents are genetically almost identical.",
    "Its genes travel, not just its bodies: close to one worldwide gene pool.",
], size=20)
notes(s, """~2 min.
Ecologists ask why and how far animals move. Population geneticists ask a different question: do the movers breed where they arrive, so that their alleles enter another gene pool? (Neal Ch. 9 introduction.)
Troast et al. (2016) PLoS ONE 11: e0148949 found very similar genetic profiles in globe skimmers from North America, South America and Asia, consistent with gene flow across oceans and a common worldwide gene pool.
The map shows the species' global distribution (it does not show migration routes).
Images carried over from the previous version: photo of a male in flight and a distribution map (Wikimedia Commons, '1920px-Pantala_flavescens_distribution_map.svg.png'). Record photographer and licence (probably CC BY-SA) before sharing outside the course.""")

# 5 Moving is not gene flow
s = new("Two Columns")
fill(ph(s, 100), "Moving is not the same as gene flow")
fill(ph(s, 101), "LONG JOURNEYS, LITTLE GENE FLOW")
fill(ph(s, 103), [
    "Sockeye salmon (*Oncorhynchus nerka*) feed at sea for years, then return to breed in the stream where they hatched.",
    "What matters is the distance from birthplace to breeding place.",
])
fill(ph(s, 104), "GENE FLOW WITHOUT MOVING ADULTS")
fill(ph(s, 106), [
    "Pollen carried by wind or insects",
    "Seeds, spores and larvae",
    "Gametes released into water",
])
notes(s, """~1.5 min.
Salmon example from Neal Ch. 9 introduction: spectacular migrations, but strong natal homing means little gene flow between river populations.
Neal's key sentence: what is important is not how far individuals move, but how far they move from where they were born to where they produce offspring.
Right column: plants do not move as adults at all, yet can have high gene flow through pollen and seed. We will meet wind-borne pollen again in the copper-mine grass example.""")

# 6 Key concept: gene flow
s = new("Key Concept")
fill(ph(s, 102), "Gene flow")
fill(ph(s, 103), "The movement of alleles from one population into the gene pool of another, through migrants or gametes that survive and reproduce there.")
fill(ph(s, 105), "Migration rate *m* = the proportion of a population's breeders that are immigrants each generation. Immigrants that do not breed contribute nothing.")
notes(s, """~1 min.
Neal 9.1: m only counts immigrants that successfully breed and mix their alleles into the native gene pool, which is why it is hard to measure directly.
m is a proportion (e.g. 0.01 = 1% of breeders). Later we will use N_e m, which is a number of migrants per generation. Keep the two apart.""")

# 7 Section 02
s = new("Section")
fill(ph(s, 102), "02")
fill(ph(s, 103), "Island models")
notes(s, "Transition. ~0.2 min.")

# 8 Four models
s = new("Title, Bullets & Photo")
fill(ph(s, 100), "Four ways to model gene flow")
picture(s, 101, FIG + "08_four_models.png")
fill(ph(s, 103), "TAKEAWAY")
fill(ph(s, 105), [
    "The models differ only in who exchanges migrants with whom.",
    "1 and 2 ignore distance; in 3 and 4, most migrants move short distances.",
    "In 4 there are no separate populations; mates come from nearby.",
], size=17)
notes(s, """~1 min. Roadmap. Say aloud: we work through models 1 to 3 in detail; model 4 behaves much like a two-dimensional stepping-stone model.
1 Continent-island: one-way flow from a large source with fixed allele frequency q_m.
2 Island: every population exchanges migrants equally with every other; immigrants to an island come from the other islands (Neal Appendix 9.1). (Wright's version uses a pool that includes the recipient; with many islands the difference is negligible.)
3 Stepping-stone: migrants only move between neighbours (Neal 9.3).
4 Isolation by distance / neighbourhood models: continuous populations where mating probability declines with distance (Wright 1969; Neal Ch. 9 introduction). Neal mentions but does not simulate these; the results resemble the 2-D stepping-stone model.
Figure: schematic, scripts/08_four_models.R.""")

# 9 Model 1 set-up: the scenario
s = new("Figure & Bullets")
fill(ph(s, 100), "Model 1: a white field among yellow fields")
picture(s, 101, FIG + "09_continent_island_diagram.png")
fill(ph(s, 102), [
    "Continent: yellow-flowered sweet clover; yellow allele frequency q_{m} = 1.",
    "Island: one field of white-flowered clover, q_{0} = 0.",
    "Each generation, 5% of the field's breeders come from outside (*m* = 0.05).",
    "How fast does the field turn yellow? Does it ever stop?",
], size=20)
notes(s, """~1.5 min. Context before equations.
Neal Example 9.2: a farmer sows a pure line of white-flowered sweet clover surrounded by fields of homozygous yellow-flowered clover. Treat the field as the 'island' and the surrounding fields as the 'continent'. This is Neal's hypothetical illustration.
Notation follows Neal 9.1: q_0 = island ('native') allele frequency, q_m = frequency among immigrants, m = immigration rate (the proportion of the island's breeders that are immigrants).
Ask for predictions before moving on: does the field ever become completely yellow? (Yes, eventually, if nothing else acts.)
Neal also rearranges these equations to estimate m from allele frequencies (Eqn 9.3, Example 9.1); point students to it for reading, including Neal's caveats about selection and drift on the markers.
Figure: schematic, scripts/09_continent_island_diagram.R.""")

# 10 Model 1: one generation, counted
s = new("Figure & Bullets")
fill(ph(s, 100), "Model 1: one generation, counted")
picture(s, 101, FIG + "09b_one_generation_counted.png")
fill(ph(s, 102), [
    "95 residents keep their white alleles",
    "5 immigrants bring yellow alleles",
    "So the yellow allele is now at 5 in 100: q_{1} = 0.05",
    "**Neal Eqn 9.1:**\nq_{1} = (1 − *m*)q_{0} + *m*q_{m}\nresidents + immigrants",
], size=20)
notes(s, """~2 min.
Count, then name the parts. For simplicity every breeder is homozygous, so the proportion of breeders carrying the yellow allele equals its allele frequency.
q_1 = 0.95 x 0 + 0.05 x 1 = 0.05. The 0.95 is (1 - m): residents keep their alleles. The 0.05 is m: immigrants bring their alleles. This is Neal Eqn 9.1.
Nothing else operates here: no selection, no drift, no mutation.
Figure: schematic, scripts/09b_one_generation_counted.R.""")

# 11 Model 1: the gap shrinks
s = new("Figure & Bullets")
fill(ph(s, 100), "Model 1: each generation, the gap shrinks")
picture(s, 101, FIG + "09c_gap_shrinks.png")
fill(ph(s, 102), [
    "Each generation the gap to the mainland shrinks by 5%",
    "Big gap, big change; small gap, small change",
    "**Neal Eqn 9.2:**\nq_{t} − q_{m} = (1 − *m*)^{t}(q_{0} − q_{m})",
    "Worked examples: end of slides",
], size=20)
_src = ph(s, 102).text_frame.paragraphs[-1]
for _r in _src.runs:
    _r.font.size = Pt(14)
    _r.font.color.rgb = RGBColor.from_string("6E6F68")
notes(s, """~1.5 min.
The gap q_m - q_t starts at 1 and is multiplied by 0.95 each generation: 1, 0.95, 0.9025, 0.857... This is Neal Eqn 9.2 in words; the derivation is on Neal p. 137.
Also say: Delta q = m(q_m - q_0) (Neal Exp. 9.2): the change depends on the migration rate AND on how different the two populations are, so change is fast at first and slows as the gap closes.
Figure: analytical, scripts/09c_gap_shrinks.R.""")

# 12 Continent-island curve
s = new("Title, Bullets & Photo")
fill(ph(s, 100), "Model 1: the field turns yellow")
picture(s, 101, FIG + "10_continent_island_curve.png")
fill(ph(s, 103), "TAKEAWAY")
fill(ph(s, 105), [
    "Fast at first, then slower, because the gap shrinks",
    "Halfway (q = 0.5) after 13.5 generations",
    "*m* sets the speed; the field always heads towards q_{m}",
])
notes(s, """~1.5 min.
Solve 0.5 - 1 = (0.95)^t (0 - 1): 0.5 = 0.95^t, t = ln 0.5 / ln 0.95 = 13.5, about 14 generations (Neal Example 9.2).
q_1 = 0.05, q_2 = 0.0975, q_3 = 0.1426 (from the previous two slides).
The grey curves show m = 0.01 and m = 0.2: the rate sets the speed, but every curve heads to q_m = 1. Gene flow homogenises.
Figure: analytical (Eqn 9.2), scripts/10_continent_island_curve.R.""")

# 11 Your turn (sketch, not calculation)
s = new("Activity")
fill(ph(s, 101), "2 MIN · PAIRS")
fill(ph(s, 102), "Sketch q over time: an island starts at q = 0.75, the mainland is at 0.25.", size=28)
fill(ph(s, 103), [
    "Where does it end up?",
    "Is the change fast or slow at first? Why?",
    "What would a higher migration rate change, and what would it not change?",
])
notes(s, """~2 min including answers. A sketch, not a calculation: the calculation (Neal Problem 9.3) is a self-study worked example at the end of the slides.
Answers: it falls towards 0.25 (gene flow pulls towards the source, not towards 1); fastest at first because the gap is largest; higher m makes it faster but does not change where it ends up.""")

# 12 Check question: island model qm
s = new("Check Question (4 options)")
fill(ph(s, 101), "Model 2: three equal islands have q = 0.2, 0.4 and 0.6. Immigrants come from the other two. What q do they bring to the 0.2 island?", size=24)
fill(ph(s, 105), "0.2")
fill(ph(s, 109), "0.3")
fill(ph(s, 113), "0.4")
fill(ph(s, 117), "0.5")
notes(s, """~1.5 min. Answer D, 0.5.
In the island model each population receives migrants from all the others, so q_m is the mean of the DONOR populations: (0.4 + 0.6)/2 = 0.5 (Neal Example 9.3).
Common wrong answer C (0.4) is the mean of all three islands, including the recipient. That would be right in Wright's version of the island model, where migrants come from a pool to which every island contributes, which is why the stem says 'from the other two'. With only three islands the two versions differ noticeably; with many islands they converge.
If populations differ in size, the donors' frequencies must be weighted by size.
Neal applies Eqn 9.2 with q_m held fixed and gets 0.3954 for this island after 10 generations (m = 0.1); he notes this is an approximation because the q_m values themselves change every generation. Iterating properly (next slide's method) gives 0.36, with all three converging on the overall mean of 0.4.""")

# 13 Island model convergence
s = new("Title, Bullets & Photo")
fill(ph(s, 100), "Model 2: islands converge")
picture(s, 101, FIG + "13_island_model.png")
fill(ph(s, 103), "TAKEAWAY")
fill(ph(s, 105), [
    "Four islands, *m* = 0.1, each receiving the mean of the others",
    "All converge on the overall mean (0.5)",
])
notes(s, """~1.5 min.
Reproduces Neal Fig. 9.1 and Appendix 9.1 (the spreadsheet simulation): starting frequencies 0.2, 0.4, 0.6, 0.8; m = 0.1; equal sizes.
Neal's conclusion (9.2): gene flow makes populations genetically uniform, and this becomes more powerful as m increases (say this aloud; the figure shows only m = 0.1, and slide 10 showed the effect of m).
Then the question Neal asks next: gene flow beats drift easily (we come back to this in Section 04), but can it beat selection?
Figure: deterministic iteration of Eqn 9.1, scripts/13_island_model.R.""")

# 15 Migration-selection balance
s = new("Title, Bullets & Photo")
fill(ph(s, 100), "Windy island: migration–selection balance")
picture(s, 101, FIG + "15_migration_selection.png")
fill(ph(s, 103), "TAKEAWAY")
fill(ph(s, 105), [
    "Winged insects: fitness 1 − *s*; wings recessive",
    "Equilibrium: q ≈ √(*m*/*s*)",
    "*m* = 0.01, *s* = 0.25: q = 0.20; 4% winged",
    "Gene flow limits local adaptation (fit to local conditions)",
], size=17)
notes(s, """~3.5 min. Start with a prediction, before pointing at the figure.
Set-up (Neal 9.2, Fig. 9.2): all mainland insects are winged (q_m = 1); on the windy island winged insects tend to be blown out to sea, so they have fitness 1 - s with s = 0.25. The wing allele is recessive, so only q^2 of island insects have wings. 1% of the island's breeders arrive from the mainland each generation (m = 0.01).
Ask for a show of hands: does selection eliminate the wing allele, or does gene flow keep it at a substantial frequency? Most students expect elimination because s = 0.25 is strong selection. The figure shows why not.
Neal Exp. 9.10: loss by selection, s p q^2 / (1 - s q^2), balances gain by immigration, m(q_m - q). With q_m = 1 this simplifies to q-hat = sqrt(m/s) (Exp. 9.11).
m = 0.01, s = 0.25: q-hat = sqrt(0.04) = 0.20, so 1% immigration maintains 20% wing alleles despite strong selection. Because wings are recessive, only q^2 = 4% of insects are winged: the allele hides in heterozygotes.
m = 0.1: q-hat = 0.632; q^2 = 0.40.
Accuracy note: Neal reaches sqrt(m/s) by approximation, but it is exact if the island is counted after immigration (life cycle: selection, then immigration). Counted after selection instead, the equilibrium is (sqrt(m/s) - m)/(1 - m): 0.59 rather than 0.63 at m = 0.1, and 0.19 rather than 0.20 at m = 0.01. Solving Neal's unsimplified Exp. 9.10 gives 0.60 at m = 0.1. The conclusion is unchanged.
Different dominance changes the numbers but not Neal's conclusion: gene flow is a powerful factor limiting differentiation by selection.
Figure: analytical, checked by iterating the recursion; scripts/15_migration_selection.R.""")

# 16 Section 03
s = new("Section")
fill(ph(s, 102), "03")
fill(ph(s, 103), "Stepping stones and clines")
notes(s, "Transition. ~0.2 min.")

# 17 Stepping-stone set-up
s = new("Figure & Bullets")
fill(ph(s, 100), "Model 3: the stepping-stone model")
picture(s, 101, FIG + "17_stepping_stone_diagram.png")
fill(ph(s, 102), [
    "Populations in a line exchange migrants only with their neighbours (Neal Exp. 9.13).",
    "Each generation, every population mixes a little with the ones on either side.",
    "Selection holds the ends at q = 0.9 and 0.1. Predict the populations in between.",
], size=20)
notes(s, """~2 min.
Neal 9.3, Fig. 9.3 and Exp. 9.13 (for reference, not on the slide): q_1 = [1 - (m21 + m23)] q_0 + m12 q_m1 + m32 q_m3, written for population 2. Subscripts give direction: m12 is from population 1 into 2; m21 is from 2 into 1.
Examples of linear chains: altitude on a mountain, salinity along an estuary shoreline.
Ask students to sketch their prediction before the next slide.
Correction to previous version: the old diagram labelled two arrows m34; the left-pointing one should be m43.""")

# 18 Stepping-stone cline
s = new("Title, Bullets & Photo")
fill(ph(s, 100), "Model 3: a gradient between the ends")
picture(s, 101, FIG + "18_stepping_stone_cline.png")
fill(ph(s, 103), "TAKEAWAY")
fill(ph(s, 105), [
    "Equal migration: a straight-line gradient",
    "A barrier (low *m*): a steep section",
    "Cline: a gradual change in allele frequency or phenotype across space",
])
notes(s, """~2.5 min.
Name the pattern: a gradient like this is a cline. Its shape reflects the balance of selection, gene flow and drift; steep sections often mark barriers to movement or sharp changes in selection. Neal 9.3: intermediate populations on real clines are not set by migration alone; selection and possibly drift also act.
Reproduces Neal Fig. 9.4 and Appendix 9.2: nine populations, ends fixed at 0.9 and 0.1, m = 0.2 between neighbours; barrier = m reduced to 0.05 between populations 4-5 and 5-6. Shown at equilibrium.
Neal's conclusion: gene flow limits differentiation of adjacent populations, and abrupt changes are associated with geographical features that reduce movement.
Caveat: a steep step can also come from an abrupt change in selection, so a step alone does not prove a barrier.
Figure: deterministic iteration, scripts/18_stepping_stone_cline.R.""")

# 20 Agrostis set-up
s = new("Figure & Bullets")
fill(ph(s, 100), "Copper tolerance in a grass on a mine")
picture(s, 101, MED + "s16_466.jpg")
fill(ph(s, 102), [
    "Common bent (*Agrostis capillaris*; *A. tenuis* in older work) on a small copper mine in Britain",
    "On the mine: selection for copper tolerance",
    "Off the mine: tolerant plants are at a disadvantage",
    "Wind blows mostly one way, carrying pollen. Predict: upwind versus downwind?",
], size=20)
notes(s, """~1.5 min.
McNeilly (1968) Heredity 23: 99-108, 'Evolution in closely adjacent plant populations III. Agrostis tenuis on a small copper mine'; described in Neal 9.3.
The mine lies at the bottom of a steep-sided valley that funnels the wind in one direction for most of the flowering season.
Correction to previous version: it said that off the mine 'there has been no selection'. In fact tolerant plants are selected against off the mine (Neal p. 143), which is what keeps tolerance low there and explains the seed-adult difference on the next slide.
Image carried over from the previous version (filename 'Agrostis-capillaris_Flints_SHammonds.JPG'); record photographer and licence before sharing.""")

# 21 Copper tolerance data
s = new("Figure & Bullets")
fill(ph(s, 100), "Pollen carries tolerance downwind")
picture(s, 101, FIG + "21_copper_tolerance.png")
fill(ph(s, 102), [
    "**Seed**: offspring after gene flow (fathers via wind-borne pollen). **Adults**: survivors of selection.",
    "On the mine: non-tolerant pollen blows in, so seed is less tolerant; copper then kills non-tolerant seedlings.",
    "Downwind: tolerant pollen blows off the mine, so seed is more tolerant; on normal soil, tolerant plants do worse and are lost.",
    "Upwind: little pollen arrives, so the edge stays steep.",
    "Gene flow pulls one way, selection pulls back: the cline is the balance.",
], size=16)
notes(s, """~2.5 min.
Site: Drws-y-Coed, a small (about 300 x 100 m) copper mine on a glaciated valley floor in North Wales (McNeilly 1968). Transect 1 is at the upwind end of the mine, transect 2 at the downwind end.
What McNeilly reports: upwind, tolerant adults stop abruptly between the last mine site and a site 1 m off the mine; downwind, tolerant adults extend well onto normal soil with no abrupt change. Every seed sample from the mine was markedly less tolerant than its adults, and every off-mine seed sample downwind was more tolerant than its adults.
Adults = established plants; Seed = offspring grown from seed collected from those adults, so seed carries the fathers' (pollen) genes.
On the mine, seed is LESS tolerant than adults: non-tolerant pollen blows in from upwind; selection on the mine then removes non-tolerant seedlings.
Downwind, seed is MORE tolerant than adults: tolerant pollen blows off the mine; selection against tolerance off the mine then removes tolerant plants before adulthood.
So each generation, gene flow and selection pull in opposite directions; the cline is the balance.
Figure: SCHEMATIC. The shape follows McNeilly's text; the values are illustrative, not his data (his Fig. 3 could not be digitised). The previous version's bar chart came from a redrawn figure that disagreed with McNeilly's text at the first downwind site, so it was replaced. Say aloud that the curves are a sketch of the pattern. scripts/21_copper_tolerance.R.""")

# 22 Section 04
s = new("Section")
fill(ph(s, 102), "04")
fill(ph(s, 103), "Measuring differentiation and gene flow")
notes(s, "Transition. ~0.2 min. This section goes beyond Neal Ch. 9; it builds on F from the inbreeding lecture (Neal 8.5) and on Neal 8.4.")

# 23 Direct vs indirect
s = new("Two Columns")
fill(ph(s, 100), "Gene flow is hard to measure directly")
fill(ph(s, 101), "DIRECT: FOLLOW INDIVIDUALS")
fill(ph(s, 103), [
    "Mark–recapture, tracking, parentage of seeds",
    "Measures movement, not necessarily breeding",
    "Short studies miss rare long-distance events",
])
fill(ph(s, 104), "INDIRECT: READ THE GENES")
fill(ph(s, 106), [
    "Compare allele frequencies among populations",
    "Less differentiation implies more gene flow",
    "Averages over many generations, but relies on a model",
])
notes(s, """~1.5 min.
Direct: following pollinators, fruit-eaters or seeds is very difficult; wind pollination almost impossible to track. Gene flow is a long-term process, but field studies last a few seasons.
Indirect: use the genetic consequences of past gene flow. That needs a way to quantify differentiation (next slides) and a model linking it to gene flow.""")

# 23b Why heterozygosity measures differentiation
s = new("Title, Bullets & Photo")
fill(ph(s, 100), "Why measure heterozygosity?")
picture(s, 101, FIG + "23b_why_heterozygosity.png")
fill(ph(s, 103), "TAKEAWAY")
fill(ph(s, 105), [
    "H_{S}: average within populations; H_{T}: populations pooled",
    "The more populations differ, the further H_{S} falls below H_{T}",
    "So the gap measures differentiation, and a lack of gene flow",
], size=17)
notes(s, """~2 min. The 'why' before the F-statistics.
We want to measure how different populations are, because that tells us about gene flow (more gene flow, more similar). Heterozygosity is a convenient yardstick.
Expected heterozygosity 2p(1 - p) (from the Hardy-Weinberg lecture) is hump-shaped. Two populations with different allele frequencies each sit lower on the hump than their pooled average would: H_S (the mean of the two green points) lies below H_T (the curve at the mean allele frequency).
Similar populations (p = 0.4 and 0.6): H_S = 0.48, H_T = 0.50, gap 0.02, F_ST = 0.04. Different populations (p = 0.1 and 0.9): H_S = 0.18, H_T = 0.50, gap 0.32, F_ST = 0.64.
Same logic as the inbreeding lecture: there, F measured a heterozygote deficit caused by mating with relatives; here the deficit is caused by population structure (the Wahlund effect). Next slide puts these into the three-level framework.
Figure: analytical, scripts/23b_why_heterozygosity.R.""")

# 24 Three heterozygosities
s = new("Figure & Bullets")
fill(ph(s, 100), "Three levels of heterozygosity")
picture(s, 101, FIG + "24_heterozygosity_levels.png")
fill(ph(s, 102), [
    "Each F compares heterozygosity at two levels (recall F from the inbreeding lecture)",
    "F_{IS}: inbreeding within subpopulations",
    "F_{ST}: differentiation among subpopulations",
    "F_{IT}: both combined",
    "**Key equation:** F_{ST} = (H_{T} − H_{S}) / H_{T}",
    "Worked example: end of slides",
], size=20)
_src = ph(s, 102).text_frame.paragraphs[-1]
for _r in _src.runs:
    _r.font.size = Pt(14)
    _r.font.color.rgb = RGBColor.from_string("6E6F68")
notes(s, """~2.5 min.
Formulas for reference (in the worked example at the end): F_IS = (H_S - H_I)/H_S; F_ST = (H_T - H_S)/H_T; F_IT = (H_T - H_I)/H_T.
H_I: observed heterozygosity, averaged over subpopulations.
H_S: expected heterozygosity (2pq) within each subpopulation, averaged.
H_T: expected heterozygosity 2 p-bar q-bar if all subpopulations were pooled into one randomly mating population.
Each F compares a lower level with a higher one. They combine as (1 - F_IT) = (1 - F_IS)(1 - F_ST); equivalently F_IT = F_IS + F_ST - F_IS F_ST.
Correction to previous version: one slide labelled the differentiation index 'F_IS (Fixation Index)'; it should be F_ST.""")

# 25 Key concept: FST
s = new("Key Concept")
fill(ph(s, 102), "F_{ST}, the fixation index")
fill(ph(s, 103), "The proportion of the total expected heterozygosity that is due to allele-frequency differences among subpopulations.")
fill(ph(s, 105), "F_{ST} = 0: subpopulations identical.  F_{ST} = 1: fixed for different alleles.")
notes(s, """~0.5 min.
Common misconception: F_IT > 0 does not mean individuals mate with relatives. It can arise purely from structure: sampling the whole population as if it were one gene pool shows fewer heterozygotes than expected (Wahlund effect).
Tell students: worked examples for self-study, including the F-statistics, are at the end of the PDF. They are not done in class.""")

# Worked example (appendix slide, built at the end): table data and helper
TABLE_HEAD = ["Subpopulation", "A_{1}A_{1}", "A_{1}A_{2}", "A_{2}A_{2}", "p", "q", "H_{S} = 2pq", "H_{I}"]
TASK_ROWS = [["1", "0.01", "0.18", "0.81", "0.1", "0.9", "", ""],
             ["2", "0.49", "0.42", "0.09", "0.7", "0.3", "", ""],
             ["Mean", "", "", "", "", "", "", ""]]
ANS_ROWS = [["1", "0.01", "0.18", "0.81", "0.1", "0.9", "0.18", "0.18"],
            ["2", "0.49", "0.42", "0.09", "0.7", "0.3", "0.42", "0.42"],
            ["Mean", "", "", "", "0.4", "0.6", "0.30", "0.30"]]


def make_table(slide, rows, top=2.15):
    shape = slide.shapes.add_table(len(rows) + 1, len(TABLE_HEAD), Inches(0.8), Inches(top),
                                   Inches(11.73), Inches(0.5 * (len(rows) + 1)))
    tbl = shape.table
    widths = [2.0] + [1.39] * 7
    for j, w in enumerate(widths):
        tbl.columns[j].width = Inches(w)
    for i, row in enumerate([TABLE_HEAD] + rows):
        for j, val in enumerate(row):
            cell = tbl.cell(i, j)
            cell.text_frame.clear()
            par = cell.text_frame.paragraphs[0]
            add_runs(par, val, size=18, color="FBFAF6" if i == 0 else "1F2623")
            if i == 0:
                for r in par.runs:
                    r.font.bold = True
            cell.fill.solid()
            cell.fill.fore_color.rgb = RGBColor.from_string(
                "1F4D3F" if i == 0 else ("EFEEE6" if i % 2 == 1 else "FBFAF6"))
    return tbl


# 28 FST to Nm
s = new("Title, Bullets & Photo")
fill(ph(s, 100), "From F_{ST} to migrants per generation")
picture(s, 101, FIG + "28_fst_nm.png")
fill(ph(s, 103), "TAKEAWAY")
fill(ph(s, 105), [
    "Wright's island model: F_{ST} ≈ 1 / (4N_{e}*m* + 1)",
    "More migrants, less differentiation",
    "N_{e}*m* = number of migrants, not a proportion",
    "Worked example: end of slides",
])
_src = ph(s, 105).text_frame.paragraphs[-1]
for _r in _src.runs:
    _r.font.size = Pt(14)
    _r.font.color.rgb = RGBColor.from_string("6E6F68")
notes(s, """~2.5 min.
Sewall Wright (spelling corrected from 'Sewell' in the previous version) derived F_ST = 1/(4Nm + 1) for an island model at equilibrium between drift and gene flow.
N_e = effective size of each subpopulation, m = migration rate (a proportion), so N_e m = number of migrants per generation. Written N_e m (Neal Eqn 8.4) rather than Nm, because in Neal Exp. 8.1 N_m means the number of males. Correction to previous version: it described Nm as 'the proportion of individuals that move'.
Rearranged (in the worked example at the end): N_e m = (1/F_ST - 1)/4. Worked check: N_e m = 1 gives F_ST = 1/5 = 0.2.
Do not apply the formula to the two-subpopulation worked example at the end of the slides (F_ST = 0.375, one locus): it assumes many subpopulations. Naively it gives N_e m = 0.42; with the finite-island correction F_ST = 1/(1 + 4 N_e m (n/(n - 1))^2) for n = 2 it gives about 0.10. A useful example of misuse if a student asks.
The relationship is flat for F_ST below about 0.1, so small errors in F_ST give large errors in N_e m.
The shaded band ('butterfly data, later example') is Edith's checkerspot, introduced a few slides on.
Figure: analytical, scripts/28_fst_nm.R.""")

# 29 Big fact
s = new("Big Fact")
fill(ph(s, 100), "≈ 1")
fill(ph(s, 102), ["migrant per generation, whatever the population size, stops drift fixing populations for different alleles.", "It does not make them identical: F_{ST} is still about 0.2.", "Neal (8.4) says one every fourth generation; either way, very few migrants are needed."], size=18)
notes(s, """~1 min.
Neal 8.4: changes in allele frequency are dominated by drift only if N_e m is much less than 1. With N_e = 100 and m = 0.01, N_e m = 1 and allele frequencies follow those of the migrants' source.
The point: because drift is weaker in large populations by exactly as much as a given m represents more migrants, what matters is the NUMBER of migrants, not the proportion.
Neal's wording is now on the slide, because students will see it in the set text. Neal (8.4) says a single migrant every fourth generation is enough to prevent fixation. Most texts use about one migrant per generation (e.g. Mills and Allendorf 1996, Conservation Biology). Both make the point that very few migrants are needed; one per generation is the safer figure.
Checked with Wright's equilibrium distribution of allele frequencies among islands (beta distribution with parameters 4 N_e m q-bar and 4 N_e m (1 - q-bar)):
- N_e m = 1, mean q = 0.5: essentially no populations near fixation for either allele; F_ST = 0.2.
- N_e m = 0.25 (Neal's one every fourth generation), mean q = 0.5: about 6% of populations near fixation (q < 0.01) for each allele; F_ST = 0.5.
- N_e m = 1 but a rare allele (mean q = 0.1): about 29% of populations have q < 0.01, but almost none are fixed for it. So 'prevents fixation for different alleles' is the accurate claim; rare alleles can still be locally lost.
F_ST = 0.2 is substantial differentiation (Wright called 0.15 to 0.25 'great'), so one migrant per generation limits divergence; it does not abolish it.
Applications: genetic rescue of small, isolated populations and managed exchange between zoo populations.""")

# 29b Concept: number vs proportion
s = new("Title, Bullets & Photo")
fill(ph(s, 100), "Beating drift versus beating selection")
picture(s, 101, FIG + "27b_number_vs_proportion.png")
fill(ph(s, 103), "TAKEAWAY")
fill(ph(s, 105), [
    "Drift: N_{e}*m* ≈ 1, a number, whatever the size",
    "Selection: *m* ≈ *s*, a proportion",
    "Gold point: 10 migrants stop drift, but *m* < *s*, so local adaptation persists",
])
notes(s, """~2 min. The idea that ties the lecture together.
Drift versus gene flow (Neal 8.4, Eqn 8.4): drift dominates only if N_e m is much less than 1. The boundary N_e m = 1 is a NUMBER of migrants, so in a large population a tiny proportion is enough (the green line falls as N_e rises).
Selection versus gene flow: a locally favoured allele is swamped once m is of the order of s, a PROPORTION, whatever the population size (the red line is flat). In Neal's recessive wing example q-hat = sqrt(m/s) reaches 1 at m = s; for an additive allele in the continent-island model the local allele is lost once m reaches s.
So between the lines, neutral genes are homogenised but locally selected genes can stay different. Example (gold point): N_e = 10,000 and m = 0.001 gives 10 migrants per generation, plenty to stop drift, but m = 0.001 is well below s = 0.01, so local adaptation persists.
Link back: the wing example (m = 0.01 kept the allele at only 20%) and the 'about 1 migrant' slide. This also answers the guiding question on the title slide.
Caveats: these are rules of thumb, not sharp thresholds. The figure assumes s = 0.01 and starts at N_e = 100, because below N_e = 1/s drift also overrides selection (Neal 8.4: N_e s much less than 1).
Figure: analytical rules of thumb, not a simulation; scripts/27b_number_vs_proportion.R.""")

# 30 Assumptions
s = new("Title & Bullets")
fill(ph(s, 100), "Read F_{ST} with care")
fill(ph(s, 101), [
    "Many subpopulations of equal size, exchanging migrants at random",
    "Drift and gene flow at equilibrium, which can take many generations",
    "Neutral markers: no selection and negligible mutation",
    "F_{ST} reflects gene flow averaged over the past, not today's movement",
    "Different histories can give the same F_{ST}",
], size=20)
notes(s, """~1.5 min.
These are the assumptions of Wright's island model. The previous version listed equal sizes, constant sizes, equilibrium and no selection or mutation; added here: many subpopulations, random exchange, and the time-averaging point.
Whitlock and McCauley (1999) Heredity 82: 117-125, 'Indirect measures of gene flow and migration: F_ST not equal to 1/(4Nm + 1)', is the classic critique: F_ST is a useful measure of differentiation, but converting it to Nm is rarely reliable.
Recent colonisation, extinction and recolonisation (metapopulations), or range expansion can all leave low F_ST without much current gene flow.""")

# 31 Checkerspot
s = new("Figure & Bullets")
fill(ph(s, 100), "Checkerspot: genes versus observations")
picture(s, 101, MED + "s37_653.png")
fill(ph(s, 102), [
    "Edith's checkerspot (*Euphydryas editha*): 21 populations, central California",
    "Seven loci: F_{ST} = 0.017 to 0.062, so N_{e}*m* ≈ 3.8 to 14.5 (mean 7.8)",
    "One locus (*Hk*): F_{ST} = 0.29, perhaps because it is under selection",
    "Mark–recapture between nearby populations: N_{e}*m* ≈ 0.1",
    "**Discuss (2 min):** why might F_{ST} suggest far more gene flow than the butterflies show today?",
    "Data: McKechnie et al. (1975); analysis: Slatkin (1987)",
], size=16)
_src = ph(s, 102).text_frame.paragraphs[-1]
for _r in _src.runs:
    _r.font.size = Pt(14)
    _r.font.color.rgb = RGBColor.from_string("6E6F68")
notes(s, """~2.5 min including a 2-minute pair discussion.
Prompts if the discussion stalls: time scales, rare events, the model's assumptions.
Sources: allozyme data for 21 populations from McKechnie, Ehrlich and White (1975) Genetics 81: 571-594; F_ST and Nm by locus in Slatkin (1987) Science 236: 787-792, Table 1, using F_ST = 1/(1 + 4Nm). Direct estimate (Nm about 0.1 between nearby populations) from Ehrlich and colleagues' mark-recapture work (Ehrlich et al. 1975, Science 188: 221), as quoted by Slatkin (1987).
Slatkin's Table 1: pgm 0.028 (Nm 8.7), pgi 0.052 (4.6), hk 0.291 (0.6), got 0.017 (14.5), ak 0.062 (3.8), bdh 0.034 (7.1), a-gpdh 0.027 (9.0), to 0.035 (6.9). Mean Nm excluding hk = 7.8.
Arithmetic check: (1/0.062 - 1)/4 = 3.78; (1/0.017 - 1)/4 = 14.5; (1/0.291 - 1)/4 = 0.61.
Why Hk matters: it is the locus that breaks the pattern. Mueller et al. (1985, Genetics 110: 495-511) found that Hk was one of three loci whose frequency changes in one population were inconsistent with drift alone, so selection is a plausible reason it stands out. This links to 'neutral markers' on the previous slide: different loci can tell different stories.
Correction to previous version: it gave the 0.017-0.062 range without saying that one of the eight loci was left out.
Answers to the discussion:
Time scales: F_ST reflects gene flow averaged over many past generations; migration may have been higher in the past (e.g. before habitat fragmentation).
Rare events: occasional long-distance dispersal is easily missed by a few seasons of mark-recapture but has a large genetic effect.
Assumptions: populations may not be at equilibrium (recent colonisation, local extinction and recolonisation keep F_ST low); unequal population sizes; selection on the markers.
Measurement: mark-recapture records movement; it may also miss migrants that breed outside the study area.
Spatial scale makes the puzzle sharper: the genetic samples come from throughout central California, yet F_ST is low; the direct estimate is between nearby populations, yet movement is rare.
Slatkin's (1987) interpretation: movement between existing populations cannot explain their genetic similarity, so there was probably substantial gene flow in the recent past. Local populations also go extinct and are recolonised (a new population was established within a year of one going extinct), which keeps F_ST low.
Neither estimate is simply 'right': they measure different things over different time scales.
Photo: Walter Siegmund, CC BY-SA 3.0 (Wikimedia Commons, Euphydryas_editha_5679.JPG).""")

# 33 Summary
s = new("Summary (Key Points Only)")
fill(ph(s, 101), "Key points")
fill(ph(s, 102), [
    "Gene flow needs migrants that breed; movement alone is not enough.",
    "Gene flow pulls populations towards a common allele frequency.",
    "It opposes drift (≈ 1 migrant per generation) and selection (recessive allele: q ≈ √(*m*/*s*)).",
    "Selection varying in space plus gene flow gives clines; barriers steepen them.",
    "F_{ST} measures differentiation; converting it to N_{e}*m* needs strong assumptions.",
    "Worked examples for self-study: end of slides",
], size=18)
_src = ph(s, 102).text_frame.paragraphs[-1]
for _r in _src.runs:
    _r.font.size = Pt(14)
    _r.font.color.rgb = RGBColor.from_string("6E6F68")
notes(s, """~1.5 min.
Say aloud (no longer on the slide): reading is Neal Ch. 9 and section 8.4; try Neal 9.4 problems 1-3; the practical is 'Neutral or adaptive evolution in humans'.
Back to the guiding question: very few migrants are needed to stop drift separating populations, but local adaptation can persist against much higher gene flow when selection is strong; the outcome depends on m relative to s.
Practical (second 45-minute slot): https://jonesor.github.io/BB512_Book/neutral-or-adaptive-evolution-in-humans-what-drives-evolution-of-our-traits.html
Bridge to the practical: which human traits would gene flow homogenise among populations, and which are held apart by selection in different environments (e.g. skin pigmentation and UV)?
Answers to Neal problems: 1. m = 1 - (0.118/0.176)^(1/10) = 0.039 (with q_m = 0); 2. after five generations: 0.317, 0.529, 0.742, 0.812 if q_m is recalculated every generation (Appendix 9.1 spreadsheet); 0.321, 0.530, 0.740, 0.810 with Neal's shortcut of holding q_m fixed (Eqn 9.2, as in Example 9.3); 3. about 10 generations (done in class).""")

# 34 Quote
s = new("Quote")
fill(ph(s, 101), "Before I came here I was confused about this subject. Having listened to your lecture I am still confused. But on a higher level.")
fill(ph(s, 103), "ATTRIBUTED TO ENRICO FERMI")
notes(s, "Kept from the previous version. Widely attributed to Fermi; no primary source is known, so 'attributed to' is used rather than a definite attribution.")


def worked(title, lhead, lbody, rhead, rbody, note, size=17):
    """Self-study worked example: question on the left, solution on the right."""
    s = new("Two Columns")
    fill(ph(s, 100), title)
    fill(ph(s, 101), lhead)
    fill(ph(s, 103), lbody, size=size)
    fill(ph(s, 104), rhead)
    fill(ph(s, 106), rbody, size=size)
    notes(s, note)
    return s

# Self-study section divider
s = new("Section")
fill(ph(s, 102), "A")
fill(ph(s, 103), "Worked examples (self-study)")
notes(s, "Self-study section of the PDF; not presented in class. Each slide works one of Neal's examples or problems, with the equation numbers from Neal Chapter 9.")

worked("Worked example: continent–island",
       "SWEET CLOVER (NEAL EXAMPLE 9.2)",
       ["White field q_{0} = 0; yellow fields q_{m} = 1; *m* = 0.05. When is q = 0.5?",
        "Neal Eqn 9.2: q_{t} − q_{m} = (1 − *m*)^{t}(q_{0} − q_{m})",
        "0.5 − 1 = 0.95^{t} × (0 − 1), so 0.5 = 0.95^{t}",
        "*t* = ln 0.5 / ln 0.95 = **13.5 generations**"],
       "BUTTERFLIES (NEAL PROBLEM 9.3)",
       ["Island q_{0} = 0.75; mainland q_{m} = 0.25; *m* = 0.05. When is q = 0.55?",
        "0.55 − 0.25 = 0.95^{t} × (0.75 − 0.25)",
        "0.30 = 0.95^{t} × 0.50, so 0.6 = 0.95^{t}",
        "*t* = ln 0.6 / ln 0.95 ≈ **10 generations**"],
       """Self-study. Both use Neal Eqn 9.2 and take logs to solve for t. Note the butterflies move DOWN towards the mainland frequency: gene flow pulls towards q_m, not towards 1.""")

worked("Worked example: island model",
       "THE QUESTION (NEAL EXAMPLE 9.3)",
       ["Three equal islands: q = 0.2, 0.4 and 0.6; *m* = 0.1.",
        "What do immigrants bring to the 0.2 island, and where is it after 10 generations?"],
       "THE SOLUTION",
       ["Immigrants come from the other two: q_{m} = (0.4 + 0.6) / 2 = **0.5**",
        "Neal Eqn 9.2 with q_{m} fixed: 0.5 + 0.9^{10} × (0.2 − 0.5) = **0.395**",
        "Caveat: q_{m} changes each generation. Recalculating it every generation gives 0.36, and all islands converge on the overall mean, 0.4."],
       """Self-study. Neal's own caveat (p. 139): holding q_m fixed is an approximation; populations actually converge on the mean of all islands because the q_m values are not readjusted. The 0.36 comes from iterating Eqn 9.1 with q_m recalculated each generation (Appendix 9.1 spreadsheet; R/models.R).""")

worked("Worked example: migration–selection",
       "THE QUESTION (NEAL SECTION 9.2)",
       ["Mainland all winged (q_{m} = 1). On the island winged insects have fitness 1 − *s*, with *s* = 0.25; wings are recessive.",
        "With *m* = 0.01 or 0.1, what is the equilibrium? How many insects have wings?"],
       "THE SOLUTION",
       ["Neal Exp. 9.11: q̂ ≈ √(*m*/*s*)",
        "*m* = 0.01: q̂ = √0.04 = **0.20**; winged q̂^{2} = **4%**",
        "*m* = 0.1: q̂ = √0.4 = **0.63**; winged q̂^{2} = **40%**",
        "Most wing alleles hide in heterozygotes, so selection cannot remove them."],
       """Self-study. Neal Exp. 9.10 balances loss by selection, s p q^2/(1 - s q^2), against gain by immigration, m(q_m - q). sqrt(m/s) is exact if the island is counted after immigration (see notes on the in-class slide).""")

# 35 Appendix: worked example (self-study, not done in class)
s = new("Title Only")
fill(ph(s, 100), "Worked example: F-statistics")
make_table(s, ANS_ROWS, top=1.95)
textbox(s, 0.8, 4.05, 6.55, 2.6, [
    "1. Allele frequency: p = f(A_{1}A_{1}) + ½ f(A_{1}A_{2}), e.g. 0.01 + 0.09 = 0.1",
    "2. Each subpopulation: H_{S} = 2pq (expected); H_{I} = f(A_{1}A_{2}) (observed). Means: 0.30 and 0.30",
    "3. Pooled: H_{T} = 2p̄q̄ = 2 × 0.4 × 0.6 = **0.48**",
    "4. F_{IS} = (0.30 − 0.30) / 0.30 = **0**;  F_{ST} = (0.48 − 0.30) / 0.48 = **0.375**;  F_{IT} = (0.48 − 0.30) / 0.48 = **0.375**",
], size=15)
textbox(s, 7.65, 4.05, 4.9, 2.6, [
    "**What it means**",
    "Each subpopulation is in Hardy–Weinberg proportions, so there is no inbreeding within them (F_{IS} = 0).",
    "The heterozygote deficit in the pooled sample (0.30 vs 0.48) is entirely due to differences between subpopulations: the Wahlund effect.",
    "One locus cannot tell us whether drift or divergent selection caused the difference.",
], size=14, color="1F4D3F")
notes(s, """Appendix slide for self-study in the PDF; not presented in class. Pointed to from the F_ST key concept and the summary.
Check: (1 - F_IT) = (1 - F_IS)(1 - F_ST) = (1 - 0)(1 - 0.375) = 0.625, so F_IT = 0.375. Consistent.
Hardy-Weinberg proportions within subpopulations do not rule out selection: divergent selection can create allele-frequency differences while each subpopulation remains in HW proportions. Telling drift from selection needs many loci (selection affects particular loci, drift affects all) or other evidence.
Do not convert this F_ST to N_e m with Wright's formula: it assumes many subpopulations (see notes on the F_ST to migrants slide).""")

worked("Worked example: F_{ST} to migrants",
       "THE QUESTION",
       ["Edith's checkerspot: F_{ST} = 0.062 at one locus.",
        "Assuming Wright's island model, how many migrants per generation does this imply?"],
       "THE SOLUTION",
       ["F_{ST} ≈ 1 / (4N_{e}*m* + 1), so N_{e}*m* ≈ (1/F_{ST} − 1) / 4",
        "(1/0.062 − 1) / 4 = (16.1 − 1) / 4 ≈ **3.8 migrants per generation**",
        "Check: N_{e}*m* = 1 gives F_{ST} = 1/5 = 0.2",
        "Only valid for many subpopulations at equilibrium; do not apply it to the two-subpopulation example."],
       """Self-study. Data from Slatkin (1987) Table 1 (locus ak). The formula assumes many equal subpopulations exchanging migrants at random, neutral markers and drift-migration equilibrium.""")

prs.save(OUT)
print("saved", OUT, len(prs.slides), "slides")
