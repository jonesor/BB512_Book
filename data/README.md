# Data Sources

This directory contains data files used by the book.

## Generated in-repo
- `heritability_pop1.csv`
- `heritability_pop2.csv`

These are generated in `3_03_Heritability.Rmd` using a fixed seed so results are reproducible.

## External sources
Some exercises reference external files that are not stored here:

- Hawk-dove results:
  - Source: Google Sheets named "Game theory part 1" (downloaded when `downloadNewData == TRUE` in `6_02.HawkDoveResults.Rmd` or `scripts/hawkDoveAnalysis.R`).

- Excel exercises (Dropbox):
  - Estimating growth: `EstimatingGrowth.xlsx`
  - Stochastic growth: `StochasticPopulationGrowth.xlsx`
  - Predator-prey dynamics PDF

If you prefer local copies, download them and store in `data/`, then update the relevant links in the Rmds.
