# Slide: "Founder effects and bottlenecks" (Title & Photo, "full")
# Conceptual schematic (no data). Colours = four alleles at one locus. A founder group
# or bottleneck survivors are a small random sample, so alleles are lost and
# frequencies shift by chance.
source("R/theme_bb512.R"); source("R/drift_helpers.R"); library(ggplot2)
set.seed(4)
acol <- c(A1 = bb512$forest, A2 = bb512$clay, A3 = bb512$blue, A4 = bb512$gold)

blob <- function(cx, cy, r, n, alleles, prob = NULL, mind = 0.33) {
  pts <- data.frame(x = numeric(0), y = numeric(0)); tries <- 0
  while (nrow(pts) < n && tries < 20000) {
    tries <- tries + 1
    a <- runif(1, 0, 2 * pi); rr <- r * sqrt(runif(1))
    cand <- c(cx + rr * cos(a), cy + rr * sin(a))
    if (nrow(pts) == 0 || min(sqrt((pts$x - cand[1])^2 + (pts$y - cand[2])^2)) > mind)
      pts <- rbind(pts, data.frame(x = cand[1], y = cand[2]))
  }
  pts$allele <- sample(alleles, nrow(pts), replace = TRUE, prob = prob)
  pts
}
circ <- function(cx, cy, r, id) {
  a <- seq(0, 2 * pi, length.out = 120)
  data.frame(x = cx + r * cos(a), y = cy + r * sin(a), id = id)
}
four <- names(acol); even <- rep(0.25, 4)
# Founder effect (left)
src  <- blob(1.6, 0, 1.45, 34, four, even)
fnd  <- data.frame(x = 4.7 + c(-0.2, 0.2, 0, -0.2, 0.2), y = c(0.25, 0.25, 0, -0.25, -0.25),
                   allele = c("A1", "A1", "A2", "A1", "A2"))
# Bottleneck (right): before, survivors, recovered
bef  <- blob(7.6, 0, 1.15, 24, four, even)
sur  <- data.frame(x = 9.55 + c(-0.17, 0.17, 0), y = c(0.15, 0.15, -0.17), allele = c("A3", "A3", "A4"))
aft  <- blob(11.5, 0, 1.15, 24, c("A3", "A4"), c(0.7, 0.3))
pts  <- rbind(src, fnd, bef, sur, aft)
rings <- rbind(circ(1.6, 0, 1.65, "a"), circ(4.7, 0, 0.62, "b"), circ(7.6, 0, 1.35, "c"),
               circ(9.55, 0, 0.45, "d"), circ(11.5, 0, 1.35, "e"))

fig <- ggplot() +
  geom_polygon(data = rings, aes(x, y, group = id), fill = bb512$pale, colour = bb512$sage, linewidth = 0.8) +
  geom_point(data = pts, aes(x, y, colour = allele), size = 4.2) +
  annotate("segment", x = 3.35, xend = 3.95, y = 0, yend = 0, colour = bb512$grey, linewidth = 1,
           arrow = arrow(length = unit(0.15, "in"), type = "closed")) +
  annotate("segment", x = c(9.0, 10.05), xend = c(9.05, 10.1), y = 0, yend = 0, colour = bb512$grey,
           linewidth = 1, arrow = arrow(length = unit(0.15, "in"), type = "closed")) +
  annotate("segment", x = 6.2, xend = 13, y = -2.05, yend = -2.05, colour = bb512$grey, linewidth = 0.8,
           arrow = arrow(length = unit(0.12, "in"), type = "closed")) +
  bb_text(x = 12.6, y = -2.35, label = "time", colour = bb512$grey, size = 5) +
  annotate("segment", x = 6.05, xend = 6.05, y = -2.3, yend = 2.4, colour = bb512$grid, linewidth = 0.8) +
  bb_text(x = 3.1, y = 2.25, label = "Founder effect", size = 6.5, fontface = "bold", colour = bb512$forest) +
  bb_text(x = 9.55, y = 2.25, label = "Bottleneck", size = 6.5, fontface = "bold", colour = bb512$forest) +
  bb_text(x = c(1.6, 4.7), y = c(-2.0, -1.0), label = c("source population", "founders"),
          size = 5, colour = bb512$ink) +
  bb_text(x = c(7.6, 9.55, 11.5), y = c(-1.65, -0.85, -1.65), label = c("before", "survivors", "recovered"),
          size = 5, colour = bb512$ink) +
  scale_colour_manual(values = acol, guide = "none") +
  coord_fixed(xlim = c(-0.2, 13.2), ylim = c(-2.6, 2.6), expand = FALSE) +
  theme_void() + theme(plot.background = element_rect(fill = bb512$bg, colour = NA))
save_bb512(fig, "08_founder_bottleneck", layout = "full")
