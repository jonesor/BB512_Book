# Migration and gene flow

From the book project root:

```r
source("lecture_figures/render_all.R")
render_lecture("migration_gene_flow")
```

Also included by `source("lecture_figures/generate_all.R")`.

`scripts/01_migration_selection.R` generates
`figures/01_migration_selection.png`, using the BB512 lecture theme (Avenir Next,
cream background, forest green and clay). Parameters: selection coefficient
s = 0.25; immigration rates m = 0 to 0.15; highlighted rates 0.01 and 0.10.
There are no random draws, so a seed is unnecessary.

The supplied migration-selection approximation is q = sqrt(m/s), with recessive
winged phenotype frequency q^2 = m/s. It assumes the wing allele arrives from
the mainland and is selected against when homozygous on the island, using HWE
to convert allele to phenotype frequencies. Treat these as approximate curves,
especially where m is not small relative to s. Exact equilibria depend on the
specified migration/selection life cycle and mainland allele frequency.

Titles and explanatory captions belong on the lecture slide.

## Progressive migration, drift and selection figures

`scripts/02_migration_drift_selection.R` exports five matched PNGs,
`figures/02_migration_build_01.png` through `02_migration_build_05.png`:

1. Drift/migration benchmark: Ne m = 1.
2. Illustrative migration/selection benchmark: m = s = 0.01.
3. Both benchmarks together.
4. Shaded region between them, where reduced neutral differentiation can
   coexist with local adaptation.
5. Worked example: Ne = 10,000, m = 0.001, Ne m = 10 and neutral FST ~ 0.024.

Every image uses identical log axes, margins and the `fullbox` export size
(11.733 x 4.250 inches, 300 dpi). They are deterministic; seeds are unnecessary.
The script also exports `02_migration_build_01_half.png` through
`02_migration_build_05_half.png` using the taller `half` layout
(5.567 x 4.250 inches). These retain the same data and axis limits, with
wrapped annotations and compact axis labels for Figure & Bullets slides.
For an exact 1.78:1 aspect ratio, use `02_migration_build_01_1_78.png` through
`02_migration_build_05_1_78.png` (10.68 x 6 inches; 3204 x 1800 pixels).
Run the script alone with:

```r
source("lecture_figures/render_all.R")
render_lecture("migration_gene_flow", "02_migration_drift_selection.R")
```

These are schematic comparisons, not sharp universal boundaries. The FST
example uses 1/(1 + 4Ne m) for neutral loci in an idealised diploid island model
at migration-drift equilibrium, with equally sized demes and symmetric
migration. It is not a selected-locus prediction or an inference of migration
from real data. Whether local adaptation persists depends on the genetic and
demographic model; m/s alone does not settle the outcome. See
[Whitlock and McCauley (1999)](https://www.nature.com/articles/6884960).

## Revised Lecture 12 figures (merged from `lecture12-migration-figures`)

| Script | Slide | Type | Notes |
|---|---:|---|---|
| `08_four_models.R` | 8 | Schematic | Continent–island, island (direct exchange, no pool), stepping-stone, isolation by distance |
| `09_continent_island_diagram.R` | 9 | Schematic | Neal Eqn 9.1 in pictures |
| `09b_one_generation_counted.R` | 10 | Schematic | 95 residents + 5 immigrants: Eqn 9.1 by counting (Neal Example 9.2 numbers) |
| `09c_gap_shrinks.R` | 11 | Analytical | Gap to mainland shrinks by (1 − m) each generation (Eqn 9.2) |
| `10_continent_island_curve.R` | 10 | Analytical | Eqn 9.2; Neal Example 9.2 (sweet clover), m = 0.01/0.05/0.2 |
| `13a_island_setup.R` | 14 | Schematic | Model 2 set-up: four islands, all exchanging migrants |
| `13_island_model.R` | 13 | Deterministic iteration | Neal Fig. 9.1 / Appendix 9.1; q = 0.2–0.8, m = 0.1 |
| `16a_migsel_setup.R` | 17 | Schematic | Windy-island set-up (Neal Fig. 9.2 style) |
| `15_migration_selection.R` | 15 | Analytical, checked by iteration | q̂ = √(m/s), s = 0.25, wings recessive; exact when censused after immigration |
| `17_stepping_stone_diagram.R` | 20 | Schematic | Nine-population chain along an environmental gradient |
| `18_stepping_stone_cline.R` | 18 | Deterministic iteration to equilibrium | Neal Fig. 9.4; m = 0.2, barrier m = 0.05 between 4–5 and 5–6 |
| `21_copper_tolerance.R` | 19 | **Schematic** (half width) | Pattern from McNeilly (1968) text; values illustrative, not data |
| `23b_why_heterozygosity.R` | 24 | Analytical | Why heterozygosity measures differentiation: H_S falls below H_T as populations diverge |
| `24_heterozygosity_levels.R` | 24 | Schematic | H_I, H_S, H_T and F_IS, F_ST, F_IT |
| `27b_number_vs_proportion.R` | 28 | Analytical rules of thumb | Drift beaten when N_e·m ≈ 1 (a number); selection swamped when m ≈ s (a proportion); s = 0.01 |
| `28_fst_nm.R` | 28 | Analytical | F_ST ≈ 1/(4Nm + 1); checkerspot band Nm 3.8–14.5 (7 of 8 loci; Slatkin 1987, Table 1) |

`build_deck.py` rebuilds the PPTX from `BB512_Theme.pptx` (python-pptx), including all speaker notes.

Model code for these scripts is in `R/models.R`. All scripts render through the shared runner above (PNG only).
