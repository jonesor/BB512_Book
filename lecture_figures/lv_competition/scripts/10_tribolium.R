# Flour beetles, Neal (Interspecific Competition), Park (1962), 24 C and 70% RH:
# Tribolium confusum (species 1) K1 = 220, alpha = 1; T. castaneum (species 2) K2 = 340, beta = 2.2.
# Parameters are empirical; the trajectories are a DETERMINISTIC discrete-time simulation with
# R1 = R2 = 0.5 (illustrative). Unstable equilibrium at (100, 120): the winner depends on the start.
# Layout: half.
source("R/theme_bb512.R"); source("R/lv_model.R")
library(ggplot2)
pars <- list(R1 = 0.5, K1 = 220, alpha = 1, R2 = 0.5, K2 = 340, beta = 2.2)
sims <- lapply(list(c(100, 20), c(20, 100)),
               function(x) do.call(lv_sim, c(pars, list(N1 = x[1], N2 = x[2], steps = 200))))
p <- lv_phase_plot(220, 1, 340, 2.2, sims = sims, lim = 380) +
  ggplot2::labs(x = expression(italic("T. confusum")~(N[1])), y = expression(italic("T. castaneum")~(N[2])))
save_bb512(p, "10_tribolium", layout = "half")
