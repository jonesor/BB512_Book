# BB512 Lecture 10: Genetic drift and effective population size: ggplot2 figures

Reproducible figures for the revised Lecture 10 deck, styled with `R/theme_bb512.R` (BB512_Theme.pptx colours, Avenir Next with a Nunito Sans/Helvetica fallback). Run from this folder:

```r
source("render_all.R")   # writes 300-dpi PNG + PDF to figures/
```

| Script | Slide | Layout | Type | Notes |
|---|---|---|---|---|
| `01_hardy_weinberg.R` | Previously: the Hardy–Weinberg principle | half | Analytical | p², 2pq, q² |
| `02_continuum.R` | Adaptive and neutral evolution are two ends of a continuum | full | Illustrative simulation | Sample correlations forced to 0.9, 0.35, 0 |
| `03_sampling_error.R` | Sampling error in allele frequencies | takeaway | Analytical (exact binomial) | One generation from p = 0.5, 2N = 20 vs 200 |
| `04_gene_pool.R` | The gene pool model | full | Schematic | Offspring shift p 0.5 → 0.7 by chance |
| `05_drift_trajectories.R` | Small populations drift faster | full | Wright–Fisher simulation | Seed searched: no N = 100 replicate absorbed by gen 60 and 2–4 N = 10 replicates still variable; seed in `figures/05_drift_trajectories_seed.txt` |
| `06_fixation.R` | Result 1: a neutral allele's fixation probability = its frequency | takeaway | Wright–Fisher simulation | 2N = 20 replicates; seed searched for exactly one fixation; seed in `figures/06_fixation_seed.txt` |
| `07_heterozygosity.R` | Result 2: diversity lost at 1/(2N) | takeaway | Analytical | H_t = H_0 (1 − 1/2N)^t |
| `08_founder_bottleneck.R` | Founder effects and bottlenecks | full | Schematic | Colours = four alleles |

Notes:

- Packages: ggplot2, ragg (which brings systemfonts), scales.
- Font: Avenir Next is used when installed (Mac); otherwise Nunito Sans, then Helvetica. The committed PNG/PDF files were rendered with the Nunito Sans fallback, so re-run `render_all.R` on a Mac to get Avenir Next.
- Seeds: the two illustrative simulations (05, 06) search for a seed that shows the intended pattern; the search conditions are in each script header and the seed used is written to `figures/*_seed.txt`.
- Figures not used by the 45-minute deck (harmonic mean, drift vs selection) were dropped; the worked numbers are in the speaker notes.
