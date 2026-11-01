# 03_cophylogeny_schematic.R  (slide "Matching trees: cospeciation", layout = "half")
# SCHEMATIC (not data). Host tree ((A,B),(C,D)) on the left; parasite tree
# (((a,e),b),(c,d)) mirrored on the right. Parasites a-d live on hosts A-D
# (cospeciation: matching branches). Parasite e is the sister of a but lives on
# host D: a host switch.
source("R/theme_bb512.R")
library(ggplot2)
FAM <- getOption("bb512.family", "Avenir Next")

y <- c(A = 5, B = 3, C = 2, D = 1)                  # host tip heights
py <- c(a = 5, e = 4, b = 3, c = 2, d = 1)          # parasite tip heights
seg <- function(x, y, xend, yend) data.frame(x, y, xend, yend)
# host tree, root at x = 0, tips at x = 1
ht <- rbind(seg(0.6, 5, 1, 5), seg(0.6, 3, 1, 3), seg(0.6, 3, 0.6, 5),   # (A,B) at x .6
            seg(0.6, 2, 1, 2), seg(0.6, 1, 1, 1), seg(0.6, 1, 0.6, 2),   # (C,D)
            seg(0.2, 4, 0.6, 4), seg(0.2, 1.5, 0.6, 1.5), seg(0.2, 1.5, 0.2, 4),
            seg(0, 2.75, 0.2, 2.75))
# parasite tree mirrored, root at x = 4, tips at x = 3
pt <- rbind(seg(3.15, 5, 3, 5), seg(3.15, 4, 3, 4), seg(3.15, 4, 3.15, 5),  # (a,e)
            seg(3.4, 4.5, 3.15, 4.5), seg(3.4, 3, 3, 3), seg(3.4, 3, 3.4, 4.5), # ((a,e),b)
            seg(3.4, 2, 3, 2), seg(3.4, 1, 3, 1), seg(3.4, 1, 3.4, 2),        # (c,d)
            seg(3.8, 3.75, 3.4, 3.75), seg(3.8, 1.5, 3.4, 1.5), seg(3.8, 1.5, 3.8, 3.75),
            seg(4, 2.625, 3.8, 2.625))
links <- data.frame(x = 1.25, xend = 2.6, y = c(5, 3, 2, 1), yend = c(5, 3, 2, 1))
sw <- data.frame(x = 1.25, xend = 2.6, y = 1, yend = 4)

g <- ggplot() +
  geom_segment(data = ht, aes(x, y, xend = xend, yend = yend), colour = bb512$forest, linewidth = 1.4, lineend = "square") +
  geom_segment(data = pt, aes(x, y, xend = xend, yend = yend), colour = bb512$blue, linewidth = 1.4, lineend = "square") +
  geom_segment(data = links, aes(x, y, xend = xend, yend = yend), colour = bb512$sage, linewidth = 0.9, linetype = "dotted") +
  geom_segment(data = sw, aes(x, y, xend = xend, yend = yend), colour = bb512$clay, linewidth = 1.1, linetype = "dashed") +
  annotate("text", x = 1.08, y = y, label = names(y), hjust = 0, size = 5.5, family = FAM, colour = bb512$forest, fontface = "bold") +
  annotate("text", x = 2.92, y = py, label = names(py), hjust = 1, size = 5.5, family = FAM, colour = bb512$blue, fontface = "bold") +
  annotate("text", x = 0.5, y = 6.0, label = "Hosts", size = 6, family = FAM, colour = bb512$forest) +
  annotate("text", x = 3.5, y = 6.0, label = "Parasites", size = 6, family = FAM, colour = bb512$blue) +
  annotate("text", x = 1.7, y = 3.5, label = "host switch", size = 5, family = FAM, colour = bb512$clay) +
  coord_cartesian(xlim = c(-0.15, 4.15), ylim = c(0.6, 6.3), expand = FALSE) +
  theme_void() + theme(plot.background = element_rect(fill = bb512$bg, colour = NA))
save_bb512(g, "03_cophylogeny_schematic", layout = "half")
