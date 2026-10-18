# Slide 36: Negative frequency-dependent selection.
# Schematic rare-morph advantage for yellow and purple orchid morphs;
# NOT an empirical fit to Dactylorhiza sambucina field data.
source("R/theme_bb512.R")

frequency_purple <- seq(0, 1, by = 0.005)
a <- 0.30
# A symmetrical example: a morph's fitness declines with its OWN frequency.
curves <- data.frame(
  p_purple = rep(frequency_purple, 2),
  fitness = c(1 - a * frequency_purple,
              1 - a * (1 - frequency_purple)),
  morph = factor(rep(c("Purple", "Yellow"), each = length(frequency_purple)),
                 levels = c("Purple", "Yellow"))
)

p <- ggplot2::ggplot(curves,
                     ggplot2::aes(p_purple, fitness, colour = morph)) +
  ggplot2::geom_line(linewidth = 1.45) +
  ggplot2::geom_vline(xintercept = 0.5, linewidth = 0.65,
                      linetype = "dashed", colour = bb512$grey) +
  ggplot2::geom_point(data = data.frame(p_purple = 0.5, fitness = 0.85,
                                       morph = "Purple"), size = 3.6) +
  ggplot2::scale_colour_manual(values = c("Purple" = bb512$clay,
                                           "Yellow" = bb512$gold),
                                name = NULL) +
  ggplot2::scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.2)) +
  ggplot2::scale_y_continuous(limits = c(0.67, 1.03), breaks = seq(0.7, 1, 0.1)) +
  ggplot2::labs(x = "Frequency of purple flowers", y = "Relative fitness (illustrative)") +
  theme_bb512()

save_bb512(p, "08_negative_frequency_dependence", layout = "takeaway")
