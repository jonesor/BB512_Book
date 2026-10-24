# Slide: "Bateman (1948): who goes unmated?" (Figure & Bullets, layout = "half")
# Empirical: Bateman (1948) Drosophila melanogaster, as redrawn in Neal (Introduction to
# Population Biology, chapter "Sexual selection and mating systems"). Values DIGITISED from
# that figure (+/- about 1 percentage point), not taken from Bateman's tables.
source("R/theme_bb512.R")
library(ggplot2)
d <- data.frame(
  mates = rep(0:5, 2),
  sex   = rep(c("Males", "Females"), each = 6),
  pct   = c(20.9, 31.6, 30.7, 15.4, 1.5, 0,
            3.6, 52.6, 39.2, 4.7, 0, NA))
p <- ggplot(subset(d, !is.na(pct)), aes(mates, pct, colour = sex)) +
  geom_line(linewidth = 1.4) + geom_point(size = 3) +
  annotate("text", x = 2.25, y = 50, label = "Females", colour = bb512$clay, size = 5.5, hjust = 0) +
  annotate("text", x = 3.3, y = 21, label = "Males", colour = bb512$forest, size = 5.5, hjust = 0) +
  scale_colour_manual(values = c(Males = bb512$forest, Females = bb512$clay), guide = "none") +
  scale_x_continuous("Number of mates", breaks = 0:5) +
  scale_y_continuous("Individuals (%)", limits = c(0, 60), breaks = seq(0, 60, 20)) +
  theme_bb512()
save_bb512(p, "02_bateman_mates", layout = "half")
