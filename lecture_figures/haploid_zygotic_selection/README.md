# BB512: Haploid and zygotic selection, figures and deck builder

Reproducible figures for the revised BB512 lecture 14 "Haploid and zygotic selection" (Neal 2004, Chapters 10 and 11), styled with `R/theme_bb512.R` (copied unchanged from `mutation_genetic_variation`). No titles or captions in the figures; these belong on the slide.

Run all figures from this folder with `source("render_all.R")`, or `LANG=C.UTF-8 Rscript render_all.R`. Needs ggplot2 (3.4 or later), scales, ragg and patchwork. Each script writes a 300 dpi PNG and a PDF to `figures/`. `scripts/00_check_numbers.R` prints every number used on the slides and in the speaker notes (it makes no figure).

`R/models.R` holds the deterministic selection models (haploid; zygotic Cases B to E, following Neal's notation, with q always the frequency of the allele selected against). All models assume an infinite population (no drift), no mutation or migration, constant fitness, random mating and non-overlapping generations.

| Script | Slide | Layout | Description | Type |
|---|---|---|---|---|
| `00_check_numbers.R` | all | none | Arithmetic check for every worked example | Analytical/iteration |
| `01_fitness_growth.R` | 6 | `half` | Geometric growth, λ = 1.05 vs 1.15 | Analytical, illustrative values |
| `02_genetic_systems.R` | 9 | `full` | 2 × 2 grid: ploidy × reproduction, with examples | Schematic |
| `03_life_cycles.R` | 10 | `full` | Asexual, haploid-dominant and diploid-dominant life cycles | Schematic |
| `04_selection_filter.R` | 14 | `full` | One generation of haploid selection in three steps | Analytical |
| `05_haploid_dynamics.R` | 17 | `full` | Worked example over 40 generations; abs(Δq) against p | Deterministic iteration |
| `06_mean_fitness.R` | 18 | `takeaway` | Mean fitness over time in the worked example | Deterministic iteration |
| `07_zygotic_cycle.R` | 22 | `full` | Zygotes → adults → next zygotes, q = 0.4, s = 0.3 | Analytical |
| `08_dq_by_case.R` | 25 | `takeaway` | abs(Δp) against the favoured allele's frequency p for Cases B, C, D and haploid, s = 0.1 | Analytical |
| `09_spread_by_case.R` | 26 | `full` | Spread of a favoured allele, s = 0.1, p0 = 0.01 | Deterministic iteration |
| `10_haldane_carbonaria.R` | 36 | `takeaway` | carbonaria 1848–1898 with the exact s (0.30); approximate value (0.33) printed only | Model fitted to Haldane's figures |
| `11_kettlewell.R` | 38 | `takeaway` | Recapture rates, Kettlewell (1956) via Neal Table 11.1 | Empirical |
| `12_west_kirby.R` | 40 | `takeaway` | carbonaria decline at West Kirby with Case D model (s = 0.15) | Empirical + fitted model |
| `13_sickle_equilibrium.R` | 44 | `takeaway` | HbS approaching q = 0.23 using Allison (1956) fitnesses | Deterministic, empirical fitnesses |
| `14_eugenics.R` | 49 | `takeaway` | Incidence of a recessive under s = 1 (PKU-like, 1 in 10,000) | Analytical (Neal Eqn 10.12) |

Slide numbers count hidden slides. Slides 16 (haploid Δq equation) and 50 (mutation–selection balance) are hidden backup slides. `images/make_equation.py` renders Neal's Eqn 10.11 (`images/eqn_10_11.png`) for the Haldane slides.

`images/prepare_images.py` crops or letterboxes photographs to their placeholder sizes (sources in `images/source/`, credits in `images/CREDITS.md`). `build_deck.py` builds the PPTX from `BB512_Theme.pptx`, including speaker notes:

    python3 build_deck.py "/Users/jones/Desktop/Keynote Themes/BB512_Theme.pptx" "BB512 - 14 - Haploid and Zygotic Selection.pptx"

The figures were rendered for checking without Avenir Next (Inter was substituted). Re-run `render_all.R` on a Mac with Avenir Next before final use, and look at the PNGs.
