# Slide 7: "Recombination reshuffles existing alleles" (Figure & Bullets, "half")
# Schematic, not data. An AaBb parent with two unlinked loci (on different chromosomes)
# makes four gamete types, AB, Ab, aB and ab, each with probability 1/4 under
# independent assortment (Mendel's second law). No new alleles: only new combinations.
# R version of the diagram previously pasted into the deck.
source("R/theme_bb512.R")
library(ggplot2)

fam <- "Avenir Next"
col_allele <- c(A = bb512$forest, a = bb512$sage, B = bb512$clay, b = bb512$gold)
txt_allele <- c(A = bb512$bg, a = bb512$ink, B = bb512$bg, b = bb512$ink)

# A chromosome drawn as a rounded bar (thick segment) with its allele letter
chrom <- function(x, y, allele, len = 0.5) {
  data.frame(x = x, y0 = y - len / 2, y1 = y + len / 2, allele = allele)
}

# Parent cell: two homologous pairs
parent_c <- rbind(chrom(4.35, 5.0, "A"), chrom(4.75, 5.0, "a"),
                  chrom(5.25, 5.0, "B"), chrom(5.65, 5.0, "b"))

# Four gametes, each with one chromosome from each pair
gx <- c(1.5, 3.85, 6.15, 8.5)
combos <- list(c("A", "B"), c("A", "b"), c("a", "B"), c("a", "b"))
gam_c <- do.call(rbind, lapply(1:4, function(i)
  rbind(chrom(gx[i] - 0.22, 2.1, combos[[i]][1], 0.45),
        chrom(gx[i] + 0.22, 2.1, combos[[i]][2], 0.45))))
gam_lab <- data.frame(x = gx, y = 1.25, lab = vapply(combos, paste, "", collapse = ""))

chroms <- rbind(parent_c, gam_c)
chroms$col <- col_allele[chroms$allele]; chroms$tcol <- txt_allele[chroms$allele]

cells <- rbind(
  data.frame(x0 = 5, y0 = 5, r = 1.0),
  data.frame(x0 = gx, y0 = 2.1, r = 0.62)
)
circle <- do.call(rbind, lapply(seq_len(nrow(cells)), function(i) {
  t <- seq(0, 2 * pi, length.out = 120)
  data.frame(id = i, x = cells$x0[i] + cells$r[i] * cos(t), y = cells$y0[i] + cells$r[i] * sin(t))
}))
arrows <- data.frame(x = 5, y = 3.9, xend = gx, yend = 2.85)

p <- ggplot() +
  geom_polygon(data = circle, aes(x, y, group = id), fill = bb512$pale,
               colour = bb512$grid, linewidth = 0.8) +
  geom_segment(data = arrows, aes(x = x, y = y, xend = xend, yend = yend),
               colour = bb512$grey, linewidth = 0.8,
               arrow = arrow(length = unit(0.1, "in"), type = "closed")) +
  geom_segment(data = chroms, aes(x = x, xend = x, y = y0, yend = y1, colour = col),
               linewidth = 9, lineend = "round") +
  geom_text(data = chroms, aes(x, (y0 + y1) / 2, label = allele, colour = tcol),
            size = 4.6, fontface = "bold", family = fam) +
  geom_text(data = gam_lab, aes(x, y, label = lab), size = 6.2, fontface = "bold",
            colour = bb512$ink, family = fam) +
  annotate("text", x = 6.3, y = 5.35, label = "AaBb", hjust = 0, size = 7.5,
           fontface = "bold", colour = bb512$ink, family = fam) +
  annotate("text", x = 6.3, y = 4.7, label = "Two unlinked loci", hjust = 0,
           size = 5, colour = bb512$grey, family = fam) +
  annotate("text", x = 5, y = 0.55, label = "Four gamete types, 1/4 each",
           size = 5.4, colour = bb512$ink, family = fam) +
  scale_colour_identity() +
  coord_fixed(xlim = c(0.6, 9.4), ylim = c(0.2, 6.2), expand = FALSE, clip = "off") +
  theme_void() +
  theme(plot.background = element_rect(fill = bb512$bg, colour = NA),
        plot.margin = margin(4, 4, 4, 4))

save_bb512(p, "00b_recombination_gametes", layout = "half")
