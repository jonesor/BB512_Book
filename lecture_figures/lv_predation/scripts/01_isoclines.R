# The two zero isoclines and the four regions they define (Neal, Predator-Prey Interactions).
# Analytical schematic with the worksheet's values: P = r/a = 25, H = d/c = 1250. Layout: half.
source("R/theme_bb512.R"); source("R/pp_model.R")
library(ggplot2)
lab <- data.frame(H = c(600, 1900, 1900, 600), P = c(12, 12, 38, 38),
                  txt = c("Prey +\nPredators -", "Prey +\nPredators +",
                          "Prey -\nPredators +", "Prey -\nPredators -"))
arr <- data.frame(x = c(500, 1950, 2000, 500), y = c(20, 22, 33, 30),
                  xend = c(800, 1950, 1700, 500), yend = c(20, 28, 33, 24))
p <- ggplot() +
  geom_hline(yintercept = 25, colour = bb512$forest, linewidth = 1.3, linetype = "22") +
  geom_vline(xintercept = 1250, colour = bb512$clay, linewidth = 1.3, linetype = "22") +
  geom_text(data = lab, aes(H, P, label = txt), family = "Avenir Next", size = 4.6, colour = bb512$ink,
            lineheight = 0.9) +
  annotate("path", x = 1250 + 520 * cos(seq(0, 2 * pi, length.out = 200)),
           y = 25 + 9 * sin(seq(0, 2 * pi, length.out = 200)), colour = bb512$grey, linewidth = 0.9) +
  # anticlockwise: angle increases along the orbit (top moves left, bottom moves right)
  annotate("segment", x = 1250 + 520 * cos(1.35), y = 25 + 9 * sin(1.35),
           xend = 1250 + 520 * cos(1.75), yend = 25 + 9 * sin(1.75),
           colour = bb512$grey, arrow = grid::arrow(length = grid::unit(0.12, "in"), type = "closed")) +
  annotate("segment", x = 1250 + 520 * cos(4.5), y = 25 + 9 * sin(4.5),
           xend = 1250 + 520 * cos(4.9), yend = 25 + 9 * sin(4.9),
           colour = bb512$grey, arrow = grid::arrow(length = grid::unit(0.12, "in"), type = "closed")) +
  annotate("text", x = 2450, y = 28, label = "P == r/a", parse = TRUE, hjust = 1,
           family = "Avenir Next", size = 5.2, colour = bb512$forest) +
  annotate("text", x = 1290, y = 48, label = "H == d/c", parse = TRUE, hjust = 0,
           family = "Avenir Next", size = 5.2, colour = bb512$clay) +
  annotate("point", x = 1250, y = 25, shape = 21, size = 3.8, stroke = 1.2, colour = bb512$ink, fill = bb512$bg) +
  scale_x_continuous(name = "Prey (H)", limits = c(0, 2500), breaks = c(0, 1250, 2500),
                     labels = scales::label_comma(), expand = expansion(mult = c(0, 0.02))) +
  scale_y_continuous(name = "Predators (P)", limits = c(0, 50), breaks = c(0, 25, 50),
                     expand = expansion(mult = c(0, 0.02))) +
  theme_bb512()
save_bb512(p, "01_isoclines", layout = "half")
