# Lotka-Volterra predator-prey model exactly as students build it in Excel
# (online book, "Lotka-Volterra predator-prey dynamics"), in Neal's notation:
#   H[t+dt] = max(0, H + dt * (r H (1 - H/K) - a (H - Hr)+ P))
#   P[t+dt] = max(0, P + dt * (c (H - Hr)+ P - d P))
# K = Inf gives exponential prey growth; Hr = 0 means no refuge.
# Deterministic: no random numbers are used anywhere in this lecture.

pp_default <- list(r = 0.25, a = 0.01, c = 0.00008, d = 0.1, H = 1000, P = 20)

pp_sim <- function(r = 0.25, a = 0.01, c = 0.00008, d = 0.1, H = 1000, P = 20,
                   dt = 1, total = 300, K = Inf, Hr = 0) {
  n <- round(total / dt)
  out <- data.frame(t = (0:n) * dt, H = NA_real_, P = NA_real_)
  out$H[1] <- H; out$P[1] <- P
  for (i in seq_len(n)) {
    h <- out$H[i]; p <- out$P[i]
    hc <- max(0, h - Hr)
    growth <- if (is.finite(K)) r * h * (1 - h / K) else r * h
    out$H[i + 1] <- max(0, h + dt * (growth - a * hc * p))
    out$P[i + 1] <- max(0, p + dt * (c * hc * p - d * p))
  }
  out
}

pp_first_zero <- function(sim) {
  i <- which(sim$H <= 0)[1]
  if (is.na(i)) NA else sim$t[i]
}

pp_cols <- c("Prey (H)" = bb512$forest, "Predators (P)" = bb512$clay)

# Time series with prey on the left axis and predators on a scaled right axis.
pp_time_plot <- function(sim, tmax = max(sim$t), scale = NULL, fam = "Avenir Next",
                         xlab = "Time (t)") {
  sim <- sim[sim$t <= tmax, ]
  if (is.null(scale)) scale <- max(sim$H) / max(max(sim$P), 1e-9)
  d <- rbind(data.frame(t = sim$t, y = sim$H, sp = "Prey (H)"),
             data.frame(t = sim$t, y = sim$P * scale, sp = "Predators (P)"))
  d$sp <- factor(d$sp, levels = names(pp_cols))
  ggplot2::ggplot(d, ggplot2::aes(t, y, colour = sp)) +
    ggplot2::geom_line(linewidth = 1.2) +
    ggplot2::scale_colour_manual(values = pp_cols, name = NULL) +
    ggplot2::scale_y_continuous(name = "Prey (H)", labels = scales::label_comma(),
                                limits = c(0, NA), expand = ggplot2::expansion(mult = c(0, 0.05)),
                                sec.axis = ggplot2::sec_axis(~ . / scale, name = "Predators (P)",
                                                             labels = scales::label_comma())) +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = c(0, 0.02))) +
    ggplot2::labs(x = xlab) +
    theme_bb512(base_family = fam) +
    ggplot2::theme(axis.title.y.left = ggplot2::element_text(colour = bb512$forest),
                   axis.title.y.right = ggplot2::element_text(colour = bb512$clay),
                   legend.position = "top")
}

# Phase plane: trajectory (grey, start marked, arrow at the end), zero isoclines,
# equilibrium point. prey_iso is a data frame of points (H, P) for the prey isocline.
pp_phase_plot <- function(sim, r = 0.25, a = 0.01, c = 0.00008, d = 0.1, K = Inf, Hr = 0,
                          xmax = NULL, ymax = NULL, fam = "Avenir Next", arrow_end = TRUE,
                          traj_col = bb512$grey, xbreaks = scales::breaks_pretty(n = 3)) {
  if (is.null(xmax)) xmax <- max(sim$H) * 1.05
  if (is.null(ymax)) ymax <- max(sim$P) * 1.1
  hstar <- Hr + d / c
  hs <- seq(0, xmax, length.out = 400)
  if (Hr > 0) {
    hs <- hs[hs > Hr * 1.02]
    piso <- data.frame(H = hs, P = r * hs / (a * (hs - Hr)))
  } else if (is.finite(K)) {
    piso <- data.frame(H = hs[hs <= K], P = (r / a) * (1 - hs[hs <= K] / K))
  } else {
    piso <- data.frame(H = c(0, xmax), P = c(r / a, r / a))
  }
  piso <- piso[piso$P <= ymax, ]
  pstar <- if (Hr > 0) r * hstar / (a * (hstar - Hr)) else if (is.finite(K)) (r / a) * (1 - hstar / K) else r / a
  p <- ggplot2::ggplot() +
    ggplot2::geom_line(data = piso, ggplot2::aes(H, P), colour = bb512$forest,
                       linewidth = 1.2, linetype = "22") +
    ggplot2::geom_segment(ggplot2::aes(x = hstar, xend = hstar, y = 0, yend = ymax),
                          colour = bb512$clay, linewidth = 1.2, linetype = "22") +
    ggplot2::geom_path(data = sim, ggplot2::aes(H, P), colour = traj_col, linewidth = 0.8,
                       arrow = if (arrow_end) grid::arrow(length = grid::unit(0.1, "in"), type = "closed") else NULL) +
    ggplot2::geom_point(data = sim[1, ], ggplot2::aes(H, P), colour = bb512$ink, size = 2.6)
  if (pstar > 0 && hstar <= xmax)
    p <- p + ggplot2::annotate("point", x = hstar, y = pstar, shape = 21, size = 3.8, stroke = 1.2,
                               colour = bb512$ink, fill = bb512$bg)
  p + ggplot2::scale_x_continuous(name = "Prey (H)", limits = c(0, xmax), labels = scales::label_comma(),
                                  breaks = xbreaks,
                                  expand = ggplot2::expansion(mult = c(0, 0.02))) +
    ggplot2::scale_y_continuous(name = "Predators (P)", limits = c(0, ymax),
                                expand = ggplot2::expansion(mult = c(0, 0.02))) +
    theme_bb512(base_family = fam)
}
