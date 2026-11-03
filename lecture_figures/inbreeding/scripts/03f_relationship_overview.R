# Overview of seven matings between relatives, in order of decreasing F, with X on a
# common baseline so that longer paths are visible. Exact values from path counting,
# assuming unrelated, non-inbred founders; R/path_counting.R stops if path counting,
# the kinship calculation and these values disagree. Schematic, not data.
source("R/theme_bb512.R")
source("R/path_counting.R")

panel_w <- 11.733 / length(relationships)
base_y  <- 1.68   # height of X
sy      <- 0.53   # inches between generations
sx      <- 0.42

p <- ped_canvas("fullbox")
for (i in seq_along(relationships)) {
  rel <- relationships[[i]]
  cx <- panel_w * (i - 0.5)
  paths <- find_paths(rel$ped)
  k <- nrow(paths)
  p <- p + ped_layers(rel, ox = cx, oy = base_y, sx = sx, sy = sy, r = 0.085, off = 0.03,
                      path_lw = 0.9, base_lw = 0.45, arrow_in = 0.06) +
    ggplot2::annotate("text", x = cx, y = 1.21, label = rel$short, size = 5, lineheight = 0.9,
                      colour = bb512$ink, family = ped_font) +
    ggplot2::annotate("text", x = cx, y = 0.70, label = paste("F =", fraction(rel$F)), size = 5.6,
                      fontface = "bold", colour = bb512$forest, family = ped_font) +
    ggplot2::annotate("text", x = cx, y = 0.42, label = sprintf("%d path%s", k, if (k > 1) "s" else ""),
                      size = 5, colour = bb512$grey, family = ped_font) +
    ggplot2::annotate("text", x = cx, y = 0.16, label = sprintf("n = %d", paths$n[1]),
                      size = 5, colour = bb512$grey, family = ped_font)
}

save_bb512(p, "03f_relationship_overview", layout = "fullbox")
