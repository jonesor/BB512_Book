# Slide 13: Island model, deterministic (Neal Section 9.2, Fig. 9.1, Appendix 9.1).
# Four equal-sized populations start at q = 0.2, 0.4, 0.6, 0.8; m = 0.1; each
# receives immigrants with the mean allele frequency of the other three.
source("R/theme_bb512.R"); source("R/models.R")
library(ggplot2)
fam <- bb512_font()
d <- island_model(c(0.2, 0.4, 0.6, 0.8), m = 0.1, generations = 30)
start <- d[d$generation == 0, ]
p <- ggplot(d, aes(generation, q, group = population)) +
  geom_hline(yintercept = 0.5, linetype = "dashed", colour = bb512$grey, linewidth = 0.6) +
  geom_line(colour = bb512$forest, linewidth = 1.3) +
  geom_point(data = start, colour = bb512$forest, size = 2.8) +
  annotate("text", x = 30, y = 0.545, label = "mean = 0.5", hjust = 1, colour = bb512$grey,
           size = 5.2, family = fam) +
  scale_x_continuous(breaks = seq(0, 30, 10), expand = expansion(mult = c(0.01, 0.02))) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
  labs(x = "Generation", y = "Allele frequency (q)") +
  theme_bb512()
save_bb512(p, "13_island_model", layout = "takeaway")
