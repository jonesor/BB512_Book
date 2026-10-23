# Slide "Three loci, seven colour classes": F2 of Nilsson-Ehle's (1909) wheat kernel-colour cross.
# Analytical (Neal 2004, Fig. 12.1). Model: 3 unlinked loci, 2 alleles each, purely additive effects,
# no dominance, no environmental effect. F1 (heterozygous at all loci) makes 2^3 = 8 gamete types,
# so F1 x F1 gives 8 x 8 = 64 equally likely combinations, 27 distinct genotypes and 7 phenotype
# classes (0 to 6 red alleles) in proportions choose(6, k) / 64 = 1:6:15:20:15:6:1.
# Each dot is one of the 64 equally likely combinations.
source("R/theme_bb512.R")
fam <- "Avenir Next"

n_loci <- 3
k <- 0:(2 * n_loci)
count <- choose(2 * n_loci, k)            # 1 6 15 20 15 6 1, sums to 64
ncol_dots <- 4                             # dots per row within a class
ramp <- grDevices::colorRampPalette(c(bb512$pale, "#D9B79B", bb512$clay, "#5E2A1F"))(length(k))

dots <- do.call(rbind, lapply(seq_along(k), function(i) {
  j <- seq_len(count[i]) - 1
  n_here <- pmin(ncol_dots, count[i] - (j %/% ncol_dots) * ncol_dots)  # dots in this row
  data.frame(k = k[i],
             x = k[i] + ((j %% ncol_dots) - (n_here - 1) / 2) * 0.2,
             y = j %/% ncol_dots + 0.5)
}))
dots$fill <- ramp[dots$k + 1]

labs_df <- data.frame(k = k, y = ceiling(count / ncol_dots) + 0.75,
                      lab = paste0(count, "/64"))

p <- ggplot2::ggplot() +
  ggplot2::geom_point(data = dots, ggplot2::aes(x, y, fill = I(fill)), shape = 21, size = 6.2,
                      colour = bb512$grey, stroke = 0.4) +
  ggplot2::geom_text(data = labs_df, ggplot2::aes(k, y, label = lab), family = fam, size = 5.6,
                     colour = bb512$ink, fontface = "bold", vjust = 0) +
  ggplot2::scale_x_continuous(breaks = k,
                              labels = c("0\nwhite", "1", "2", "3", "4", "5", "6\ndark red")) +
  ggplot2::scale_y_continuous(limits = c(0, 7.2), expand = c(0, 0)) +
  ggplot2::labs(x = "Number of red alleles (out of 6)", y = NULL) +
  theme_bb512() +
  ggplot2::theme(axis.text.y = ggplot2::element_blank(), axis.line.y = ggplot2::element_blank(),
                 panel.grid.major.y = ggplot2::element_blank(),
                 axis.text.x = ggplot2::element_text(size = 16, colour = bb512$ink, vjust = 1, lineheight = 0.9))
save_bb512(p, "01_wheat_f2", layout = "full")
