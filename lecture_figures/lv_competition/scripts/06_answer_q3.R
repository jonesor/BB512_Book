# Q3 answer (book solutions): R1 = 0.75, K1 = 2500, alpha = 0.75; R2 = 0.5, K2 = 2000, beta = 0.5.
# DETERMINISTIC, 200 time steps. Time series from (50, 50); phase plane adds the book's five
# other starts, which all return to the stable equilibrium (1600, 1200).
source("R/theme_bb512.R"); source("R/lv_model.R")
library(ggplot2); library(patchwork)
pars <- list(R1 = 0.75, K1 = 2500, alpha = 0.75, R2 = 0.5, K2 = 2000, beta = 0.5)
starts <- list(c(50, 50), c(1000, 1), c(1, 1000), c(500, 2500), c(1000, 3000), c(250, 3000))
sims <- lapply(starts, function(x) do.call(lv_sim, c(pars, list(N1 = x[1], N2 = x[2], steps = 200))))
a <- lv_time_plot(sims[[1]], ymax = 2000)
b <- lv_phase_plot(2500, 0.75, 2000, 0.5, sims = sims, lim = 4100)
save_bb512(a + b, "06_answer_q3", layout = "takeaway")
