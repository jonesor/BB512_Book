# Full-sib pedigree used to calculate F by hand and by path counting.
# Assumptions: grandparents A and B are unrelated and not inbred (F_A = F_B = 0);
# each parent passes on either allele with probability 1/2 (Mendelian segregation).
# Schematic, not data.
source("R/theme_bb512.R")
source("R/pedigree.R")

# 03a: the pedigree on its own
p_a <- draw_pedigree()
save_bb512(p_a, "03a_pedigree_fullsib", layout = "half")

# 03b: one allele from grandparent A travelling to X by both routes
p_b <- draw_pedigree(highlight = list(c("A", "C", "X"), c("A", "D", "X")),
                     cols = c(bb512$clay, bb512$clay), halves = TRUE, label_frac = 0.36,
                     node_fill = c(A = bb512$clay))
save_bb512(p_b, "03b_pedigree_one_allele", layout = "takeaway")

# 03c: the four mutually exclusive ways X can be autozygous
routes <- data.frame(
  lab = c("A[1]*A[1]~'from A'", "A[2]*A[2]~'from A'",
          "B[1]*B[1]~'from B'", "B[2]*B[2]~'from B'"),
  anc = c("A", "A", "B", "B"),
  allele = c("A[1]", "A[2]", "B[1]", "B[2]")   # the allele copy travelling down each side
)
panels <- lapply(seq_len(nrow(routes)), function(i) {
  a <- routes$anc[i]
  col <- if (a == "A") bb512$clay else bb512$blue
  nf <- stats::setNames(col, a)
  draw_pedigree(highlight = list(c(a, "C", "X"), c(a, "D", "X")),
                cols = c(col, col), node_fill = nf, row_labels = FALSE,
                r = 0.25, node_text = 5.5, xlim = c(0.6, 3.4), ylim = c(0.0, 4.0)) +
    ggplot2::annotate("text", x = 2, y = 3.75, label = routes$lab[i], parse = TRUE,
                      size = 5.6, colour = bb512$ink, family = "Avenir Next") +
    ggplot2::annotate("text", x = c(1.28, 2.72), y = c(1.35, 1.35), label = routes$allele[i],
                      parse = TRUE, size = 5.4, colour = col, fontface = "bold",
                      family = "Avenir Next") +
    ggplot2::annotate("text", x = 2, y = 0.2,
                      label = "(1/2)^4*' = 1/16'", parse = TRUE, size = 5.6, colour = col,
                      family = "Avenir Next", fontface = "bold")
})

if (!requireNamespace("patchwork", quietly = TRUE)) stop("Install 'patchwork'")
p_c <- patchwork::wrap_plots(panels, nrow = 1) &
  ggplot2::theme(plot.background = ggplot2::element_rect(fill = bb512$bg, colour = NA))
save_bb512(p_c, "03c_four_routes", layout = "full")

# 03d: path counting. One panel per loop. Arrows show genes moving DOWN from the
# common ancestor to each of X's parents (same meaning as the arrows in 03b and 03c).
# The loop closes at X (dashed), but X is not counted: n = the individuals on the
# path between X's two parents through the common ancestor (here C, A, D), so n = 3.
# Loop labels: the full loop X-C-A-D-X, with X greyed out because it is not counted.
# Drawn as a grey layer (whole loop) plus an ink layer with X replaced by phantom().
loops <- list(list(anc = "A", col = bb512$clay, mid = "C\u2013A\u2013D", num = 1),
              list(anc = "B", col = bb512$blue, mid = "C\u2013B\u2013D", num = 2))
loop_label <- function(L, grey) {
  if (grey) sprintf("phantom('Loop %d: ')*'X\u2013%s\u2013X'", L$num, L$mid)
  else sprintf("'Loop %d: '*phantom('X\u2013')*'%s'*phantom('\u2013X')", L$num, L$mid)
}
r_node <- 0.25
closing <- local({
  pos <- function(id) ped_nodes[match(id, ped_nodes$id), c("x", "y")]
  seg <- function(a, b) {
    pa <- pos(a); pb <- pos(b)
    d <- sqrt((pb$x - pa$x)^2 + (pb$y - pa$y)^2)
    ux <- (pb$x - pa$x) / d; uy <- (pb$y - pa$y) / d
    data.frame(x = pa$x + ux * (r_node + 0.03), y = pa$y + uy * (r_node + 0.03),
               xend = pb$x - ux * (r_node + 0.03), yend = pb$y - uy * (r_node + 0.03))
  }
  rbind(seg("C", "X"), seg("D", "X"))
})
loop_panels <- lapply(loops, function(L) {
  nf <- c(stats::setNames(L$col, L$anc), C = L$col, D = L$col)
  draw_pedigree(highlight = list(c(L$anc, "C"), c(L$anc, "D")), cols = c(L$col, L$col),
                node_fill = nf, row_labels = FALSE, r = r_node, node_text = 5.5,
                xlim = c(0.6, 3.4), ylim = c(0.0, 4.0)) +
    ggplot2::geom_segment(data = closing, ggplot2::aes(x, y, xend = xend, yend = yend),
                          colour = L$col, linewidth = 1.2, linetype = "22",
                          inherit.aes = FALSE) +
    ggplot2::annotate("text", x = 2, y = 3.75, label = loop_label(L, TRUE), parse = TRUE,
                      size = 5.4, colour = bb512$sage, family = "Avenir Next") +
    ggplot2::annotate("text", x = 2, y = 3.75, label = loop_label(L, FALSE), parse = TRUE,
                      size = 5.4, colour = bb512$ink, family = "Avenir Next") +
    ggplot2::annotate("text", x = 2, y = 0.2, label = "n == 3*':'~(1/2)^3*' = 1/8'", parse = TRUE,
                      size = 5.4, colour = L$col, fontface = "bold", family = "Avenir Next")
})
p_d <- patchwork::wrap_plots(loop_panels, nrow = 1) &
  ggplot2::theme(plot.background = ggplot2::element_rect(fill = bb512$bg, colour = NA))
save_bb512(p_d, "03d_path_counting", layout = "half")
