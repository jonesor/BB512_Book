# Slide "Heterozygote advantage gives a stable equilibrium": HbS frequency over generations.
# Fitnesses estimated from Allison (1956), Tanzania (via Neal 2004 Table 11.3):
# W(AA) = 0.7565, W(AS) = 1, W(SS) = 0.1986 (survival from infancy to adulthood only;
# assumes equal fertility). Deterministic iteration from four starting frequencies.
# Equilibrium q_hat = s1 / (s1 + s2) (Neal Eqn 10.15).
source("R/theme_bb512.R"); source("R/models.R")
fam <- "Avenir Next"
inf <- c(189, 89, 9); ad <- c(400, 249, 5)
lam <- (ad / sum(ad)) / (inf / sum(inf)); W <- lam / max(lam)
s1 <- 1 - W[1]; s2 <- 1 - W[3]; qhat <- s1 / (s1 + s2)
starts <- c(0.02, 0.10, 0.50, 0.80); G <- 30
df <- do.call(rbind, lapply(starts, function(q0)
  data.frame(t = 0:G, q = iterate(q0, G, zygotic_step, W[1], W[2], W[3]), start = q0)))
p <- ggplot2::ggplot(df, ggplot2::aes(t, q, group = start)) +
  ggplot2::geom_hline(yintercept = qhat, linetype = "dashed", linewidth = 0.75, colour = bb512$grey) +
  ggplot2::geom_line(linewidth = 1.3, colour = bb512$forest) +
  ggplot2::annotate("text", x = G, y = qhat + 0.06, hjust = 1, family = fam, size = 5.2, colour = bb512$grey,
                    label = sprintf("hat(q) == %.2f", qhat), parse = TRUE) +
  ggplot2::scale_y_continuous(limits = c(0, 0.85), breaks = seq(0, 0.8, 0.2)) +
  ggplot2::labs(x = "Generation (t)", y = "Frequency of HbS (q)") +
  theme_bb512()
save_bb512(p, "13_sickle_equilibrium", layout = "takeaway")
cat(sprintf("W = %s; q_hat = %.4f\n", paste(round(W, 4), collapse = ", "), qhat))
