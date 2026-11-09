# Species 1 zero isocline, N1 = K1 - alpha N2, with the worksheet defaults K1 = 1200, alpha = 0.75.
# ANALYTICAL schematic: horizontal arrows show the direction of change in N1 on each side
# (species 1 grows to the left of its isocline and declines to the right). Layout: half.
source("R/theme_bb512.R"); source("R/lv_model.R")
library(ggplot2)
fam <- "Avenir Next"
K1 <- 1200; alpha <- 0.75; lim <- 1800
arr <- expand.grid(N2 = c(300, 750, 1200), side = c(-1, 1))
arr$x0 <- K1 - alpha * arr$N2 + arr$side * 330
arr$x1 <- arr$x0 - arr$side * 190
arr <- arr[arr$x0 > 60 & arr$x0 < lim - 40, ]
p <- ggplot() +
  annotate("segment", x = K1, y = 0, xend = 0, yend = K1 / alpha, colour = bb512$forest, linewidth = 1.4) +
  geom_segment(data = arr, aes(x = x0, xend = x1, y = N2, yend = N2), colour = bb512$forest,
               linewidth = 0.9, arrow = grid::arrow(length = grid::unit(0.1, "in"), type = "closed")) +
  annotate("text", x = 120, y = 180, label = "N[1]~grows", parse = TRUE, hjust = 0, family = fam,
           size = 5.2, colour = bb512$ink) +
  annotate("text", x = 1720, y = 1500, label = "N[1]~declines", parse = TRUE, hjust = 1, family = fam,
           size = 5.2, colour = bb512$ink) +
  annotate("text", x = K1, y = -0.035 * lim, label = "K[1]", parse = TRUE, vjust = 1, family = fam,
           size = 5.2, colour = bb512$forest) +
  annotate("text", x = -0.025 * lim, y = K1 / alpha, label = "K[1]/alpha", parse = TRUE, hjust = 1,
           family = fam, size = 5.2, colour = bb512$forest) +
  coord_cartesian(xlim = c(0, lim), ylim = c(0, lim), clip = "off") +
  scale_x_continuous(breaks = NULL, expand = c(0, 0)) +
  scale_y_continuous(breaks = NULL, expand = c(0, 0)) +
  labs(x = expression("Species 1 ("*N[1]*")"), y = expression("Species 2 ("*N[2]*")")) +
  theme_bb512() +
  theme(panel.grid.major.y = element_blank(),
        axis.title.x = element_text(margin = margin(t = 26)),
        axis.title.y = element_text(margin = margin(r = 42)))
save_bb512(p, "01_one_isocline", layout = "half")
