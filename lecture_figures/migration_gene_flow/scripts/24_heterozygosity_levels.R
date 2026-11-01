# Slide 24: Three levels of heterozygosity and the F-statistics linking them. Not data.
source("R/theme_bb512.R")
library(ggplot2)
fam <- bb512_font()
lv <- data.frame(y = c(4.6, 2.9, 1.2),
                 sym = c("H[T]", "H[S]", "H[I]"),
                 txt = c("expected, total population",
                         "expected, within subpopulations",
                         "observed, within subpopulations"))
br <- function(x, y1, y2, lab, col) list(
  annotate("segment", x = x, xend = x, y = y1, yend = y2, colour = col, linewidth = 1.1),
  annotate("segment", x = x, xend = x - 0.12, y = c(y1, y2), yend = c(y1, y2), colour = col, linewidth = 1.1),
  annotate("text", x = x + 0.15, y = (y1 + y2) / 2, label = lab, parse = TRUE, hjust = 0,
           colour = col, size = 6.2, family = fam))
p <- ggplot() +
  annotate("rect", xmin = 0.1, xmax = 4.45, ymin = lv$y - 0.5, ymax = lv$y + 0.5, fill = bb512$pale) +
  annotate("text", x = 0.35, y = lv$y + 0.12, label = lv$sym, parse = TRUE, hjust = 0,
           colour = bb512$forest, size = 7.2, family = fam) +
  annotate("text", x = 1.15, y = lv$y + 0.12, label = lv$txt, hjust = 0, colour = bb512$ink,
           size = 4.9, family = fam) +
  br(4.85, 4.55, 2.95, "F[ST]", bb512$clay) +
  br(4.85, 2.85, 1.25, "F[IS]", bb512$blue) +
  br(5.85, 4.55, 1.25, "F[IT]", bb512$gold) +
  annotate("text", x = 2.3, y = 0.25, label = "(1 - F[IT]) == (1 - F[IS]) * (1 - F[ST])", parse = TRUE,
           colour = bb512$ink, size = 5.3, family = fam) +
  coord_cartesian(xlim = c(0, 6.7), ylim = c(-0.05, 5.2), expand = FALSE) +
  theme_void() + theme(plot.background = element_rect(fill = bb512$bg, colour = NA))
save_bb512(p, "24_heterozygosity_levels", layout = "half")
