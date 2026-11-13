"""Build the predator-prey Excel worksheet (students) and completed workbook for practical_files/.
Neal's notation: H prey, P predators, r, a, c, d; dt = time step.
Usage: python3 build_worksheet.py ../../practical_files
"""
import sys, os
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.styles.colors import Color
from openpyxl.drawing.spreadsheet_drawing import TwoCellAnchor, AnchorMarker
from openpyxl.chart import ScatterChart, Reference, Series
from openpyxl.chart.shapes import GraphicalProperties
from openpyxl.drawing.line import LineProperties

OUT = sys.argv[1]
NSTEP = 3000                 # rows of the model: enough for dt = 0.1 over 300 time units
FIRST, LAST = 11, 11 + NSTEP
TMAX = 300                   # time axis of the time-series graph

# Formatting copied from the competition worksheet (LV_competition_worksheet.xlsx):
# Calibri 12, bold labels with arrows, yellow cells for student formulas,
# orange cells (blue text) for the parameters students change, no borders.
YELLOW = PatternFill("solid", fgColor="FFFFE699")
ORANGE = PatternFill("solid", fgColor="FFFCE4D6")
F = "Calibri"
BOLD = Font(name=F, size=12, bold=True)
PLAIN = Font(name=F, size=12)
PARAM = Font(name=F, size=12, color=Color(theme=3))
RIGHT = Alignment(horizontal="right")
# The two graphs sit side by side from D13 (rows 13-28), each six columns wide,
# so they cover no text and fit on a laptop screen at 100 % zoom.
CHART_ROWS = (12, 28)        # 0-based anchor rows: top of row 13 to top of row 29 (rows 1-12 stay clear)
CHART_COLS = [(3, 9), (9, 15)]   # D:I and J:O
CHART_COL_WIDTH = 10
HELPER = ("R", "S")          # chart data for the curved prey isocline (Part 4), clear of the graphs
PREY_COL, PRED_COL, ISO_COL = "1F4D3F", "A4503A", "6E6F68"

PREY = {
    "basic":   "MAX(0,B{p}+$F$8*($F$4*B{p}-$F$5*B{p}*C{p}))",
    "K":       "MAX(0,B{p}+$F$8*($F$4*B{p}*(1-B{p}/$F$9)-$F$5*B{p}*C{p}))",
    "refuge":  "MAX(0,B{p}+$F$8*($F$4*B{p}-$F$5*MAX(0,B{p}-$F$9)*C{p}))",
}
PRED = {
    "basic":   "MAX(0,C{p}+$F$8*($F$6*B{p}*C{p}-$F$7*C{p}))",
    "K":       "MAX(0,C{p}+$F$8*($F$6*B{p}*C{p}-$F$7*C{p}))",
    "refuge":  "MAX(0,C{p}+$F$8*($F$6*MAX(0,B{p}-$F$9)*C{p}-$F$7*C{p}))",
}

def line(series, colour, width=22000, dash=None):
    series.marker.symbol = "none"
    series.smooth = False
    series.graphicalProperties.line.solidFill = colour
    series.graphicalProperties.line.width = width
    if dash:
        series.graphicalProperties.line.dashStyle = dash

def place(ws, chart, i):
    """Anchor a chart to cells (two-cell anchor), so the two graphs never overlap."""
    (c0, c1), (r0, r1) = CHART_COLS[i], CHART_ROWS
    gap = 57150 if i == 1 else 0          # 6 px between the graphs
    chart.anchor = TwoCellAnchor(_from=AnchorMarker(col=c0, colOff=gap, row=r0),
                                 to=AnchorMarker(col=c1, row=r1))
    # Excel overlays titles and legends on the plot unless told not to
    chart.title.overlay = False
    chart.legend.overlay = False
    axes = [chart.x_axis, chart.y_axis] + [ax for c in getattr(chart, "_charts", []) for ax in (c.x_axis, c.y_axis)]
    for ax in axes:
        if ax.title is not None:
            ax.title.overlay = False
    ws.add_chart(chart)

