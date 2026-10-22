# Slide "One generation of zygotic selection": worked example as a cycle.
# Deterministic. No dominance (Neal Case B), s = 0.3: W = 1, 0.85, 0.70 for A1A1, A1A2, A2A2.
# Start: q = 0.4, zygotes in Hardy-Weinberg proportions. Selection acts on viability (zygote to adult);
# adults then mate at random, so the next zygotes are again in Hardy-Weinberg proportions with q' = 0.359.
source("R/theme_bb512.R"); source("R/models.R")
fam <- "Avenir Next"
q <- 0.4; p <- 1 - q; w <- c(1, 0.85, 0.7)
z0 <- c(p^2, 2*p*q, q^2); ad <- z0 * w / sum(z0 * w)
q1 <- ad[3] + ad[2] / 2; z1 <- c((1-q1)^2, 2*q1*(1-q1), q1^2)
stopifnot(abs(q1 - zygotic_step(q, w[1], w[2], w[3])) < 1e-12)
geno <- c("A[1]*A[1]", "A[1]*A[2]", "A[2]*A[2]")
centres <- c(1.6, 6.5, 11.4)
df <- data.frame(stage = rep(1:3, each = 3), g = rep(1:3, 3), f = c(z0, ad, z1))
df$x <- centres[df$stage] + (df$g - 2) * 1.0
df$lab <- sprintf("%.2f", df$f)
cols <- c(bb512$forest, bb512$sage, bb512$clay)
heads <- data.frame(x = centres, y = 0.70,
  lab = c("Zygotes (HWE)\nq = 0.40", "Adults after selection\n(not in HWE)", "Next zygotes (HWE)\nq' = 0.36"))
p_ <- ggplot2::ggplot(df) +
  ggplot2::geom_col(ggplot2::aes(x, f, fill = factor(g)), width = 0.85) +
  ggplot2::geom_text(ggplot2::aes(x, f + 0.035, label = lab), family = fam, size = 5, colour = bb512$ink) +
  ggplot2::geom_text(ggplot2::aes(x, -0.045, label = rep(geno, 3)), parse = TRUE, family = fam,
                     size = 5.3, colour = bb512$grey) +
  ggplot2::geom_text(data = heads, ggplot2::aes(x, y, label = lab), family = fam, size = 5.3,
                     fontface = "bold", colour = bb512$ink, lineheight = 0.9) +
  ggplot2::annotate("segment", x = c(3.35, 8.25), xend = c(4.75, 9.65), y = 0.3, yend = 0.3,
                    linewidth = 1.1, colour = bb512$clay,
                    arrow = grid::arrow(length = grid::unit(0.14, "in"), type = "closed")) +
  ggplot2::annotate("text", x = c(4.05, 8.95), y = c(0.42, 0.42), family = fam, size = 5, colour = bb512$clay,
                    lineheight = 0.9, label = c("Selection:\n× W, ÷ 0.88", "Random\nmating")) +
  ggplot2::scale_fill_manual(values = cols, guide = "none") +
  ggplot2::coord_cartesian(xlim = c(0, 13), ylim = c(-0.07, 0.78), expand = FALSE, clip = "off") +
  ggplot2::theme_void() +
  ggplot2::theme(plot.background = ggplot2::element_rect(fill = bb512$bg, colour = NA),
                 plot.margin = ggplot2::margin(6, 10, 6, 10))
save_bb512(p_, "07_zygotic_cycle", layout = "full")
