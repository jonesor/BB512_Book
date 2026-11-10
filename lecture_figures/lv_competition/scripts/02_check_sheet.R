# What a correctly built worksheet shows with its default values (time axis 0-200, as in Excel):
# R1 = R2 = 1, K1 = 1200, alpha = 0.75, K2 = 1000, beta = 0.5, start N1 = 100, N2 = 50.
# DETERMINISTIC discrete-time simulation (R/lv_model.R); stable coexistence at (720, 640).
# Left: time series; right: phase plane with both isoclines. Layout: takeaway.
source("R/theme_bb512.R"); source("R/lv_model.R")
library(ggplot2); library(patchwork)
s <- lv_sim(1, 1200, 0.75, 1, 1000, 0.5, 100, 50, steps = 200)
a <- lv_time_plot(s, ymax = 1000, vjust = c(-0.6, 1.6))  # t = 0 to 200, as in the worksheet's graph
b <- lv_phase_plot(1200, 0.75, 1000, 0.5, sims = list(s), lim = 2100)
save_bb512(a + b + plot_layout(widths = c(1, 1)), "02_check_sheet", layout = "takeaway")
