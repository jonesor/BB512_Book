# Q2 answer (book solutions): R1 = R2 = 0.25, K1 = 3000, alpha = 2.25; K2 = 2000, beta = 0.25;
# start 50, 50. DETERMINISTIC, 200 time steps. Species 2 excludes species 1 although K1 > K2.
source("R/theme_bb512.R"); source("R/lv_model.R")
library(ggplot2); library(patchwork)
s <- lv_sim(0.25, 3000, 2.25, 0.25, 2000, 0.25, 50, 50, steps = 200)
a <- lv_time_plot(s, ymax = 2300)
b <- lv_phase_plot(3000, 2.25, 2000, 0.25, sims = list(s), lim = 8500, ylim = 2300)
# Axes are not to the same scale (K2/beta = 8000 is far out on the N1 axis).
save_bb512(a + b, "05_answer_q2", layout = "takeaway")
