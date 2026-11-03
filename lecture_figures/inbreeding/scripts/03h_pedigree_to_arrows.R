# The same first-cousin mating drawn two ways. Left: the family-tree convention from
# human genetics (Bennett et al. 2008): square male, circle female, a horizontal line
# joining mates, a double line for mates who are related. Right: the arrow diagram used
# for path counting, in which each individual appears once. Sexes are arbitrary, and
# sex does not affect F at an autosomal locus. Schematic, not data.
source("R/theme_bb512.R")
source("R/path_counting.R")

rel <- relationships$first

# Family-tree layout, in inches
tree <- data.frame(
  id    = c("A", "B", "m1", "E", "F", "m2", "C", "D", "X"),
  x     = c(2.15, 3.25, 0.85, 1.85, 3.55, 4.55, 1.35, 4.05, 2.70),
  y     = c(3.75, 3.75, 2.75, 2.75, 2.75, 2.75, 1.75, 1.75, 0.75),
  shape = c("s", "c", "c", "s", "c", "s", "s", "c", "s")
)
r <- 0.2
th <- seq(0, 2 * pi, length.out = 72)
outline <- do.call(rbind, lapply(seq_len(nrow(tree)), function(i) {
  t <- tree[i, ]
  if (t$shape == "c") {
    data.frame(id = t$id, x = t$x + r * cos(th), y = t$y + r * sin(th))
  } else {
    s <- r * 0.92
    data.frame(id = t$id, x = t$x + s * c(-1, 1, 1, -1), y = t$y + s * c(-1, -1, 1, 1))
  }
}))
outline$fill <- ifelse(outline$id == "X", bb512$sage,
                       ifelse(outline$id %in% c("m1", "m2"), bb512$sage, bb512$forest))
at <- function(id) tree[match(id, tree$id), ]
line <- function(x, y, xend, yend) data.frame(x = x, y = y, xend = xend, yend = yend)

lines <- rbind(
  line(at("A")$x + r, 3.75, at("B")$x - r, 3.75),          # A = B mating
  line(2.70, 3.75, 2.70, 3.25),                            # descent
  line(1.85, 3.25, 3.55, 3.25),                            # sibship
  line(1.85, 3.25, 1.85, 2.75 + r), line(3.55, 3.25, 3.55, 2.75 + r),
  line(at("m1")$x + r, 2.75, at("E")$x - r, 2.75),         # E's mate
  line(at("F")$x + r, 2.75, at("m2")$x - r, 2.75),         # F's mate
  line(1.35, 2.75, 1.35, 1.75 + r), line(4.05, 2.75, 4.05, 1.75 + r),
  line(2.70, 1.74, 2.70, 0.75 + r)                         # descent to X
)
double <- rbind(line(at("C")$x + r, 1.79, at("D")$x - r, 1.79),
                line(at("C")$x + r, 1.69, at("D")$x - r, 1.69))

p <- ped_canvas("fullbox") +
  ggplot2::geom_segment(data = lines, ggplot2::aes(x, y, xend = xend, yend = yend),
                        colour = bb512$grey, linewidth = 0.8) +
  ggplot2::geom_segment(data = double, ggplot2::aes(x, y, xend = xend, yend = yend),
                        colour = bb512$clay, linewidth = 0.9) +
  ggplot2::geom_polygon(data = outline, ggplot2::aes(x, y, group = id, fill = fill), colour = NA) +
  ggplot2::annotate("text", x = tree$x[!tree$id %in% c("m1", "m2")],
                    y = tree$y[!tree$id %in% c("m1", "m2")],
                    label = tree$id[!tree$id %in% c("m1", "m2")], size = 5.2, fontface = "bold",
                    colour = ifelse(tree$id[!tree$id %in% c("m1", "m2")] == "X", bb512$ink, bb512$bg),
                    family = ped_font) +
  ggplot2::annotate("text", x = 2.70, y = 2.03, label = "related mates", size = 5,
                    colour = bb512$clay, family = ped_font) +
  ggplot2::annotate("text", x = 2.70, y = 0.22, label = "Family tree: squares and circles",
                    size = 5, colour = bb512$grey, family = ped_font) +
  ggplot2::annotate("segment", x = 5.45, xend = 6.25, y = 2.2, yend = 2.2, colour = bb512$ink,
                    linewidth = 1.1,
                    arrow = grid::arrow(length = grid::unit(0.14, "inches"), type = "closed")) +
  ped_layers(rel, ox = 8.95, oy = 0.72, sx = 1.2, sy = 1.02, r = 0.2, off = 0.055,
             letters_size = 5.2, path_lw = 1.3, base_lw = 0.7, arrow_in = 0.11) +
  ggplot2::annotate("text", x = 8.95, y = 0.22, label = "Arrow diagram: paths to count",
                    size = 5, colour = bb512$grey, family = ped_font)

save_bb512(p, "03h_pedigree_to_arrows", layout = "fullbox")
