# Migration-selection set-up (Neal Section 9.2, Fig. 9.2): winged mainland (q_m = 1)
# sends a proportion m of breeders to a windy island where winged insects (qq; wings
# recessive) have fitness 1 - s. Schematic, not data.
source("R/theme_bb512.R")
library(ggplot2)
fam <- bb512_font()
circle <- function(x0, y0, r, n = 80) {
  a <- seq(0, 2 * pi, length.out = n); data.frame(x = x0 + r * cos(a), y = y0 + r * sin(a))
}
p <- ggplot() +
  geom_polygon(data = circle(1.5, 3.2, 1.25), aes(x, y), fill = bb512$forest) +
  geom_polygon(data = circle(5.0, 3.2, 0.8), aes(x, y), fill = bb512$sage) +
  annotate("text", x = 1.5, y = 3.55, label = "Mainland", colour = bb512$bg, size = 5.6, family = fam, fontface = "bold") +
  annotate("text", x = 1.5, y = 2.9, label = "all winged\n(q = 1)", parse = FALSE, colour = bb512$bg, size = 5, family = fam, lineheight = 0.9) +
  annotate("text", x = 5.0, y = 3.2, label = "Island", colour = bb512$ink, size = 5.6, family = fam, fontface = "bold") +
  annotate("segment", x = 2.85, xend = 4.1, y = 3.2, yend = 3.2, colour = bb512$clay, linewidth = 1.3,
           arrow = arrow(length = unit(0.15, "in"), type = "closed")) +
  annotate("text", x = 3.47, y = 3.6, label = "m", fontface = "italic", colour = bb512$clay, size = 7, family = fam) +
  annotate("text", x = 3.0, y = 1.6, label = "immigrants bring\nwing alleles", colour = bb512$grey, size = 4.6, family = fam, lineheight = 0.9) +
  # wind blowing winged insects off the island
  annotate("segment", x = 5.45, xend = 6.3, y = 2.45, yend = 1.75, colour = bb512$gold, linewidth = 1.1,
           arrow = arrow(length = unit(0.13, "in"), type = "closed")) +
  annotate("text", x = 5.3, y = 1.0, hjust = 0.5, label = "selection s:\nwinged insects\nblown out to sea", colour = bb512$gold,
           size = 4.6, family = fam, lineheight = 0.9) +
  coord_fixed(xlim = c(0.1, 6.5), ylim = c(0.3, 4.7), expand = FALSE) +
  theme_void() + theme(plot.background = element_rect(fill = bb512$bg, colour = NA))
save_bb512(p, "16a_migsel_setup", layout = "half")
