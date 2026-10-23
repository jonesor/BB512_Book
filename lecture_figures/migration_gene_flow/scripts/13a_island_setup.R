# Model 2 set-up: four equal-sized islands, each exchanging migrants with all the
# others (Neal Section 9.1, Example 9.3, Appendix 9.1). Schematic, not data.
# Island colour shows its starting allele frequency (q = 0.2, 0.4, 0.6, 0.8).
source("R/theme_bb512.R")
library(ggplot2)
fam <- bb512_font()
circle <- function(x0, y0, r, n = 80) {
  a <- seq(0, 2 * pi, length.out = n); data.frame(x = x0 + r * cos(a), y = y0 + r * sin(a))
}
isl <- data.frame(x = c(1.2, 4.8, 1.2, 4.8), y = c(4.2, 4.2, 1.2, 1.2), q = c(0.8, 0.6, 0.4, 0.2))
r <- 0.62
polys <- do.call(rbind, lapply(1:4, function(i) cbind(circle(isl$x[i], isl$y[i], r), id = i, q = isl$q[i])))
pairs <- t(combn(4, 2))
links <- do.call(rbind, lapply(seq_len(nrow(pairs)), function(k) {
  a <- isl[pairs[k, 1], ]; b <- isl[pairs[k, 2], ]
  d <- sqrt((b$x - a$x)^2 + (b$y - a$y)^2); ux <- (b$x - a$x) / d; uy <- (b$y - a$y) / d
  g <- r + 0.15
  data.frame(x = a$x + ux * g, y = a$y + uy * g, xend = b$x - ux * g, yend = b$y - uy * g)
}))
p <- ggplot() +
  geom_segment(data = links, aes(x, y, xend = xend, yend = yend), colour = bb512$grey,
               linewidth = 0.8, arrow = arrow(length = unit(0.1, "in"), type = "closed", ends = "both")) +
  geom_polygon(data = polys, aes(x, y, group = id, fill = q), colour = NA) +
  geom_text(data = isl, aes(x, y, label = paste0("q = ", q)), colour = c(bb512$bg, bb512$bg, bb512$ink, bb512$ink),
            size = 5.4, family = fam, fontface = "bold") +
  scale_fill_gradient(low = bb512$pale, high = bb512$forest, limits = c(0, 1), guide = "none") +
  annotate("text", x = 3, y = -0.2, label = "Each island exchanges migrants\nwith every other island", lineheight = 0.9,
           colour = bb512$grey, size = 5, family = fam) +
  coord_fixed(xlim = c(0.3, 5.7), ylim = c(-0.75, 5.0), expand = FALSE) +
  theme_void() + theme(plot.background = element_rect(fill = bb512$bg, colour = NA))
save_bb512(p, "13a_island_setup", layout = "half")
