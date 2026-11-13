# BB512: Lotka-Volterra predator-prey practical, figures and deck builder

Reproducible figures for the green-theme practical deck "BB512 - Lotka Volterra Predator Prey Practical v2" (two sessions, after the Predation 1 and 2 lectures; Neal, *Predator-Prey Interactions*). The deck is deliberately minimal (12 slides): students work from the online book, and the slides only show the task and what students should see (worksheet and check screenshots from Excel in images/, isocline reference, answers). Figures are styled with `R/theme_bb512.R` (copied from `lv_competition`). `R/pp_model.R` holds the model exactly as students build it in the Excel worksheet (`practical_files/` (built by `build_worksheet.py`)), in Neal's notation (H, P, r, a, c, d), with the time step dt, an optional prey carrying capacity K and an optional prey refuge Hr, plus shared time-series and phase-plane plotting functions. Every simulation is deterministic. Answer slides use the parameter values of the book's solutions chapter (`6_01_Solutions.Rmd`, "Solutions: Lotka-Volterra predator-prey dynamics").

Run with `Rscript lecture_figures/render_all.R lv_predation`. `scripts/00_check_numbers.R` prints every number used on the slides and in the notes.

| Script | Slide | Layout | Description | Type |
|---|---|---|---|---|
| `00_check_numbers.R` | all | none | Equilibria, peaks, extinction times, K and refuge results | Arithmetic |
| `01_isoclines.R` | 4 | `half` | Isoclines P = r/a and H = d/c, the four regions, anticlockwise cycle | Analytical schematic |
| `02_check_sheet.R` | 3 | `takeaway` | Worksheet values, dt = 1, 0-300 time units (prey extinct at t = 220) | Deterministic simulation |
| `03_time_step.R` | 7 | `full` | dt = 1 (cycles grow, prey extinct at t = 220) versus dt = 0.1 (zoomed axes) | Deterministic simulation |
| `04_answer_cycles.R` | 6 | `takeaway` | Cycles with dt = 0.1, quarter-cycle lag | Deterministic simulation |
| `05_answer_isoclines.R` | 8 | `full` | Doubling r, a, c or d moves one isocline | Analytical schematic |
| `06_prey_K.R` | 9 | `takeaway` | K = 2000: damped cycles settle at (1250, 9.375) | Deterministic simulation |
| `07_K_values.R` | 10 | `full` | K = 1000, 2000, 10000 | Deterministic simulation |
| `08_refuge.R` | 11 | `full` | Refuge Hr = 0, 100, 200, 400 | Deterministic simulation |

`build_deck.py` builds the PPTX from `BB512_Theme.pptx`, with speaker notes and no slide numbers:

    python3 build_deck.py ../theme/BB512_Theme.pptx "BB512 - Lotka Volterra Predator Prey Practical v2.pptx"

The title slide has no photo yet (see the speaker notes). The figures were rendered without Avenir Next (Inter was substituted). Re-run `render_all.R` on a Mac with Avenir Next before final use, and look at the PNGs.
