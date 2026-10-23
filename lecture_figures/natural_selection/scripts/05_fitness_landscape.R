# Slide "Fitness landscapes": a one-trait fitness landscape (Wright 1932, drawn in its
# phenotypic form) with a lower local peak and a higher global peak.
# SCHEMATIC. Mean fitness is the sum of two Gaussian peaks (illustrative shapes, no data).
# The population (dots) sits on the local peak; selection alone moves the population mean
# uphill only, so it cannot cross the valley to the higher peak.
source("R/theme_bb512.R")
fam <- "Avenir Next"
fit <- function(x) 0.62 * exp(-(x - 2.6)^2 / (2 * 0.75^2)) + 1.0 * exp(-(x - 7.2)^2 / (2 * 1.0^2)) + 0.08
x <- seq(0, 10, length.out = 400)
curve_df <- data.frame(x = x, w = fit(x))
set.seed(512)
pop <- data.frame(x = rnorm(25, 2.6, 0.45))
pop$w <- fit(pop$x)
valley_x <- optimize(fit, c(3, 6.5))$minimum
p <- ggplot2::ggplot(curve_df, ggplot2::aes(x, w)) +
  ggplot2::geom_area(fill = bb512$pale, colour = NA) +
  ggplot2::geom_line(colour = bb512$forest, linewidth = 1.5) +
  ggplot2::geom_point(data = pop, colour = bb512$clay, size = 3, alpha = 0.85) +
  ggplot2::annotate("text", x = 2.6, y = 0.86, label = "Local peak:\npopulation stuck here", family = fam,
                    size = 5, colour = bb512$clay, fontface = "bold", lineheight = 0.9) +
  ggplot2::annotate("text", x = 7.2, y = 1.2, label = "Higher (global) peak", family = fam,
                    size = 5, colour = bb512$forest, fontface = "bold") +
  ggplot2::annotate("text", x = valley_x, y = 0.56, label = "Valley:\nselection\ncannot cross",
                    family = fam, size = 5, colour = bb512$grey, lineheight = 0.9) +
  ggplot2::scale_y_continuous(limits = c(0, 1.32), breaks = NULL) +
  ggplot2::scale_x_continuous(breaks = NULL) +
  ggplot2::labs(x = "Trait value", y = "Mean fitness") +
  theme_bb512() +
  ggplot2::theme(panel.grid.major.y = ggplot2::element_blank())
save_bb512(p, "05_fitness_landscape", layout = "takeaway")
