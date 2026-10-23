# Slide "More loci plus environment give a bell curve": F2 phenotype distributions.
# Analytical (extends Neal 2004's kernel colour figures). Model: n unlinked additive loci, 2 alleles each,
# F2 of a cross between homozygous lines, so the number of "+" alleles is Binomial(2n, 0.5).
# Phenotype is scaled to 0-1 (proportion of "+" alleles). Where environment is included it adds
# Normal(0, sd_e) noise on this 0-1 scale (sd_e chosen for illustration, not estimated).
source("R/theme_bb512.R")
fam <- "Avenir Next"

sd_e <- 0.06       # environmental SD on the 0-1 scale (illustrative)
panels <- c("1 locus", "3 loci", "3 loci\n+ environment", "20 loci\n+ environment")
grid_x <- seq(-0.15, 1.15, length.out = 801)

bars <- function(n, panel) {
  k <- 0:(2 * n)
  data.frame(panel = panel, x = k / (2 * n), p = dbinom(k, 2 * n, 0.5))
}
dens <- function(n, panel) {
  k <- 0:(2 * n); w <- dbinom(k, 2 * n, 0.5)
  d <- vapply(grid_x, function(x) sum(w * dnorm(x, k / (2 * n), sd_e)), numeric(1))
  data.frame(panel = panel, x = grid_x, d = d)
}
b <- rbind(bars(1, panels[1]), bars(3, panels[2]))
d <- rbind(dens(3, panels[3]), dens(20, panels[4]))
# Put bars and densities on a comparable height: scale each panel to a maximum of 1
b$h <- ave(b$p, b$panel, FUN = function(v) v / max(v))
d$h <- ave(d$d, d$panel, FUN = function(v) v / max(v))
b$panel <- factor(b$panel, panels); d$panel <- factor(d$panel, panels)

p <- ggplot2::ggplot() +
  ggplot2::geom_col(data = b, ggplot2::aes(x, h), width = 0.07, fill = bb512$forest) +
  ggplot2::geom_area(data = d, ggplot2::aes(x, h), fill = bb512$sage, colour = bb512$forest,
                     linewidth = 1.2, alpha = 0.6) +
  ggplot2::facet_wrap(~panel, nrow = 1) +
  ggplot2::scale_x_continuous(breaks = c(0, 0.5, 1), labels = c("White", "", "Dark red"),
                              limits = c(-0.15, 1.15)) +
  ggplot2::scale_y_continuous(limits = c(0, 1.05), expand = c(0, 0)) +
  ggplot2::labs(x = "Kernel colour", y = "Relative frequency") +
  theme_bb512() +
  ggplot2::theme(axis.text.y = ggplot2::element_blank(), strip.text = ggplot2::element_text(lineheight = 0.9, vjust = 0), panel.spacing = grid::unit(0.35, "in"))
save_bb512(p, "02_more_loci", layout = "full")
