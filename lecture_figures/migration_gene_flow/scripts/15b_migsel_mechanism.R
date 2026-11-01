# Why migration-selection balance happens (Neal Exp. 9.10), analytical.
# Life cycle: selection, then immigration; census after immigration.
# Per generation, starting from wing-allele frequency q (p = 1 - q):
#   loss to selection   = s p q^2 / (1 - s q^2)
#   gain from immigrants = m (1 - q') = m p / (1 - s q^2), q' = frequency after selection
# Equal when s q^2 = m, i.e. q_hat = sqrt(m / s) (Neal Exp. 9.11), exactly.
# Neal writes the gain as m(1 - q), an approximation that hardly changes the picture.
# Illustrated for m = 0.01, s = 0.25 (q_hat = 0.20), the case on the slides.
source("R/theme_bb512.R"); source("R/models.R")
library(ggplot2)
fam <- bb512_font()
s <- 0.25; m <- 0.01
q <- seq(0, 0.45, length.out = 400)
den <- 1 - s * q^2
d <- data.frame(q = q, loss = s * (1 - q) * q^2 / den, gain = m * (1 - q) / den)
qh <- migsel(m, s)
yh <- m * (1 - qh) / (1 - s * qh^2)
stopifnot(abs(qh - 0.2) < 1e-12, abs(s * (1 - qh) * qh^2 / (1 - s * qh^2) - yh) < 1e-12)
ymax <- 0.03
p <- ggplot(d, aes(q)) +
  geom_line(aes(y = gain), colour = bb512$forest, linewidth = 1.5) +
  geom_line(aes(y = loss), colour = bb512$clay, linewidth = 1.5) +
  annotate("segment", x = qh, xend = qh, y = 0, yend = yh, linetype = "dashed", colour = bb512$grey, linewidth = 0.6) +
  annotate("point", x = qh, y = yh, colour = bb512$ink, size = 3.6) +
  annotate("text", x = 0.012, y = 0.0118, hjust = 0, label = "gain from immigrants", colour = bb512$forest,
           size = 5.2, family = fam) +
  annotate("text", x = 0.32, y = 0.022, hjust = 1, label = "loss to selection", colour = bb512$clay,
           size = 5.2, family = fam) +
  annotate("text", x = qh + 0.012, y = yh - 0.0018, hjust = 0, label = "balance: 0.20", colour = bb512$ink,
           size = 5, family = fam, fontface = "bold") +
  # direction of change either side of the balance
  annotate("segment", x = 0.04, xend = 0.17, y = 0.0275, yend = 0.0275, colour = bb512$grey, linewidth = 0.9,
           arrow = arrow(length = unit(0.12, "in"), type = "closed")) +
  annotate("text", x = 0.105, y = 0.0293, label = "gain > loss: q rises", colour = bb512$grey, size = 4.4, family = fam) +
  annotate("segment", x = 0.36, xend = 0.23, y = 0.0045, yend = 0.0045, colour = bb512$grey, linewidth = 0.9,
           arrow = arrow(length = unit(0.12, "in"), type = "closed")) +
  annotate("text", x = 0.295, y = 0.0025, label = "loss > gain: q falls", colour = bb512$grey, size = 4.4, family = fam) +
  annotate("text", x = 0.012, y = 0.0235, hjust = 0, vjust = 0, label = "italic(m) == 0.01*','~~italic(s) == 0.25",
           parse = TRUE, colour = bb512$grey, size = 4.6, family = fam) +
  scale_x_continuous(breaks = seq(0, 0.4, 0.1), expand = expansion(mult = c(0.01, 0.02))) +
  scale_y_continuous(limits = c(0, 0.0305), breaks = seq(0, 0.03, 0.01)) +
  labs(x = expression("Wing allele frequency on the island, "*italic(q)),
       y = expression("Change in "*italic(q)*" per generation")) +
  theme_bb512()
save_bb512(p, "15b_migsel_mechanism", layout = "takeaway")
