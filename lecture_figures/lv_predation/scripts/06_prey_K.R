# Answer, Part 3: prey carrying capacity K = 2000, dt = 1. Damped cycles settle at (1250, 9.375).
# The prey isocline slopes from P = r/a at H = 0 to H = K at P = 0. DETERMINISTIC. Layout: takeaway.
source("R/theme_bb512.R"); source("R/pp_model.R")
library(ggplot2); library(patchwork)
s <- pp_sim(K = 2000, dt = 1, total = 150)
a <- pp_time_plot(s, scale = 100)
b <- pp_phase_plot(s, xbreaks = c(0, 1000, 2000), K = 2000, xmax = 2100, ymax = 27)
save_bb512(a + b + plot_layout(widths = c(1.15, 1)), "06_prey_K", layout = "takeaway")
