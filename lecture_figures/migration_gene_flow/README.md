# BB512 Lecture 12: Migration, gene flow and differentiation — ggplot2 figures

Reproducible figures for the revised Lecture 12 (Neal 2004, Chapter 9), styled with
`R/theme_bb512.R` to match `BB512_Theme.pptx`. Model code is in `R/models.R`.

Run from this folder: `source("render_all.R")` (needs ggplot2, scales, ragg; ggforce not needed).
PNG (300 dpi) and PDF go to `figures/`. The font defaults to Avenir Next; set
`Sys.setenv(BB512_FONT = "Helvetica")` to override without editing the theme. The PNGs in this
folder were rendered on Linux with Nunito Sans as a stand-in, so **re-run on your Mac** to get
Avenir Next before final use.

`theme_bb512.R` here adds the `fullbox` layout (11.733 × 4.25 in) described in
`BB512_figure_instructions.md`, and the `BB512_FONT` override.

| Script | Slide | Type | Notes |
|---|---:|---|---|
| `08_four_models.R` | 8 | Schematic | Continent–island, island (direct exchange, no pool), stepping-stone, isolation by distance |
| `09_continent_island_diagram.R` | 9 | Schematic | Neal Eqn 9.1 in pictures |
| `09b_one_generation_counted.R` | 10 | Schematic | 95 residents + 5 immigrants: Eqn 9.1 by counting (Neal Example 9.2 numbers) |
| `09c_gap_shrinks.R` | 11 | Analytical | Gap to mainland shrinks by (1 − m) each generation (Eqn 9.2) |
| `10_continent_island_curve.R` | 10 | Analytical | Eqn 9.2; Neal Example 9.2 (sweet clover), m = 0.01/0.05/0.2 |
| `13_island_model.R` | 13 | Deterministic iteration | Neal Fig. 9.1 / Appendix 9.1; q = 0.2–0.8, m = 0.1 |
| `15_migration_selection.R` | 15 | Analytical, checked by iteration | q̂ = √(m/s), s = 0.25, wings recessive; exact when censused after immigration |
| `17_stepping_stone_diagram.R` | 17 | Schematic | Neal Fig. 9.3 |
| `18_stepping_stone_cline.R` | 18 | Deterministic iteration to equilibrium | Neal Fig. 9.4; m = 0.2, barrier m = 0.05 between 4–5 and 5–6 |
| `21_copper_tolerance.R` | 19 | **Schematic** (half width) | Pattern from McNeilly (1968) text; values illustrative, not data |
| `23b_why_heterozygosity.R` | 24 | Analytical | Why heterozygosity measures differentiation: H_S falls below H_T as populations diverge |
| `24_heterozygosity_levels.R` | 24 | Schematic | H_I, H_S, H_T and F_IS, F_ST, F_IT |
| `27b_number_vs_proportion.R` | 28 | Analytical rules of thumb | Drift beaten when N_e·m ≈ 1 (a number); selection swamped when m ≈ s (a proportion); s = 0.01 |
| `28_fst_nm.R` | 28 | Analytical | F_ST ≈ 1/(4Nm + 1); checkerspot band Nm 3.8–14.5 (7 of 8 loci; Slatkin 1987, Table 1) |

`build_deck.py` rebuilds the PPTX from `BB512_Theme.pptx` (python-pptx), including all speaker notes.
