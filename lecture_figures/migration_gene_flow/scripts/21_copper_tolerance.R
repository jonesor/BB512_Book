# Slide 21: Copper tolerance in Agrostis capillaris (as A. tenuis) across a small copper
# mine at Drws-y-Coed, North Wales (McNeilly 1968, Heredity 23: 99–108; described in
# Neal 2004, section 9.3).
#
# SCHEMATIC, NOT DATA. The curves are illustrative. Their shape follows what McNeilly
# reports in the text of the paper:
#   * Upwind (transect 1): adults tolerant on the mine, with an abrupt drop between the
#     last mine site and the first site just off the mine; no tolerant plants further out.
#   * On the mine: seed is markedly LESS tolerant than adults (non-tolerant pollen in).
#   * Downwind (transect 2): tolerance in adults extends well off the mine with no
#     abrupt change; every off-mine seed sample is MORE tolerant than its adults.
# The tolerance values and distances are not McNeilly's numbers (his Fig. 3 could not be
# digitised). The earlier version of this figure used values read from a redrawn figure
# that disagreed with McNeilly's text at the first downwind site, so it was replaced.
source("R/theme_bb512.R")
library(ggplot2)
fam <- bb512_font()

x <- seq(-40, 100, by = 0.5)                 # arbitrary position units; mine = 0 to 30
logistic <- function(z) 1 / (1 + exp(-z))
# steep upwind edge x long, shallow downwind tail (one smooth curve)
adult <- 5 + 52 * logistic(x / 1.2) * logistic(-(x - 62) / 11)
# Seed differs from adults by a smoothly varying offset: none upwind (little pollen
# moves upwind), negative on the mine (non-tolerant pollen in), positive downwind.
on_mine  <- logistic((x - 1) / 1.5) * logistic(-(x - 28) / 2.5)
downwind <- logistic((x - 32) / 3)
mine_level <- max(adult)
# Downwind, tolerant pollen pulls seed part of the way towards the mine adults' level,
# so seed sits above its own adults but never above the mine population.
offset <- -14 * on_mine + 0.5 * (mine_level - adult) * downwind
seed <- pmax(adult + offset, 5)
d <- rbind(data.frame(x = x, tol = adult, stage = "Adults"),
           data.frame(x = x, tol = seed, stage = "Seed"))

p <- ggplot(d, aes(x, tol, colour = stage)) +
  annotate("rect", xmin = 0, xmax = 30, ymin = -Inf, ymax = Inf, fill = bb512$pale) +
  annotate("text", x = 15, y = 71, label = "mine", colour = bb512$grey, size = 5.2, family = fam) +
  annotate("segment", x = 40, xend = 95, y = 71, yend = 71, colour = bb512$grey, linewidth = 0.7,
           arrow = arrow(length = unit(0.12, "in"), type = "closed")) +
  annotate("text", x = 67.5, y = 75.5, label = "prevailing wind", colour = bb512$grey, size = 5, family = fam) +
  geom_line(linewidth = 1.5) +
  # (In-plot annotations removed: the slide's text explains each region.)
  scale_colour_manual(values = c(Adults = bb512$forest, Seed = bb512$gold), name = NULL) +
  scale_x_continuous(breaks = c(-20, 15, 65), labels = c("upwind", "on mine", "downwind"),
                     expand = expansion(add = 1)) +
  scale_y_continuous(limits = c(0, 79), breaks = NULL) +
  labs(x = NULL, y = "Copper tolerance (schematic)") +
  theme_bb512() +
  theme(legend.position = "top", legend.justification = "left",
        panel.grid.major.y = element_blank(),
        axis.text.x = element_text(size = 16, colour = bb512$ink))

save_bb512(p, "21_copper_tolerance", layout = "half")
