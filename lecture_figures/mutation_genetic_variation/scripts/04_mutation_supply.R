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
  ggplot2::annotate("text", x = 1.8e6, y = 1.1, hjust = 0, vjust = 1,
                    label = "E(M) == 2",
                    parse = TRUE, colour = bb512$ink, size = 4.6) +
  ggplot2::scale_colour_manual(
    values = stats::setNames(c(bb512$blue, bb512$forest, bb512$clay),
                             sprintf("%.0e", mu_values)),
    name = "Mutation rate (μ)",
    labels = function(x) parse(text = sub("1e", "10^", x))) +
  ggplot2::scale_x_log10(breaks = 10^c(2, 4, 6, 8),
                         labels = scales::label_math(10^.x, format = log10)) +
  ggplot2::scale_y_log10(breaks = 10^seq(-5, 5, 2),
                         labels = scales::label_math(10^.x, format = log10)) +
  ggplot2::labs(x = "Population size (N)",
                y = "New mutants") +
  ggplot2::guides(colour = ggplot2::guide_legend(title.position = "top",
                                                 title.hjust = 0.5)) +
  theme_bb512()

save_bb512(p, "04_mutation_supply", layout = "half")
