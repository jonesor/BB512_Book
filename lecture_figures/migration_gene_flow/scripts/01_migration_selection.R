# Continent-island migration-selection balance: supplied approximation.
# Mainland immigrants carry the wing allele; on the island the winged
# recessive homozygote is selected against with coefficient s.
# q ~= sqrt(m/s), so the HWE recessive phenotype frequency q^2 ~= m/s.
# These are deterministic approximations, not exact equilibria for every
# migration/selection life cycle (particularly when m is large relative to s).
source("R/theme_bb512.R")

s <- 0.25
m <- seq(0, 0.15, length.out = 500)
stopifnot(s > 0, s <= 1, all(m >= 0), all(m <= s))
df <- data.frame(m = m, q = sqrt(m / s), winged = m / s)
pts <- data.frame(m = c(0.01, 0.10))
pts$q <- sqrt(pts$m / s)
pts$winged <- pts$m / s
stopifnot(isTRUE(all.equal(df$q^2, df$winged)))

p <- ggplot2::ggplot(df, ggplot2::aes(x = m)) +
  # Dashed guides connect each highlighted immigration rate to the allele curve.
  ggplot2::geom_segment(data = pts,
    ggplot2::aes(x = m, xend = m, y = 0, yend = q), inherit.aes = FALSE,
    colour = bb512$grey, linetype = "dashed", linewidth = 0.6) +
  ggplot2::geom_line(ggplot2::aes(y = q, colour = "allele"), linewidth = 1.5) +
  ggplot2::geom_line(ggplot2::aes(y = winged, colour = "phenotype"), linewidth = 1.5) +
  ggplot2::geom_point(data = pts, ggplot2::aes(y = q),
                      colour = bb512$forest, size = 3.5) +
  ggplot2::geom_point(data = pts, ggplot2::aes(y = winged),
                      colour = bb512$clay, size = 3.5) +
  ggplot2::annotate("text", x = 0.003, y = 0.59, label = "wing allele, q",
                     colour = bb512$forest, hjust = 0, size = 5.5, family = "Avenir Next") +
  ggplot2::annotate("text", x = 0.103, y = 0.30,
                     label = "'winged insects,'~q^2", parse = TRUE,
                     colour = bb512$clay, hjust = 0, size = 5.5, family = "Avenir Next") +
  ggplot2::annotate("text", x = 0.002, y = 0.83,
                     label = sprintf("s == %.2f", s), parse = TRUE,
                     colour = bb512$grey, hjust = 0, size = 5, family = "Avenir Next") +
  ggplot2::scale_colour_manual(
    values = c(allele = bb512$forest, phenotype = bb512$clay),
    guide = "none") +
  ggplot2::scale_x_continuous(breaks = seq(0, 0.15, 0.05),
    labels = function(x) sprintf("%.2f", x),
    expand = ggplot2::expansion(mult = c(0.01, 0.03))) +
  ggplot2::scale_y_continuous(breaks = seq(0, 0.8, 0.2), limits = c(0, 0.89),
                              expand = c(0, 0)) +
  ggplot2::labs(x = "Immigration rate from mainland (m)", y = "Equilibrium frequency") +
  theme_bb512()

save_bb512(p, "01_migration_selection", layout = "fullbox")
