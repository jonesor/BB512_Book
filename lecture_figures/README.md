# Lecture figures

Lecture-specific figure generators and their outputs live here so that they
remain separate from the Bookdown source and rendered book files.

## RStudio Console

To immediately generate all lectures from the repository root:

```r
source("lecture_figures/generate_all.R")
```

With the book project open, load the shared runner from the repository root.
This loads the commands without generating figures:

```r
source("lecture_figures/render_all.R")

# Generate one lecture
render_lecture("natural_selection")
render_lecture("hardy_weinberg")
render_lecture("inbreeding")
render_lecture("mutation_genetic_variation")
render_lecture("haploid_zygotic_selection")
render_lecture("polygenic_quantitative_genetics")
render_lecture("life_tables")
render_lecture("age_stage_structured_models")
render_lecture("life_histories")
render_lecture("sexual_selection")

# Generate all lectures
render_lectures()

# Generate one figure script within a lecture
render_lecture("inbreeding", script = "04_heterozygote_deficit.R")
```

The runner resolves paths automatically and restores your working directory
and random-number state afterwards. Each figure script and its helpers run
in a separate environment. Stochastic scripts retain their existing seeds.
After loading the runner, its commands work even if you change working directory.

Before every script, the runner resets the seed to `512` using
`Mersenne-Twister`, `Inversion` and `Rejection` RNG settings. This makes random
draws independent of which scripts ran earlier. Individual scripts can override
the default: the fluctuation simulation uses `51205`, drift versus selection
uses `51206`, and the gene-pool illustration uses `512`. The neutral-mutation
figure searches from seed `1` reproducibly for its illustrative fixation outcome.
The fluctuation plots also fix their point-jitter seed to `1`.
The runner restores both the caller's RNG settings and random-number state,
including when rendering fails.

## Terminal

From the repository root:

```sh
Rscript lecture_figures/render_all.R all
Rscript lecture_figures/render_all.R hardy_weinberg
Rscript lecture_figures/render_all.R inbreeding 04_heterozygote_deficit.R
```

From another directory, supply the absolute path to the runner. Running it
without arguments also generates all lectures. Existing per-lecture
`render_all.R` files still generate their own lecture when sourced or executed.
Hardy-Weinberg currently generates all its figures together in one script.

## Packages

Install the required packages once. The runner checks dependencies and reports
missing packages; it does not install anything automatically.

```r
install.packages(c("ggplot2", "scales", "ragg", "patchwork",
                   "dplyr", "tibble", "systemfonts"))
```

Hardy-Weinberg uses `ggplot2`, `ragg`, `patchwork`, `dplyr`, `tibble` and
`systemfonts`. Natural selection uses `ggplot2`, `ragg` and `patchwork`. The other lectures use `ggplot2`, `scales` and `ragg`;
inbreeding and haploid/zygotic selection also use `patchwork`.
Use Avenir Next for the intended lecture typography.

## Output

| Lecture | Output location | Formats |
|---|---|---|
| Understanding natural selection | `natural_selection/figures/` | PNG |
| Hardy-Weinberg | `hardy_weinberg/output/full/` and `output/half/` | PNG |
| Inbreeding | `inbreeding/figures/` | PNG |
| Mutation and genetic variation | `mutation_genetic_variation/figures/` | PNG |
| Haploid and zygotic selection | `haploid_zygotic_selection/figures/` | PNG |
| Polygenic inheritance and quantitative genetics | `polygenic_quantitative_genetics/figures/` | PNG |
| Life tables and age-structured population growth | `life_tables/figures/` | PNG |
| Age and stage-structured models | `age_stage_structured_models/figures/` | PNG |
| Evolution of life histories | `life_histories/figures/` | PNG |

Existing names, dimensions and styling are preserved, including the
Hardy-Weinberg figure referenced by the book. Rendering overwrites matching
outputs but does not remove older files. These commands generate lecture
figures; they do not build the book or presentation decks.
