# Discrete-time Lotka-Volterra competition model, exactly as students build it in Excel
# (practical worksheet, Equations 2 and 3), written in Neal's notation:
#   N1[t+1] = N1[t] + R1 * N1[t] * (K1 - N1[t] - alpha * N2[t]) / K1
#   N2[t+1] = N2[t] + R2 * N2[t] * (K2 - N2[t] - beta  * N1[t]) / K2
# alpha = per capita effect of species 2 on species 1 (worksheet: a12)
# beta  = per capita effect of species 1 on species 2 (worksheet: a21)
# R is a rate per time step (keep R <= 1 to avoid the oscillations of the discrete logistic).
# Deterministic: no random numbers are used anywhere in this lecture.

lv_sim <- function(R1, K1, alpha, R2, K2, beta, N1, N2, steps = 200) {
  out <- data.frame(t = 0:steps, N1 = NA_real_, N2 = NA_real_)
  out$N1[1] <- N1; out$N2[1] <- N2
  for (i in seq_len(steps)) {
    n1 <- out$N1[i]; n2 <- out$N2[i]
    out$N1[i + 1] <- n1 + R1 * n1 * (K1 - n1 - alpha * n2) / K1
    out$N2[i + 1] <- n2 + R2 * n2 * (K2 - n2 - beta * n1) / K2
  }
  out
}

lv_equilibrium <- function(K1, alpha, K2, beta) {
  c(N1 = (K1 - alpha * K2) / (1 - alpha * beta),
    N2 = (K2 - beta * K1) / (1 - alpha * beta))
}

sp_cols <- c("Species 1" = bb512$forest, "Species 2" = bb512$clay)

# Time series of both species, labelled directly at the right-hand end.
lv_time_plot <- function(sim, steps = max(sim$t), ymax = NULL, fam = "Avenir Next",
                         vjust = c(-0.6, -0.6)) {
  d <- rbind(data.frame(t = sim$t, N = sim$N1, sp = "Species 1"),
             data.frame(t = sim$t, N = sim$N2, sp = "Species 2"))
  d <- d[d$t <= steps, ]
  ends <- d[d$t == steps, ]
  ends$vj <- vjust
  if (is.null(ymax)) ymax <- max(d$N) * 1.08
  ggplot2::ggplot(d, ggplot2::aes(t, N, colour = sp)) +
    ggplot2::geom_line(linewidth = 1.3) +
    ggplot2::geom_text(data = ends, ggplot2::aes(label = sp, vjust = vj), hjust = 1,
                       family = fam, size = 5.2, fontface = "bold") +
    ggplot2::scale_colour_manual(values = sp_cols, guide = "none") +
    ggplot2::scale_y_continuous(limits = c(0, ymax), labels = scales::label_comma(),
                                expand = ggplot2::expansion(mult = c(0, 0.02))) +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = c(0, 0.02))) +
    ggplot2::labs(x = "Time step (t)", y = "Population size (N)") +
    theme_bb512()
}

# Phase plane: both zero isoclines, intercepts labelled with plotmath,
# one or more trajectories (grey line, start marked) and the equilibrium if interior.
lv_phase_plot <- function(K1, alpha, K2, beta, sims = list(), lim = NULL, ylim = lim,
                          fam = "Avenir Next", show_eq = TRUE, intercept_labels = TRUE) {
  x1 <- K1; y1 <- K1 / alpha        # species 1 isocline intercepts
  x2 <- K2 / beta; y2 <- K2         # species 2 isocline intercepts
  if (is.null(lim)) lim <- max(x1, y1, x2, y2) * 1.1
  if (is.null(ylim)) ylim <- lim
  iso <- data.frame(x = c(x1, x2), y = c(0, 0), xend = c(0, 0), yend = c(y1, y2),
                    sp = c("Species 1", "Species 2"))
  p <- ggplot2::ggplot() +
    ggplot2::geom_segment(data = iso, ggplot2::aes(x, y, xend = xend, yend = yend, colour = sp,
                                                   linetype = sp), linewidth = 1.3) +
    ggplot2::scale_colour_manual(values = sp_cols, guide = "none") +
    ggplot2::scale_linetype_manual(values = c("Species 1" = "solid", "Species 2" = "22"), guide = "none")
  for (s in sims) {
    p <- p +
      ggplot2::geom_path(data = s, ggplot2::aes(N1, N2), colour = bb512$grey, linewidth = 0.9,
                         arrow = grid::arrow(length = grid::unit(0.09, "in"), type = "closed")) +
      ggplot2::geom_point(data = s[1, ], ggplot2::aes(N1, N2), colour = bb512$grey, size = 2.4)
  }
  if (show_eq) {
    eq <- lv_equilibrium(K1, alpha, K2, beta)
    if (all(eq > 0)) {
      stable <- alpha * beta < 1
      p <- p + ggplot2::annotate("point", x = eq[1], y = eq[2], shape = 21, size = 4.2, stroke = 1.3,
                                 colour = bb512$ink, fill = if (stable) bb512$ink else bb512$bg)
    }
  }
  # intercept labels on the axes (plotmath)
  ax <- data.frame(v = c(x1, x2), lab = c("K[1]", "K[2]/beta"), col = c("Species 1", "Species 2"))
  ay <- data.frame(v = c(y1, y2), lab = c("K[1]/alpha", "K[2]"), col = c("Species 1", "Species 2"))
  if (intercept_labels) p <- p +
    ggplot2::geom_text(data = ax, ggplot2::aes(x = v, y = -0.035 * ylim, label = lab, colour = col),
                       parse = TRUE, vjust = 1, family = fam, size = 5.2) +
    ggplot2::geom_text(data = ay, ggplot2::aes(x = -0.025 * lim, y = v, label = lab, colour = col),
                       parse = TRUE, hjust = 1, family = fam, size = 5.2)
  p +
    ggplot2::coord_cartesian(xlim = c(0, lim), ylim = c(0, ylim), clip = "off") +
    ggplot2::scale_x_continuous(breaks = NULL, expand = c(0, 0)) +
    ggplot2::scale_y_continuous(breaks = NULL, expand = c(0, 0)) +
    ggplot2::labs(x = expression("Species 1 ("*N[1]*")"), y = expression("Species 2 ("*N[2]*")")) +
    theme_bb512() +
    ggplot2::theme(panel.grid.major.y = ggplot2::element_blank(),
                   axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 26)),
                   axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 42)))
}
