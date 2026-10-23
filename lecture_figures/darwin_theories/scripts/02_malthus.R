# Slide "Malthus: populations outrun their food" (layout "takeaway").
# Analytical illustration using Malthus's own example (Essay on the Principle of Population, ch. 1):
# population doubles every 25 years (1, 2, 4, 8, ...) while food increases by a fixed amount (1, 2, 3, 4, ...).
source("R/theme_bb512.R")
fam <- Sys.getenv("BB512_FONT", "Avenir Next")

t <- 0:8                       # 25-year periods
d <- rbind(data.frame(years = 25 * t, value = 2^t,   what = "Population"),
           data.frame(years = 25 * t, value = t + 1, what = "Food supply"))
lab <- data.frame(years = c(200, 200), value = c(256, -17), what = c("Population", "Food supply"),
                  txt = c("Population\n(doubles every 25 years)", "Food supply (fixed increase)"))

p <- ggplot2::ggplot(d, ggplot2::aes(years, value, colour = what)) +
  ggplot2::geom_ribbon(data = data.frame(years = 25 * t, lo = t + 1, hi = 2^t),
                       ggplot2::aes(years, ymin = lo, ymax = hi), inherit.aes = FALSE,
                       fill = bb512$sage, alpha = 0.35) +
  ggplot2::geom_line(linewidth = 1.4) +
  ggplot2::geom_point(size = 2.6) +
  ggplot2::geom_text(data = lab, ggplot2::aes(label = txt), hjust = 1, nudge_x = -6,
                     vjust = c(0.4, 0.5), family = fam, size = 5, lineheight = 0.9) +
  ggplot2::annotate("text", x = 176, y = 52, label = "Shortfall:\nthe struggle\nfor existence",
                    colour = bb512$ink, family = fam, size = 5, lineheight = 0.9, hjust = 0.5) +
  ggplot2::scale_colour_manual(values = c(Population = bb512$clay, "Food supply" = bb512$forest), guide = "none") +
  ggplot2::scale_x_continuous(breaks = seq(0, 200, 50)) +
  ggplot2::scale_y_continuous(breaks = seq(0, 250, 50), limits = c(-30, 265)) +
  ggplot2::labs(x = "Years", y = "Relative amount") +
  theme_bb512(base_family = fam)
save_bb512(p, "02_malthus", layout = "takeaway")
