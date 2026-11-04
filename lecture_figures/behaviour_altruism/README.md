# BB512: Behaviour, altruism and limiting aggression, figures and deck builder

Reproducible figures for the revised BB512 lecture 17 (v3) "Animal behaviour, altruism and limiting aggression" (Neal 2004, Chapter 19), styled with `R/theme_bb512.R` (copied from `inbreeding`, with one change: `save_bb512()` writes PNG only unless `pdf = TRUE`, following the BB512 figure rules). No titles or captions in the figures; these belong on the slide.

Run all figures from the repository root with `Rscript lecture_figures/render_all.R behaviour_altruism` (or `source("lecture_figures/render_all.R"); render_lecture("behaviour_altruism")`). `render_all.R` in this folder still works when sourced. Needs ggplot2 (3.4 or later), scales, ragg and patchwork. `scripts/00_check_numbers.R` prints every number used on the slides and in the speaker notes (it makes no figure).

| Script | Slide | Layout | Description | Type |
|---|---|---|---|---|
| `00_check_numbers.R` | all | none | Relatedness, inclusive fitness, kingfisher totals, Hawk–Dove and Bourgeois payoffs, ESS | Arithmetic |
| `01_rover_sitter.R` | 4 | `half` | P × P, F1 and F2 of the rover/sitter cross (3 : 1) | Schematic |
| `02_zebrafish_selection.R` | 5 | `takeaway` | Divergent selection on alarm-substance sensitivity, 4 generations (Gandolfi 1972, digitised from Neal Fig. 19.2) | Empirical |
| `03_group_selection.R` | 9 | `full` | Naive group selection for altruism in five steps (redrawn from the previous version's build slides) | Schematic (seed 17) |
| `04_relatedness_pedigree.R` | 13 | `half` | r from "You" to relatives in an outbred family | Schematic |
| `05_kingfisher_fitness.R` | 19 | `takeaway` | Direct + indirect fitness of yearling male pied kingfishers (Reyer 1990, Neal Table 19.3) | Empirical |
| `06_haplodiploidy.R` | 20 | `half` | Worker's relatedness to daughter, sister, brother, sister under multiple mating | Analytical |
| `07_hawk_dove_dynamics.R` | 31 | `full` | Payoff to Hawk and Dove against p; replicator dynamics converging on p* = 7/12 (B = 50, C = 100, D = 10) | Analytical + deterministic iteration |

`images/prepare_images.py` crops or letterboxes photographs to their placeholder sizes (sources in `images/source/`, credits in `images/CREDITS.md`). `build_deck.py` builds the PPTX from `BB512_Theme.pptx`, including speaker notes:

    python3 build_deck.py ../theme/BB512_Theme.pptx "BB512 - 17 - Behaviour Altruism and Limiting Aggression.pptx"

The figures were rendered for checking without Avenir Next (Inter was substituted). Re-run `render_all.R` on a Mac with Avenir Next before final use, and look at the PNGs.
