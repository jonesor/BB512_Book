# Answer slide for "What is F for the child of two half-siblings?"
# Left: half siblings C and D share one parent (A); their other parents (B, E) are
# unrelated to everyone. One loop, X-C-A-D-X, n = 3, so F = (1/2)^3 = 1/8.
# Right: full siblings for comparison: two loops, F = 2 x (1/2)^3 = 1/4.
# Assumes all founders are unrelated and not inbred (F_A = F_B = 0). Schematic.
source("R/theme_bb512.R")
source("R/pedigree.R")

full_nodes <- ped_nodes; full_edges <- ped_edges   # keep the full-sib pedigree

half_nodes <- data.frame(id = c("B", "A", "E", "C", "D", "X"),
                         x  = c(0.75, 2, 3.25, 1, 3, 2),
                         y  = c(3, 3, 3, 2, 2, 1))
half_edges <- data.frame(from = c("B", "A", "A", "E", "C", "D"),
                         to   = c("C", "C", "D", "D", "X", "X"))

r_node <- 0.25
closing_segs <- function(nodes) {
  pos <- function(id) nodes[match(id, nodes$id), c("x", "y")]
  seg <- function(a, b) {
    pa <- pos(a); pb <- pos(b)
    d <- sqrt((pb$x - pa$x)^2 + (pb$y - pa$y)^2)
    ux <- (pb$x - pa$x) / d; uy <- (pb$y - pa$y) / d
    data.frame(x = pa$x + ux * (r_node + 0.03), y = pa$y + uy * (r_node + 0.03),
               xend = pb$x - ux * (r_node + 0.03), yend = pb$y - uy * (r_node + 0.03))
  }
  rbind(seg("C", "X"), seg("D", "X"))
}

# Title with the loop(s), X greyed out (not counted): grey layer + ink layer with phantom X.
loop_title <- function(head, mids) {
  loops_g <- paste(sprintf("'X–%s–X'", mids), collapse = "*';  '*")
  loops_i <- paste(sprintf("phantom('X–')*'%s'*phantom('–X')", mids), collapse = "*';  '*")
  list(grey = sprintf("phantom('%s')*%s", head, loops_g),
       ink  = sprintf("'%s'*%s", head, loops_i))
}

panel <- function(nodes, edges, ancs, mids, col, heading, result, xlim) {
  ped_nodes <<- nodes; ped_edges <<- edges
  hl <- unlist(lapply(ancs, function(a) list(c(a, "C"), c(a, "D"))), recursive = FALSE)
  nf <- c(stats::setNames(rep(col, length(ancs)), ancs), C = col, D = col)
  lt <- loop_title("", mids)
  g <- draw_pedigree(highlight = hl, cols = rep(col, length(hl)), node_fill = nf,
                     row_labels = FALSE, r = r_node, node_text = 5.5,
                     xlim = xlim, ylim = c(0.0, 4.35)) +
    ggplot2::geom_segment(data = closing_segs(nodes),
                          ggplot2::aes(x, y, xend = xend, yend = yend),
                          colour = col, linewidth = 1.2, linetype = "22", inherit.aes = FALSE) +
    ggplot2::annotate("text", x = 2, y = 4.15, label = heading, size = 5.6,
                      fontface = "bold", colour = bb512$ink, family = "Avenir Next") +
    ggplot2::annotate("text", x = 2, y = 3.65, label = lt$grey, parse = TRUE, size = 5,
                      colour = bb512$sage, family = "Avenir Next") +
    ggplot2::annotate("text", x = 2, y = 3.65, label = lt$ink, parse = TRUE, size = 5,
                      colour = bb512$ink, family = "Avenir Next") +
    ggplot2::annotate("text", x = 2, y = 0.25, label = result, parse = TRUE, size = 5.6,
                      colour = col, fontface = "bold", family = "Avenir Next")
  ped_nodes <<- full_nodes; ped_edges <<- full_edges
  g
}

p_half <- panel(half_nodes, half_edges, ancs = "A", mids = "C–A–D",
                col = bb512$clay, heading = "Half siblings: 1 loop",
                result = "F == (1/2)^3*' = 1/8'", xlim = c(0.35, 3.65))
p_full <- panel(full_nodes, full_edges, ancs = c("A", "B"),
                mids = c("C–A–D", "C–B–D"),
                col = bb512$blue, heading = "Full siblings: 2 loops",
                result = "F == 2%*%(1/2)^3*' = 1/4'", xlim = c(0.35, 3.65))

if (!requireNamespace("patchwork", quietly = TRUE)) stop("Install 'patchwork'")
p_e <- patchwork::wrap_plots(p_half, p_full, nrow = 1) &
  ggplot2::theme(plot.background = ggplot2::element_rect(fill = bb512$bg, colour = NA))
save_bb512(p_e, "03e_half_sib_answer", layout = "takeaway")
