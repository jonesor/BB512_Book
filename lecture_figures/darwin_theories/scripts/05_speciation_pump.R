# Slide "One species becomes two: allopatric speciation" (layout "full").
# Schematic, redrawn from the previous version's "allopatric species pump" lake diagram.
# A falling water level splits one lake into two; populations diverge in isolation (selection and drift);
# when the lake refills they meet again as two species that no longer interbreed. Positions are illustrative.
source("R/theme_bb512.R")
fam <- Sys.getenv("BB512_FONT", "Avenir Next")
set.seed(512)

panels <- c("1  One lake,\none species", "2  Water falls:\ntwo isolated lakes",
            "3  Populations diverge\nin isolation", "4  Water rises: two\nspecies, one lake")
level  <- c(4.2, 2.3, 2.3, 4.2)
x  <- seq(0, 10, length.out = 401)
gx <- 0.6 + 2.6 * exp(-((x - 5) / 0.9)^2) + 0.35 * ((x - 5) / 5)^4 * 12   # basin with a central ridge
ground <- do.call(rbind, lapply(seq_along(panels), function(i)
  data.frame(panel = panels[i], x = x, g = gx, w = pmax(level[i], gx))))
ground$panel <- factor(ground$panel, panels)

g_at <- function(x) 0.6 + 2.6 * exp(-((x - 5) / 0.9)^2) + 0.35 * ((x - 5) / 5)^4 * 12
# Place points in water only: rejection sampling, with a maximum number of tries
fish <- function(panel, n, xr, yr, sp, tries = 1000) {
  out <- data.frame(); k <- 0
  while (nrow(out) < n && k < tries) {
    k <- k + 1; x <- runif(1, xr[1], xr[2]); y <- runif(1, yr[1], yr[2])
    if (y > g_at(x) + 0.3 && (nrow(out) == 0 || min((out$x - x)^2 + (out$y - y)^2) > 0.5)) out <- rbind(out, data.frame(x = x, y = y))
  }
  data.frame(panel = panel, x = out$x, y = out$y, sp = sp)
}
pts <- rbind(
  fish(panels[1], 9, c(1.2, 8.8), c(1.3, 3.9), "A"),
  fish(panels[2], 4, c(1.3, 3.6), c(0.9, 2.05), "A"), fish(panels[2], 4, c(6.4, 8.7), c(0.9, 2.05), "A"),
  fish(panels[3], 4, c(1.3, 3.6), c(0.9, 2.05), "A"), fish(panels[3], 4, c(6.4, 8.7), c(0.9, 2.05), "B"),
  fish(panels[4], 5, c(1.2, 8.8), c(1.3, 3.8), "A"), fish(panels[4], 5, c(1.2, 8.8), c(1.3, 3.8), "B"))
pts$panel <- factor(pts$panel, panels)

p <- ggplot2::ggplot(ground) +
  ggplot2::geom_ribbon(ggplot2::aes(x, ymin = g, ymax = w), fill = "#BFD3D6") +
  ggplot2::geom_ribbon(ggplot2::aes(x, ymin = 0, ymax = g), fill = bb512$sage) +
  ggplot2::geom_point(data = pts, ggplot2::aes(x, y, shape = sp, colour = sp), size = 4, stroke = 1.2) +
  ggplot2::scale_shape_manual(values = c(A = 16, B = 17), guide = "none") +
  ggplot2::scale_colour_manual(values = c(A = bb512$forest, B = bb512$clay), guide = "none") +
  ggplot2::facet_wrap(~panel, nrow = 1) +
  ggplot2::coord_cartesian(xlim = c(0, 10), ylim = c(0, 5), expand = FALSE) +
  theme_bb512(base_family = fam) +
  ggplot2::theme(axis.text = ggplot2::element_blank(), axis.title = ggplot2::element_blank(),
                 axis.line = ggplot2::element_blank(), panel.grid.major.y = ggplot2::element_blank(),
                 panel.spacing = grid::unit(0.3, "in"),
                 strip.text = ggplot2::element_text(hjust = 0, lineheight = 0.9, size = 16))
save_bb512(p, "05_speciation_pump", layout = "full")
