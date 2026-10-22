# Slide "Selection raises mean fitness": population multiplication rate over time.
# Deterministic: worked example (lambda_A = 1.6, lambda_B = 1.2, p0 = 0.01).
# Mean absolute fitness each generation = p_t * 1.6 + q_t * 1.2.
source("R/theme_bb512.R"); source("R/models.R")
fam <- "Avenir Next"
q <- iterate(0.99, 40, haploid_step, s = 0.25)
df <- data.frame(t = 0:40, lam = (1 - q) * 1.6 + q * 1.2)
p <- ggplot2::ggplot(df, ggplot2::aes(t, lam)) +
  ggplot2::geom_hline(yintercept = c(1.2, 1.6), linetype = "dashed", linewidth = 0.7, colour = bb512$grey) +
  ggplot2::geom_line(linewidth = 1.4, colour = bb512$forest) +
  ggplot2::annotate("text", x = 40, y = c(1.225, 1.575), hjust = 1, family = fam, size = 5,
                    colour = bb512$grey, label = c("lambda[B] == 1.2", "lambda[A] == 1.6"), parse = TRUE) +
  ggplot2::scale_y_continuous(limits = c(1.15, 1.65), breaks = seq(1.2, 1.6, 0.1)) +
  ggplot2::labs(x = "Generation (t)", y = expression("Mean fitness of population (" * bar(lambda) * ")")) +
  theme_bb512()
save_bb512(p, "06_mean_fitness", layout = "takeaway")
