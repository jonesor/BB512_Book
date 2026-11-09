# Identical species: R1 = R2 = 0.5, K1 = K2 = 1000, alpha = beta = 1 (Neal's fifth case).
# DETERMINISTIC, 200 time steps. The isoclines coincide; every point on the line is an equilibrium,
# so (100, 300) ends at (250, 750) and (300, 100) at (750, 250): no exclusion. Layout: half.
source("R/theme_bb512.R"); source("R/lv_model.R")
library(ggplot2)
pars <- list(R1 = 0.5, K1 = 1000, alpha = 1, R2 = 0.5, K2 = 1000, beta = 1)
sims <- lapply(list(c(100, 300), c(300, 100)),
               function(x) do.call(lv_sim, c(pars, list(N1 = x[1], N2 = x[2], steps = 200))))
fam <- "Avenir Next"
p <- lv_phase_plot(1000, 1, 1000, 1, sims = sims, lim = 1100, show_eq = FALSE, intercept_labels = FALSE) +
  annotate("text", x = 1000, y = -38, label = "K[1] == K[2]/beta", parse = TRUE, vjust = 1, family = fam, size = 5.2, colour = bb512$ink) +
  annotate("text", x = -28, y = 1000, label = "K[2] == K[1]/alpha", parse = TRUE, hjust = 1, family = fam, size = 5.2, colour = bb512$ink) +
  annotate("point", x = c(250, 750), y = c(750, 250), size = 3.6, colour = bb512$ink) +
  annotate("text", x = 290, y = 800, label = "(250, 750)", hjust = 0, family = fam, size = 5, colour = bb512$ink) +
  annotate("text", x = 790, y = 300, label = "(750, 250)", hjust = 0, family = fam, size = 5, colour = bb512$ink)
save_bb512(p, "09_identical_species", layout = "half")
