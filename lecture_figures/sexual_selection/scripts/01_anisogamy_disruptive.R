# Disruptive selection on gamete size (SCHEMATIC, not data).
# After Parker, Baker & Smith (1972); review Lehtonen & Parker (2014) Mol Hum Reprod.
# For a fixed budget, many small gametes gain fertilisation chances, few large gametes
# give better zygote survival; intermediates get neither, so fitness is U-shaped.
source("R/theme_bb512.R")
font <- if ("Avenir Next" %in% systemfonts::system_fonts()$family) "Avenir Next" else "Inter"
library(ggplot2)

d <- data.frame(x = seq(0.05, 0.95, length.out = 200))
d$w <- 0.2 + 2.6 * (d$x - 0.5)^2

p <- ggplot(d, aes(x, w)) +
  geom_line(colour = bb512$forest, linewidth = 1.5) +
  annotate("segment", x = 0.42, xend = 0.16, y = 0.45, yend = 0.45, colour = bb512$clay,
           linewidth = 1.2, arrow = arrow(length = unit(0.12, "in"), type = "closed")) +
  annotate("segment", x = 0.58, xend = 0.84, y = 0.45, yend = 0.45, colour = bb512$clay,
           linewidth = 1.2, arrow = arrow(length = unit(0.12, "in"), type = "closed")) +
  annotate("text", x = 0.08, y = 0.93, hjust = 0, label = "Many small:\nmore fertilisations",
           family = font, size = 5.5, colour = bb512$ink, lineheight = 0.9) +
  annotate("text", x = 0.92, y = 0.93, hjust = 1, label = "Few large:\nzygote survives",
           family = font, size = 5.5, colour = bb512$ink, lineheight = 0.9) +
  annotate("text", x = 0.5, y = 0.11, label = "Intermediate: neither",
           family = font, size = 5.5, colour = bb512$grey) +
  scale_x_continuous("Gamete size", breaks = c(0.05, 0.95), labels = c("small", "large"),
                     limits = c(0, 1)) +
  scale_y_continuous("Fitness", breaks = NULL, limits = c(0, 1.05)) +
  theme_bb512(base_family = font) +
  theme(panel.grid.major.y = element_blank())

save_bb512(p, "01_anisogamy_disruptive", layout = "half")
