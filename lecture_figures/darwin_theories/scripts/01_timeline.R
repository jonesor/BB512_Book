# Slide "Darwin's life and ideas: a timeline" (layout "full").
# Historical dates, not data. Sources: Neal (2004) chapters 1-2; Darwin Correspondence Project.
# 1838 Malthus: Darwin read the 6th edition (1826) of Malthus's Essay on 28 Sept 1838 (Notebook D).
source("R/theme_bb512.R")
fam <- Sys.getenv("BB512_FONT", "Avenir Next")

ev <- data.frame(
  year  = c(1809, 1831, 1837, 1838, 1844, 1858, 1859, 1866, 1882, 1900),
  label = c("Born", "Beagle sails\n(to 1836)", "Gould: new species;\ntransmutation notebooks",
            "Reads\nMalthus", "Unpublished essay;\nVestiges (anon.)", "Wallace's\nletter",
            "On the Origin\nof Species", "Mendel\npublishes", "Darwin\ndies", "Mendel\nrediscovered"),
  y     = c(0.42, -0.42, 0.98, -0.98, 0.42, -0.42, 0.98, -0.98, 0.42, -0.42),
  key   = c(FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE)
)
ev$col <- ifelse(ev$key, bb512$clay, bb512$ink)
ev$lx <- ev$year; ev$lx[ev$year == 1844] <- 1847.5  # shift label clear of the 1837 line

p <- ggplot2::ggplot() +
  # Beagle voyage (blue) and the 20-year delay (gold) as bands on the axis
  ggplot2::annotate("rect", xmin = 1831.9, xmax = 1836.75, ymin = -0.08, ymax = 0.08, fill = bb512$blue) +
  ggplot2::annotate("rect", xmin = 1838.75, xmax = 1858.5, ymin = -0.045, ymax = 0.045, fill = bb512$gold) +
  ggplot2::annotate("text", x = 1848.6, y = -0.2, label = "20-year delay", colour = bb512$gold,
                    family = fam, size = 5.2, fontface = "bold") +
  ggplot2::annotate("segment", x = 1805, xend = 1904, y = 0, yend = 0, colour = bb512$grey, linewidth = 0.6) +
  ggplot2::geom_segment(data = ev, ggplot2::aes(x = year, xend = year, y = 0, yend = y * 0.92),
                        colour = bb512$grey, linewidth = 0.5) +
  ggplot2::geom_point(data = ev, ggplot2::aes(year, 0), colour = ev$col, size = 3.2) +
  ggplot2::geom_text(data = ev, ggplot2::aes(lx, y, label = paste0(year, "\n", label)),
                     colour = ev$col, family = fam, size = 4.9, lineheight = 0.85,
                     vjust = ifelse(ev$y > 0, 0, 1)) +
  ggplot2::scale_x_continuous(limits = c(1801, 1908), expand = c(0, 0)) +
  ggplot2::scale_y_continuous(limits = c(-1.62, 1.62), expand = c(0, 0)) +
  theme_bb512(base_family = fam) +
  ggplot2::theme(axis.text = ggplot2::element_blank(), axis.title = ggplot2::element_blank(),
                 axis.line = ggplot2::element_blank(), panel.grid.major.y = ggplot2::element_blank(),
                 plot.margin = ggplot2::margin(4, 4, 4, 4))
save_bb512(p, "01_timeline", layout = "full")
