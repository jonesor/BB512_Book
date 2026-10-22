# The gene pool as a leaky tub: mutation pours alleles in; drift and
# selection drain them out. Redrawn after Owen Jones' original lecture diagram.
source("R/theme_bb512.R")
set.seed(512)
pal <- c(bb512$forest, bb512$clay, bb512$blue, bb512$gold, bb512$sage, "#7A5C8E", "#D98F5C")
# tub: trapezoid from x 3..7 at top (y=5) to 3.6..6.4 at bottom (y=0.6)
tub <- data.frame(x = c(3, 3.6, 4.85, NA, 5.15, 6.4, 7), y = c(5, 0.6, 0.6, NA, 0.6, 0.6, 5))
n <- 110; balls <- data.frame(); tries <- 0
while (nrow(balls) < n && tries < 20000) {
  tries <- tries + 1
  y <- runif(1, 0.85, 3.6); half <- 1.4 + (y - 0.6) / 4.4 * 0.6 - 0.22
  x <- runif(1, 5 - half, 5 + half)
  if (nrow(balls) == 0 || min((balls$x - x)^2 + ((balls$y - y) * 1)^2) > 0.055)
    balls <- rbind(balls, data.frame(x = x, y = y, c = sample(pal, 1)))
}
inflow  <- data.frame(x = c(4.65, 4.8, 4.95), y = c(5.55, 5.0, 4.45), c = pal[c(2, 6, 4)])
outflow <- data.frame(x = c(5.0, 5.0, 5.0), y = c(0.25, -0.15, -0.55), c = pal[c(3, 7, 1)])
# Erlenmeyer flask drawn upright (mouth up), then rotated so the mouth tips
# towards the tub.
up <- data.frame(x = c(-0.95, 0.95, 0.24, 0.24, -0.24, -0.24, -0.95),
                 y = c(0, 0, 1.25, 1.85, 1.85, 1.25, 0))
th <- -125 * pi / 180
fl <- data.frame(x = up$x * cos(th) - up$y * sin(th),
                 y = up$x * sin(th) + up$y * cos(th))
mouth <- c(0, 1.85); mrot <- c(mouth[1] * cos(th) - mouth[2] * sin(th),
                               mouth[1] * sin(th) + mouth[2] * cos(th))
fl$x <- fl$x + 4.45 - mrot[1]; fl$y <- fl$y + 6.0 - mrot[2]
p <- ggplot2::ggplot() +
  ggplot2::geom_polygon(data = fl, ggplot2::aes(x, y), fill = "#E8ECE6", colour = bb512$grey, linewidth = 1.1) +
  ggplot2::geom_path(data = tub, ggplot2::aes(x, y), colour = bb512$grey, linewidth = 1.6, na.rm = TRUE) +
  ggplot2::geom_point(data = balls, ggplot2::aes(x, y), colour = balls$c, size = 4.8) +
  ggplot2::geom_point(data = inflow, ggplot2::aes(x, y), colour = inflow$c, size = 4.8) +
  ggplot2::geom_point(data = outflow, ggplot2::aes(x, y), colour = outflow$c, size = 4.8, alpha = c(0.9, 0.6, 0.35)) +
  ggplot2::annotate("text", x = 5.9, y = 7.2, label = "New alleles\nfrom mutation", hjust = 0, vjust = 0.5,
                    size = 5.8, fontface = "bold", colour = bb512$clay, lineheight = 0.9) +
  ggplot2::annotate("text", x = 7.2, y = 2.4, label = "Gene pool\n(standing\nvariation)", hjust = 0,
                    size = 6.6, fontface = "bold", colour = bb512$forest, lineheight = 0.9) +
  ggplot2::annotate("text", x = 5.45, y = -0.15, label = "Alleles lost by\ndrift or selection", hjust = 0,
                    size = 6.6, fontface = "bold", colour = bb512$blue, lineheight = 0.9) +
  ggplot2::coord_fixed(xlim = c(-0.5, 10.6), ylim = c(-0.9, 8.3), expand = FALSE, clip = "off") +
  ggplot2::theme_void() +
  ggplot2::theme(plot.background = ggplot2::element_rect(fill = bb512$bg, colour = NA))
save_bb512(p, "12_gene_pool_tub", layout = "takeaway")
