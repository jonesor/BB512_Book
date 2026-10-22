# Helper for drawing the small full-sib pedigree used throughout the lecture.
# Grandparents A and B (unrelated, not inbred) have two children, C and D
# (full siblings), who mate and produce X.
# Requires theme_bb512.R to have been sourced first (for the bb512 colours).

ped_nodes <- data.frame(
  id = c("A", "B", "C", "D", "X"),
  x  = c(1, 3, 1, 3, 2),
  y  = c(3, 3, 2, 2, 1)
)

ped_edges <- data.frame(
  from = c("A", "A", "B", "B", "C", "D"),
  to   = c("C", "D", "C", "D", "X", "X")
)

# Draw the pedigree.
#   highlight: list of character vectors, each a path of node ids
#              (e.g. c("A", "C", "X")), drawn as arrows in the matching colour.
#   cols:      colours for the highlighted paths.
#   halves:    label highlighted edges with "1/2"?
#   label_frac: where along each edge the "1/2" label sits (0 = start, 1 = end);
#              below 0.5 keeps labels clear of the crossing lines in the middle.
#   node_fill: named vector of fills for particular nodes.
#   row_labels: show "Grandparents", "Parents", "Child" on the left?
#   r:         node radius in data units.
#   offset:    shift parallel highlighted paths sideways so shared edges show both colours.
draw_pedigree <- function(highlight = list(), cols = bb512$clay,
                          halves = FALSE, label_frac = 0.5, node_fill = NULL,
                          row_labels = TRUE, r = 0.22, node_text = 6.5, offset = FALSE,
                          label_size = 5, xlim = NULL, ylim = c(0.7, 3.3)) {
  cols <- rep_len(cols, max(1, length(highlight)))
  pos <- function(id) ped_nodes[match(id, ped_nodes$id), c("x", "y")]

  # Shorten an edge so it starts and ends at the circle boundaries.
  trim <- function(x1, y1, x2, y2, r) {
    d <- sqrt((x2 - x1)^2 + (y2 - y1)^2)
    ux <- (x2 - x1) / d; uy <- (y2 - y1) / d
    c(x1 + ux * r, y1 + uy * r, x2 - ux * r, y2 - uy * r)
  }

  base <- do.call(rbind, lapply(seq_len(nrow(ped_edges)), function(i) {
    a <- pos(ped_edges$from[i]); b <- pos(ped_edges$to[i])
    t <- trim(a$x, a$y, b$x, b$y, r)
    data.frame(x = t[1], y = t[2], xend = t[3], yend = t[4])
  }))

  hl <- NULL
  if (length(highlight)) {
    hl <- do.call(rbind, lapply(seq_along(highlight), function(k) {
      path <- highlight[[k]]
      do.call(rbind, lapply(seq_len(length(path) - 1), function(j) {
        a <- pos(path[j]); b <- pos(path[j + 1])
        t <- trim(a$x, a$y, b$x, b$y, r + 0.03)
        # offset parallel paths slightly so shared edges stay visible
        off <- if (offset && length(highlight) > 1) (k - (length(highlight) + 1) / 2) * 0.06 else 0
        data.frame(x = t[1] + off, y = t[2], xend = t[3] + off, yend = t[4],
                   colour = cols[k],
                   mx = a$x + label_frac * (b$x - a$x), my = a$y + label_frac * (b$y - a$y))
      }))
    }))
  }

  fills <- rep(bb512$forest, nrow(ped_nodes))
  if (!is.null(node_fill)) fills[match(names(node_fill), ped_nodes$id)] <- node_fill
  circ <- do.call(rbind, lapply(seq_len(nrow(ped_nodes)), function(i) {
    th <- seq(0, 2 * pi, length.out = 80)
    data.frame(id = ped_nodes$id[i], x = ped_nodes$x[i] + r * cos(th),
               y = ped_nodes$y[i] + r * sin(th), fill = fills[i])
  }))

  if (is.null(xlim)) xlim <- if (row_labels) c(-0.9, 3.35) else c(0.6, 3.4)

  g <- ggplot2::ggplot() +
    ggplot2::geom_segment(data = base,
                          ggplot2::aes(x, y, xend = xend, yend = yend),
                          colour = bb512$sage, linewidth = 1.1)
  if (!is.null(hl)) {
    g <- g + ggplot2::geom_segment(
      data = hl, ggplot2::aes(x, y, xend = xend, yend = yend, colour = colour),
      linewidth = 2, lineend = "round",
      arrow = grid::arrow(length = grid::unit(0.16, "inches"), type = "closed")) +
      ggplot2::scale_colour_identity()
    if (halves) {
      lab <- unique(hl[, c("mx", "my", "colour")])
      # background disc then text: avoids geom_label(), whose border argument
      # changed between ggplot2 versions
      g <- g + ggplot2::annotate("point", x = lab$mx, y = lab$my, size = 9,
                                 colour = bb512$bg) +
        ggplot2::annotate("text", x = lab$mx, y = lab$my,
                          label = "1/2", colour = lab$colour,
                          size = label_size, fontface = "bold",
                          family = "Avenir Next")
    }
  }
  g <- g +
    ggplot2::geom_polygon(data = circ, ggplot2::aes(x, y, group = id, fill = fill),
                          colour = NA) +
    ggplot2::scale_fill_identity() +
    ggplot2::annotate("text", x = ped_nodes$x, y = ped_nodes$y, label = ped_nodes$id,
                      colour = bb512$bg, size = node_text, fontface = "bold",
                      family = "Avenir Next")
  if (row_labels) {
    g <- g + ggplot2::annotate("text", x = -0.85, y = c(3, 2, 1),
                               label = c("Grandparents", "Parents\n(full siblings)", "Child"),
                               hjust = 0, colour = bb512$grey, size = label_size,
                               family = "Avenir Next", lineheight = 0.9)
  }
  g + ggplot2::coord_equal(xlim = xlim, ylim = ylim, clip = "off") +
    ggplot2::theme_void() +
    ggplot2::theme(plot.background = ggplot2::element_rect(fill = bb512$bg, colour = NA),
                   plot.margin = ggplot2::margin(6, 6, 6, 6))
}
