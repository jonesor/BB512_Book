# Slide: "The Bateman gradient" (Figure & Bullets, layout = "half")
# Empirical: Bateman (1948), as redrawn in Neal (chapter "Sexual selection and mating systems").
# Means and error bars DIGITISED from that figure; error-bar definition as in the source.
source("R/theme_bb512.R")
library(ggplot2)
d <- data.frame(
  mates = rep(0:3, 2),
  sex   = rep(c("Males", "Females"), each = 4),
  off   = c(0, 45.2, 79.1, 133.7, 0, 69.1, 66.1, 76.7),
  err   = c(0, 6.5, 10, 24, 0, 8.6, 3.8, 2.6))
p <- ggplot(d, aes(mates, off, colour = sex)) +
  geom_errorbar(aes(ymin = off - err, ymax = off + err), width = 0.08, linewidth = 0.8) +
  geom_line(linewidth = 1.4) + geom_point(size = 3) +
  annotate("text", x = 2.55, y = 140, label = "Males", colour = bb512$forest, size = 5.5, hjust = 1) +
  annotate("text", x = 2.9, y = 58, label = "Females", colour = bb512$clay, size = 5.5, hjust = 1) +
  scale_colour_manual(values = c(Males = bb512$forest, Females = bb512$clay), guide = "none") +
  scale_x_continuous("Number of mates", breaks = 0:3) +
  scale_y_continuous("Number of offspring", limits = c(0, 160), breaks = seq(0, 160, 40)) +
  theme_bb512()
save_bb512(p, "03_bateman_gradient", layout = "half")
