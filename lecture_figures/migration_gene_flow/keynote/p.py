import sys, json; sys.path.insert(0,'/home/claude/work/kn'); import gen
a=[]
for n in sys.argv[1:]:
    a += gen.full_slide(int(n))
for x in a: x["input"].pop("action_summary", None)
print(json.dumps(a, ensure_ascii=False, separators=(',',':')))
