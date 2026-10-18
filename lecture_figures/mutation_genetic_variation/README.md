# BB512: Mutation and genetic variation — ggplot2 figures

These are reproducible R scripts for the illustrated revision of BB512 Lecture 09. All figures match the supplied `BB512_Theme.pptx` (Avenir Next, cream `#FBFAF6`, forest green `#1F4D3F`, gold `#C08A2E`, clay `#A4503A`, blue `#3E6E7E`, etc.). The figure functions deliberately omit titles and captions; these belong in the slide itself.

## Installation and use

1. Open this folder as your working directory in R/RStudio.
2. Install packages once:

```r
install.packages(c("ggplot2", "scales", "ragg"))
```

3. Run all figures:

```r
source("render_all.R")
```

Alternatively run one figure with `source("scripts/06_drift_vs_selection.R")`, etc. Each script generates a 300-dpi PNG and a vector PDF in the `figures/` folder. The PDF is preferable for slide sharpness, while the PNG offers predictable appearance across systems. The fonts rely on your local Avenir Next installation; change `base_family` to `Helvetica` in `R/theme_bb512.R` if needed.

## Mapping to the revised 39-slide presentation

| Script | Intended slide(s) | Description | Model and caveats |
|---|---:|---|---|
| `01_luria_delbruck.R` | 15 | Fluctuation-test resistant colony counts | Simulated growth and Poisson null, **not historical data**; rare-event approximation ignores overlapping mutant lineages |
| `02_neutral_mutation_fate.R` | 18 | Newly arisen neutral allele: loss versus rare fixation | Wright–Fisher, N=20 deliberately small, no mutation or selection; all 600 trajectories shown faintly |
| `03_mutation_pressure.R` | 20 | Irreversible mutation for three rates | Exact deterministic prediction, no back mutation, drift, migration or selection |
| `04_mutation_supply.R` | 23 | New mutants per locus versus population size | `E[M] = 2Nμ`, assumes diploid population and per-allele mutation rate |
| `05_expected_heterozygosity.R` | 28 | `H_E = 2p(1-p)` | Diallelic locus; *expected* (not observed) heterozygosity |
| `06_drift_vs_selection.R` | 32 | Matched allele-frequency simulations | Wright–Fisher finite-population sampling in both panels; selection is additive in one panel |
| `07_heterozygote_advantage.R` | 35 | Genotype fitness and stable allele-frequency equilibrium | Two outputs; fitness coefficients are *illustrative*, not measured from malaria data |
| `08_frequency_dependent_selection.R` | 36 | Rare-colour advantage in orchid morphs | Symmetric illustrative model, not fitted to field observations of orchids |
| `09_pesticide_resistance.R` | 38 | Selection on standing resistance | Deterministic haploid model, resistance already present; selection begins at generation 15 |

## PowerPoint sizes (inches)

The export wrapper accepts `layout = "full"`, `"takeaway"`, `"half"`, `"third"`, or `"slide"`. Dimensions correspond directly to the supplied theme:

- `full`: **11.733 × 3.950** — Title & Photo
- `takeaway`: **7.400 × 4.250** — Title, Bullets & Photo
- `half`: **5.567 × 4.250** — Figure & Bullets
- `third`: **3.644 × 5.300** — Photo – 3 Up
- `slide`: **13.333 × 7.500** — full slide

The default exports use a `full` figure box. If placing a figure in a half-width figure placeholder, change its `save_bb512(... layout = "half")` call. For very dense figures, use full-width plots to protect legibility.

## Population-genetic assumptions worth explaining aloud

- The fixation probability of a single newly arisen **neutral** allele in a finite diploid Wright–Fisher population is `1/(2N)`. A neutral allele is therefore **not inevitably lost**.
- The Luria–Delbrück figure contrasts outcomes **if mutations arose before selection** with a simplified null of **independent mutation at exposure**. It does **not** imply that mutagens cannot alter mutation rates; the crucial principle is randomness *with respect to adaptive need*.
- Mutation pressure and mutation supply are different quantities. Mutation alone generally changes allele frequencies slowly, yet large populations generate substantial numbers of mutant copies across generations.
- The overdominance curves use simple hypothetical genotype relative fitnesses to show a stable polymorphism. They should **not** be interpreted as real estimates for a particular human population.
- The rare-morph fitness curves are a pedagogical approximation motivated by frequency-dependent pollinator behaviour, not a quantitative reconstruction of the elderflower orchid study.
- The pesticide resistance model assumes standing resistance and haploid selection for simplicity; it makes no claim that real insect resistance is always haploid, monogenic, or free of dominance and fitness costs.

## Editing simulations

Each figure has a small block near the top containing parameters (population size, selection strength, mutation rate, generations and seed). Adjust these freely and rerun. All stochastic figures call `set.seed()` for reproducibility.

## Validation

All equations and simulation specifications were independently checked against their stated models. **R execution was not available in the authoring environment**, so the scripts have not been run end-to-end there; please run `source("render_all.R")` locally and inspect exports before including them in the slides.
