# Slide "Absolute and relative fitness": two genotypes growing geometrically.
# Analytical: N_t = N_0 * lambda^t with lambda_A = 1.05 and lambda_B = 1.15 (illustrative values),
# N_0 = 1 for both. No density dependence.
source("R/theme_bb512.R")
fam <- "Avenir Next"
lambda <- c(A = 1.05, B = 1.15); t <- 0:20
df <- data.frame(t = rep(t, 2), genotype = rep(names(lambda), each = length(t)))
df$N <- lambda[df$genotype]^df$t
lab <- data.frame(t = 20.4, N = lambda^20, genotype = names(lambda),
                  txt = c("Genotype A\nlambda == 1.05", "Genotype B\nlambda == 1.15"))
lab$txt <- c("atop('Genotype A', lambda == 1.05)", "atop('Genotype B', lambda == 1.15)")
p <- ggplot2::ggplot(df, ggplot2::aes(t, N, colour = genotype)) +
  ggplot2::geom_line(linewidth = 1.4) +
  ggplot2::geom_text(data = lab, ggplot2::aes(label = txt), parse = TRUE, hjust = 0,
                     size = 5.2, family = fam) +
  ggplot2::scale_colour_manual(values = c(A = bb512$grey, B = bb512$forest), guide = "none") +
  ggplot2::scale_x_continuous(breaks = seq(0, 20, 5), expand = ggplot2::expansion(c(0, 0.02))) +
  ggplot2::scale_y_continuous(limits = c(0, 17), breaks = seq(0, 16, 4)) +
  ggplot2::coord_cartesian(clip = "off") +
  ggplot2::labs(x = "Generation (t)", y = "Population size (N)") +
  theme_bb512() + ggplot2::theme(plot.margin = ggplot2::margin(14, 120, 12, 16, "pt"))
save_bb512(p, "01_fitness_growth", layout = "half")
