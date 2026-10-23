# Slide "Gene flow can swamp local adaptation": two habitats (desert, grassland), each
# with individuals of a pale (desert-matching) or green (grass-matching) form.
# SCHEMATIC, redrawn from the previous version of the lecture. Left: no movement between
# habitats, so each habitat comes to be dominated by the locally favoured form (here 90%).
# Right: frequent migration mixes the forms, so neither habitat is well adapted (here 50%).
# The outcome in reality depends on the migration rate relative to the strength of selection
# (migration-selection balance; see the lecture on migration and gene flow). Seed 512.
source("R/theme_bb512.R")
fam <- "Avenir Next"
set.seed(512)
n <- 22
make <- function(scenario, p_local) {
  do.call(rbind, lapply(c("Desert", "Grassland"), function(h) {
    x0 <- if (h == "Desert") 0 else 1
    local <- if (h == "Desert") "pale" else "green"
    other <- setdiff(c("pale", "green"), local)
    k <- round(n * p_local)
    data.frame(scenario = scenario, habitat = h,
               x = x0 + runif(n, 0.08, 0.92), y = runif(n, 0.06, 0.72),
               form = sample(c(rep(local, k), rep(other, n - k))))
  }))
}
sc <- c("No gene flow: local adaptation", "Frequent gene flow: no local adaptation")
pts <- rbind(make(sc[1], 0.9), make(sc[2], 0.5))
pts$scenario <- factor(pts$scenario, levels = sc)
hab <- data.frame(scenario = factor(rep(sc, each = 2), levels = sc), habitat = rep(c("Desert", "Grassland"), 2),
                  xmin = rep(c(0, 1), 2), xmax = rep(c(1, 2), 2))
lab <- transform(hab, x = (xmin + xmax) / 2, y = 0.93)
arrows <- data.frame(scenario = factor(sc[2], levels = sc), x = c(0.82, 1.18), xend = c(1.18, 0.82),
                     y = c(0.85, 0.78))
p <- ggplot2::ggplot() +
  ggplot2::geom_rect(data = hab, ggplot2::aes(xmin = xmin, xmax = xmax, ymin = 0, ymax = 1.05, fill = habitat),
                     colour = bb512$bg, linewidth = 1.5) +
  ggplot2::geom_text(data = lab, ggplot2::aes(x, y, label = habitat), family = fam, size = 5.5,
                     fontface = "bold", colour = bb512$ink) +
  ggplot2::geom_point(data = pts, ggplot2::aes(x, y, colour = form), size = 4.2) +
  ggplot2::geom_segment(data = arrows, ggplot2::aes(x = x, xend = xend, y = y, yend = y),
                        colour = bb512$ink, linewidth = 1,
                        arrow = ggplot2::arrow(length = ggplot2::unit(0.1, "in"), type = "closed")) +
  ggplot2::facet_wrap(~scenario, nrow = 1) +
  ggplot2::scale_fill_manual(values = c(Desert = "#E8D9B4", Grassland = "#C9D6C8"), guide = "none") +
  ggplot2::scale_colour_manual(values = c(pale = bb512$gold, green = bb512$forest), guide = "none") +
  ggplot2::coord_cartesian(xlim = c(0, 2), ylim = c(0, 1.05), expand = FALSE) +
  ggplot2::theme_void(base_family = fam) +
  ggplot2::theme(plot.background = ggplot2::element_rect(fill = bb512$bg, colour = NA),
                 strip.text = ggplot2::element_text(size = 17, face = "bold", colour = bb512$forest,
                                                    margin = ggplot2::margin(0, 0, 8, 0)),
                 panel.spacing = ggplot2::unit(2.2, "lines"),
                 plot.margin = ggplot2::margin(10, 16, 10, 16))
save_bb512(p, "06_gene_flow", layout = "full")
