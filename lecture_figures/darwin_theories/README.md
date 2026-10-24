# BB512: Darwin and his theories, figures and deck builder

Reproducible figures and deck builder for the revised BB512 lecture 01 "Darwin and his theories" (Neal 2004 chapters 1–2; Neal 2018 chapters 1–2). Figures use `R/theme_bb512.R` (copied unchanged from `polygenic_quantitative_genetics`). No titles or captions in the figures; these belong on the slide.

Run all figures from this folder with `source("render_all.R")` or `LANG=C.UTF-8 Rscript render_all.R`. Needs ggplot2, scales and ragg. Each script writes a 300 dpi PNG to `figures/`. Set the environment variable `BB512_FONT` to override the font (default Avenir Next).

| Script | Slide | Layout | Description | Type |
|---|---|---|---|---|
| `01_timeline.R` | 15 | `full` | Darwin's life and ideas 1809–1900, with the Beagle voyage and the 20-year delay | Historical dates |
| `02_malthus.R` | 28 | `takeaway` | Population doubling every 25 years against food increasing by a fixed amount (Malthus's own numbers) | Analytical |
| `03_facts_inferences.R` | 29 | `full` | Darwin's argument: five facts, three inferences (Neal, after Mayr 1982) | Schematic |
| `04_blending.R` | 42 | `takeaway` | Variance under blending (halves each generation) vs particulate inheritance (20 loci) | Simulation, N = 2000, seed 512 |
| `05_speciation_pump.R` | 33 | `full` | Allopatric "species pump": a falling lake level splits one species into two | Schematic, redrawn from the previous deck |

`images/prepare_images.py` crops, letterboxes and assembles photographs into grids at their placeholder sizes (sources in `images/source/`, credits in `images/CREDITS.md`). `build_deck.py` builds the PPTX from `BB512_Theme.pptx`, copying bullet and paragraph styles from the theme's sample slides, and writes speaker notes for every slide. Inline markup: `*italic*`, `**bold**`, `~subscript~`, `^superscript^`, backticks for code (Menlo).

    python3 images/prepare_images.py
    python3 build_deck.py "/Users/jones/Desktop/Keynote Themes/BB512_Theme.pptx" "BB512 - 01 - Darwin and his theories.pptx"

The figures were rendered for checking without Avenir Next (Inter was substituted). Re-run `render_all.R` on a Mac with Avenir Next before final use, and look at the PNGs.
