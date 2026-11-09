# Unequal unstable case: R1 = R2 = 1, K1 = K2 = 1000, alpha = 1.2, beta = 1.3.
# DETERMINISTIC, 200 time steps. Unstable equilibrium at (357, 536).
# Species 2 starts larger in both runs: from (120, 160) species 1 wins; from (100, 160) species 2 wins.
# Layout: half.
source("R/theme_bb512.R"); source("R/lv_model.R")
library(ggplot2)
pars <- list(R1 = 1, K1 = 1000, alpha = 1.2, R2 = 1, K2 = 1000, beta = 1.3)
sims <- lapply(list(c(120, 160), c(100, 160)),
               function(x) do.call(lv_sim, c(pars, list(N1 = x[1], N2 = x[2], steps = 200))))
fam <- "Avenir Next"
p <- lv_phase_plot(1000, 1.2, 1000, 1.3, sims = sims, lim = 1100) +
  annotate("text", x = 560, y = 45, label = "from (120, 160)", hjust = 0.5, family = fam, size = 5,
           colour = bb512$ink) +
  annotate("text", x = 70, y = 1060, label = "from (100, 160)", hjust = 0, family = fam, size = 5,
           colour = bb512$ink)
save_bb512(p, "08_smaller_can_win", layout = "half")
