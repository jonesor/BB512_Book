# One worked path-counting figure for each mating, for the self-study slides.
# Left: the pedigree, one colour per path, each counted individual numbered. Arrows show
# genes moving down from the common ancestor; dashed lines close on X, which is not counted.
# Right: every path with its n and contribution, then the sum.
# Exact values, assuming unrelated, non-inbred founders (so F_CA = 0). Schematic, not data.
source("R/theme_bb512.R")
source("R/path_counting.R")

ped_cx <- 2.75   # centre of the pedigree (inches)
col_x  <- c(ca = 6.05, path = 7.25, n = 9.65, value = 10.75)   # table columns

for (key in names(relationships)) {
  rel <- relationships[[key]]
  ped <- rel$ped
  paths <- find_paths(ped)
  plist <- attr(paths, "paths")
  top <- max(ped$y)
  sy <- if (top == 1) 1.5 else min(0.78, 3.35 / top)   # selfing needs room for its curves
  sx <- 1.2
  oy <- (3.95 - top * sy) / 2

  # Number each counted individual in path order. Paths through different common
  # ancestors share their other individuals and these get the same number.
  numbers <- do.call(rbind, lapply(plist, function(l) {
    data.frame(id = l$individuals, num = seq_along(l$individuals))
  }))
  numbers <- unique(numbers)
  numbers <- cbind(numbers, ped[match(numbers$id, ped$id), c("x", "y")])
  numbers$px <- ped_cx + numbers$x * sx
  numbers$py <- oy + numbers$y * sy
  centred <- abs(numbers$x) < 0.01
  side <- ifelse(numbers$x < 0, -1, 1)
  numbers$lx <- ifelse(centred, numbers$px, numbers$px + side * 0.36)
  numbers$ly <- ifelse(centred, numbers$py + 0.36, numbers$py)

  p <- ped_canvas("full") +
    ped_layers(rel, ox = ped_cx, oy = oy, sx = sx, sy = sy, r = 0.2, off = 0.055,
               letters_size = 5.2, path_lw = 1.3, base_lw = 0.7, arrow_in = 0.11) +
    ggplot2::annotate("text", x = numbers$lx, y = numbers$ly, label = numbers$num,
                      size = 5, colour = bb512$grey, family = ped_font)

  # Table
  k <- nrow(paths)
  y_head <- 3.15
  y_rows <- y_head - 0.55 * seq_len(k)
  cols <- path_colours(rel)[paths$ca]
  values <- fraction(paths$contribution)
  sum_txt <- if (k > 1) {
    paste("F =", paste(values, collapse = " + "), "=", fraction(rel$F))
  } else paste("F =", fraction(rel$F))
  y_sum <- min(y_rows) - 0.75

  p <- p +
    ggplot2::annotate("text", x = col_x[c("ca", "path", "n")], y = y_head,
                      label = c("Ancestor", "Path", "n"), hjust = 0, size = 5,
                      colour = bb512$grey, family = ped_font) +
    ggplot2::annotate("text", x = col_x[["value"]], y = y_head, label = "(1/2)^n", parse = TRUE,
                      hjust = 0, size = 5, colour = bb512$grey, family = ped_font) +
    ggplot2::annotate("segment", x = col_x[["ca"]], xend = 11.45, y = y_head - 0.24,
                      yend = y_head - 0.24, colour = bb512$grid, linewidth = 0.6) +
    ggplot2::annotate("text", x = col_x[["ca"]] + 0.28, y = y_rows, label = paths$ca, hjust = 0.5,
                      size = 5.6, fontface = "bold", colour = cols, family = ped_font) +
    ggplot2::annotate("text", x = col_x[["path"]], y = y_rows, label = paths$path, hjust = 0,
                      size = 5.6, colour = bb512$ink, family = ped_font) +
    ggplot2::annotate("text", x = col_x[["n"]], y = y_rows, label = paths$n, hjust = 0,
                      size = 5.6, colour = bb512$ink, family = ped_font) +
    ggplot2::annotate("text", x = col_x[["value"]], y = y_rows, label = values, hjust = 0,
                      size = 5.6, colour = bb512$ink, family = ped_font) +
    ggplot2::annotate("text", x = col_x[["ca"]], y = y_sum, label = sum_txt, hjust = 0,
                      size = 6.4, fontface = "bold", colour = bb512$forest, family = ped_font) +
    ggplot2::annotate("text", x = col_x[["ca"]], y = y_sum - 0.5,
                      label = "n counts the individuals on the path, not X", hjust = 0,
                      size = 5, colour = bb512$grey, family = ped_font)

  save_bb512(p, paste0("03g_worked_", key), layout = "full")
}
