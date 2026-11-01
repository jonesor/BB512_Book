# Rover/sitter cross in Drosophila melanogaster larvae (de Belle & Sokolowski 1987; Neal 2004 section 19.1).
# Schematic of a single-locus Mendelian cross: rover allele (R, the foraging gene's for^R) dominant
# to sitter (S, for^s). F2 shown as the expected 1 RR : 2 RS : 1 SS, i.e. 3 rovers : 1 sitter.
# Not data.
source("R/theme_bb512.R")
library(ggplot2)
fam <- "Avenir Next"
col_ph <- c(rover = bb512$clay, sitter = bb512$blue)

tok <- data.frame(
  x   = c(1.5, 3.5,   2.5,   1, 2, 3, 4),
  y   = c(3,   3,     2,     1, 1, 1, 1),
  g   = c("RR", "SS", "RS", "RR", "RS", "RS", "SS"),
  ph  = c("rover", "sitter", "rover", "rover", "rover", "rover", "sitter")
)
rows <- data.frame(y = c(3, 2, 1), lab = c("Parents", "F1", "F2"))

p <- ggplot() +
  # cross lines
  annotate("segment", x = 1.5, xend = 3.5, y = 3, yend = 3, colour = bb512$grey, linewidth = 0.7) +
  annotate("text", x = 2.5, y = 3.17, label = "×", size = 7, colour = bb512$grey, family = fam) +
  annotate("segment", x = 2.5, xend = 2.5, y = 2.98, yend = 2.27, colour = bb512$grey, linewidth = 0.7,
           arrow = arrow(length = unit(0.12, "in"), type = "closed")) +
  annotate("segment", x = 2.5, xend = 2.5, y = 1.75, yend = 1.6, colour = bb512$grey, linewidth = 0.7) +
  annotate("segment", x = 1, xend = 4, y = 1.6, yend = 1.6, colour = bb512$grey, linewidth = 0.7) +
  annotate("segment", x = c(1, 2, 3, 4), xend = c(1, 2, 3, 4), y = 1.6, yend = 1.3,
           colour = bb512$grey, linewidth = 0.7, arrow = arrow(length = unit(0.1, "in"), type = "closed")) +
  geom_label(data = tok, aes(x, y, label = g, fill = ph), colour = "white", family = fam, fontface = "bold",
             size = 6.5, label.padding = unit(0.32, "lines"), label.r = unit(0.25, "lines"), label.size = 0) +
  geom_text(data = rows, aes(x = 0.15, y = y, label = lab), hjust = 0, family = fam, size = 5.6,
            colour = bb512$ink, fontface = "bold") +
  annotate("text", x = 2.5, y = 0.45, label = "3 rovers : 1 sitter", family = fam, size = 6,
           colour = bb512$ink, fontface = "bold") +
  annotate("text", x = c(3.55), y = 2, label = "all rovers", hjust = 0, family = fam, size = 5,
           colour = bb512$grey) +
  annotate("text", x = c(4.62, 4.62), y = c(3.85, 3.5), label = c("rover", "sitter"), hjust = 0,
           family = fam, size = 5, colour = c(bb512$clay, bb512$blue), fontface = "bold") +
  annotate("point", x = c(4.5, 4.5), y = c(3.85, 3.5), shape = 15, size = 5,
           colour = c(bb512$clay, bb512$blue)) +
  scale_fill_manual(values = col_ph, guide = "none") +
  coord_cartesian(xlim = c(0.1, 5.3), ylim = c(0.3, 4.0), expand = FALSE) +
  theme_void() +
  theme(plot.background = element_rect(fill = bb512$bg, colour = NA),
        plot.margin = margin(6, 6, 6, 6))
save_bb512(p, "01_rover_sitter", layout = "half")
