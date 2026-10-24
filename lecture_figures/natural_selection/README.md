# BB512: Understanding natural selection, figures and deck builder

Reproducible figures for the revised BB512 lecture 02 "Understanding natural selection" (Neal 2004, chapter "Understanding natural selection"), styled with `R/theme_bb512.R` (copied unchanged from `haploid_zygotic_selection`). No titles or captions in the figures; these belong on the slide.

Run all figures with `render_lecture("natural_selection")` after `source("lecture_figures/render_all.R")`, or from this folder with `source("render_all.R")` / `LANG=C.UTF-8 Rscript render_all.R`. Needs ggplot2, ragg and patchwork. Figures do not rely on colour alone (shapes or direct labels). Each script writes a 300 dpi PNG to `figures/`.

| Script | Slide | Layout | Description | Type |
|---|---|---|---|---|
| `01_rs_variation.R` | 7 | `full` | Great tit clutch sizes (SDU) and Soay sheep lifetime offspring | Empirical, **digitised** from the previous slide's histograms; replace with raw data if available |
| `02_trait_rs.R` | 8 | `full` | Selection for larger, for smaller, and no selection (neutral) | Simulated (Poisson, seed 512) |
| `03_cumulative_selection.R` | 14 | `takeaway` | METHINKS IT IS LIKE A WEASEL: keep correct letters vs random typing | Simulated (seed 512; target reached in generation 99) |
| `04_guppy_life_history.R` | 23 | `takeaway` | Age and mass at maturity, Aripo River, 11 years after introduction (populations differ in shape as well as colour) | Empirical, Reznick et al. (1997) Table 1 |
| `05_fitness_landscape.R` | 28 | `takeaway` | One-trait landscape with local and global peaks | Schematic |
| `06_gene_flow.R` | 29 | `full` | Desert and grassland forms with and without gene flow | Schematic (redrawn from the previous version); forms differ in shape as well as colour |
| `07_antibiotic_fitness.R` | 26 | `half` | Growth of susceptible and resistant bacteria with and without antibiotic | Illustrative values, not data |

`images/prepare_images.py` crops or letterboxes photographs to their placeholder or frame sizes (sources in `images/source/`, mostly extracted from the 2022 deck; credits in `images/CREDITS.md`). `build_deck.py` builds the PPTX from `BB512_Theme.pptx`, including speaker notes with timings (about 43 minutes in total):

    python3 images/prepare_images.py
    python3 build_deck.py "/Users/jones/Desktop/Keynote Themes/BB512_Theme.pptx" "BB512 - 02 - Understanding Natural Selection.pptx"

The Nilsson & Pelger "< 400,000 generations" Big Fact slide was removed; its content is now an optional aside in the notes of "Two camera eyes, two histories" (16). Antibiotic resistance (26) is the next candidate to cut if short of time.

The figures and the check render were made without Avenir Next (Inter was substituted). Re-run the figures on a Mac with Avenir Next before final use, and look at the PNGs and the deck in Keynote: text in the theme font may wrap slightly differently.
