# Slide 20: Decline of ancestral A under irreversible A -> a mutation.
# Exact deterministic prediction with no selection, drift or back-mutation.
source("R/theme_bb512.R")

mu_values <- c(1e-6, 1e-5, 1e-4)
time <- seq(0, 500000, by = 1000)
df <- do.call(rbind, lapply(mu_values, function(mu) {
  data.frame(generation = time,
             p_A = exp(time * log1p(-mu)),
             mu = factor(sprintf("%.0e", mu),
                         levels = sprintf("%.0e", mu_values)))
}))

p <- ggplot2::ggplot(df, ggplot2::aes(generation, p_A, colour = mu)) +
  ggplot2::geom_line(linewidth = 1.25) +
  ggplot2::scale_colour_manual(
    values = stats::setNames(c(bb512$blue, bb512$forest, bb512$clay),
                             sprintf("%.0e", mu_values)),
    name = "Mutation rate per allele per generation") +
  ggplot2::scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
  ggplot2::scale_x_continuous(labels = scales::label_comma()) +
  ggplot2::labs(x = "Generations", y = "Frequency of ancestral allele A") +
  theme_bb512()

save_bb512(p, "03_mutation_pressure", layout = "full")
cat(sprintf("For mu = 10^-5, A remaining at 1000 generations: %.4f\n",
            (1 - 1e-5)^1000))
