# BB512: Evolution of life histories, figures and deck builder

From the book project root, use the [shared runner](../README.md):

```r
source("lecture_figures/render_all.R")
render_lecture("life_histories")
```

Reproducible figures for the revised BB512 lecture 07 "Evolution of life histories" (Neal 2004, "Evolution of life histories"), styled with `R/theme_bb512.R` (copied unchanged from `polygenic_quantitative_genetics`). No titles or captions in the figures; these belong on the slide.

Run all figures from this folder with `source("render_all.R")`, or `LANG=C.UTF-8 Rscript render_all.R`. Needs ggplot2 (3.4 or later), scales and ragg. Each script writes a 300 dpi PNG to `figures/`. `scripts/00_check_numbers.R` prints every number used on the slides and in the speaker notes (it makes no figure).

| Script | Slide | Layout | Description | Type |
|---|---|---|---|---|
| `00_check_numbers.R` | all | none | Arithmetic check: thought experiment, red deer, Lack's starlings, Cole's paradox | Analytical |
| `01_allocation.R` | 9 | `takeaway` | Budget split between maintenance, growth and reproduction, slow vs fast | Schematic |
| `02_logistic_rK.R` | 11 | `half` | Logistic growth with the r- and K-selection regimes | Analytical, illustrative |
| `03_optimality.R` | 16 | `takeaway` | Saturating benefit, accelerating cost, net benefit and optimum | Schematic |
| `04_lack_starlings.R` | 20 | `takeaway` | Swiss starlings: brood-size frequency and young recovered per brood | Empirical (Lack 1948, via Neal's table) |
| `05_lifetime_clutch.R` | 23 | `takeaway` | Single-season vs lifetime optimal clutch with a parental survival cost | Schematic |
| `06_thought_experiment.R` | 26, 27 | `full` | Expected offspring by age (s = 0.8, m = 10, ages 1–21), normal and mutant | Analytical |
| `07_red_deer_force.R` | 28 | `takeaway` | Hamilton's force of selection on survival, red deer, Rhum 1957 | Empirical life table (Lowe 1969, via Neal's table), analytical measure |

Slide 17 (maternal age and infant mortality) is hidden by default; the speaker-note timings add up to about 44 minutes for the visible slides. The last two slides are self-study slides for the PDF and are not presented.

`images/prepare_images.py` crops or letterboxes photographs to their placeholder sizes (sources in `images/source/`, credits and open questions in `images/CREDITS.md`). `build_deck.py` builds the PPTX from `BB512_Theme.pptx`, including speaker notes. Inline markup in slide text: `*italic*`, `**bold**`, `~subscript~`, `^superscript^`, and backticks for code (set in Menlo).

    python3 images/prepare_images.py
    python3 build_deck.py "/Users/jones/Desktop/Keynote Themes/BB512_Theme.pptx" "BB512 - 07 - Evolution of life histories.pptx"

The figures were rendered for checking without Avenir Next (Inter was substituted). Re-run `render_all.R` on a Mac with Avenir Next before final use, and look at the PNGs.