def sheet(wb, title, kind, heading, instruction, student_prey, student_pred):
    ws = wb.create_sheet(title)
    ws["A1"] = heading; ws["A1"].font = BOLD
    ws["A2"] = instruction; ws["A2"].font = BOLD
    # parameters
    ws["E3"] = "Parameters"; ws["E3"].font = BOLD
    params = [("r", 0.25, "prey growth rate (per prey per unit time)"),
              ("a", 0.01, "attack rate (prey caught per prey per predator per unit time)"),
              ("c", 0.00008, "conversion efficiency (new predators per prey per predator per unit time)"),
              ("d", 0.1, "predator death rate (per predator per unit time)"),
              ("dt", 1, "time step: 1 = one update per time unit; try 0.1")]
    if kind == "K":
        params.append(("K", 2000, "prey carrying capacity"))
    if kind == "refuge":
        params.append(("Hr", 200, "prey in the refuge (cannot be caught)"))
    for i, (sym, val, note) in enumerate(params):
        r = 4 + i
        ws[f"E{r}"] = f"{sym} -->"; ws[f"E{r}"].font = BOLD; ws[f"E{r}"].alignment = RIGHT
        ws[f"F{r}"] = val; ws[f"F{r}"].fill = ORANGE; ws[f"F{r}"].font = PARAM
        ws[f"G{r}"] = note; ws[f"G{r}"].font = PLAIN
    ws["F6"].number_format = "0.00000"

    # equilibrium and isocline end points (for the phase-plane graph)
    ws["A3"] = "Zero isoclines"; ws["A3"].font = BOLD
    ws["B3"] = "H"; ws["C3"] = "P"; ws["B3"].font = BOLD; ws["C3"].font = BOLD
    if kind == "basic":
        ws["A4"] = "Prey isocline, P = r/a"
        ws["B4"] = 0;                         ws["C4"] = "=F4/F5"
        ws["B5"] = f"=MAX(B{FIRST}:B{LAST})";  ws["C5"] = "=F4/F5"
        ws["A6"] = "Predator isocline, H = d/c"
        ws["B6"] = "=F7/F6";                  ws["C6"] = 0
        ws["B7"] = "=F7/F6";                  ws["C7"] = f"=MAX(C{FIRST}:C{LAST})"
        ws["A8"] = "Equilibrium (H*, P*)"
        ws["B8"] = "=F7/F6";                  ws["C8"] = "=F4/F5"
    elif kind == "K":
        ws["A4"] = "Prey isocline (to H = K)"
        ws["B4"] = 0;                         ws["C4"] = "=F4/F5"
        ws["B5"] = "=F9";                     ws["C5"] = 0
        ws["A6"] = "Predator isocline, H = d/c"
        ws["B6"] = "=F7/F6";                  ws["C6"] = 0
        ws["B7"] = "=F7/F6";                  ws["C7"] = "=F4/F5"
        ws["A8"] = "Equilibrium (H*, P*)"
        ws["B8"] = "=F7/F6";                  ws["C8"] = "=IF(F7/F6<F9,(F4/F5)*(1-(F7/F6)/F9),0)"
    else:
        ws["A4"] = "Prey isocline: data in R:S"
        ws["A6"] = "Pred. isocline, H = Hr + d/c"
        ws["B6"] = "=F9+F7/F6";               ws["C6"] = 0
        ws["B7"] = "=F9+F7/F6";               ws["C7"] = f"=MAX(C{FIRST}:C{LAST})"
        ws["A8"] = "Equilibrium (H*, P*)"
        ws["B8"] = "=F9+F7/F6";               ws["C8"] = "=F4*B8/(F5*(B8-F9))"
        # prey isocline P = rH / (a (H - Hr)) for H > Hr
        hx, hy = HELPER
        ws[f"{hx}9"] = "Prey isocline (chart data, do not edit)"; ws[f"{hx}9"].font = BOLD
        ws[f"{hx}10"] = "H"; ws[f"{hy}10"] = "P = rH/(a(H-Hr))"
        for j in range(40):
            rr = 11 + j
            ws[f"{hx}{rr}"] = f"=$F$9+(MAX($B${FIRST}:$B${LAST})-$F$9)*({j}+1.5)/41"
            ws[f"{hy}{rr}"] = f"=$F$4*{hx}{rr}/($F$5*({hx}{rr}-$F$9))"
            ws[f"{hx}{rr}"].number_format = "0.0"; ws[f"{hy}{rr}"].number_format = "0.0"
    for rr in range(4, 9):
        for col in "BC":
            ws[f"{col}{rr}"].number_format = "0.0"

    # model
    ws["A10"] = "Time (t)"; ws["B10"] = "Prey (H)"; ws["C10"] = "Predators (P)"
    for c in "ABC":
        ws[f"{c}10"].font = BOLD
    ws["A10"].alignment = RIGHT
    for rr in range(4, 9):
        ws[f"A{rr}"].font = BOLD; ws[f"A{rr}"].alignment = RIGHT
    ws["E10"] = "See Neal, chapter 'Predator-Prey Interactions'"; ws["E10"].font = BOLD
    ws[f"A{FIRST}"] = 0; ws[f"B{FIRST}"] = 1000; ws[f"C{FIRST}"] = 20
    for rr in range(FIRST + 1, LAST + 1):
        p = rr - 1
        ws[f"A{rr}"] = f"=A{p}+$F$8"
        if rr == FIRST + 1 and student_prey:
            ws[f"B{rr}"].fill = YELLOW
        elif not student_prey:
            ws[f"B{rr}"] = "=" + PREY[kind].format(p=p)
        if rr == FIRST + 1 and student_pred:
            ws[f"C{rr}"].fill = YELLOW
        elif not student_pred:
            ws[f"C{rr}"] = "=" + PRED[kind].format(p=p)
        ws[f"B{rr}"].number_format = "0.000"
        ws[f"C{rr}"].number_format = "0.000"
    ws.column_dimensions["A"].width = 27
    ws.column_dimensions["B"].width = 10
    ws.column_dimensions["C"].width = 13
    for col in "DEFGHIJKLMNO":
        ws.column_dimensions[col].width = CHART_COL_WIDTH
    for col in HELPER:
        ws.column_dimensions[col].width = 12

    # time-series graph: prey (left axis), predators (right axis)
    xs = Reference(ws, min_col=1, min_row=FIRST, max_row=LAST)
    c1 = ScatterChart(); c1.title = "Prey and predators through time"; c1.style = 13
    s = Series(Reference(ws, min_col=2, min_row=FIRST, max_row=LAST), xs, title="Prey (H)")
    line(s, PREY_COL); c1.series.append(s)
    c1.x_axis.title = "Time (t)"; c1.y_axis.title = "Prey (H)"
    c1.x_axis.scaling.min = 0; c1.x_axis.scaling.max = TMAX
    c2 = ScatterChart()
    s2 = Series(Reference(ws, min_col=3, min_row=FIRST, max_row=LAST), xs, title="Predators (P)")
    line(s2, PRED_COL); c2.series.append(s2)
    c2.y_axis.axId = 200; c2.y_axis.title = "Predators (P)"; c2.y_axis.crosses = "max"
    c2.y_axis.majorGridlines = None
    c1.x_axis.delete = False; c1.y_axis.delete = False; c2.y_axis.delete = False; c2.x_axis.delete = True
    c1.x_axis.number_format = "0"; c1.y_axis.number_format = "0"; c2.y_axis.number_format = "0"
    c1 += c2
    c1.legend.position = "b"
    place(ws, c1, 0)

    # phase-plane graph
    c3 = ScatterChart(); c3.title = "Phase plane"; c3.style = 13
    s3 = Series(Reference(ws, min_col=3, min_row=FIRST, max_row=LAST),
                Reference(ws, min_col=2, min_row=FIRST, max_row=LAST), title="Trajectory")
    line(s3, PREY_COL, 15000); c3.series.append(s3)
    if kind == "refuge":
        si = Series(Reference(ws, min_col=19, min_row=11, max_row=50),
                    Reference(ws, min_col=18, min_row=11, max_row=50), title="Prey isocline")
    else:
        si = Series(Reference(ws, min_col=3, min_row=4, max_row=5),
                    Reference(ws, min_col=2, min_row=4, max_row=5), title="Prey isocline")
    line(si, ISO_COL, 19000, "dash"); c3.series.append(si)
    sp = Series(Reference(ws, min_col=3, min_row=6, max_row=7),
                Reference(ws, min_col=2, min_row=6, max_row=7), title="Predator isocline")
    line(sp, PRED_COL, 19000, "dash"); c3.series.append(sp)
    c3.x_axis.title = "Prey (H)"; c3.y_axis.title = "Predators (P)"
    c3.x_axis.scaling.min = 0; c3.y_axis.scaling.min = 0
    if kind == "refuge":
        c3.y_axis.scaling.max = 200
    c3.x_axis.delete = False; c3.y_axis.delete = False
    c3.x_axis.number_format = "0"; c3.y_axis.number_format = "0"
    c3.legend.position = "b"
    place(ws, c3, 1)
    return ws

