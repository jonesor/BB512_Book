# BB512: Inbreeding, ggplot2 figures

From the book project root, use the [shared runner](../README.md):

```r
source("lecture_figures/render_all.R")
render_lecture("inbreeding")
# Or generate every lecture:
render_lectures()
```

Reproducible figures for the revised BB512 lecture "Inbreeding" (session 21), styled with `R/theme_bb512.R` (copied unchanged from `mutation_genetic_variation`). No titles or captions in the figures; these belong on the slide.

Run all figures from this folder with `source("render_all.R")`, or `LANG=C.UTF-8 Rscript render_all.R` from a terminal. Needs ggplot2 (3.4 or later, for `linewidth`), scales, ragg and patchwork. Labels use plotmath rather than Unicode sub/superscripts, so they render in Avenir Next. Each script writes a 300 dpi PNG to `figures/`.

| Script | Slide | Layout | Description | Type |
|---|---|---|---|---|
| `01_ancestor_slots.R` | 4 | `half` | 2^t ancestor slots vs generations, with N = 50 and N = 1,000 | Exact arithmetic |
| `02_F_over_time.R` | 7 | `takeaway` | F_t = 1 - (1 - 1/2Ne)^t for Ne = 10, 50, 500 | Analytical; no mutation, migration or selection |
| `03_pedigrees.R` | 9, 10, 11, 13 | `half`, `takeaway`, `full` | Full-sib pedigree: plain (03a), one allele from A (03b), four autozygous routes (03c), path-counting loops (03d) | Schematic; founders unrelated and not inbred |
| `03e_half_sib_answer.R` | 15 | `takeaway` | Answer to the half-sibling activity: one loop (F = 1/8) beside full siblings (two loops, F = 1/4) | Schematic; founders unrelated and not inbred |
| `04_heterozygote_deficit.R` | 18 | `takeaway` | HWE genotype curves; expected vs observed heterozygosity at p = 0.3 | Analytical; illustrative numbers |
| `05_punnett_inbreeding.R` | 19 | `square` | Matched Punnett squares for p = 0.6, q = 0.4: F = 0 and F = 0.25; cell areas to scale | Schematic |
| `06_F_by_relationship.R` | 16 | `takeaway` | F of offspring by relationship, plus Charles II of Spain (F = 0.254; Alvarez et al. 2009) | Analytical + one empirical estimate |

`R/pedigree.R` holds the shared pedigree-drawing helper.

`scripts/07_repeated_relative_mating.R` exports
`figures/07_repeated_relative_mating.png`: ten generations of self-fertilisation,
full-sib, half-sib, first-cousin and unrelated mating. It is included automatically
by the shared runner. No random draws are involved, so no seed is needed.
The starting values are F = 0.5, 0.25, 0.125 and 0.0625 for the first four
crosses, respectively; all founders start at F = 0. The unrelated baseline
assumes an unlimited supply of mates unrelated to the focal lineage.

The half-sib and cousin curves use the recurrences specified in the script as
illustrative repeated mating schemes. Their later values depend on how the
pedigree is propagated; relationship labels alone do not uniquely determine a
trajectory. See [Half-sib mating structures](https://pubmed.ncbi.nlm.nih.gov/8468535/).
State the assumed mating scheme when presenting these curves.

For the Punnett-square comparison, place `05_punnett_no_inbreeding` on the left
and `05_punnett_inbreeding` on the right, at exactly the same displayed size.
Both are exported as 7.4-inch square PNG/PDF files with identical coordinate
limits, so the coloured squares have matching side lengths. Reveal the left
figure first, then the right. Allele frequencies remain p = 0.6 and q = 0.4;
only genotype frequencies change. Use slide headings "No inbreeding (F = 0)"
and "With inbreeding (F = 0.25)".

Suggested explanation for the first reveal: "Even without inbreeding, offspring
can inherit two A1 alleles. They match in type, but are not identical by descent
relative to our ancestral reference." The blue cells are allozygous homozygotes;
the red column in the second reveal adds autozygous (IBD) homozygotes.

The figures were rendered for checking in an environment without Avenir Next (a substitute sans font was used). Re-run `render_all.R` on a Mac with Avenir Next before final use, and look at the PNGs.
