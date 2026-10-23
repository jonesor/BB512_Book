# Slide "Does the trait predict reproductive success?": three relationships between a trait
# and reproductive success (RS).
# SIMULATED, illustrative only. 60 individuals per panel; trait ~ Normal(0, 1) (standardised);
# RS ~ Poisson(exp(a + b * trait)) with b = +0.6 (selection for larger values),
# b = -0.6 (selection for smaller values) and b = 0 (no selection: the trait can then change
# only by chance, i.e. genetic drift). Seed 512 (set by the runner, repeated here).
source("R/theme_bb512.R")
fam <- "Avenir Next"
set.seed(512)
n <- 60; a <- log(2)
panels <- c("Selection for larger values", "Selection for smaller values", "No selection (neutral)")
b <- c(0.6, -0.6, 0)
df <- do.call(rbind, lapply(1:3, function(i) {
  z <- rnorm(n)
  data.frame(panel = panels[i], trait = z, rs = rpois(n, exp(a + b[i] * z)))
}))
df$panel <- factor(df$panel, levels = panels)
# Expected RS (the true relationship used in the simulation)
grid <- expand.grid(trait = seq(-2.5, 2.5, length.out = 100), panel = panels)
grid$rs <- exp(a + b[match(grid$panel, panels)] * grid$trait)
grid$panel <- factor(grid$panel, levels = panels)
cols <- c(bb512$forest, bb512$clay, bb512$grey)
p <- ggplot2::ggplot(df, ggplot2::aes(trait, rs)) +
  ggplot2::geom_point(ggplot2::aes(colour = panel), alpha = 0.55, size = 2.6,
                      position = ggplot2::position_jitter(width = 0, height = 0.18, seed = 1)) +
  ggplot2::geom_line(data = grid, ggplot2::aes(colour = panel), linewidth = 1.4) +
  ggplot2::facet_wrap(~panel, nrow = 1) +
  ggplot2::scale_colour_manual(values = setNames(cols, panels), guide = "none") +
  ggplot2::scale_x_continuous(breaks = c(-2, 0, 2), labels = c("Small", "Average", "Large")) +
  ggplot2::scale_y_continuous(breaks = seq(0, 12, 4)) +
  ggplot2::coord_cartesian(xlim = c(-2.6, 2.6), ylim = c(0, 12)) +
  ggplot2::labs(x = "Trait value", y = "Offspring") +
  theme_bb512() +
  ggplot2::theme(panel.spacing = ggplot2::unit(1.6, "lines"))
save_bb512(p, "02_trait_rs", layout = "full")
