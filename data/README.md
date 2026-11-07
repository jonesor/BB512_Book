# Data Sources

This directory contains data files used by the book.

## Generated in-repo
- `heritability_pop1.csv`
- `heritability_pop2.csv`

These are generated in `3_04_Heritability.Rmd` using a fixed seed so results are reproducible.

## External sources
Some exercises reference external files that are not stored here:

- Hawk-dove results:
  - `6_02_HawkDoveResults.Rmd` reads `data/gametheoryResults2022.xlsx` (sheets `Game1_raw`, `Game2_raw`).
  - From the next cohort, class data are entered live in a copy of the "Hawk-Dove Live Results" Google Sheet template (sheets `Game1_Data`, `Game2_Data`, `Live_Dashboard`; see `5_01_HawkDoveCardGame.Rmd`). 6_02 will need updating to read that format.
- Hawk-dove Game 2:
  - Files are stored in `data/` and should be named `gametheoryResultsYYYY.xlsx`.
  - The book will use the most recently modified matching file as the input.

- Excel exercises (Dropbox):
  - Estimating growth: `EstimatingGrowth.xlsx`
  - Stochastic growth: `StochasticPopulationGrowth.xlsx`
  - Predator-prey dynamics PDF

If you prefer local copies, download them and store in `data/`, then update the relevant links in the Rmds.
