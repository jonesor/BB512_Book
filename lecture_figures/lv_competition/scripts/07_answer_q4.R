# Q4 answer (book solutions): R1 = R2 = 0.5, K1 = K2 = 1000, alpha = beta = 1.25.
# DETERMINISTIC, 200 time steps. Unstable equilibrium at (444.4, 444.4).
# Time series from (100, 50): species 1 wins. Phase plane: starts (100, 50), (50, 100), (50, 50);
# the last goes to the unstable point and stays only because the model is deterministic.
source("R/theme_bb512.R"); source("R/lv_model.R")
library(ggplot2); library(patchwork)
pars <- list(R1 = 0.5, K1 = 1000, alpha = 1.25, R2 = 0.5, K2 = 1000, beta = 1.25)
starts <- list(c(100, 50), c(50, 100), c(50, 50))
sims <- lapply(starts, function(x) do.call(lv_sim, c(pars, list(N1 = x[1], N2 = x[2], steps = 200))))
a <- lv_time_plot(sims[[1]], ymax = 1100)
b <- lv_phase_plot(1000, 1.25, 1000, 1.25, sims = sims, lim = 1100)
save_bb512(a + b, "07_answer_q4", layout = "takeaway")
