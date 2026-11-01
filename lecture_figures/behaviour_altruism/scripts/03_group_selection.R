# Naive group selection for an altruism allele: schematic in five steps (after the previous
# version of this lecture). Dots = individuals; circles = local groups (demes).
# Clay circles = altruist allele carriers; sage triangles = selfish (shape as well as colour, for colour-blind readers). Random dot positions, seed 17. Not data.
source("R/theme_bb512.R")
library(ggplot2)
fam <- "Avenir Next"
set.seed(17)

dots_in <- function(cx, cy, r, n, type, min_d = 0.11) {
  pts <- data.frame(x = numeric(0), y = numeric(0))
  tries <- 0
  while (nrow(pts) < n && tries < 5000) {
    tries <- tries + 1
    a <- runif(1, 0, 2 * pi); rr <- (r - 0.09) * sqrt(runif(1))
    x <- cx + rr * cos(a); y <- cy + rr * sin(a)
    if (nrow(pts) == 0 || min(sqrt((pts$x - x)^2 + (pts$y - y)^2)) > min_d) pts <- rbind(pts, data.frame(x, y))
  }
  pts$type <- rep(type, length.out = nrow(pts))
  pts
}
circ <- function(cx, cy, r, id) {
  t <- seq(0, 2 * pi, length.out = 100)
  data.frame(x = cx + r * cos(t), y = cy + r * sin(t), id = id)
}
cols <- c(alt = bb512$clay, self = bb512$sage)
shp <- c(alt = 16, self = 17)
labs_key <- c(alt = "Altruist", self = "Selfish")

panel <- function(groups, dots, extra = NULL, num, lab) {
  dots$type <- factor(dots$type, levels = c("alt", "self"))
  g <- ggplot() +
    geom_polygon(data = groups, aes(x, y, group = id), fill = bb512$pale, colour = bb512$grey, linewidth = 0.6) +
    geom_point(data = dots, aes(x, y, colour = type, shape = type), size = 2.6) +
    scale_colour_manual(values = cols, labels = labs_key, name = NULL, drop = FALSE) +
    scale_shape_manual(values = shp, labels = labs_key, name = NULL, drop = FALSE) +
    annotate("text", x = 0, y = 1.45, label = num, family = fam, fontface = "bold", size = 7,
             colour = bb512$gold) +
    annotate("text", x = 0, y = -1.42, label = lab, family = fam, size = 4.95, colour = bb512$ink,
             lineheight = 0.92, vjust = 1) +
    coord_equal(xlim = c(-1.15, 1.15), ylim = c(-2.25, 1.65), expand = FALSE) +
    theme_void() + theme(plot.background = element_rect(fill = bb512$bg, colour = NA))
  if (!is.null(extra)) g <- g + extra
  g
}

# 1 new mutation in a large group
d1 <- dots_in(0, 0, 1, 45, "self"); d1$type[1] <- "alt"
p1 <- panel(circ(0, 0, 1, 1), d1, num = "1", lab = "A new altruism\nmutation arises")
# 2 lost by within-group selection
d2 <- dots_in(0, 0, 1, 45, "self")
p2 <- panel(circ(0, 0, 1, 1), d2, num = "2", lab = "Selection within the\ngroup removes it")
# 3 drift fixes it in a tiny isolated group
g3 <- rbind(circ(-0.45, 0.35, 0.55, 1), circ(0.55, -0.45, 0.32, 2))
d3 <- rbind(dots_in(-0.45, 0.35, 0.55, 12, "self"), dots_in(0.55, -0.45, 0.32, 4, "alt"))
p3 <- panel(g3, d3, num = "3", lab = "...unless drift fixes\nit in a tiny group")
# 4 altruistic group grows and founds new groups
g4 <- rbind(circ(-0.25, 0.1, 0.8, 1), circ(0.78, 0.82, 0.25, 2), circ(0.82, -0.62, 0.25, 3))
d4 <- rbind(dots_in(-0.25, 0.1, 0.8, 30, "alt"), dots_in(0.78, 0.82, 0.25, 2, "alt"),
            dots_in(0.82, -0.62, 0.25, 2, "alt"))
ar4 <- list(annotate("segment", x = c(0.38, 0.4), y = c(0.45, -0.22), xend = c(0.56, 0.6),
                     yend = c(0.68, -0.45), colour = bb512$ink, linewidth = 0.6,
                     arrow = arrow(length = unit(0.08, "in"), type = "closed")))
p4 <- panel(g4, d4, ar4, num = "4", lab = "The altruistic group\ngrows and spreads")
# 5 selfish migrants invade and out-reproduce
d5 <- dots_in(0, 0, 1, 40, "alt"); d5$type[sample(nrow(d5), 12)] <- "self"
ar5 <- list(annotate("segment", x = -1.12, y = 1.1, xend = -0.72, yend = 0.72, colour = bb512$ink,
                     linewidth = 0.6, arrow = arrow(length = unit(0.08, "in"), type = "closed")),
            annotate("point", x = -1.05, y = 1.2, colour = bb512$sage, shape = 17, size = 2.6))
p5 <- panel(circ(0, 0, 1, 1), d5, ar5, num = "5", lab = "...but selfish migrants\ninvade and win")

p <- patchwork::wrap_plots(p1, p2, p3, p4, p5, nrow = 1, guides = "collect") &
  guides(colour = guide_legend(override.aes = list(size = 4.5))) &
  theme(plot.background = element_rect(fill = bb512$bg, colour = NA),
        legend.position = "bottom", legend.text = element_text(size = 15, family = fam, colour = bb512$ink),
        legend.margin = margin(0, 0, 0, 0))
save_bb512(p, "03_group_selection", layout = "full")
