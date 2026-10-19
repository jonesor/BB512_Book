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
                    label = "p == '0.50'*','~H[e] == '0.50'", parse = TRUE,
                    colour = bb512$ink, size = 5.1, hjust = 0.50) +
  ggplot2::annotate("text", x = 0.87, y = 0.18,
                    label = "p == '0.90'*','~H[e] == '0.18'", parse = TRUE,
                    colour = bb512$ink, size = 4.9, hjust = 1) +
  ggplot2::annotate("text", x = 0.96, y = 0.035,
                    label = "p == '0.99'*','~H[e] == '0.0198'", parse = TRUE,
                    colour = bb512$ink, size = 4.9, hjust = 1) +
  ggplot2::scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
  ggplot2::scale_y_continuous(limits = c(0, 0.58), breaks = seq(0, 0.5, 0.1)) +
  ggplot2::labs(x = "Frequency of allele A (p)",
                y = expression("Expected heterozygosity, "*H[e])) +
  theme_bb512()

save_bb512(p, "05_expected_heterozygosity", layout = "takeaway")
