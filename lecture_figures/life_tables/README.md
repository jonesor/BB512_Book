# BB512: Life tables and age-structured population growth, figures and deck builder

From the book project root, use the [shared runner](../README.md):

```r
source("lecture_figures/render_all.R")
render_lecture("life_tables")
```

Reproducible figures for the revised BB512 lecture 05 "Life tables and age-structured population growth" (Neal 2004, "Life tables and age-specific death rates" and "Age-specific reproduction and population growth rates"), styled with `R/theme_bb512.R` (copied from `polygenic_quantitative_genetics`, with one extra size, `tall` = 11.73 × 4.35 in, for full-width figures placed on a Title Only slide). No titles or captions in the figures; these belong on the slide.

Run all figures from this folder with `source("render_all.R")`, or `LANG=C.UTF-8 Rscript render_all.R`. Needs ggplot2 (3.4 or later), scales, ragg, patchwork and png. Each script writes a 300 dpi PNG to `figures/`. `scripts/00_check_numbers.R` prints every number used on the slides, in the speaker notes and in the practical (it makes no figure).

| Script | Slides | Layout | Description | Type |
|---|---|---|---|---|
| `00_check_numbers.R` | all | none | Life table, R0, T, r (approx. and Euler–Lotka), Leslie λ, q vs μ, generation-time example, Dall sheep, Uinta ground squirrel | Analytical |
| `01_age_stage.R` | 5–7 | `full` | Six life stages (photos) with mortality and fertility curves, three-step build | Schematic |
| `02_dall_sheep.R` | 15 | `full` | Dall sheep survivorship (log scale) and q(x) | Empirical (Murie 1944, Deevey 1947, via Neal) |
| `03_rate_vs_probability.R` | 18, 19 | `full`, `takeaway` | One Gompertz schedule as q(x) and μ(x); q = 1 − e^−μ | Analytical, illustrative |
| `04_hazard_types.R` | 20 | `tall` | Increasing, constant and decreasing hazards and the survivorship they produce (Types I–III) | Analytical, illustrative |
| `05_generation_time.R` | 28 | `takeaway` | Same R0 = 2, T = 1 vs 2 years | Analytical |
| `06_euler_lotka.R` | 38 (self-study) | `takeaway` | Euler–Lotka sum against trial r; exact vs ln(R0)/T | Analytical |
| `07_cohort_lx.R` | 13 | `half` | Survivorship of the lecture's hypothetical cohort, next to the table | Analytical |
| `08_uinta.R` | 29 | `takeaway` | Uinta ground squirrel survivorship before and after density was halved | Empirical (Slade & Balph 1974, via Neal) |

`images/prepare_images.py` crops or letterboxes photographs and published figures to their placeholder sizes (sources in `images/source/`, credits in `images/CREDITS.md`). `build_deck.py` builds the PPTX from `BB512_Theme.pptx`, including speaker notes with timings (about 40 minutes for slides 1–32, leaving time for questions; slides 33–39 are self-study for the PDF). Inline markup in slide text: `*italic*`, `**bold**`, `~subscript~`, `^superscript^`, and backticks for code (set in Menlo).

    python3 build_deck.py "/Users/jones/Desktop/Keynote Themes/BB512_Theme.pptx" "BB512 - 05 - Life tables and age-structured population growth.pptx"

The lecture's hypothetical cohort (500, 400, 200, 50 females; m = 0, 2, 3, 1) is the same as Gotelli's Table 3.1 and the "Worked example" sheet of the practical spreadsheet (`Life_Tables_Exercises.xlsx`).

Figures 01–06 were rendered on a Mac with Avenir Next (23 October 2026) and checked. 03b (one label changed), 07 and 08 were rendered for checking with Inter substituted; re-run `render_all.R` on the Mac before final use.
