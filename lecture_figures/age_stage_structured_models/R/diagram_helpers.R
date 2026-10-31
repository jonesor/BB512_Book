# Life cycle diagrams drawn with ggplot2 geometry, in data units that equal
# inches at the exported figure size (so radii, arrows and text land where intended).
# nodes: data.frame(id, x, y, label)
# edges: built with edge(). type: "survival" (forest arrow), "fertility" (clay arrow),
#   "stasis" (forest self-loop), "fertility_loop" (clay self-loop).
#   Curved arrows are cubic Bezier curves that leave the FROM node at angle a_out
#   and enter the TO node at angle a_in (degrees, 0 = right, 90 = up); NA = straight.
#   For loops, a_out gives the direction of the loop (e.g. -90 = below the node).

lc_circle <- function(x, y, r, n = 120) {
  a <- seq(0, 2 * pi, length.out = n)
  data.frame(x = x + r * cos(a), y = y + r * sin(a))
}

.dir <- function(deg) c(cos(deg * pi / 180), sin(deg * pi / 180))

lc_curve <- function(p0, p1, r, a_out, a_in, k = NULL, gap = 0.07, n = 100) {
  if (is.na(a_out)) {
    d <- (p1 - p0) / sqrt(sum((p1 - p0)^2))
    a <- p0 + d * (r + gap); b <- p1 - d * (r + gap)
    return(list(path = data.frame(x = c(a[1], b[1]), y = c(a[2], b[2])), mid = (a + b) / 2))
  }
  a <- p0 + .dir(a_out) * (r + gap); b <- p1 + .dir(a_in) * (r + gap)
  if (is.null(k) || is.na(k)) k <- 0.45 * sqrt(sum((b - a)^2))
  c1 <- a + .dir(a_out) * k; c2 <- b + .dir(a_in) * k
  t <- seq(0, 1, length.out = n)
  B <- function(t) outer((1 - t)^3, a) + outer(3 * (1 - t)^2 * t, c1) +
    outer(3 * (1 - t) * t^2, c2) + outer(t^3, b)
  pts <- B(t)
  list(path = data.frame(x = pts[, 1], y = pts[, 2]), mid = as.numeric(B(0.5)))
}

lc_loop <- function(p, r, dir_deg = -90, rr = 0.32, gap = 0.05, n = 120) {
  u <- .dir(dir_deg)
  cen <- p + u * (r + rr * 0.6)
  theta_c <- atan2(-u[2], -u[1])          # angle from loop centre back to node centre
  a <- seq(theta_c, theta_c + 2 * pi, length.out = n)
  pts <- data.frame(x = cen[1] + rr * cos(a), y = cen[2] + rr * sin(a))
  keep <- sqrt((pts$x - p[1])^2 + (pts$y - p[2])^2) > r + gap
  pts <- pts[keep, ]
  list(path = pts, label = cen + u * (rr + 0.25))
}

edge <- function(from, to, value, type, a_out = NA, a_in = NA, k = NA,
                 label_dx = 0, label_dy = 0) {
  data.frame(from = from, to = to, value = value, type = type, a_out = a_out, a_in = a_in,
             k = k, label_dx = label_dx, label_dy = label_dy, stringsAsFactors = FALSE)
}

lc_plot <- function(nodes, edges, width, height, r = 0.6, xlim = c(0, width), ylim = c(0, height),
                    value_size = 6.4, node_text_size = 5.6, fade = character(0),
                    highlight = character(0)) {
  library(ggplot2)
  col_type <- c(survival = bb512$forest, stasis = bb512$forest,
                fertility = bb512$clay, fertility_loop = bb512$clay)
  p <- ggplot() +
    coord_fixed(xlim = xlim, ylim = ylim, expand = FALSE) +
    theme_void() +
    theme(plot.background = element_rect(fill = bb512$bg, colour = NA),
          panel.background = element_rect(fill = bb512$bg, colour = NA),
          plot.margin = margin(0, 0, 0, 0))
  arrow_spec <- grid::arrow(length = grid::unit(0.15, "inches"), type = "closed", angle = 24)
  P <- function(id) as.numeric(nodes[nodes$id == id, c("x", "y")])
  for (i in seq_len(nrow(edges))) {
    e <- edges[i, ]
    col <- col_type[[e$type]]
    if (e$from %in% fade || e$to %in% fade) col <- bb512$sage
    lw <- if (paste(e$from, e$to) %in% highlight) 2.2 else 1.3
    if (e$type %in% c("stasis", "fertility_loop")) {
      g <- lc_loop(P(e$from), r, dir_deg = ifelse(is.na(e$a_out), -90, e$a_out))
      lab <- g$label
    } else {
      g <- lc_curve(P(e$from), P(e$to), r, e$a_out, e$a_in, e$k)
      lab <- g$mid
    }
    p <- p + geom_path(data = g$path, aes(x, y), colour = col, linewidth = lw,
                       arrow = arrow_spec, lineend = "butt", linejoin = "mitre") +
      annotate("label", x = lab[1] + e$label_dx, y = lab[2] + e$label_dy, label = e$value,
               colour = col, fill = bb512$bg, linewidth = 0, size = value_size,
               family = "Avenir Next", fontface = "bold", label.padding = grid::unit(0.12, "lines"))
  }
  for (i in seq_len(nrow(nodes))) {
    nd <- nodes[i, ]
    fill <- if (nd$id %in% fade) bb512$sage else bb512$forest
    p <- p + geom_polygon(data = lc_circle(nd$x, nd$y, r), aes(x, y), fill = fill, colour = NA) +
      annotate("text", x = nd$x, y = nd$y, label = nd$label, colour = "white",
               size = node_text_size, family = "Avenir Next", fontface = "bold", lineheight = 0.85)
  }
  p
}
