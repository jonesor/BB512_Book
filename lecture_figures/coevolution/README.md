# BB512 Lecture 16: Coevolution

Figure scripts for the revised Coevolution lecture (Keynote: iCloud Keynote › BB512 › "BB512 - 16 - Coevolution v2"). Styled with `R/theme_bb512.R`; the font can be overridden with `options(bb512.family = ...)` (default Avenir Next). Outputs are PNG only, in `figures/`.

Render through the shared runner from the repository root:

```r
source("lecture_figures/render_all.R")
render_lecture("coevolution")
render_lecture("coevolution", script = "05_copes_rule_passive.R")
```

or `Rscript lecture_figures/render_all.R coevolution`. Needs ggplot2 (3.4+) and ragg.

`R/models.R` holds two deterministic, illustrative models: `sim_matching_alleles()` (haploid host and parasite, two alleles each; mutation keeps the cycles going) and `sim_escalation()` (two quantitative traits, each selected to exceed the other, with a small cost; not currently used on a slide). `scripts/00_check_numbers.R` prints every number quoted on the slides and in the speaker notes.

| Script | Slide | Layout | Description | Type |
|---|---|---|---|---|
| `00_check_numbers.R` | all | none | Arithmetic and model checks | Analytical |
| `02_red_queen_cycles.R` | 20 | `takeaway` | Host and parasite allele cycles, with time lag | Simulated (matching alleles) |
| `03_cophylogeny_schematic.R` | 38 | `half` | Cospeciation and a host switch | Schematic |
| `04_brower_toads.R` | 28 | `takeaway` | Brower & Brower (1966), via Neal's chapter on predation | Empirical |
| `05_copes_rule_passive.R` | 14 | `takeaway` | Driven vs passive increase in body size (seed 16) | Simulated |
| `06_fig_wasp_schematic.R` | 37 | `half` | Matching fig and wasp trees and traits | Schematic |
| `07_primate_lice.R` | 39 | `half` | Primate and louse trees, host switch (after Reed et al. 2007) | Redrawn, topology only |
| `08_myxoma_lethality.R` | 44 | `takeaway` | Case fatality of myxoma strains (Kerr et al. 2012) | Empirical summary |

Script numbering skips 01: an escalation-vs-fluctuation figure was dropped from the deck.
