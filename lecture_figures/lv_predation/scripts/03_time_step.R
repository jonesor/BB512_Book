# The time step: dt = 1 (cycles grow, prey hit zero at t = 220) versus dt = 0.1 (almost closed).
# Both run for 300 time units from (1000, 20). The panels have DIFFERENT axis scales
# (the dt = 0.1 orbit is invisible at the dt = 1 scale). DETERMINISTIC simulations. Layout: full.
source("R/theme_bb512.R"); source("R/pp_model.R")
library(ggplot2); library(patchwork)
s1 <- pp_sim(dt = 1, total = 300)
s2 <- pp_sim(dt = 0.1, total = 300)
lim_x <- 17000; lim_y <- 240
a <- pp_phase_plot(s1, xmax = lim_x, ymax = lim_y, arrow_end = FALSE) +
  annotate("label", x = lim_x, y = lim_y * 0.95, label = "dt = 1: the cycles grow", hjust = 1,
           family = "Avenir Next", size = 5.4, fontface = "bold", colour = bb512$ink, fill = bb512$bg, label.size = 0)
b <- pp_phase_plot(s2, xmax = 2500, ymax = 45, arrow_end = FALSE) +
  annotate("label", x = 2500, y = 45 * 0.95, label = "dt = 0.1 (zoomed in): almost closed", hjust = 1,
           family = "Avenir Next", size = 5.4, fontface = "bold", colour = bb512$ink, fill = bb512$bg, label.size = 0)
save_bb512(a + b, "03_time_step", layout = "full")
