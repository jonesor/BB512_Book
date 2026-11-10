# Answer, Part 2 task 1: the cycles with dt = 0.1 (close to the continuous model), 0-120 time units.
# Prey peak at t = 13.8, 54, 94.2; predators about a quarter of a cycle later (22.4, 62.5, 102.7).
# DETERMINISTIC simulation. Layout: takeaway.
source("R/theme_bb512.R"); source("R/pp_model.R")
library(ggplot2)
s <- pp_sim(dt = 0.1, total = 120)
p <- pp_time_plot(s, scale = 60) +
  annotate("segment", x = 13.8, xend = 22.4, y = 2050, yend = 2050, colour = bb512$ink,
           arrow = grid::arrow(length = grid::unit(0.08, "in"), ends = "both")) +
  annotate("text", x = 26, y = 2050, label = "1/4 cycle", hjust = 0, family = "Avenir Next",
           size = 4.8, colour = bb512$ink)
save_bb512(p, "04_answer_cycles", layout = "takeaway")
