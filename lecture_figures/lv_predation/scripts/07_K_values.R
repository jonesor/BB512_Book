# Answer, Part 3: K = 1000 (< d/c: predators die out), 2000 and 10000 (damps more slowly), dt = 1, 300 time units.
# DETERMINISTIC simulations. Layout: full.
source("R/theme_bb512.R"); source("R/pp_model.R")
library(ggplot2); library(patchwork)
labs <- c("K = 1000: predators die out", "K = 2000: settles quickly", "K = 10000: settles slowly")
pl <- Map(function(K, lab) {
  s <- pp_sim(K = K, dt = 1, total = 300)
  pp_phase_plot(s, K = K, xmax = 2600, ymax = 32, arrow_end = FALSE) +
    annotate("label", x = 2600, y = 31, label = lab, hjust = 1, family = "Avenir Next",
             size = 4.4, fontface = "bold", colour = bb512$ink, fill = bb512$bg, label.size = 0) +
    theme(axis.title = element_text(size = 14), axis.text = element_text(size = 12))
}, c(1000, 2000, 10000), labs)
save_bb512(wrap_plots(pl, nrow = 1), "07_K_values", layout = "full")
