# Slide "Haploid selection: slow, fast, slow": the worked example over many generations.
# Analytical/deterministic: Neal Eqn 10.1/10.2. Genotype A lambda = 1.6, B lambda = 1.2,
# so W_B = 0.75 and s = 0.25. Starting frequency of A, p0 = 0.01. Infinite population (no drift).
source("R/theme_bb512.R"); source("R/models.R")
fam <- "Avenir Next"
s <- 0.25; q0 <- 0.99; gens <- 40
q <- iterate(q0, gens, haploid_step, s = s)
df <- data.frame(t = rep(0:gens, 2), freq = c(1 - q, q), g = rep(c("A", "B"), each = gens + 1))
pa <- ggplot2::ggplot(df, ggplot2::aes(t, freq, colour = g)) +
  ggplot2::geom_line(linewidth = 1.4) +
  ggplot2::annotate("text", x = c(31, 31), y = c(0.90, 0.10), label = c("A (fitter)", "B"),
                    colour = c(bb512$forest, bb512$clay), family = fam, size = 5.5, hjust = 0) +
  ggplot2::scale_colour_manual(values = c(A = bb512$forest, B = bb512$clay), guide = "none") +
  ggplot2::scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
  ggplot2::labs(x = "Generation (t)", y = "Frequency") + theme_bb512()
qs <- seq(0, 1, by = 0.005)
dq <- data.frame(q = qs, d = abs(haploid_dq(qs, s)))
pb <- ggplot2::ggplot(dq, ggplot2::aes(1 - q, d)) +
  ggplot2::geom_line(linewidth = 1.4, colour = bb512$forest) +
  ggplot2::annotate("text", x = c(0.1, 0.47, 0.9), y = c(0.055, 0.08, 0.055), label = c("slow", "fast", "slow"),
                    family = fam, size = 5.3, colour = bb512$grey) +
  ggplot2::scale_x_continuous(breaks = seq(0, 1, 0.25)) +
  ggplot2::scale_y_continuous(limits = c(0, 0.085), breaks = seq(0, 0.075, 0.025)) +
  ggplot2::labs(x = "Frequency of A (p)", y = expression("|" * Delta * q * "| per generation")) +
  theme_bb512()
p <- patchwork::wrap_plots(pa, pb, nrow = 1)
save_bb512(p, "05_haploid_dynamics", layout = "full")
