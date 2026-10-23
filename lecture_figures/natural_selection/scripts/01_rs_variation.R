# Slide "Condition 2: reproductive success varies": two study systems.
# EMPIRICAL, but DIGITISED: bar heights were read from the histograms on the previous version
# of this slide (images/source/tit_clutch_size.png, soay_lrs.png), so counts may be off by one.
# Replace with the raw data if available.
# Left: clutch size of great tits (Parus major) in SDU nest boxes. The original was drawn with
# R's hist() default (right-closed bins), so the first bar (36 nests) combines clutches of
# 0 and 1 egg; most are presumably 0 (box used but no eggs laid).
# Right: lifetime number of offspring produced by Soay sheep (Ovis aries), St Kilda.
source("R/theme_bb512.R")
fam <- "Avenir Next"
tit <- data.frame(x = c("0–1", as.character(2:13)),
                  n = c(36, 2, 1, 6, 2, 9, 10, 12, 8, 9, 6, 2, 1),
                  panel = "Great tits: eggs per clutch")
soay <- data.frame(x = as.character(0:19),
                   n = c(420, 150, 80, 40, 20, 10, 8, 9, 2, 0, 3, 0, 0, 2, 4, 0, 1, 3, 2, 1),
                   panel = "Soay sheep: offspring in a lifetime")
mk <- function(d, col, xlab, ylab, breaks) {
  d$x <- factor(d$x, levels = d$x)
  ggplot2::ggplot(d, ggplot2::aes(x, n)) +
    ggplot2::geom_col(fill = col, width = 0.85) +
    ggplot2::scale_x_discrete(breaks = breaks) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.05))) +
    ggplot2::facet_wrap(~panel) +
    ggplot2::labs(x = xlab, y = ylab) +
    theme_bb512()
}
p1 <- mk(tit, bb512$forest, "Clutch size (eggs)", "Nests", c("0–1", "3", "5", "7", "9", "11", "13"))
p2 <- mk(soay, bb512$clay, "Offspring produced", "Sheep", as.character(seq(0, 18, 3)))
p <- patchwork::wrap_plots(p1, p2, nrow = 1) +
  patchwork::plot_annotation(theme = ggplot2::theme(plot.background = ggplot2::element_rect(fill = bb512$bg, colour = NA)))
save_bb512(p, "01_rs_variation", layout = "full")