def build(completed):
    wb = Workbook(); wb.remove(wb.active)
    # default font for every cell: Calibri 12, as in the competition worksheet
    from openpyxl.utils.indexed_list import IndexedList
    wb._fonts = IndexedList([Font(name=F, size=12, family=2)])
    wb._named_styles["Normal"].font = Font(name=F, size=12, family=2)
    tag = "Completed sheet (solutions)." if completed else ""
    sheet(wb, "Part 1 Basic model", "basic",
          "Lotka-Volterra predator-prey model (Neal's notation)",
          tag or "Part 1: type the prey formula in B12 and the predator formula in C12 (yellow), copy both down to row 3011, then check that t = 1 gives H = 1050 and P = 19.6.",
          student_prey=not completed, student_pred=not completed)
    sheet(wb, "Part 3 Prey K", "K",
          "Predator-prey model with a prey carrying capacity (K)",
          tag or "Part 3: type the new prey formula (with K) in B12 (yellow) and copy it down to row 3011. The predator formula is unchanged and already filled in.",
          student_prey=not completed, student_pred=False)
    sheet(wb, "Part 4 Prey refuge", "refuge",
          "Predator-prey model with a prey refuge (Hr prey cannot be caught)",
          tag or "Part 4: both formulas are filled in. Change Hr (cell F9) and watch the graphs.",
          student_prey=False, student_pred=False)
    wb.calculation.fullCalcOnLoad = True
    name = "LV_predator_prey_completed.xlsx" if completed else "LV_predator_prey_worksheet.xlsx"
    wb.save(os.path.join(OUT, name))
    print("wrote", name)

os.makedirs(OUT, exist_ok=True)
build(False); build(True)
