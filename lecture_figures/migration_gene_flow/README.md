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
