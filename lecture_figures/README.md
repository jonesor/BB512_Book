# Lecture figures

Lecture-specific figure generators and their outputs live here so that they
remain separate from the Bookdown source and rendered book files.

Run each generator from the repository root:

```r
source("lecture_figures/hardy_weinberg/generate_figures.R")
```

Each lecture directory contains:

- `generate_figures.R`: the reproducible source code.
- `output/full/`: figures prepared for full-width placement.
- `output/half/`: figures prepared for half-width placement.

Generators write PNG files only.
