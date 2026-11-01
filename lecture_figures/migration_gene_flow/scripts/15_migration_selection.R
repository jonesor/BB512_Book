# Migration-selection balance (Neal Exp. 9.10-9.11), analytical outcome.
# Mainland fixed for the wing allele (q_m = 1); on the island winged
# homozygotes (wings recessive) have fitness 1 - s, s = 0.25.
# Equilibrium q_hat = sqrt(m / s) (exact with census after immigration; see R/models.R).
# Points labelled directly so the m = 0.01 case can be read off the graph.
source("R/theme_bb512.R"); source("R/models.R")
library(ggplot2)
fam <- bb512_font()
s <- 0.25
d <- data.frame(m = seq(0, 0.15, length.out = 400))
d$q <- migsel(d$m, s)
d$winged <- d$q^2
pts <- data.frame(m = c(0.01, 0.1))
pts$q <- migsel(pts$m, s)
stopifnot(abs(migsel_iterate(0.01, s) - pts$q[1]) < 1e-6)
lab <- function(x) formatC(x, format = "f", digits = 2)
p <- ggplot(d, aes(m)) +
  geom_line(aes(y = q), colour = bb512$forest, linewidth = 1.5) +
  geom_line(aes(y = winged), colour = bb512$clay, linewidth = 1.3) +
  geom_segment(data = pts, aes(x = m, xend = m, y = 0, yend = q), linetype = "dashed",
               colour = bb512$grey, linewidth = 0.6) +
  geom_point(data = pts, aes(y = q), colour = bb512$forest, size = 3.4) +
  geom_point(data = pts, aes(y = q^2), colour = bb512$clay, size = 3.4) +
  # direct value labels
  annotate("text", x = 0.016, y = 0.165, hjust = 0, label = lab(pts$q[1]), colour = bb512$forest,
           size = 5, family = fam, fontface = "bold") +
  annotate("text", x = 0.014, y = 0.045, hjust = 0, label = "4%", colour = bb512$clay, size = 5, family = fam, fontface = "bold") +
  annotate("text", x = 0.097, y = 0.665, hjust = 1, label = lab(pts$q[2]), colour = bb512$forest,
           size = 5, family = fam, fontface = "bold") +
  annotate("text", x = 0.104, y = 0.37, hjust = 0, label = "40%", colour = bb512$clay, size = 5, family = fam, fontface = "bold") +
  # series labels (no hats: they render poorly in this font)
  annotate("text", x = 0.148, y = 0.81, hjust = 1, label = "wing allele frequency", colour = bb512$forest,
           size = 5.2, family = fam) +
  annotate("text", x = 0.148, y = 0.27, hjust = 1, label = "proportion of insects winged", colour = bb512$clay,
           size = 5.2, family = fam) +
  annotate("text", x = 0.002, y = 0.84, hjust = 0, label = "italic(s) == 0.25", parse = TRUE, colour = bb512$grey,
           size = 5.2, family = fam) +
  scale_x_continuous(breaks = c(0, 0.01, 0.05, 0.1, 0.15), labels = c("0", "0.01", "0.05", "0.10", "0.15"),
                     expand = expansion(mult = c(0.01, 0.03))) +
  scale_y_continuous(limits = c(0, 0.86), breaks = seq(0, 0.8, 0.2)) +
  labs(x = expression("Immigration rate from mainland, "*italic(m)), y = "Equilibrium frequency") +
  theme_bb512()
save_bb512(p, "15_migration_selection", layout = "takeaway")
