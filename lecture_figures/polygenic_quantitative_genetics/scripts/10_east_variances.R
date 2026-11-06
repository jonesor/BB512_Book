# Slide "Estimating V_E and V_G from East's plants": the calculation behind Neal's partition.
# RECONSTRUCTED data, not East's raw counts. Counts per 3 mm corolla-length class were first digitised from
# the histograms of East (1916) Nicotiana longiflora (cross of a short line, P1, with a long line, P2), as
# reproduced in Neal (2004, figure of breeding experiments on flower length; images/east_histograms.jpg).
# The digitised means matched East's (P1 40.4, P2 93.2, F1 63.5 mm) but the variances were larger than the
# values Neal reports from East's data. The counts were then ADJUSTED (a smooth taper towards each group's
# mean, keeping n and the mean) so that the variances reproduce Neal's summary values:
#   V_E = mean of P1, P2, F1 variances = (3.3 + 4.2 + 8.1) / 3 = 5.2; V_P (F2) = 40.5; V_G = 35.3 (87%).
# Neal does not give the three separate group variances; their relative sizes follow the digitised data.
# Digitised counts, for reference:
#   P1 3, 20, 108, 50 | P2 9, 39, 82, 18 | F1 6, 11, 41, 75, 41, 5 | F2 5, 10, 18, 52, 59, 92, 75, 62, 46, 27, 10, 14, 5
# Variances are sample variances of grouped data: sum(f * (x - mean)^2) / (n - 1).
source("R/theme_bb512.R")
fam <- "Avenir Next"

d <- rbind(
  data.frame(group = "P1", x = c(34, 37, 40, 43), n = c(2, 18, 118, 43)),
  data.frame(group = "P2", x = c(88, 91, 94, 97), n = c(6, 41, 87, 14)),
  data.frame(group = "F1", x = seq(55, 70, 3), n = c(4, 10, 45, 82, 35, 3)),
  data.frame(group = "F2", x = seq(52, 88, 3), n = c(2, 6, 14, 47, 59, 100, 84, 69, 48, 26, 8, 9, 3))
)
gvar <- function(x, n) { m <- sum(x * n) / sum(n); sum(n * (x - m)^2) / (sum(n) - 1) }
v <- do.call(rbind, lapply(split(d, d$group), function(g)
  data.frame(group = g$group[1], N = sum(g$n), mean = sum(g$x * g$n) / sum(g$n), var = gvar(g$x, g$n))))
VE <- mean(round(v$var[v$group != "F2"], 1)); VP <- round(v$var[v$group == "F2"], 1); VG <- VP - VE
stopifnot(isTRUE(all.equal(VE, 5.2)), isTRUE(all.equal(VP, 40.5)))
print(v); cat(sprintf("V_E = %.1f, V_P = %.1f, V_G = %.1f, genetic share = %.0f%%\n", VE, VP, VG, 100 * VG / VP))

lev <- c("P1", "P2", "F1", "F2")
d$group <- factor(d$group, lev); v$group <- factor(v$group, lev)
d$uniform <- d$group != "F2"
v$lab <- sprintf('s^2 == "%.1f"', v$var)
v$ypos <- tapply(d$n, d$group, max)[as.character(v$group)] * 0.62
v$what <- ifelse(v$group == "F2", "genes + environment", "environment only")

p <- ggplot2::ggplot(d, ggplot2::aes(x, n)) +
  ggplot2::geom_col(ggplot2::aes(fill = uniform), width = 2.7) +
  ggplot2::scale_fill_manual(values = c(`TRUE` = bb512$sage, `FALSE` = bb512$forest), guide = "none") +
  ggplot2::geom_text(data = v, ggplot2::aes(x = 101, y = ypos, label = lab), parse = TRUE,
                     hjust = 0, family = fam, size = 5.2, colour = bb512$ink) +
  ggplot2::geom_text(data = v, ggplot2::aes(x = 101, y = ypos * 0.35, label = what),
                     hjust = 0, family = fam, size = 4.2, colour = bb512$grey) +
  ggplot2::facet_grid(group ~ ., scales = "free_y", switch = "y") +
  ggplot2::scale_x_continuous(limits = c(31, 121), breaks = seq(40, 100, 10)) +
  ggplot2::scale_y_continuous(breaks = NULL, expand = ggplot2::expansion(mult = c(0, 0.08))) +
  ggplot2::coord_cartesian(clip = "off") +
  ggplot2::labs(x = "Corolla length (mm)", y = NULL) +
  theme_bb512() +
  ggplot2::theme(strip.placement = "outside",
                 strip.text.y.left = ggplot2::element_text(angle = 0, size = 17, face = "bold", colour = bb512$ink),
                 panel.grid.major.y = ggplot2::element_blank(),
                 axis.line.y = ggplot2::element_blank(),
                 panel.spacing.y = ggplot2::unit(6, "pt"))
save_bb512(p, "10_east_variances", layout = "takeaway")
