# Slide 23: Expected NUMBER of new mutations depends on population size.
# Diploid locus: E[M] = 2N*mu; not the probability that the allele fixes.
source("R/theme_bb512.R")

mu_values <- c(1e-7, 1e-6, 1e-5)
Ns <- 10^seq(2, 9, length.out = 200)
df <- do.call(rbind, lapply(mu_values, function(mu) {
  data.frame(N = Ns, expected = 2 * Ns * mu,
             mu = factor(sprintf("%.0e", mu),
                         levels = sprintf("%.0e", mu_values)))
}))
example <- data.frame(N = 1e6, expected = 2)

p <- ggplot2::ggplot(df, ggplot2::aes(N, expected, colour = mu)) +
  ggplot2::geom_line(linewidth = 1.2) +
  ggplot2::geom_point(data = example, ggplot2::aes(N, expected),
                      inherit.aes = FALSE, colour = bb512$ink, size = 3.5) +
  ggplot2::annotate("text", x = 1.6e6, y = 1.3, hjust = 0,
                    label = "N = 10⁶, μ = 10⁻⁶: E[M] = 2",
                    colour = bb512$ink, size = 5) +
  ggplot2::scale_colour_manual(
    values = stats::setNames(c(bb512$blue, bb512$forest, bb512$clay),
                             sprintf("%.0e", mu_values)),
    name = "Mutation rate per allele") +
  ggplot2::scale_x_log10(breaks = 10^c(2, 4, 6, 8),
                         labels = function(x) format(x, scientific = TRUE, trim = TRUE)) +
  ggplot2::scale_y_log10(breaks = 10^seq(-5, 5, 2),
                         labels = function(x) format(x, scientific = TRUE, trim = TRUE)) +
  ggplot2::labs(x = "Diploid population size (N)",
                y = "Expected new mutants per locus per generation") +
  theme_bb512()

save_bb512(p, "04_mutation_supply", layout = "full")
