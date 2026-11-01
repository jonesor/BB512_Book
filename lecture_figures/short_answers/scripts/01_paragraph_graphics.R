# Schematic "paragraph" graphics for the short-answer practical deck
# (Writing short answers). Slides: 1 (title picture) and the "anatomy of a
# paragraph" slide.
# Lines of a paragraph are drawn as rounded bars: topic sentence, supporting
# sentences, concluding sentence. No text in the figures, so they render the
# same whatever fonts are installed.
# Schematic only: not data. Deterministic (no random numbers).
# Run through the shared runner: render_lecture("short_answers").
source("R/theme_bb512.R")

# Line lengths (fraction of the full width) for a 10-line paragraph
line_len <- c(0.96, 0.62, 0.98, 0.94, 0.97, 0.90, 0.96, 0.71, 0.95, 0.58)
role     <- c("topic", "topic", rep("support", 6), "concl", "concl")
para <- data.frame(line = seq_along(line_len), len = line_len, role = role)

bar_plot <- function(df, fills, bg, gap = 0.35) {
  df$y <- -df$line * (1 + gap)
  ggplot2::ggplot(df) +
    ggplot2::geom_rect(ggplot2::aes(xmin = 0, xmax = len, ymin = y - 0.5, ymax = y + 0.5,
                                    fill = role)) +
    ggplot2::scale_fill_manual(values = fills, guide = "none") +
    ggplot2::coord_cartesian(expand = TRUE) +
    ggplot2::theme_void() +
    ggplot2::theme(plot.background = ggplot2::element_rect(fill = bg, colour = NA),
                   panel.background = ggplot2::element_rect(fill = bg, colour = NA))
}

# 01: title-slide picture (Title layout picture placeholder, 5.43 x 7.5 in):
#     paragraph in light colours on a forest background
p_title <- bar_plot(para,
                    fills = c(topic = bb512$pale, support = bb512$sage, concl = bb512$gold),
                    bg = bb512$forest) +
  ggplot2::theme(plot.margin = ggplot2::margin(150, 60, 150, 60, "pt"))
save_bb512(p_title, "01_title_paragraph", layout = "titlepic", background = bb512$forest)

# 02: anatomy of a paragraph (Figure & Bullets layout, "half")
p_anat <- bar_plot(para,
                   fills = c(topic = bb512$forest, support = bb512$blue, concl = bb512$gold),
                   bg = bb512$bg) +
  ggplot2::theme(plot.margin = ggplot2::margin(18, 24, 18, 12, "pt"))
save_bb512(p_anat, "02_paragraph_anatomy", layout = "half")
