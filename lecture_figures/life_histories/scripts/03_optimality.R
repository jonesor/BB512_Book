# Slide "Costs and benefits give an intermediate optimum": a generic optimality model.
# SCHEMATIC. Benefit saturates, B(x) = 10 (1 - exp(-x/3)); cost accelerates, C(x) = 0.12 x^2.
# Net benefit (a proxy for fitness) = B - C, maximal at x = 3.85, where the slopes of B and C are equal.
# Replaces the previous diagram, which showed two U-shaped curves and placed the optimum where they were closest.
source("R/theme_bb512.R")
fam <- "Avenir Next"

B <- function(x) 10 * (1 - exp(-x / 3)); C <- function(x) 0.12 * x^2
x <- seq(0, 10, by = 0.02)
opt <- optimize(function(x) B(x) - C(x), c(0, 10), maximum = TRUE)$maximum
d <- rbind(data.frame(x = x, y = B(x), curve = "Benefit"),
           data.frame(x = x, y = C(x), curve = "Cost"),
           data.frame(x = x, y = B(x) - C(x), curve = "Net benefit (fitness)"))
cols <- c("Benefit" = bb512$forest, "Cost" = bb512$clay, "Net benefit (fitness)" = bb512$gold)
lab <- data.frame(x = c(9.9, 7.4, 4.0), y = c(B(9.9) + 0.75, C(7.4) - 1.1, -1.6),
                  curve = names(cols), hj = c(1, 0, 0))

p <- ggplot2::ggplot(d, ggplot2::aes(x, y, colour = curve)) +
  ggplot2::geom_hline(yintercept = 0, colour = bb512$grey, linewidth = 0.5) +
  ggplot2::annotate("segment", x = opt, xend = opt, y = C(opt), yend = B(opt),
                    colour = bb512$ink, linewidth = 0.8,
                    arrow = ggplot2::arrow(ends = "both", length = ggplot2::unit(0.12, "in"))) +
  ggplot2::geom_line(linewidth = 1.4) +
  ggplot2::geom_vline(xintercept = opt, linetype = "dashed", colour = bb512$grey, linewidth = 0.7) +
  ggplot2::annotate("text", x = opt + 0.15, y = 11.6, label = "Optimum", hjust = 0, family = fam,
                    size = 5.4, fontface = "bold", colour = bb512$ink) +
  ggplot2::geom_text(data = lab, ggplot2::aes(label = curve, hjust = hj), family = fam, size = 5.2,
                     fontface = "bold") +
  ggplot2::annotate("segment", x = 7.2, xend = 7.75, y = -1.0, yend = B(7.75) - C(7.75) - 0.35,
                    colour = bb512$gold, linewidth = 0.6) +
  ggplot2::scale_colour_manual(values = cols, guide = "none") +
  ggplot2::scale_x_continuous("Trait value (e.g. age at maturity, clutch size)", breaks = NULL,
                              expand = c(0.01, 0)) +
  ggplot2::scale_y_continuous("Benefit or cost", breaks = NULL, limits = c(-2.5, 12.3)) +
  theme_bb512(base_family = fam) +
  ggplot2::theme(panel.grid.major.y = ggplot2::element_blank())

save_bb512(p, "03_optimality", layout = "takeaway")
