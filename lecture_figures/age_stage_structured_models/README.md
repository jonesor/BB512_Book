# BB512: Age and stage-structured models, figures and deck builder

From the book project root, use the [shared runner](../README.md):

```r
source("lecture_figures/render_all.R")
render_lecture("age_stage_structured_models")
```

Reproducible figures for the revised BB512 lecture 6 "Age and stage-structured models" (Neal 2004, Chapter 15.3; the course schedule lists "Neal 7" in the current edition), styled with `R/theme_bb512.R` (copied unchanged from `polygenic_quantitative_genetics`). No titles or captions in the figures; these belong on the slide.

Every matrix is defined once, in `R/mpm_models.R` (columns = stage at time *t*, rows = stage at *t* + 1), together with base-R helpers for λ, stable stage distribution, reproductive value, sensitivity and elasticity (same results as `popdemo::eigs()` and `popdemo::elas()`). `R/diagram_helpers.R` draws life cycle diagrams with ggplot2 geometry. Needs ggplot2, scales and ragg. Each script writes a 300 dpi PNG to `figures/`. `scripts/00_check_numbers.R` prints every number used on the slides and in the speaker notes (it makes no figure).

| Script | Slide | Layout | Description | Type |
|---|---|---|---|---|
| `00_check_numbers.R` | all | none | λ, stable stage distributions, elasticities, worked projection, in silico results | Analytical |
| `01_leslie_diagram.R` | 8, 10 | `full` | Age-based diagram: survival only (01a), then with fertility F(x) = g(x) b(x+1) (01b) | Analytical, from the life table |
| `02_stage_diagram.R` | 13–16 | `full`, `takeaway` | Juvenile/adult/senescent diagram built in three steps; `takeaway` copy for the "Your turn" slide | Illustrative values |
| `03_whale_diagram.R` | 24 | `full` | Resident killer whale life cycle (females) | Empirical (Brault & Caswell 1993) |
| `04_whale_projection.R` | 26 | `full` | Projection from two starting vectors over 60 years, log scale | Analytical, empirical matrix |
| `05_whale_ssd.R` | 28 | `takeaway` | Stable stage distribution | Analytical, empirical matrix |
| `06_whale_elasticity.R` | 33 (hidden) | `takeaway` | Elasticity of each matrix element, laid out as the matrix | Analytical, empirical matrix |
| `07_crouse_elasticity.R` | 38 | `takeaway` | Loggerhead elasticities by stage and transition type | Analytical, published matrix (Crouse et al. 1987) |
| `08_crouse_in_silico.R` | 39 | `takeaway` | λ after halving the mortality of one stage, with stay/grow recalculated from survival and stage duration as in Crouse et al. (1987); 100% egg survival | Analytical, published stage survivals and durations |
| `09_fox_diagram.R` | 40 (hidden) | `full` | Red fox life cycle, Bristol (age classes 0, 1, 2, 3+) | Empirical (Devenish-Nelson et al. 2013, via COMADRE) |
| `10_life_history_contrast.R` | 42 (hidden) | `takeaway` | Elasticity split into reproduction, pre-breeding survival and breeder survival: fox, loggerhead, killer whale | Analytical, three empirical matrices |

Slides 25 ("From diagram to matrix"), 33 (killer whale elasticities) and 40–42 (red fox: a fast life history, contrasted with the loggerhead and killer whale) are hidden by default to keep the lecture to 45 minutes; the speaker-note timings add up to about 48 minutes for the visible slides. Slides 36–37 show the loggerhead projection matrix beside its elasticity matrix as native text (values hard-coded in `build_deck.py` from `00_check_numbers.R`), first plain for students to find the big numbers, then highlighted.

`images/prepare_images.py` crops or letterboxes photographs to their placeholder sizes (sources in `images/source/`, credits in `images/CREDITS.md`). `build_deck.py` builds the PPTX from `BB512_Theme.pptx`, including speaker notes. Matrices on the slides are native, editable text boxes (one per cell) with brackets drawn as lines. Inline markup in slide text: `*italic*`, `**bold**`, `~subscript~`, `^superscript^`, and backticks for code (set in Menlo).

    python3 images/prepare_images.py
    python3 build_deck.py "/Users/jones/Desktop/Keynote Themes/BB512_Theme.pptx" "BB512 - 06 - Age and stage-structured models.pptx"

The figures were rendered for checking without Avenir Next (Inter was substituted). Re-run the figures on a Mac with Avenir Next before final use, and look at the PNGs.

## Changes from the previous version (2025 deck)

- Age-based (Leslie) matrix: the top row used raw births b(x) (0, 2, 3, 1). With a post-breeding census fertility is F(x) = g(x) b(x+1) (Neal Eqn 15.8), giving 1.6, 1.5, 0.25, 0; λ = 2.17 rather than 1.55.
- Puerto Rican parrot (illustrative and biologically implausible vital rates) replaced by the published resident killer whale matrix (Brault & Caswell 1993; Caswell 2001 Example 5.1), λ = 1.0254. The old parrot scripts `03_parrot_diagram.R` to `06_parrot_elasticity.R` are now empty stubs; they and `figures/0[3-6]_parrot_*.png` can be deleted.
- Loggerhead in silico experiment: stay and grow are now recalculated from stage survival and duration, as in Crouse et al. (1987); halving large-juvenile mortality gives λ = 1.044 (previously 0.992 with proportional scaling).
- Stochastic slide: n_t × A corrected to A_t × n_t.
- Assumptions: "exponential growth once stable structure is reached" (a consequence) replaced by closed population, females only, fixed projection interval and census time.
- Added: learning objectives, census-timing key concept, "write the matrix" activity, prediction step in the worked projection, λ as dominant eigenvalue and the stable stage distribution, Crouse et al. context slide, published-matrix elasticity and in silico figures (replacing screenshots of the paper), LTRE in the practical preview.
