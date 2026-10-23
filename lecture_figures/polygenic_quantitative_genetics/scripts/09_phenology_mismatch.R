# Slide "Plasticity and climate change: phenological mismatch": timing reaction norms of three
# trophic levels (oak bud burst, winter moth caterpillar hatching, great tit hatching) against spring
# temperature. Schematic (redrawn from the previous version of the lecture, slide 28): straight lines,
# illustrative slopes. Left: equal plasticity, so the levels stay in step as springs warm. Right: the bird is
# less plastic than its food, so a gap opens in warm springs.
source("R/theme_bb512.R")
fam <- "Avenir Next"

panels <- c("Equal plasticity: stays matched", "Bird less plastic: mismatch")
lvl <- c("Oak bud burst", "Caterpillars hatch", "Great tits hatch")
cols <- c(bb512$sage, bb512$gold, bb512$forest)
names(cols) <- lvl
mk <- function(panel, slopes) {
  int <- c(0.40, 0.62, 0.85)
  do.call(rbind, lapply(1:3, function(i) data.frame(panel = panel, lvl = lvl[i], t = c(0, 1),
                                                    y = int[i] - slopes[i] * c(0, 1))))
}
d <- rbind(mk(panels[1], c(0.35, 0.35, 0.35)), mk(panels[2], c(0.35, 0.35, 0.08)))
d$panel <- factor(d$panel, panels); d$lvl <- factor(d$lvl, lvl)
labs <- subset(d, t == 0)
gap <- data.frame(panel = factor(panels[2], panels), t = 0.98, y0 = 0.62 - 0.35 * 0.98, y1 = 0.85 - 0.08 * 0.98)

p <- ggplot2::ggplot(d, ggplot2::aes(t, y, colour = lvl)) +
  ggplot2::geom_line(linewidth = 1.5) +
  ggplot2::geom_text(data = labs, ggplot2::aes(label = lvl), hjust = 0, vjust = -0.5, nudge_x = 0.02,
                     family = fam, size = 4.8) +
  ggplot2::geom_segment(data = gap, ggplot2::aes(x = t, xend = t, y = y0, yend = y1), inherit.aes = FALSE,
                        colour = bb512$clay, linewidth = 1,
                        arrow = grid::arrow(ends = "both", length = grid::unit(0.08, "in"))) +
  ggplot2::geom_text(data = data.frame(panel = factor(panels[2], panels), t = 0.95, y = 0.55),
                     ggplot2::aes(t, y), inherit.aes = FALSE, label = "mismatch", hjust = 1, family = fam,
                     size = 5, colour = bb512$clay, fontface = "bold") +
  ggplot2::facet_wrap(~panel, nrow = 1) +
  ggplot2::scale_colour_manual(values = cols, guide = "none") +
  ggplot2::scale_x_continuous(breaks = c(0.05, 0.95), labels = c("Cold", "Warm"), limits = c(0, 1)) +
  ggplot2::scale_y_continuous(limits = c(0, 1), breaks = c(0.1, 0.9), labels = c("Early", "Late")) +
  ggplot2::labs(x = "Spring temperature", y = "Timing (day of year)") +
  theme_bb512() +
  ggplot2::theme(panel.spacing = grid::unit(0.5, "in"), panel.grid.major.y = ggplot2::element_blank())
save_bb512(p, "09_phenology_mismatch", layout = "full")
