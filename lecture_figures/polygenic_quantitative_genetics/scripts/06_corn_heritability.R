# Slide "Selection uses up additive variance": heritability of oil content during the Illinois
# long-term selection experiment on maize (Zea mays), started 1896.
# Empirical: Dudley (1977), as tabulated in Neal (2004) Table 12.3. Values are for blocks of generations;
# plotted at the block mid-points.
source("R/theme_bb512.R")
fam <- "Avenir Next"

blocks <- c("1–9", "10–25", "26–52", "53–76")
mid <- c(5, 17.5, 39, 64.5)
d <- data.frame(line = rep(c("High-oil line", "Low-oil line"), each = 4), gen = rep(mid, 2),
                block = rep(blocks, 2), h2 = c(0.32, 0.34, 0.11, 0.12, 0.50, 0.23, 0.10, 0.15))
lab <- data.frame(line = c("High-oil line", "Low-oil line"), gen = c(66, 66), h2 = c(0.12, 0.15) + c(-0.045, 0.045))

p <- ggplot2::ggplot(d, ggplot2::aes(gen, h2, colour = line)) +
  ggplot2::geom_line(linewidth = 1.3) +
  ggplot2::geom_point(size = 3.6) +
  ggplot2::geom_text(data = lab, ggplot2::aes(label = line), family = fam, size = 5.2, hjust = 0.5) +
  ggplot2::scale_colour_manual(values = c("High-oil line" = bb512$forest, "Low-oil line" = bb512$clay), guide = "none") +
  ggplot2::scale_x_continuous(breaks = mid, labels = blocks, limits = c(0, 76)) +
  ggplot2::scale_y_continuous(limits = c(0, 0.55), breaks = seq(0, 0.5, 0.1)) +
  ggplot2::labs(x = "Generations of selection", y = "Heritability of oil content (h²)") +
  theme_bb512()
save_bb512(p, "06_corn_heritability", layout = "takeaway")
