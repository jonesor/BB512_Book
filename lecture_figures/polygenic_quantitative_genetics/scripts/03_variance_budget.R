# Slides "Partitioning East's tobacco data" and "Completing the partition": variance components.
# Empirical: East (1916) Nicotiana longiflora corolla length, as analysed in Neal (2004, section
# "Partitioning phenotypic variation into different components"). V_E = 5.2 (mean variance of P1, P2 and F1), V_P(F2) = 40.5, V_G = V_P - V_E = 35.3,
# h2 = 0.8348 (mid-parent regression), V_A = h2 * V_P = 33.8, V_D + V_I = V_G - V_A = 1.5.
# Assumes genetic and environmental effects are additive and independent.
source("R/theme_bb512.R")
fam <- "Avenir Next"

VP <- 40.5; VE <- 5.2; h2 <- 0.8348
VG <- VP - VE; VA <- round(h2 * VP, 1); VNA <- round(VG - VA, 1)

bar <- function(df, rows, file) {
  df$row <- factor(df$row, rev(rows))
  df <- df[order(df$row, df$order), ]
  df$xmax <- ave(df$v, df$row, FUN = cumsum); df$xmin <- df$xmax - df$v
  df$mid <- (df$xmin + df$xmax) / 2
  df$pct <- sprintf("%.0f%%", 100 * df$v / VP)
  big <- df$v > 8
  if (is.null(df$below)) df$below <- FALSE
  df$ylab <- as.numeric(df$row) + ifelse(df$below, -0.42, 0.42)
  p <- ggplot2::ggplot(df) +
    ggplot2::geom_rect(ggplot2::aes(xmin = xmin, xmax = xmax, ymin = as.numeric(row) - 0.36,
                                    ymax = as.numeric(row) + 0.36, fill = I(fill)),
                       colour = bb512$bg, linewidth = 1.2) +
    ggplot2::geom_text(data = df[big, ], ggplot2::aes(mid, as.numeric(row),
                                   label = sprintf('atop(bold("%s"), bold(%s == "%s"))', name, sym, format(v, nsmall = 1))),
                       parse = TRUE, family = fam, colour = "white", size = 6) +
    ggplot2::geom_text(data = df[!big, ], ggplot2::aes(mid, ylab, vjust = ifelse(below, 1, 0),
                                                       label = sprintf('%s == "%s"', sym, format(v, nsmall = 1))),
                       parse = TRUE, family = fam, colour = bb512$ink, size = 5.2, hjust = 0.5) +
    ggplot2::scale_y_continuous(breaks = seq_along(rows), labels = rev(rows), limits = c(0.35, length(rows) + 0.75)) +
    ggplot2::scale_x_continuous(limits = c(0, 41), breaks = seq(0, 40, 10), expand = c(0, 0)) +
    ggplot2::labs(x = "Variance in corolla length (mm²)", y = NULL) +
    theme_bb512() +
    ggplot2::theme(panel.grid.major.y = ggplot2::element_blank(),
                   panel.grid.major.x = ggplot2::element_line(colour = bb512$grid, linewidth = 0.5),
                   axis.text.y = ggplot2::element_text(size = 16, colour = bb512$ink),
                   plot.margin = ggplot2::margin(10, 30, 10, 10))
  save_bb512(p, file, layout = "takeaway")
}

a <- data.frame(row = "F2 plants", name = c("Genetic", "Environment"), sym = c("V[G]", "V[E]"), v = c(VG, VE),
                fill = c(bb512$forest, bb512$sage), order = 1:2)
bar(a, "F2 plants", "03a_variance_vg_ve")

b <- data.frame(row = c(rep("Total", 2), rep("Genetic split", 3)),
                name = c("Genetic", "Environment", "Additive", "Dominance + interaction", "Environment"),
                sym = c("V[G]", "V[E]", "V[A]", "V[D] + V[I]", "V[E]"),
                v = c(VG, VE, VA, VNA, VE),
                fill = c(bb512$forest, bb512$sage, bb512$gold, bb512$clay, bb512$sage),
                order = c(1, 2, 1, 2, 3), below = c(FALSE, FALSE, FALSE, TRUE, FALSE))
bar(b, c("Total", "Genetic split"), "03b_variance_va")
