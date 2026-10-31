# Punnett square with inbreeding: areas are genotype frequencies.
# Rows: allele from one parent (A1 with prob. p, A2 with prob. q).
# Columns: with prob. F the second allele is IBD with the first (autozygous);
# otherwise (prob. 1 - F) it is drawn independently: A1 with p(1-F), A2 with q(1-F).
# Genotype frequencies: A1A1 = p^2(1-F) + pF, A1A2 = 2pq(1-F), A2A2 = q^2(1-F) + qF.
# Allele frequencies are unchanged: p^2(1-F) + pF + pq(1-F) = p.
# Matched baseline and inbreeding diagrams: p = 0.6 in both.
# Both exports have identical canvas sizes, coordinate limits and square sides.
source("R/theme_bb512.R")

punnett_inbreeding <- function(p_val = 0.6, F_val = 0.25) {
  stopifnot(p_val > 0, p_val < 1, F_val >= 0, F_val < 1)
  q_val <- 1 - p_val
  stopifnot(abs(p_val^2 * (1 - F_val) + p_val * F_val + p_val * q_val * (1 - F_val) - p_val) < 1e-12)

  colw <- c(p_val * (1 - F_val), q_val * (1 - F_val), F_val)
  if (F_val == 0) colw <- colw[1:2]
  x0 <- c(0, head(cumsum(colw), -1)); x1 <- cumsum(colw)
  y1 <- c(1, q_val); y0 <- c(q_val, 0)

  cell <- function(r, c, type, lab1, lab2) {
    data.frame(xmin = x0[c], xmax = x1[c], ymin = y0[r], ymax = y1[r],
               type = type, lab1 = lab1, lab2 = lab2,
               x = (x0[c] + x1[c]) / 2, y = (y0[r] + y1[r]) / 2)
  }
  cells <- rbind(
    cell(1, 1, "allo", "A[1]*A[1]", if (F_val == 0) "p^2" else "p^2*(1-F)"),
    cell(1, 2, "het", "A[1]*A[2]", if (F_val == 0) "pq" else "pq*(1-F)"),
    cell(2, 1, "het", "A[2]*A[1]", if (F_val == 0) "pq" else "pq*(1-F)"),
    cell(2, 2, "allo", "A[2]*A[2]", if (F_val == 0) "q^2" else "q^2*(1-F)")
  )
  if (F_val > 0) {
    cells <- rbind(cells,
                   cell(1, 3, "auto", "A[1]*A[1]", "pF"),
                   cell(2, 3, "auto", "A[2]*A[2]", "qF"))
  }
  headers <- if (F_val == 0) {
    c("atop(A[1],~p)", "atop(A[2],~q)")
  } else {
    c("atop(A[1],~p*(1-F))", "atop(A[2],~q*(1-F))", "atop(IBD,~F)")
  }
  # Blue vs clay (not green vs clay) so the two homozygote types stay distinct
  # for red-green colour-blind viewers.
  fills <- c(allo = bb512$blue, het = bb512$pale, auto = bb512$clay)
  txt   <- c(allo = bb512$bg,     het = bb512$ink,  auto = bb512$bg)
  cells$fill <- fills[cells$type]; cells$tcol <- txt[cells$type]

  p <- ggplot2::ggplot(cells) +
    ggplot2::geom_rect(ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
                                    fill = fill), colour = bb512$bg, linewidth = 1.5) +
    ggplot2::scale_fill_identity() +
    ggplot2::geom_text(ggplot2::aes(x, y + 0.06, label = lab1, colour = tcol), parse = TRUE,
                       size = 5.6, fontface = "bold", family = "Avenir Next") +
    ggplot2::geom_text(ggplot2::aes(x, y - 0.07, label = lab2, colour = tcol), parse = TRUE,
                       size = 5.2, family = "Avenir Next") +
    ggplot2::scale_colour_identity() +
    # column headers
    ggplot2::annotate("text", x = (x0 + x1) / 2, y = 1.07,
                      label = headers, parse = TRUE,
                      size = 5.2, colour = c(bb512$ink, bb512$ink, bb512$clay)[seq_along(headers)],
                      family = "Avenir Next") +
    # row headers
    ggplot2::annotate("text", x = -0.035, y = c((y0[1] + y1[1]) / 2, (y0[2] + y1[2]) / 2),
                      label = c("A[1]:~p", "A[2]:~q"), parse = TRUE, hjust = 1,
                      size = 5.2, colour = bb512$ink, family = "Avenir Next") +
    ggplot2::coord_fixed(ratio = 1, xlim = c(-0.17, 1.005),
                        ylim = c(-0.005, 1.17), expand = FALSE, clip = "off") +
    ggplot2::theme_void() +
    ggplot2::theme(plot.background = ggplot2::element_rect(fill = bb512$bg, colour = NA),
                   plot.margin = ggplot2::margin(3, 3, 3, 3))

  p
}

# Separate files allow the no-inbreeding case to be revealed first on a slide.
no_inbreeding <- punnett_inbreeding(p_val = 0.6, F_val = 0)
with_inbreeding <- punnett_inbreeding(p_val = 0.6, F_val = 0.25)
save_bb512(no_inbreeding, "05_punnett_no_inbreeding", layout = "square")
save_bb512(with_inbreeding, "05_punnett_inbreeding", layout = "square")
