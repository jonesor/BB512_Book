# BB512: Polygenic inheritance and quantitative genetics, figures and deck builder

From the book project root, use the [shared runner](../README.md):

```r
source("lecture_figures/render_all.R")
render_lecture("polygenic_quantitative_genetics")
```

Reproducible figures for the revised BB512 lecture 15 "Polygenic inheritance and quantitative genetics" (Neal 2004, "Polygenic inheritance, quantitative genetics and heritability"), styled with `R/theme_bb512.R` (copied unchanged from `haploid_zygotic_selection`). No titles or captions in the figures; these belong on the slide.

Run all figures from this folder with `source("render_all.R")`, or `LANG=C.UTF-8 Rscript render_all.R`. Needs ggplot2 (3.4 or later), scales and ragg. Each script writes a 300 dpi PNG to `figures/`. `scripts/00_check_numbers.R` prints every number used on the slides and in the speaker notes (it makes no figure).

| Script | Slide | Layout | Description | Type |
|---|---|---|---|---|
| `00_check_numbers.R` | all | none | Arithmetic check for every worked example | Analytical |
| `01_wheat_f2.R` | 6 | `full` | F2 of Nilsson-Ehle's 3-locus wheat cross: 64 combinations in 7 classes | Analytical (Neal, wheat kernel colour figure) |
| `02_more_loci.R` | 7 | `full` | 1 locus, 3 loci, 3 loci + environment, 20 loci + environment | Analytical, illustrative environmental SD |
| `03_variance_budget.R` | 14, 19 | `takeaway` | East's variance components: V_G and V_E (03a); V_A, V_D + V_I, V_E (03b) | Empirical (Neal, partitioning section) |
| `04_east_regression.R` | 18 | `takeaway` | Mid-parent–offspring regression, slope 0.8348, with h² = 1 and h² = 0 reference lines | Empirical, points digitised from Neal's parent–offspring figure |
| `05_breeders_equation.R` | 25 | `takeaway` | Sheep weight: S = 25 kg, h² = 0.5, R = 12.5 kg | Analytical, illustrative (SD 15 kg assumed) |
| `06_corn_heritability.R` | 29 (Keynote 27) | `takeaway` | Illinois maize: line means of oil content (top) and h² by block of generations (bottom) | Empirical. Top: DIGITISED from Neal Fig. 12.6 (after Dudley 1977), approximate; bottom: Neal Table 12.3 |
| `07_reaction_norms.R` | 33 | `full` | Four reaction-norm patterns (plastic, genetic, both, G×E) | Schematic |
| `08_gxe_heritability.R` | 34 | `takeaway` | Crossing reaction norms: V_G high, zero, moderate across environments | Schematic |
| `09_phenology_mismatch.R` | 35 (hidden) | `full` | Bud burst, caterpillar and great tit timing against spring temperature | Schematic |
| `10_east_variances.R` | 13a (Keynote 14) | `takeaway` | Worked example: East's P1, P2, F1 and F2 histograms with variances; V_E = (3.3 + 4.2 + 8.1)/3 = 5.2, V_P = 40.5, V_G = 35.3 (87%) | Reconstructed: counts digitised from Neal's figure of East's experiment, then adjusted to reproduce Neal's V_E and V_P (digitised counts kept in the script) |
| `11_gene_action.R` | 15 (Keynote 14) | custom 9.6 x 4.1 in | Neal's two-locus series drawn as wheat kernels: additive, dominance, epistasis only, dominance + epistasis (replaces the table) | Analytical/illustrative (Neal, partitioning genetic variation); the epistasis-only row (score = nA x nB) is added for BB512 |

Slides 22 (racehorses) and 35 (phenological mismatch) are hidden by default to keep the lecture to 45 minutes; the speaker-note timings add up to 45 minutes for the visible slides. The worked-example slide (`10_east_variances.R`), added after the PPTX was built and inserted in the Keynote deck before "Partitioning East's data", adds about 2.5 minutes; in the Keynote deck it replaces "Only the F2 has genetic variation" and "Partitioning East's data" (both now skipped), so `03a_variance_vg_ve.png` is no longer shown and the visible slides total about 44.5 minutes. "Genetic variance has parts" went from 1.5 to 2 minutes when the epistasis-only row was added, so the total is now about 45 minutes.

`images/prepare_images.py` crops or letterboxes photographs and published figures to their placeholder sizes (sources in `images/source/`, credits in `images/CREDITS.md`). `build_deck.py` builds the PPTX from `BB512_Theme.pptx`, including speaker notes. Inline markup in slide text: `*italic*`, `**bold**`, `~subscript~`, `^superscript^`, and backticks for code (set in Menlo).

    python3 build_deck.py ../theme/BB512_Theme.pptx "BB512 - 15 - Polygenic inheritance and quantitative genetics.pptx"

The figures were rendered for checking without Avenir Next (Inter was substituted). Re-run `render_all.R` on a Mac with Avenir Next before final use, and look at the PNGs.
