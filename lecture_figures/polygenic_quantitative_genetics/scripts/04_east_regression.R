# Slide "Offspring resemble their parents: the slope is h²": mid-parent-offspring regression.
# Empirical: East (1916) Nicotiana longiflora corolla length, from Neal (2004), parent–offspring regression figure.
# Points were DIGITISED by eye from Neal's figure (17 families), so they are approximate.
# The fitted line uses the PUBLISHED slope, 0.8348 (Neal 2004), drawn through the mean of the
# digitised points. (OLS on the digitised points gives 0.838, close to the published value.)
# Reference lines show the expectations if h² were 1 (dashed) or 0 (flat, dotted).
source("R/theme_bb512.R")
fam <- "Avenir Next"

d <- data.frame(parent    = c(41, 43, 44, 46, 50, 50, 60, 61, 61, 72, 77, 80, 81, 82, 85, 87, 90),
                offspring = c(42, 46, 45.5, 53.5, 50, 53, 56, 67.5, 69.5, 73, 73, 74, 76.5, 80, 82.3, 82.8, 88))
slope <- 0.8348
mx <- mean(d$parent); my <- mean(d$offspring)
xr <- c(38, 92)
lines <- data.frame(x = xr, fit = my + slope * (xr - mx), one = my + 1 * (xr - mx), zero = my)

p <- ggplot2::ggplot(d, ggplot2::aes(parent, offspring)) +
  ggplot2::geom_line(data = lines, ggplot2::aes(x, one), colour = bb512$grey, linewidth = 0.7, linetype = "dashed") +
  ggplot2::geom_line(data = lines, ggplot2::aes(x, zero), colour = bb512$grey, linewidth = 0.7, linetype = "dotted") +
  ggplot2::geom_line(data = lines, ggplot2::aes(x, fit), colour = bb512$clay, linewidth = 1.4) +
  ggplot2::geom_point(size = 3.6, colour = bb512$forest) +
  ggplot2::annotate("text", x = 91, y = my + 1 * (91 - mx) + 1.5, label = "h² = 1", hjust = 1, vjust = 0,
                    family = fam, size = 5, colour = bb512$grey) +
  ggplot2::annotate("text", x = 91, y = my + 1.2, label = "h² = 0", hjust = 1, vjust = 0,
                    family = fam, size = 5, colour = bb512$grey) +
  ggplot2::annotate("text", x = 64, y = 86, label = "slope = h² = 0.83", hjust = 1,
                    family = fam, size = 6, colour = bb512$clay, fontface = "bold") +
  ggplot2::scale_x_continuous(limits = xr, breaks = seq(40, 90, 10)) +
  ggplot2::scale_y_continuous(limits = c(38, 95), breaks = seq(40, 90, 10)) +
  ggplot2::labs(x = "Mid-parent corolla length (mm)", y = "Mean offspring\ncorolla length (mm)") +
  theme_bb512()
save_bb512(p, "04_east_regression", layout = "takeaway")
