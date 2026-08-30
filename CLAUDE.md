# CS-1-01 (MO) — Computer Systems and Programming · public course site

Quarto **book** site for IIT Jammu, semester 2026-01 (Aug 3 – Nov 20, 2026).
Instructor: Soma S Dhavala. Sections: Electrical, Mechanical, Metallurgy & Materials.
Live at <https://acads-iit-jammu.github.io/csp-f26-dhavala>.

## ⚠️ Read this before you publish anything

**Two repos, one working directory.**

| | |
|---|---|
| this repo (outer) | **public** — `acads-iit-jammu/csp-f26-dhavala` |
| `private/` (nested, separate git repo) | **private** — `acads-iit-jammu/csp-f26-dhavala-private` |

`private/` holds answer keys, exam papers, TA guides and scoring sheets. It is
git-ignored here and **must never be committed to this repo**.

**`.gitignore` does not protect the published site.** `quarto publish gh-pages`
publishes the **`_site` output directory**, not the git tree — and Quarto copies every
unlisted top-level folder into `_site` as a resource by default. This actually happened:
Lab 01/02 answer keys were live and publicly fetchable for weeks (fixed 2026-08-25).

The guard is in `_quarto.yml` — **keep these lines**:

```yaml
project:
  resources:
    - "!private/**"
    - "!private/"
```

(`.quartoignore` does **not** work for this — tried on Quarto 1.5.55, all 108 files still
landed in `_site`. Only the `resources` negation worked.)

**Run this before every publish. It must print nothing:**

```bash
find _site \( -name "*ta-guide*" -o -name "*scoring*" -o -name "*-ta.tar.gz" -o -path "*answers*" \)
```

Also spot-check a known key over HTTP — it must 404:

```bash
curl -o /dev/null -w '%{http_code}\n' \
  https://acads-iit-jammu.github.io/csp-f26-dhavala/private/labs/lab02/answers/e1.c
```

**Publishing is gated on the instructor's explicit say-so.** Committing and pushing `main`
is fine; `quarto publish gh-pages` needs them to ask for it. Note the two can drift —
publishing renders from the *working tree*, so the live site can be ahead of `main`.
After publishing, commit and push too.

## Commands

```bash
quarto preview                 # local dev server
quarto render                  # build _site
quarto render labs.qmd         # single page (fast iteration)
quarto publish gh-pages        # GATED — ask first, and run the leak check above
```

## Layout

| Path | What |
|---|---|
| `index.qmd` `course.qmd` `syllabus.qmd` `labs.qmd` | top-level pages; `course.qmd` holds the weekly lecture plan and assessment weights |
| `weeks/w01…w16.qmd`, `mu1/mu2.qmd` | weekly notes. Each ends with **PAGAL Notes** (*Perspectives on Algorithms, Generative AI & Learning*) — an informal blog-style column |
| `labsheets/lab01…lab13.qmd` | student-facing lab sheets |
| `materials/wNN-<name>.html` | self-contained decks/apps (React 18 UMD + `createElement`, no build step) |
| `labs/labNN.tar.gz` | student lab packs — **build products**, produced by `private/labs/labNN/build.sh` |
| `cs1100-cse-iitm-2021/slides/` | CS1100 IIT Madras slides, mirrored with permission — keep acknowledgements |
| `iitjammu.scss` | theme: IIT Jammu blues `#003f87` `#002d63` `#0056b8`, Roboto + Roboto Slab |

Quarto books emit a late `:root{font-size:11pt}`, so the root-size override must live in
the **rules** layer of the scss, not the defaults layer.

## Conventions

- Deck/artifact files are named with a week prefix: `wNN-<name>.html`.
- Artifacts are developed in `private/materials/` first and migrate to public
  `materials/` **on request** — not automatically.
- Lab sheets are **self-contained**: where a lab reaches a construct before its lecture,
  the sheet introduces just enough of it.
- Lab schedule drifts between the Tue (EE) and Wed (Mech/Materials) batches because
  holidays fall on different weekdays — **go by session number, not date**. There are
  12 sessions, not 13; `labsheets/lab13.qmd` is intentionally unlisted in `_quarto.yml`.
- Any change to the lab schedule must be made in **both** `labs.qmd` (the index table)
  and the individual `labsheets/labNN.qmd` date rows. They drift easily; verify after.

## Working style the instructor expects

- **Verify, don't assert.** Compile and run every code snippet before claiming its
  output; check every arithmetic answer with a script. Both the lab packs and the exams
  ship with test suites for exactly this reason — run them.
- Show content for review before generating a full bundle when asked to.
- Flag schedule/consistency problems rather than silently papering over them.

See `private/CLAUDE.md` for the instructor-side workflow (lab pack architecture, exam
conventions, grading model) and `private/instructions.md` for the instructor's own
statement of intent.
