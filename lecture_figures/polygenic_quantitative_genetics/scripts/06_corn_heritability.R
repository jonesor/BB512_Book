# Slide "Selection uses up additive variance": the Illinois long-term selection experiment on maize
# (Zea mays) oil content, started 1896. Two stacked panels sharing the generation axis:
#   top:    mean oil content (%) of the high-oil and low-oil lines, generations 0-76
#   bottom: heritability of oil content (h²) in blocks of generations
# Top panel, empirical: means DIGITISED from Neal (2004) Fig. 12.6 (after Dudley 1977) by pixel analysis
#   of the page image at 300 dpi, read every 2 generations; values are approximate (about +/- 0.2 %).
#   Generation 0 set to 4.7 %, the common starting value shown in the figure.
#   The two reverse-selection lines started at generation 46 are omitted.
#   Low line at generation 74 touches the x axis in the figure; set to 0.2 %.
# Bottom panel, empirical: Dudley (1977), as tabulated in Neal (2004) Table 12.3. Each value applies to a
#   block of generations and is plotted at the block mid-point.
source("R/theme_bb512.R")
fam <- "Avenir Next"

gen  <- seq(0, 76, 2)
high <- c(4.70, 5.11, 6.03, 6.23, 6.94, 7.33, 7.19, 7.48, 7.65, 8.27, 8.53, 9.12, 9.15, 9.75, 9.86,
          10.17, 10.88, 11.79, 11.91, 11.96, 12.34, 13.58, 12.52, 13.29, 13.84, 15.30, 13.32, 13.19,
          12.84, 14.20, 14.91, 14.64, 14.99, 15.79, 15.54, 17.22, 15.81, 16.70, 18.24)
low  <- c(4.70, 3.92, 3.54, 3.05, 2.92, 2.64, 2.36, 2.21, 2.13, 1.93, 2.08, 1.89, 1.78, 1.67, 1.52,
          1.43, 1.23, 1.26, 1.17, 1.07, 1.28, 1.74, 1.30, 1.40, 0.87, 1.11, 0.86, 0.70, 0.63, 1.03,
          0.77, 0.54, 0.58, 0.71, 0.68, 0.37, 0.50, 0.20, 0.36)
stopifnot(length(high) == length(gen), length(low) == length(gen))
cols <- c("High-oil line" = bb512$forest, "Low-oil line" = bb512$clay)

m <- data.frame(gen = rep(gen, 2), oil = c(high, low), line = rep(names(cols), each = length(gen)))
mlab <- data.frame(gen = c(60, 60), oil = c(18.3, 2.9), line = names(cols),
                   lab = c("High-oil line keeps rising", "Low-oil line nears zero"))

top <- ggplot2::ggplot(m, ggplot2::aes(gen, oil, colour = line)) +
  ggplot2::geom_hline(yintercept = 4.7, colour = bb512$grey, linetype = "dashed", linewidth = 0.5) +
  ggplot2::annotate("text", x = 30, y = 6.1, label = "starting mean: 4.7 %", family = fam, size = 4.3,
                    colour = bb512$grey, hjust = 0) +
  ggplot2::geom_line(linewidth = 1.1) +
  ggplot2::geom_text(data = mlab, ggplot2::aes(label = lab), family = fam, size = 4.6, hjust = 1) +
  ggplot2::scale_colour_manual(values = cols, guide = "none") +
  ggplot2::scale_x_continuous(limits = c(0, 77), breaks = seq(0, 70, 10)) +
  ggplot2::scale_y_continuous(limits = c(0, 19.5), breaks = seq(0, 15, 5)) +
  ggplot2::labs(x = NULL, y = "Oil content (%)") +
  theme_bb512() +
  ggplot2::theme(axis.text.x = ggplot2::element_blank())

h <- data.frame(line = rep(names(cols), each = 4),
                from = rep(c(1, 10, 26, 53), 2), to = rep(c(9, 25, 52, 76), 2),
                h2 = c(0.32, 0.34, 0.11, 0.12, 0.50, 0.23, 0.10, 0.15))
h$mid <- (h$from + h$to) / 2   # plotted at block mid-points (5, 17.5, 39, 64.5)
bot <- ggplot2::ggplot(h, ggplot2::aes(mid, h2, colour = line)) +
  ggplot2::geom_line(linewidth = 1.1) +
  ggplot2::geom_point(size = 2.8) +
  ggplot2::scale_colour_manual(values = cols, guide = "none") +
  ggplot2::scale_x_continuous(limits = c(0, 77), breaks = seq(0, 70, 10)) +
  ggplot2::scale_y_continuous(limits = c(0, 0.55), breaks = c(0, 0.25, 0.5)) +
  ggplot2::labs(x = "Generations of selection", y = expression(h^2)) +
  theme_bb512()

p <- patchwork::wrap_plots(top, bot, ncol = 1, heights = c(2.3, 1))
dir.create("figures", showWarnings = FALSE)
dims <- .bb512_dimensions[["takeaway"]]
ggplot2::ggsave("figures/06_corn_heritability.png", p, device = ragg::agg_png, width = dims[1],
                height = dims[2], units = "in", dpi = 300, bg = bb512$bg)
