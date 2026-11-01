# 06_fig_wasp_schematic.R  (slide "Figs and fig wasps: partners for life", layout = "half")
# SCHEMATIC (not data), simplified from the fig and fig-wasp phylogenies in the
# previous deck (probably Stearns & Hoekstra Fig. 18.8; to confirm). Five figs
# and their pollinating wasps: matching trees, and a matching trait. Wasps whose
# figs have fluid-filled cavities have enlarged breathing openings.
source("R/theme_bb512.R")
library(ggplot2)
FAM <- getOption("bb512.family", "Avenir Next")
seg <- function(x, y, xend, yend) data.frame(x, y, xend, yend)
# tips y = 5..1; topology (((1,2),3),(4,5)) on both sides
left  <- rbind(seg(0.7, 5, 1, 5), seg(0.7, 4, 1, 4), seg(0.7, 4, 0.7, 5),
               seg(0.4, 4.5, 0.7, 4.5), seg(0.4, 3, 1, 3), seg(0.4, 3, 0.4, 4.5),
               seg(0.7, 2, 1, 2), seg(0.7, 1, 1, 1), seg(0.7, 1, 0.7, 2),
               seg(0.1, 3.75, 0.4, 3.75), seg(0.1, 1.5, 0.7, 1.5), seg(0.1, 1.5, 0.1, 3.75),
               seg(0, 2.625, 0.1, 2.625))
right <- transform(left, x = 4 - x, xend = 4 - xend)
fluid <- c(TRUE, TRUE, FALSE, FALSE, FALSE)                    # tips 1..5 (y = 5..1)
tips  <- data.frame(y = 5:1, fluid = fluid)
col_t <- ifelse(tips$fluid, bb512$blue, bb512$gold)
g <- ggplot() +
  geom_segment(data = left,  aes(x, y, xend = xend, yend = yend), colour = bb512$forest, linewidth = 1.4, lineend = "square") +
  geom_segment(data = right, aes(x, y, xend = xend, yend = yend), colour = bb512$grey, linewidth = 1.4, lineend = "square") +
  geom_segment(data = tips, aes(x = 1.45, xend = 2.55, y = y, yend = y), colour = bb512$sage, linetype = "dotted", linewidth = 0.9) +
  geom_point(data = tips, aes(x = 1.15, y = y), colour = col_t, size = 7) +
  geom_point(data = tips, aes(x = 2.85, y = y), colour = col_t, size = 7, shape = 15) +
  annotate("text", x = 0.5, y = 6.05, label = "Figs", size = 6, family = FAM, colour = bb512$forest) +
  annotate("text", x = 4.05, y = 6.05, hjust = 1, label = "Pollinating wasps", size = 6, family = FAM, colour = bb512$grey) +
  annotate("text", x = 2, y = 0.25, label = "Fluid-filled fig cavity / enlarged breathing openings",
           size = 4.9, family = FAM, colour = bb512$blue) +
  annotate("text", x = 2, y = -0.25, label = "Dry fig cavity / normal breathing openings",
           size = 4.9, family = FAM, colour = bb512$gold) +
  coord_cartesian(xlim = c(-0.1, 4.1), ylim = c(-0.5, 6.4), expand = FALSE) +
  theme_void() + theme(plot.background = element_rect(fill = bb512$bg, colour = NA))
save_bb512(g, "06_fig_wasp_schematic", layout = "half")
