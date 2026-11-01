# BB512: Writing short answers (practical), ggplot2 figures

Reproducible figures for the practical deck "Writing short answers", built by
`build_deck.py`. Styled with `R/theme_bb512.R` (the shared BB512 theme, plus a
`titlepic` layout sized for the Title layout's picture placeholder).

Render from the repository root with the shared runner:

```r
source("lecture_figures/render_all.R")
render_lecture("short_answers")
```

or `Rscript lecture_figures/render_all.R short_answers`. Sourcing this folder's
`render_all.R` does the same. Needs ggplot2 and ragg. Each script writes a
300 dpi PNG to `figures/`.

| Script | Slide | Layout | Description | Type |
|---|---|---|---|---|
| `01_paragraph_graphics.R` | 1 (title) | `titlepic` | `01_title_paragraph`: a paragraph as bars, light on forest | Schematic |
| `01_paragraph_graphics.R` | Anatomy of a paragraph | `half` | `02_paragraph_anatomy`: topic (forest), supporting (blue), concluding (gold) sentences | Schematic |

No text in the figures, so they do not depend on Avenir Next being installed.
