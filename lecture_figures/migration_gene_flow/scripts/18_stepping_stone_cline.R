# Slide 18: Linear stepping-stone model at equilibrium (Neal Section 9.3, Fig. 9.4,
# Appendix 9.2). Deterministic. Nine populations; ends held at q = 0.9 and 0.1 by
# selection; m = 0.2 between neighbours. Barrier: m = 0.05 between 4–5 and 5–6
# (Neal suggests 0.05 or 0.01; 0.05 reproduces his Fig. 9.4).
# Iterated 20 000 generations to reach equilibrium.
source("R/theme_bb512.R"); source("R/models.R")
library(ggplot2)
fam <- bb512_font()
n <- 9
even <- stepping_stone(m_between = rep(0.2, n - 1))
mb <- rep(0.2, n - 1); mb[4:5] <- 0.05
barrier <- stepping_stone(m_between = mb)
d <- rbind(data.frame(pop = 1:n, q = even, scenario = "even"),
           data.frame(pop = 1:n, q = barrier, scenario = "barrier"))
p <- ggplot(d, aes(pop, q)) +
  annotate("rect", xmin = 4, xmax = 6, ymin = -Inf, ymax = Inf, fill = bb512$pale) +
  annotate("text", x = 5, y = 0.98, label = "low m", colour = bb512$clay, size = 5.2, family = fam) +
  geom_line(data = d[d$scenario == "even", ], colour = bb512$forest, linewidth = 1.3) +
  geom_point(data = d[d$scenario == "even", ], colour = bb512$forest, size = 3) +
  geom_line(data = d[d$scenario == "barrier", ], colour = bb512$clay, linewidth = 1.3, linetype = "22") +
  geom_point(data = d[d$scenario == "barrier", ], colour = bb512$clay, size = 3, shape = 21,
             fill = bb512$bg, stroke = 1.4) +
  annotate("text", x = 7.25, y = 0.48, label = "equal migration", colour = bb512$forest,
           size = 5.2, family = fam, hjust = 0) +
  annotate("text", x = 6.2, y = 0.12, label = "barrier", colour = bb512$clay,
           size = 5.2, family = fam, hjust = 0) +
  annotate("text", x = c(1.15, 9), y = c(0.985, 0.02), label = "held by selection", colour = bb512$grey,
           size = 4.9, family = fam, hjust = c(0, 1)) +
  scale_x_continuous(breaks = 1:9, expand = expansion(add = 0.3)) +
  scale_y_continuous(limits = c(0, 1.02), breaks = seq(0, 1, 0.25)) +
  labs(x = "Population along the gradient", y = "Allele frequency (q)") +
  theme_bb512()
save_bb512(p, "18_stepping_stone_cline", layout = "takeaway")
