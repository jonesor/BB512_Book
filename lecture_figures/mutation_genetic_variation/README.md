# BB512: Mutation and genetic variation, ggplot2 figures

From the book project root, use the [shared runner](../README.md):

```r
source("lecture_figures/render_all.R")
render_lecture("mutation_genetic_variation")
# Or one figure:
render_lecture("mutation_genetic_variation", script = "02_neutral_mutation_fate.R")
```

Reproducible figures for BB512 Lecture 09, "Mutation and genetic variation" (Keynote deck "BB512 - 09 - Mutation and genetic variation"). Styled with `R/theme_bb512.R` to match the BB512 theme (Avenir Next, background `#FBFAF6`). No titles or captions in the figures; these belong on the slide. Each script writes a 300 dpi PNG to `figures/`. Labels use plotmath rather than Unicode sub/superscripts; run from a terminal with `LANG=C.UTF-8 Rscript render_all.R`.

Needs ggplot2 (3.4 or later), scales and ragg. `R/simulations.R` holds the shared Wright-Fisher, viability-selection and fluctuation-test helpers.

All scripts were run end-to-end with the shared runner on 1 November 2026.

| Script | Output(s) | Slide | Layout | Description | Type |
|---|---|---|---|---|---|
| `01_luria_delbruck.R` | `01a_luria_delbruck_prediction.png` | "Prediction: jackpots create a long tail" | `takeaway` | Resistant colonies per culture if resistance is induced at exposure (Poisson) vs arises during growth | Simulated |
| | `01b_luria_delbruck_data.png` | "The evidence: jackpots create a long tail" | `takeaway` | Luria and Delbruck (1943) colony counts: samples from one culture vs independent cultures | Published data; means and variances as published |
| `01c_luria_delbruck_trees.R` | `01c_luria_delbruck_trees.png` | "The mean can't tell them apart; the variance can" | `half` | Lineage trees (five divisions) under induced vs pre-existing mutation; both total 11 resistant colonies | Schematic |
| `02_neutral_mutation_fate.R` | `02_neutral_mutation_fate.png` | "Model 1: the fate of one new mutation" | `takeaway` | One new neutral copy in each of 2N = 40 populations (N = 20): 39 lost, 1 fixed, as 1/(2N) predicts | Wright-Fisher simulation; seed chosen so exactly one fixes (disclosed in script) |
| `03_mutation_pressure.R` | `03_mutation_pressure.png` | "Mutation pressure usually changes p slowly" | `takeaway` | p_t = p_0(1 - mu)^t for three mutation rates | Analytical; one-way mutation only |
| `03b_reversible_equilibrium.R` | `03b_reversible_equilibrium.png` | "...but the equilibrium is reached very slowly" | `takeaway` | Two-way mutation (mu = 1e-5, nu = 1e-6) approaching q_hat = 0.91 from both starts; halfway in ~63,000 generations | Analytical |
| `04_mutation_supply.R` | `04_mutation_supply.png` | "Why mutation supply depends on population size" | `half` | E(M) = 2N mu against N for three mutation rates | Analytical |
| `05_expected_heterozygosity.R` | `05_expected_heterozygosity.png` | "Expected heterozygosity measures gene diversity" | `takeaway` | H_e = 2pq, with three labelled points | Analytical |
| `06_drift_vs_selection.R` | `06_drift_vs_selection.png` | "Drift and selection look different through time" | `half` | Replicate trajectories under drift alone vs additive selection (N = 120, p_0 = 0.2, s = 0.12) | Wright-Fisher simulation |
| `07_heterozygote_advantage.R` | `07a_heterozygote_advantage_fitness.png` | "Selection can also maintain variation" | `takeaway` | Relative fitness of HbA/HbA, HbA/HbS, HbS/HbS | Illustrative fitnesses, not measured values |
| | `07b_heterozygote_advantage_equilibrium.png` | (spare; not in the current deck) | `takeaway` | Approach to the stable overdominance equilibrium | Deterministic |
| `08_frequency_dependent_selection.R` | `08_negative_frequency_dependence.png` | "Each colour does best when it is rare" | `takeaway` | Fitness of purple and yellow orchid morphs against frequency; lines cross at a stable balance | Schematic, not fitted to *Dactylorhiza sambucina* data |
| `09_pesticide_resistance.R` | `09_pesticide_resistance.png` | "Standing variation gives resistance a head start" | `half` | Resistance allele already present (1 in 1,000) vs waiting for a new mutation (arrives 40 generations later) | Deterministic haploid selection, s = 0.25 |
| `10_loci_matrix.R` | `10_loci_matrix.png` | "Natural populations contain many alleles" | `half` | Genotypes of six individuals at three loci with 4, 2 and 1 alleles; heterozygotes highlighted | Schematic |
| `11_allele_evenness.R` | `11_allele_evenness.png` | "The number of alleles is not enough" | `fullbox` | Two populations with two alleles each: H_e = 0.50 vs 0.058 | Schematic |
| `12_gene_pool_tub.R` | `12_gene_pool_tub.png` | "The gene pool is a leaky tub" | `takeaway` | Mutation pours new alleles into the gene pool; drift and selection drain them out | Schematic; redrawn after the original lecture diagram |

Slide titles rather than numbers are given, because slide numbers change as the deck is edited.

## Sizes (inches)

`save_bb512(..., layout = )` accepts:

- `full`: 11.733 x 3.950 (Title & Photo, PPTX placeholder)
- `fullbox`: 11.733 x 4.250 (Title & Photo placeholder as it appears in Keynote)
- `takeaway`: 7.400 x 4.250 (Title, Bullets & Photo)
- `half`: 5.567 x 4.250 (Figure & Bullets)
- `third`: 3.644 x 5.300 (Photo - 3 Up)
- `slide`: 13.333 x 7.500 (whole slide)

Placeholders fill and crop, so export at the placeholder's real aspect ratio.

## Points worth explaining aloud

- A new neutral allele is usually lost, but is not inevitably lost: it fixes with probability 1/(2N).
- Luria and Delbruck show that mutation is random with respect to need: resistance mutations arose during growth, before any contact with phage. This does not mean mutation rates are uniform or unaffected by mutagens.
- Mutation pressure (a change in allele frequency of order mu per generation) is weak, but mutation supply (2N mu new copies per generation) can be large.
- A mutation-only equilibrium exists (q_hat = mu / (mu + nu)), but it takes of the order of 10^5 generations to approach; observed allele frequencies are set mainly by drift and selection.
- The overdominance, frequency-dependence and pesticide figures are illustrative models, not estimates for particular populations.

## Editing

Each script has its parameters (population size, rates, generations, seed) near the top. Stochastic figures set their own seed; the shared runner also resets the seed before each script so results do not depend on run order.
