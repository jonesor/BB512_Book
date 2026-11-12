# BB512: Lotka-Volterra competition practical, figures and deck builder

Reproducible figures for the green-theme practical deck "BB512 - Lotka Volterra Competition Practical v2" (two sessions; Neal, *Interspecific Competition*). The deck is deliberately minimal: students work from the online book, and the slides only show the task and what students should see (check figure, isocline cases, answers Q1 to Q5), styled with `R/theme_bb512.R` (copied from `behaviour_altruism`). `R/lv_model.R` holds the discrete-time model exactly as students build it in Excel (worksheet Equations 2 and 3, in Neal's notation α and β), plus shared time-series and phase-plane plotting functions. Every simulation is deterministic (no random numbers). Colours match the worksheet's Excel charts (species 1 forest green, solid; species 2 clay red, dashed), and phase-plane axis ticks sit at the four intercepts, labelled with value and symbol, so students can compare directly with their Excel phase graph. Answer slides use the parameter values of the book's solutions chapter (`6_01_Solutions.Rmd`, "Solutions: Lotka-Volterra competition").

Run with `Rscript lecture_figures/render_all.R lv_competition`. `scripts/00_check_numbers.R` prints every number used on the slides and in the notes.

| Script | Slide | Layout | Description | Type |
|---|---|---|---|---|
| `00_check_numbers.R` | all | none | Equilibria and values at t = 50 and t = 200 for every case | Arithmetic |
| `01_one_isocline.R` | not used | `half` | Species 1 zero isocline with direction arrows (K1 = 1200, α = 0.75) | Analytical schematic |
| `02_check_sheet.R` | 4 | `takeaway` | Worksheet defaults: time series (t = 0-200, as in Excel) and phase plane, settling at (720, 640) | Deterministic simulation |
| `03_four_outcomes.R` | 5 | `full` | The four isocline arrangements, stable and unstable equilibria | Analytical schematic |
| `04_answer_q1.R` | 7 | `takeaway` | Q1: species 1 excludes species 2 | Deterministic simulation |
| `05_answer_q2.R` | 8 | `takeaway` | Q2: species 2 excludes species 1 (phase-plane axes not to scale) | Deterministic simulation |
| `06_answer_q3.R` | 9 | `takeaway` | Q3: stable coexistence at (1600, 1200) from six starts | Deterministic simulation |
| `07_answer_q4.R` | 10 | `takeaway` | Q4: unstable equilibrium at (444, 444) | Deterministic simulation |
| `08_smaller_can_win.R` | not used | `half` | α = 1.2, β = 1.3: species 1 wins from (120, 160), loses from (100, 160) | Deterministic simulation |
| `09_identical_species.R` | not used | `half` | Identical species: the isoclines coincide, no exclusion | Deterministic simulation |
| `10_tribolium.R` | 11 | `half` | Park's flour beetles (Neal's parameters), either can win | Empirical parameters, simulated trajectories |

`build_deck.py` builds the PPTX from `BB512_Theme.pptx`, with speaker notes and no slide numbers. Figures marked "not used" are kept for the book or for discussion:

    python3 build_deck.py ../theme/BB512_Theme.pptx "BB512 - Lotka Volterra Competition Practical v2.pptx"

Slide 3 shows `images/lv_worksheet_blank.png`, Owen's Excel screenshot of the student worksheet (rows 1-13). The title photo goes in `images/title_tribolium.jpg` (see `images/CREDITS.md`); the builder leaves the picture placeholder empty if the file is missing. The figures were rendered for checking without Avenir Next (Inter was substituted). Re-run `render_all.R` on a Mac with Avenir Next before final use, and look at the PNGs.
