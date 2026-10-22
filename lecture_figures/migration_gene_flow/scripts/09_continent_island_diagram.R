# Slide 9: Continent–island model schematic (Neal Eqn 9.1). Not data.
source("R/theme_bb512.R")
library(ggplot2)
fam <- bb512_font()
circle <- function(x0, y0, r, n = 80) {
  a <- seq(0, 2 * pi, length.out = n); data.frame(x = x0 + r * cos(a), y = y0 + r * sin(a))
}
p <- ggplot() +
  geom_polygon(data = circle(1.6, 3.2, 1.45), aes(x, y), fill = bb512$forest) +
  geom_polygon(data = circle(5.3, 3.2, 0.75), aes(x, y), fill = bb512$sage) +
  annotate("text", x = 1.6, y = 3.55, label = "Continent", colour = bb512$bg, size = 5.6, family = fam, fontface = "bold") +
  annotate("text", x = 1.6, y = 2.85, label = "q[m]", parse = TRUE, colour = bb512$bg, size = 7, family = fam) +
  annotate("text", x = 5.3, y = 4.3, label = "Island", colour = bb512$ink, size = 5.6, family = fam, fontface = "bold") +
  annotate("text", x = 5.3, y = 3.2, label = "q[0]", parse = TRUE, colour = bb512$ink, size = 7, family = fam) +
  annotate("segment", x = 3.15, xend = 4.45, y = 3.2, yend = 3.2, colour = bb512$clay, linewidth = 1.3,
           arrow = arrow(length = unit(0.16, "in"), type = "closed")) +
  annotate("text", x = 3.8, y = 3.6, label = "m", fontface = "italic", colour = bb512$clay, size = 7, family = fam) +
  annotate("text", x = 3.45, y = 1.05, label = "(1 - m)*q[0]", parse = TRUE, colour = bb512$ink, size = 6, family = fam) +
  annotate("text", x = 3.45, y = 0.5, label = "residents keep their alleles", colour = bb512$grey, size = 5, family = fam) +
  annotate("text", x = 3.45, y = 5.45, label = "m*q[m]", parse = TRUE, colour = bb512$clay, size = 6, family = fam) +
  annotate("text", x = 3.45, y = 4.95, label = "immigrants bring theirs", colour = bb512$grey, size = 5, family = fam) +
  coord_fixed(xlim = c(0, 6.3), ylim = c(0.2, 5.8), expand = FALSE) +
  theme_void() + theme(plot.background = element_rect(fill = bb512$bg, colour = NA))
save_bb512(p, "09_continent_island_diagram", layout = "half")
