# Q1 answer (book solutions): R1 = 0.25, K1 = 3000, alpha = 1.25; R2 = 0.5, K2 = 1000, beta = 0.5;
# start N1 = 50, N2 = 100. DETERMINISTIC discrete-time simulation, 200 time steps.
# Species 1 excludes species 2 although species 2 grows faster, starts larger and alpha > 1.
source("R/theme_bb512.R"); source("R/lv_model.R")
library(ggplot2); library(patchwork)
s <- lv_sim(0.25, 3000, 1.25, 0.5, 1000, 0.5, 50, 100, steps = 200)
a <- lv_time_plot(s, ymax = 3300)
b <- lv_phase_plot(3000, 1.25, 1000, 0.5, sims = list(s), lim = 3300)
save_bb512(a + b, "04_answer_q1", layout = "takeaway")
