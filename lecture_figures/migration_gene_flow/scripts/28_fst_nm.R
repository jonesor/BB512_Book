# Slide 28: Wright's island-model relationship at drift–migration equilibrium,
# F_ST ~ 1 / (4 Ne m + 1). Analytical approximation (many demes, small m, neutral loci).
# Highlight: Ne m = 1 gives F_ST = 0.2. Shaded band: Edith's checkerspot F_ST 0.017–0.062.
source("R/theme_bb512.R"); source("R/models.R")
library(ggplot2)
fam <- bb512_font()
d <- data.frame(Nm = 10^seq(-2, 2, length.out = 400))
d$Fst <- fst_from_nm(d$Nm)
band <- nm_from_fst(c(0.062, 0.017))  # 3.8 to 14.5
p <- ggplot(d, aes(Nm, Fst)) +
  annotate("rect", xmin = band[1], xmax = band[2], ymin = -Inf, ymax = Inf, fill = bb512$pale) +
  annotate("text", x = sqrt(prod(band)), y = 0.62, label = "checkerspot\n(7 loci)",
           colour = bb512$grey, size = 4.9, family = fam, lineheight = 0.9) +
  geom_line(colour = bb512$forest, linewidth = 1.5) +
  annotate("segment", x = 1, xend = 1, y = 0, yend = 0.2, linetype = "dashed", colour = bb512$grey, linewidth = 0.6) +
  annotate("segment", x = 0.01, xend = 1, y = 0.2, yend = 0.2, linetype = "dashed", colour = bb512$grey, linewidth = 0.6) +
  annotate("point", x = 1, y = 0.2, colour = bb512$clay, size = 3.8) +
  annotate("text", x = 1.3, y = 0.28, label = "N[e]*m == 1*\",\"~~F[ST] == 0.2", parse = TRUE, hjust = 0, colour = bb512$clay,
           size = 5.3, family = fam) +
  scale_x_log10(breaks = c(0.01, 0.1, 1, 10, 100), labels = c("0.01", "0.1", "1", "10", "100")) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
  labs(x = expression("Migrants per generation, "*N[e]*m*" (log scale)"), y = expression(F[ST])) +
  theme_bb512()
save_bb512(p, "28_fst_nm", layout = "takeaway")
