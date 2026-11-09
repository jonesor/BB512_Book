# The four arrangements of the zero isoclines (ANALYTICAL schematics, illustrative values).
# Species 1 solid forest (intercepts K1, K1/alpha); species 2 dashed clay (K2/beta, K2).
# Filled circle = stable equilibrium; open circle = unstable equilibrium. Layout: full.
source("R/theme_bb512.R"); source("R/lv_model.R")
library(ggplot2); library(patchwork)
fam <- "Avenir Next"
cases <- list(
  list(t = "Species 1 wins",       K1 = 1100, K1a = 1500, K2b = 500,  K2 = 800),
  list(t = "Species 2 wins",       K1 = 500,  K1a = 800,  K2b = 1100, K2 = 1500),
  list(t = "Coexistence",          K1 = 1000, K1a = 1500, K2b = 1500, K2 = 1000),
  list(t = "Either can win",       K1 = 1150, K1a = 650,  K2b = 550,  K2 = 1150))
panel <- function(cc) {
  lim <- 1650
  p <- ggplot() +
    annotate("segment", x = cc$K1, y = 0, xend = 0, yend = cc$K1a, colour = bb512$forest, linewidth = 1.3) +
    annotate("segment", x = cc$K2b, y = 0, xend = 0, yend = cc$K2, colour = bb512$clay, linewidth = 1.3,
             linetype = "22") +
    annotate("text", x = cc$K1, y = -0.04 * lim, label = "K[1]", parse = TRUE, vjust = 1, family = fam,
             size = 5, colour = bb512$forest) +
    annotate("text", x = cc$K2b, y = -0.04 * lim, label = "K[2]/beta", parse = TRUE, vjust = 1,
             family = fam, size = 5, colour = bb512$clay) +
    annotate("text", x = -0.06 * lim, y = cc$K1a, label = "K[1]/alpha", parse = TRUE, hjust = 1,
             family = fam, size = 5, colour = bb512$forest) +
    annotate("text", x = -0.06 * lim, y = cc$K2, label = "K[2]", parse = TRUE, hjust = 1, family = fam,
             size = 5, colour = bb512$clay) +
    annotate("text", x = lim / 2, y = lim * 1.08, label = cc$t, family = fam, size = 5.6,
             fontface = "bold", colour = bb512$forest)
  alpha <- cc$K1 / cc$K1a; beta <- cc$K2 / cc$K2b
  # Stable boundary equilibria: (K1, 0) if species 2 cannot invade (K1 > K2/beta);
  # (0, K2) if species 1 cannot invade (K2 > K1/alpha). Interior equilibrium drawn if it exists.
  if (cc$K1 > cc$K2b) p <- p + annotate("point", x = cc$K1, y = 0, shape = 21, size = 4, stroke = 1.3,
                                        colour = bb512$ink, fill = bb512$ink)
  if (cc$K2 > cc$K1a) p <- p + annotate("point", x = 0, y = cc$K2, shape = 21, size = 4, stroke = 1.3,
                                        colour = bb512$ink, fill = bb512$ink)
  eq <- lv_equilibrium(cc$K1, alpha, cc$K2, beta)
  if (all(eq > 0)) {
    p <- p + annotate("point", x = eq[1], y = eq[2], shape = 21, size = 4, stroke = 1.3,
                      colour = bb512$ink, fill = if (alpha * beta < 1) bb512$ink else bb512$bg)
  }
  p + coord_cartesian(xlim = c(0, lim), ylim = c(0, lim), clip = "off") +
    scale_x_continuous(breaks = NULL, expand = c(0, 0)) +
    scale_y_continuous(breaks = NULL, expand = c(0, 0)) +
    labs(x = expression(N[1]), y = expression(N[2])) +
    theme_bb512() +
    theme(panel.grid.major.y = element_blank(),
          axis.title.x = element_text(margin = margin(t = 22)),
          axis.title.y = element_text(margin = margin(r = 58), angle = 0, vjust = 0.5),
          plot.margin = margin(30, 10, 8, 10))
}
p <- wrap_plots(lapply(cases, panel), nrow = 1)
save_bb512(p, "03_four_outcomes", layout = "full")
