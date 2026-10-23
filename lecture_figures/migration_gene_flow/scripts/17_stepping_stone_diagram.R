# Model 3 set-up: a linear stepping-stone chain of nine populations along an
# environmental gradient (Neal Section 9.3, Fig. 9.3, Appendix 9.2). Selection favours
# different alleles at the two ends; migrants move only between neighbours. Schematic.
source("R/theme_bb512.R")
library(ggplot2)
fam <- bb512_font()
n <- 9
x <- seq(0.6, 5.4, length.out = n)
pops <- data.frame(x = x, y = 2.4, fill = c(bb512$forest, rep(bb512$pale, n - 2), bb512$clay),
                   txt = c("1", rep("?", n - 2), "9"), col = c(bb512$bg, rep(bb512$grey, n - 2), bb512$bg))
gap <- 0.2
links <- data.frame(x = x[-n] + gap, xend = x[-1] - gap)
p <- ggplot() +
  annotate("segment", x = 0.4, xend = 5.6, y = 4.05, yend = 4.05, colour = bb512$grey, linewidth = 0.7,
           arrow = arrow(length = unit(0.11, "in"), type = "closed", ends = "both")) +
  annotate("text", x = 3, y = 4.4, label = "environmental gradient (e.g. up a mountainside)",
           colour = bb512$grey, size = 4.8, family = fam) +
  geom_segment(data = links, aes(x = x, xend = xend, y = 2.4, yend = 2.4), colour = bb512$grey,
               linewidth = 1.2) +
  geom_point(data = pops, aes(x, y), shape = 21, size = 10, fill = pops$fill, colour = bb512$grey, stroke = 0.6) +
  geom_text(data = pops, aes(x, y, label = txt), colour = pops$col, size = 5, family = fam, fontface = "bold") +
  annotate("text", x = 0.6, y = 3.35, label = "selection\nfavours A", colour = bb512$forest, size = 4.7,
           family = fam, lineheight = 0.9) +
  annotate("text", x = 5.4, y = 3.35, label = "selection\nfavours a", colour = bb512$clay, size = 4.7,
           family = fam, lineheight = 0.9) +
  annotate("text", x = 3, y = 1.35, label = "Lines: migrants move only between neighbours",
           colour = bb512$ink, size = 5, family = fam) +
  coord_cartesian(xlim = c(0.1, 5.9), ylim = c(0.9, 4.7), expand = FALSE) +
  theme_void() + theme(plot.background = element_rect(fill = bb512$bg, colour = NA))
save_bb512(p, "17_stepping_stone_diagram", layout = "half")
