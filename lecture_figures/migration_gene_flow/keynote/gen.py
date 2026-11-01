"""Generate Chrome browser_batch actions to type and format a Keynote text box.
Usage: python3 gen.py SLIDE PH_INDEX X Y [--noformat]"""
import json, sys
TAB = 547296531
DOTS = (1410, 345); BASE = (1446, 490); SUB = (1432, 546); SUP = (1432, 519)

def act(action, **kw):
    d = {"action": action, "tabId": TAB}; d.update(kw); return {"name": "computer", "input": d}

def keys(k, n, summary):
    out = []
    while n > 0:
        r = min(n, 100); out.append(act("key", text=k, repeat=r, action_summary=summary)); n -= r
    return out

def fmt_actions(text, runs):
    import unicodedata
    def g(i): return i - sum(1 for c in text[:i] if unicodedata.combining(c))
    L = g(len(text)); out = []
    for start0, ln0, kinds in runs:
        start = g(start0); ln = g(start0 + ln0) - start
        for kind in kinds:
            if kind not in ("sub", "sup", "italic", "bold"): continue
            if True:
                out.append(act("key", text="cmd+Up", action_summary="Moves the cursor to the start of the text"))
                out += keys("Right", start + ln, "Moves the cursor forward to a formatted run")
            else:
                out.append(act("key", text="cmd+Down", action_summary="Moves the cursor to the end of the text"))
                out += keys("Left", L - (start + ln), "Moves the cursor back to a formatted run")
            out.append(act("wait", duration=0.3))
            out += keys("shift+Left", ln, "Selects the run to format")
            out.append(act("wait", duration=0.3))
            if kind == "italic": out += [act("key", text="cmd+i", action_summary="Makes the selection italic"), act("wait", duration=0.4)]
            elif kind == "bold": out += [act("key", text="cmd+b", action_summary="Makes the selection bold"), act("wait", duration=0.4)]
            else:
                out.append(act("left_click", coordinate=list(DOTS), action_summary="Opens advanced font options"))
                out.append(act("wait", duration=0.7))
                out.append(act("left_click", coordinate=list(BASE), action_summary="Opens the Baseline menu"))
                out.append(act("wait", duration=0.5))
                out.append(act("left_click", coordinate=list(SUB if kind == "sub" else SUP),
                               action_summary="Sets the selection to " + ("subscript" if kind == "sub" else "superscript")))
                out.append(act("wait", duration=0.5))
                out.append(act("left_click", coordinate=list(DOTS), action_summary="Closes advanced font options"))
                out.append(act("wait", duration=0.8))
    return out

def type_box(text, runs, x, y, fmt=True):
    out = [act("double_click", coordinate=[x, y], action_summary="Enters text editing in a placeholder"),
           act("key", text="cmd+a", action_summary="Selects the placeholder text"),
           act("type", text=text, action_summary="Types the slide text")]
    if fmt: out += fmt_actions(text, runs)
    out.append(act("key", text="Escape", action_summary="Leaves text editing"))
    return out

if __name__ == "__main__":
    deck = json.load(open("/home/claude/work/deck.json"))
    n, pi, x, y = int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4])
    ph = deck[n - 1]["ph"][pi]
    print(json.dumps(type_box(ph["text"], ph["runs"], x, y, "--noformat" not in sys.argv), ensure_ascii=False))

def notes_actions(n):
    deck = json.load(open("/home/claude/work/deck.json"))
    t = deck[n - 1]["notes"]
    return [act("left_click", coordinate=[690, 680], action_summary="Places the cursor in the presenter notes"),
            act("key", text="cmd+a", action_summary="Selects any existing notes"),
            act("type", text=t, action_summary="Types the speaker notes")]

# placeholder idx -> click point (full-frame coordinates at 104% zoom)
POS = {"Quote": {101: (420,230), 103: (350,458)}, "Summary (Key Points Only)": {101: (380,188), 102: (500,282)}, "Big Fact": {100: (500,225), 102: (408,415)}, "Title & Bullets": {100: (370,142), 101: (650,240)}, "Check Question (4 options)": {101: (367,183), 105: (405,292), 109: (828,292), 113: (405,427), 117: (828,427)}, "Activity": {101: (488,127), 102: (493,198), 103: (373,335)}, "Title, Bullets & Photo": {100: (370,142), 105: (970,330)}, "Key Concept": {102: (338,205), 103: (492,302), 105: (483,452)}, 
 "Title": {103: (437, 345), 104: (437, 522)},
 "Agenda": {101: (405, 198), 103: (690, 192)},
 "Section": {102: (345, 262), 103: (430, 400)},
 "Figure & Bullets": {100: (360, 142), 102: (910, 235)},
 "Two Columns": {100: (360, 142), 101: (430, 235), 103: (440, 292), 104: (850, 235), 106: (865, 292)},
}
PIC = {"Title, Bullets & Photo": (535, 365), "Figure & Bullets": (470, 365)}
PICKER = {"Title": (75, 140), "Section": (195, 140), "Agenda": (75, 232), "Title & Bullets": (195, 232),
          "Title & Photo": (75, 325), "Title, Bullets & Photo": (195, 325), "Figure & Bullets": (75, 430),
          "Key Concept": (195, 430), "Two Columns": (75, 521), "Activity": (195, 521),
          "Check Question (4 options)": (75, 613), "Check Question (2 options)": (195, 613)}

def slide_text_actions(n):
    deck = json.load(open("/home/claude/work/deck.json"))
    d = deck[n - 1]; pos = POS[d["layout"]]; out = []
    for ph in d["ph"]:
        if ph["idx"] in pos:
            x, y = pos[ph["idx"]]
            out += type_box(ph["text"], ph["runs"], x, y)
    out += notes_actions(n)
    return out

def new_slide(layout):
    return [act("left_click", coordinate=[59, 767], action_summary="Opens the new-slide layout picker"),
            act("wait", duration=1),
            act("left_click", coordinate=list(PICKER[layout]), action_summary="Adds a slide with the " + layout + " layout"),
            act("wait", duration=1)]

def full_slide(n, add=True):
    deck = json.load(open("/home/claude/work/deck.json"))
    d = deck[n - 1]
    out = new_slide(d["layout"]) if add else []
    out += slide_text_actions(n)
    if d["pics"] and d["layout"] in PIC:
        out += [act("left_click", coordinate=list(PIC[d["layout"]]), action_summary="Selects the image placeholder"),
                act("wait", duration=1),
                act("left_click", coordinate=[1372, 160], action_summary="Clicks Replace in the Image panel"),
                act("wait", duration=1)]
    else:
        out += [act("screenshot", scale=0.6)]
    return out

def fix_runs(n, idx, run_ids, x, y):
    d = json.load(open("/home/claude/work/deck.json"))[n - 1]
    p = [p for p in d["ph"] if p["idx"] == idx][0]
    runs = [p["runs"][i] for i in run_ids]
    out = [act("double_click", coordinate=[x, y]), act("wait", duration=0.6)]
    out += fmt_actions(p["text"], runs)
    out += [act("key", text="Escape"), act("wait", duration=0.5)]
    return out

def plain_slide(n):
    deck = json.load(open("/home/claude/work/deck.json"))
    d = deck[n - 1]; pos = POS[d["layout"]]
    out = new_slide(d["layout"])
    for ph in d["ph"]:
        if ph["idx"] in pos:
            x, y = pos[ph["idx"]]
            out += [act("double_click", coordinate=[x, y]), act("key", text="cmd+a"),
                    act("type", text=ph["text"]), act("key", text="Escape")]
    out += notes_actions(n)
    return out
