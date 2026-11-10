# What a correctly built Part 1 sheet shows: worksheet values, dt = 1, 0-300 time units (the worksheet graph's range).
# Prey hit zero at t = 220; predators then dwindle.
# DETERMINISTIC discrete-time simulation (R/pp_model.R). Layout: takeaway.
source("R/theme_bb512.R"); source("R/pp_model.R")
library(ggplot2); library(patchwork)
s <- pp_sim(dt = 1, total = 300)
a <- pp_time_plot(s, scale = 70)
b <- pp_phase_plot(s, xbreaks = c(0, 8000, 16000), xmax = 17000, ymax = 240, arrow_end = FALSE)
save_bb512(a + b + plot_layout(widths = c(1.15, 1)), "02_check_sheet", layout = "takeaway")
