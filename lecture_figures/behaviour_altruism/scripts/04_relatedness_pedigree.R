# Coefficient of relatedness (r) from "You" to relatives in an outbred, diploid family.
# r = sum over paths of (1/2)^(number of parent-offspring links). Neal (2004) Table 19.1.
# Assumes no inbreeding and that sisters and the aunt are full siblings. In-laws (grey) are
# unrelated (r = 0). Schematic, not data.
source("R/theme_bb512.R")
library(ggplot2)
fam <- "Avenir Next"
n <- data.frame(
  id  = c("gp", "mum", "dad", "aunt", "inlaw", "you", "sis", "cousin", "niece"),
  x   = c(2.9, 1.9, 0.55, 3.9, 5.3, 0.9, 2.3, 4.6, 2.3),
  y   = c(4, 3, 3, 3, 3, 2, 2, 2, 1),
  lab = c("Grandparents\n0.25 each", "Mother\n0.5", "Father\n0.5", "Aunt\n0.25", "In-law\n0",
          "You", "Sister\n0.5", "Cousin\n0.125", "Niece\n0.25"),
  grp = c("rel", "rel", "rel", "rel", "out", "you", "rel", "rel", "rel")
)
seg <- data.frame(
  x    = c(2.9, 1.9, 0.55, 1.225, 0.9, 3.9, 4.6, 2.3),
  y    = c(4,   3.5, 3,    3,     2.5, 3,   3,   2),
  xend = c(2.9, 3.9, 1.9,  1.225, 2.3, 5.3, 4.6, 2.3),
  yend = c(3.5, 3.5, 3,    2.5,   2.5, 3,   2,   1)
)
stub <- data.frame(x = c(0.9, 2.3, 1.9, 3.9), y = c(2.5, 2.5, 3.5, 3.5),
                   xend = c(0.9, 2.3, 1.9, 3.9), yend = c(2.0, 2.0, 3.0, 3.0))
fills <- c(rel = bb512$forest, out = bb512$grey, you = bb512$gold)
p <- ggplot() +
  geom_segment(data = rbind(seg, stub), aes(x, y, xend = xend, yend = yend), colour = bb512$grey,
               linewidth = 0.7) +
  geom_label(data = n, aes(x, y, label = lab, fill = grp), colour = "white", family = fam, size = 4.95,
             lineheight = 0.88, label.padding = unit(0.28, "lines"), label.r = unit(0.2, "lines"),
             label.size = 0, fontface = "bold") +
  scale_fill_manual(values = fills, guide = "none") +
  coord_cartesian(xlim = c(-0.1, 6.0), ylim = c(0.6, 4.4), expand = FALSE) +
  theme_void() + theme(plot.background = element_rect(fill = bb512$bg, colour = NA))
save_bb512(p, "04_relatedness_pedigree", layout = "half")
