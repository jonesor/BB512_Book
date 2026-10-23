# BB512: Inbreeding, ggplot2 figures

From the book project root, use the [shared runner](../README.md):

```r
source("lecture_figures/render_all.R")
render_lecture("inbreeding")
# Or generate every lecture:
render_lectures()
```

Reproducible figures for the revised BB512 lecture "Inbreeding" (session 21), styled with `R/theme_bb512.R` (copied unchanged from `mutation_genetic_variation`). No titles or captions in the figures; these belong on the slide.

Run all figures from this folder with `source("render_all.R")`, or `LANG=C.UTF-8 Rscript render_all.R` from a terminal. Needs ggplot2 (3.4 or later, for `linewidth`), scales, ragg and patchwork. Labels use plotmath rather than Unicode sub/superscripts, so they render in Avenir Next. Each script writes a 300 dpi PNG to `figures/`.

| Script | Slide | Layout | Description | Type |
|---|---|---|---|---|
| `01_ancestor_slots.R` | 4 | `half` | 2^t ancestor slots vs generations, with N = 50 and N = 1,000 | Exact arithmetic |
| `02_F_over_time.R` | 7 | `takeaway` | F_t = 1 - (1 - 1/2Ne)^t for Ne = 10, 50, 500 | Analytical; no mutation, migration or selection |
| `03_pedigrees.R` | 9, 10, 11, 13 | `half`, `takeaway`, `full` | Full-sib pedigree: plain (03a), one allele from A (03b), four autozygous routes (03c), path-counting loops (03d) | Schematic; founders unrelated and not inbred |
| `03e_half_sib_answer.R` | 15 | `takeaway` | Answer to the half-sibling activity: one loop (F = 1/8) beside full siblings (two loops, F = 1/4) | Schematic; founders unrelated and not inbred |
| `04_heterozygote_deficit.R` | 18 | `takeaway` | HWE genotype curves; expected vs observed heterozygosity at p = 0.3 | Analytical; illustrative numbers |
| `05_punnett_inbreeding.R` | 19 | `takeaway` | Punnett square with an IBD column; areas to scale for p = 0.6, F = 0.25 | Schematic |
| `06_F_by_relationship.R` | 16 | `takeaway` | F of offspring by relationship, plus Charles II of Spain (F = 0.254; Alvarez et al. 2009) | Analytical + one empirical estimate |

`R/pedigree.R` holds the shared pedigree-drawing helper.

The figures were rendered for checking in an environment without Avenir Next (a substitute sans font was used). Re-run `render_all.R` on a Mac with Avenir Next before final use, and look at the PNGs.
