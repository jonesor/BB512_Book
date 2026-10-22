# Schematic: genotypes at three loci in six diploid individuals.
# Locus A has four alleles, locus B two, locus C one (monomorphic).
# Each individual carries at most two alleles per locus; heterozygotes highlighted.
source("R/theme_bb512.R")

g <- list(A = list(c(1,3), c(2,2), c(1,4), c(2,3), c(1,1), c(3,4)),
          B = list(c(1,1), c(1,2), c(1,1), c(1,1), c(1,2), c(1,2)),
          C = list(c(1,1), c(1,1), c(1,1), c(1,1), c(1,1), c(1,1)))
df <- do.call(rbind, lapply(names(g), function(l) do.call(rbind, lapply(1:6, function(i) {
  a <- g[[l]][[i]]
  data.frame(locus = l, ind = i, het = a[1] != a[2],
             lab = sprintf("%s[%d]*%s[%d]", l, a[1], l, a[2]))
}))))
df$y <- match(df$locus, c("C", "B", "A"))
lab_right <- data.frame(y = 3:1, lab = c("4 alleles", "2 alleles", "1 allele"),
                        col = c(bb512$forest, bb512$forest, bb512$grey))

p <- ggplot2::ggplot(df) +
  ggplot2::geom_tile(ggplot2::aes(ind, y, colour = het, fill = het),
                     width = 0.86, height = 0.62, linewidth = 1.1) +
  ggplot2::geom_text(ggplot2::aes(ind, y, label = lab, colour = het),
                     parse = TRUE, size = 5, family = "Avenir Next") +
  ggplot2::annotate("text", x = 0.3, y = 3:1, label = paste("Locus", c("A","B","C")),
                    hjust = 1, size = 5, colour = bb512$ink, family = "Avenir Next") +
  ggplot2::annotate("text", x = 1:6, y = 3.62, label = 1:6, size = 4.4,
                    colour = bb512$grey, family = "Avenir Next") +
  ggplot2::annotate("text", x = 3.5, y = 3.98, label = "Individual", size = 4.6,
                    colour = bb512$grey, family = "Avenir Next") +
  ggplot2::geom_text(data = lab_right, ggplot2::aes(6.7, y, label = lab), colour = lab_right$col,
                     hjust = 0, size = 4.6, family = "Avenir Next", fontface = "bold") +
  ggplot2::annotate("text", x = 3.5, y = 0.25, size = 4.2, colour = bb512$clay,
                    label = "Highlighted = heterozygous", family = "Avenir Next") +
  ggplot2::scale_colour_manual(values = c(`FALSE` = bb512$grey, `TRUE` = bb512$clay), guide = "none") +
  ggplot2::scale_fill_manual(values = c(`FALSE` = "white", `TRUE` = "#F6E7E1"), guide = "none") +
  ggplot2::coord_cartesian(xlim = c(-1.5, 8.4), ylim = c(0.1, 4.1), expand = FALSE, clip = "off") +
  ggplot2::theme_void() +
  ggplot2::theme(plot.background = ggplot2::element_rect(fill = bb512$bg, colour = NA))

save_bb512(p, "10_loci_matrix", layout = "half")
