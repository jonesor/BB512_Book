# Slide after the "≈ 1 migrant" Big Fact: why gene flow beats drift far more easily than
# it beats selection. ANALYTICAL RULES OF THUMB, not a simulation.
#   * Drift vs gene flow (Neal 8.4, Eqn 8.4): drift dominates only if Ne m << 1, so the
#     boundary is Ne m = 1, i.e. m = 1 / Ne: a NUMBER of migrants per generation.
#   * Selection vs gene flow: a locally favoured allele is swamped when m is of the
#     order of s, i.e. a PROPORTION of migrants. (For Neal's recessive wing example,
#     q_hat = sqrt(m / s) reaches 1 at m = s; for an additive allele in a
#     continent–island model, q_hat ~ 1 - m/s and the allele is lost when m >= s.)
#   * Illustrated for s = 0.01. Boundaries are rules of thumb, not sharp thresholds:
#     differentiation falls steadily with Ne m (F_ST ~ 1/(4 Ne m + 1): 0.2 at Ne m = 1,
#     0.02 at Ne m = 10), so the line marks where drift stops fixing different alleles.
#   * Below Ne = 1/s (= 100 here) drift also overrides selection (Ne s < 1), so the
#     plot starts at Ne = 100.
source("R/theme_bb512.R")
library(ggplot2)
fam <- bb512_font()

s <- 0.01
Ne <- 10^seq(2, 5, length.out = 300)
ymin_plot <- 1e-6
ymax_plot <- 1
d <- data.frame(Ne = Ne, drift = 1 / Ne)
example <- data.frame(Ne = 1e4, m = 1e-3)  # 10 migrants per generation, m < s

p <- ggplot(d, aes(Ne)) +
  # region where gene flow swamps selection too (m > s)
  annotate("rect", xmin = 100, xmax = 1e5, ymin = s, ymax = ymax_plot, fill = bb512$pale) +
  # region where drift can differentiate populations (m < 1/Ne)
  geom_ribbon(aes(ymin = ymin_plot, ymax = drift), fill = "#F3EBDD") +
  geom_line(aes(y = drift), colour = bb512$forest, linewidth = 1.5) +
  annotate("segment", x = 100, xend = 1e5, y = s, yend = s, colour = bb512$clay, linewidth = 1.5) +
  annotate("text", x = 1.2e2, y = 0.12, hjust = 0, colour = bb512$ink, size = 5, family = fam,
           label = "Gene flow swamps local adaptation") +
  annotate("text", x = 9e4, y = 3.8e-3, hjust = 1, colour = bb512$ink, size = 5, family = fam,
           label = "Drift held in check;\nlocal adaptation persists", lineheight = 0.9) +
  annotate("text", x = 8.5e4, y = 3e-6, hjust = 1, colour = bb512$ink, size = 5, family = fam,
           label = "Drift can fix different alleles") +
  annotate("text", x = 1.1e5, y = s * 1.6, hjust = 1, vjust = 0, colour = bb512$clay, size = 5,
           family = fam, label = "m = s  (a proportion)") +
  annotate("text", x = 6e3, y = 6e-5, hjust = 0.5, colour = bb512$forest, size = 5,
           family = fam, label = "N[e]*m == 1~~'(a number):'~~F[ST] %~~% 0.2", parse = TRUE, angle = -17) +
  geom_point(data = example, aes(Ne, m), colour = bb512$gold, size = 4) +
  annotate("text", x = 1.3e4, y = 6.5e-4, hjust = 0, vjust = 0.5, colour = bb512$gold, size = 4.8,
           family = fam, label = "10 migrants\nper generation", lineheight = 0.9) +
  annotate("text", x = 1.3e4, y = 1.9e-4, hjust = 0, colour = bb512$gold, size = 4.8,
           family = fam, label = "F[ST] %~~% 0.02", parse = TRUE) +
  scale_x_log10(breaks = c(1e2, 1e3, 1e4, 1e5), labels = c("100", "1,000", "10,000", "100,000"),
                expand = c(0, 0)) +
  scale_y_log10(breaks = c(1e-6, 1e-4, 1e-2, 1), labels = c("0.000001", "0.0001", "0.01", "1"),
                limits = c(ymin_plot, ymax_plot), expand = c(0, 0)) +
  labs(x = expression("Effective population size, "*N[e]),
       y = "Migration rate, m (proportion)") +
  theme_bb512() +
  theme(panel.grid.major.y = element_blank(), plot.margin = ggplot2::margin(14, 30, 12, 16, "pt"))

save_bb512(p, "27b_number_vs_proportion", layout = "takeaway")
