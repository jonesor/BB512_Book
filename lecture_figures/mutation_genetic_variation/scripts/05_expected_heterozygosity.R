# Slide 28: Expected heterozygosity for a diallelic locus, H_E = 2pq.
# This is NOT necessarily the observed heterozygote frequency.
source("R/theme_bb512.R")

p_grid <- seq(0, 1, length.out = 501)
df <- data.frame(p_A = p_grid, H_E = 2 * p_grid * (1 - p_grid))
points <- data.frame(p_A = c(0.5, 0.9, 0.99))
points$H_E <- 2 * points$p_A * (1 - points$p_A)

p <- ggplot2::ggplot(df, ggplot2::aes(p_A, H_E)) +
  ggplot2::geom_line(colour = bb512$forest, linewidth = 1.4) +
  ggplot2::geom_point(data = points, colour = bb512$clay, size = 3.3) +
  ggplot2::annotate("text", x = 0.50, y = 0.55,
                    label = "p = 0.50, Hₑ = 0.50",
                    colour = bb512$ink, size = 5.1, hjust = 0.50) +
  ggplot2::annotate("text", x = 0.91, y = 0.29,
                    label = "p = 0.90, Hₑ = 0.18",
                    colour = bb512$ink, size = 4.9, hjust = 0.90) +
  ggplot2::annotate("text", x = 0.94, y = 0.095,
                    label = "p = 0.99, Hₑ = 0.0198",
                    colour = bb512$ink, size = 4.9, hjust = 0.87) +
  ggplot2::scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
  ggplot2::scale_y_continuous(limits = c(0, 0.58), breaks = seq(0, 0.5, 0.1)) +
  ggplot2::labs(x = "Frequency of allele A (p)",
                y = "Expected heterozygosity (Hₑ = 2pq)") +
  theme_bb512()

save_bb512(p, "05_expected_heterozygosity", layout = "full")
