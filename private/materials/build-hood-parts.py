#!/usr/bin/env python3
"""Split under-the-hood.html (master, single file) into three station-group
files with cross-file navigation. Edit the master, then re-run this."""
import re, os

HERE = os.path.dirname(os.path.abspath(__file__))
master = open(os.path.join(HERE, "w02-under-the-hood.html")).read()

PARTS = [
    ("w02-under-the-hood-1-parts.html",   "Part 1 · The Parts — switch → gates → adder",      [0, 1, 2, 3]),
    ("w02-under-the-hood-2-memory.html",  "Part 2 · Memory & Time — the loop and the bell",   [4, 5]),
    ("w02-under-the-hood-3-machine.html", "Part 3 · The Machine — and the whole ladder",      [6, 7]),
]
SHORTS = ["0 · Promise", "1 · Switch", "2 · Gates", "3 · Adder",
          "4 · Memory", "5 · Clock", "6 · Machine", "7 · The ladder"]

# --- carve up the master ---
head, rest = master.split('<script>\n"use strict";', 1)
shared_js, rest = rest.split("/* ================= stations ================= */", 1)
stations_js, _stepper = rest.split("/* ================= stepper ================= */", 1)
tail = "</script>\n</body>\n</html>\n"

blocks = re.split(r"/\* ---------- Station \d+ ---------- \*/", stations_js)
prelude = blocks[0]              # station()/stationDefs helpers
station_blocks = blocks[1:]
assert len(station_blocks) == 8, f"expected 8 stations, got {len(station_blocks)}"

# global station index -> (file, local index)
where = {}
for fname, _t, idxs in PARTS:
    for li, gi in enumerate(idxs):
        where[gi] = (fname, li)

for fname, title, idxs in PARTS:
    all_js = ",\n    ".join(
        f'["{SHORTS[g]}","{where[g][0]}",{where[g][1]}]' for g in range(8))
    stepper = f"""
/* ================= stepper (cross-file) ================= */
const ALLSTATIONS=[
    {all_js}];
const THISFILE="{fname}";
(function(){{
  const nav=$("stepper"), mainEl=$("stations");
  const localGlobals=ALLSTATIONS.map((s,g)=>s[1]===THISFILE?g:-1).filter(g=>g>=0);
  const secs={{}};
  stationDefs.forEach((sd,li)=>{{
    const g=localGlobals[li];
    const sec=document.createElement("section"); sec.className="station"; mainEl.appendChild(sec);
    sd.build(sec);
    const last=(g===ALLSTATIONS.length-1);
    const btns=h(`<div class="navbtns">
      <button class="big ghost">← back</button>
      <button class="big">${{last? "climb again ↺" : "next station →"}}</button></div>`);
    btns.children[0].addEventListener("click",()=>go(Math.max(0,g-1)));
    btns.children[1].addEventListener("click",()=>go(last?0:g+1));
    if(g===0) btns.children[0].style.visibility="hidden";
    sec.appendChild(btns);
    secs[g]=sec;
  }});
  ALLSTATIONS.forEach((s,g)=>{{
    const b=document.createElement("button"); b.textContent=s[0];
    b.addEventListener("click",()=>go(g)); nav.appendChild(b);
  }});
  function go(g){{
    const [_,file,li]=[null,ALLSTATIONS[g][1],ALLSTATIONS[g][2]];
    if(file!==THISFILE){{ location.href=file+"?s="+g; return; }}
    Object.entries(secs).forEach(([gg,s])=>s.className="station"+(+gg===g?" show":""));
    nav.querySelectorAll("button").forEach((b,j)=>b.className=(j===g?"cur":""));
    window.scrollTo({{top:0}});
  }}
  const want=parseInt(new URLSearchParams(location.search).get("s"));
  go(Number.isInteger(want)&&ALLSTATIONS[want]&&ALLSTATIONS[want][1]===THISFILE ? want : localGlobals[0]);
}})();
"""
    part_head = head.replace(
        "a guided climb through every floor of a computer",
        f"{title} · a guided climb through every floor of a computer")
    body = prelude + "".join(
        f"/* ---------- Station {g} ---------- */" + station_blocks[g] for g in idxs)
    out = (part_head + '<script>\n"use strict";' + shared_js +
           "/* ================= stations ================= */" + body + stepper + tail)
    open(os.path.join(HERE, fname), "w").write(out)
    print(f"wrote {fname}: stations {idxs}, {len(out)} bytes")
