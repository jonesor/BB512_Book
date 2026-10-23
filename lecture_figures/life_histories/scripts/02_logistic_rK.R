# Slide "r- and K-selection": logistic growth dN/dt = r N (1 - N/K), with the two regimes that
# MacArthur & Wilson (1967) and Pianka (1970) linked to r- and K-selection (Neal 2004, "Life-history
# strategies: r- and K-selection"). ANALYTICAL curve, illustrative parameters (r = 1, K = 100, N0 = 2).
source("R/theme_bb512.R")
fam <- "Avenir Next"

r <- 1; K <- 100; N0 <- 2
t <- seq(0, 12, by = 0.05)
d <- data.frame(t = t, N = K / (1 + (K - N0) / N0 * exp(-r * t)))

p <- ggplot2::ggplot(d, ggplot2::aes(t, N)) +
  ggplot2::annotate("rect", xmin = 0, xmax = 3.4, ymin = -Inf, ymax = Inf, fill = bb512$clay, alpha = 0.10) +
  ggplot2::annotate("rect", xmin = 7.6, xmax = 12, ymin = -Inf, ymax = Inf, fill = bb512$forest, alpha = 0.10) +
  ggplot2::geom_hline(yintercept = K, linetype = "dashed", colour = bb512$grey, linewidth = 0.7) +
  ggplot2::geom_line(colour = bb512$ink, linewidth = 1.4) +
  ggplot2::annotate("text", x = 0.2, y = K + 7, label = "Carrying capacity, K", hjust = 0,
                    family = fam, size = 5, colour = bb512$grey) +
  ggplot2::annotate("text", x = 1.7, y = 62, label = "Far below K:\nhigh r pays\n(r-selection)",
                    family = fam, size = 5.2, colour = bb512$clay, fontface = "bold", lineheight = 0.95) +
  ggplot2::annotate("text", x = 9.8, y = 55, label = "Near K:\ncompeting\npays\n(K-selection)",
                    family = fam, size = 5.2, colour = bb512$forest, fontface = "bold", lineheight = 0.95) +
  ggplot2::scale_x_continuous("Time", breaks = NULL, expand = c(0, 0)) +
  ggplot2::scale_y_continuous("Population size, N", breaks = NULL, limits = c(0, 112), expand = c(0, 0)) +
  theme_bb512(base_family = fam) +
  ggplot2::theme(panel.grid.major.y = ggplot2::element_blank())

save_bb512(p, "02_logistic_rK", layout = "half")
