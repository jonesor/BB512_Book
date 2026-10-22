# Slide 21: Copper tolerance in Agrostis capillaris (as A. tenuis) around a small
# copper mine (McNeilly 1968, Heredity 23: 99–108), as redrawn in Neal (2004).
# EMPIRICAL but APPROXIMATE: bar heights were read by eye from the published
# figure used in the earlier version of this lecture; they are not the original data.
# Adults = established plants; seed = seed collected from those plants and grown on.
source("R/theme_bb512.R")
library(ggplot2)
fam <- bb512_font()
d <- data.frame(
  transect = rep(c("Transect 1: upwind", "Transect 2: downwind"), each = 10),
  distance = c(rep(c(0, 15, 20, 35, 45), each = 2), rep(c(0, 60, 80, 95, 160), each = 2)),
  stage = rep(c("Adults", "Seed"), 10),
  tolerance = c(12, 12, 25, 18, 42, 25, 53, 38, 56, 39,
                43, 35, 40, 32, 30, 38, 28, 41, 18, 38))
d$transect <- factor(d$transect, levels = unique(d$transect))
mine <- data.frame(transect = factor(levels(d$transect), levels = levels(d$transect)),
                   xmin = c(18, -Inf), xmax = c(Inf, 8))
dodge <- c(Adults = -1, Seed = 1)
d$x <- d$distance + dodge[d$stage] * ifelse(d$transect == levels(d$transect)[1], 0.9, 2.7)
w <- ifelse(d$transect == levels(d$transect)[1], 1.6, 4.8)
p <- ggplot(d) +
  geom_rect(data = mine, aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf),
            fill = bb512$pale, inherit.aes = FALSE) +
  geom_col(aes(x, tolerance, fill = stage), width = w) +
  geom_text(data = data.frame(transect = factor(levels(d$transect), levels = levels(d$transect)),
                              x = c(31.5, 4), y = 63, label = c("mine", "mine")),
            aes(x, y, label = label), colour = bb512$grey, size = 5, family = fam) +
  facet_wrap(~transect, scales = "free_x") +
  scale_fill_manual(values = c(Adults = bb512$forest, Seed = bb512$gold), name = NULL) +
  scale_y_continuous(limits = c(0, 66), breaks = seq(0, 60, 20)) +
  labs(x = "Distance along transect (m)", y = "Index of copper tolerance") +
  theme_bb512() + theme(legend.position = "top", legend.justification = "left",
                        panel.spacing = unit(1.4, "lines"))
save_bb512(p, "21_copper_tolerance", layout = "takeaway")
