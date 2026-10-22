# Slide 17: Linear stepping-stone model schematic (Neal Fig. 9.3). Not data.
source("R/theme_bb512.R")
library(ggplot2)
fam <- bb512_font()
xs <- c(0.9, 2.7, 4.5)
p <- ggplot() +
  annotate("rect", xmin = xs - 0.55, xmax = xs + 0.55, ymin = 2.6, ymax = 3.6,
           fill = c(bb512$sage, bb512$forest, bb512$sage)) +
  annotate("text", x = xs, y = 3.1, label = c("1", "2", "3"),
           colour = c(bb512$ink, bb512$bg, bb512$ink), size = 7, family = fam, fontface = "bold") +
  # arrows right (upper) and left (lower)
  annotate("segment", x = c(1.5, 3.3, 5.1), xend = c(2.1, 3.9, 5.7), y = 3.4, yend = 3.4,
           colour = bb512$clay, linewidth = 1, arrow = arrow(length = unit(0.11, "in"), type = "closed")) +
  annotate("segment", x = c(2.1, 3.9, 5.7), xend = c(1.5, 3.3, 5.1), y = 2.8, yend = 2.8,
           colour = bb512$blue, linewidth = 1, arrow = arrow(length = unit(0.11, "in"), type = "closed")) +
  annotate("text", x = c(1.8, 3.6, 5.4), y = 3.8, label = c("m[12]", "m[23]", "m[34]"), parse = TRUE,
           colour = bb512$clay, size = 5.6, family = fam) +
  annotate("text", x = c(1.8, 3.6, 5.4), y = 2.4, label = c("m[21]", "m[32]", "m[43]"), parse = TRUE,
           colour = bb512$blue, size = 5.6, family = fam) +
  annotate("text", x = 6.05, y = 3.1, label = "...", colour = bb512$grey, size = 8, family = fam) +
  annotate("text", x = 3.2, y = 1.35, hjust = 0.5, colour = bb512$ink, size = 5.2, family = fam,
           label = "Each population exchanges migrants\nonly with its two neighbours") +
  annotate("text", x = 3.2, y = 4.65, hjust = 0.5, colour = bb512$grey, size = 5, family = fam,
           label = "e.g. along an altitude or salinity gradient") +
  coord_fixed(xlim = c(0.1, 6.4), ylim = c(0.7, 5.1), expand = FALSE) +
  theme_void() + theme(plot.background = element_rect(fill = bb512$bg, colour = NA))
save_bb512(p, "17_stepping_stone_diagram", layout = "half")
