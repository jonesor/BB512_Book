# Slide 7: "Different genotypes can give the same phenotype" (Figure & Bullets, "half")
# Schematic, not data. The genotype -> phenotype -> fitness map is many-to-one:
# four genotypes (G1-G4) give three phenotypes (P1-P3), which give two fitness values
# (F1, F2). Selection acts on phenotype, so it cannot tell apart genotypes that share a
# phenotype (e.g. synonymous mutations, canalisation); those differences evolve neutrally.
# The particular mapping is illustrative. Replaces a textbook figure (after Herron &
# Freeman, Evolutionary Analysis) previously pasted into the deck.
source("R/theme_bb512.R"); library(ggplot2)
fam <- .bb512_font

y_lev <- c(G = 1, P = 3, F = 5)
nodes <- rbind(
  data.frame(id = paste0("G", 1:4), lev = "G", x = c(2.2, 3.6, 5.0, 6.4)),
  data.frame(id = paste0("P", 1:3), lev = "P", x = c(2.9, 5.0, 6.4)),
  data.frame(id = paste0("F", 1:2), lev = "F", x = c(3.95, 6.4))
)
nodes$y <- y_lev[nodes$lev]
nodes$fill <- c(G = bb512$pale, P = bb512$sage, F = bb512$forest)[nodes$lev]
nodes$tcol <- c(G = bb512$ink, P = bb512$ink, F = bb512$bg)[nodes$lev]
nodes$lab <- sub("([A-Z])([0-9])", "\\1[\\2]", nodes$id)   # plotmath subscripts

# Many-to-one links: G1, G2 -> P1; G3 -> P2; G4 -> P3; P1, P2 -> F1; P3 -> F2
links <- data.frame(from = c("G1", "G2", "G3", "G4", "P1", "P2", "P3"),
                    to   = c("P1", "P1", "P2", "P3", "F1", "F1", "F2"))
r <- 0.36
seg <- do.call(rbind, lapply(seq_len(nrow(links)), function(i) {
  a <- nodes[nodes$id == links$from[i], ]; b <- nodes[nodes$id == links$to[i], ]
  d <- c(b$x - a$x, b$y - a$y); d <- d / sqrt(sum(d^2))
  data.frame(x = a$x + d[1] * r * 1.2, y = a$y + d[2] * r * 1.2,
             xend = b$x - d[1] * r * 1.35, yend = b$y - d[2] * r * 1.35)
}))
levels_df <- data.frame(y = y_lev, lab = c("Genotype", "Phenotype", "Fitness"))

p <- ggplot() +
  geom_segment(data = seg, aes(x = x, y = y, xend = xend, yend = yend),
               colour = bb512$grey, linewidth = 0.9,
               arrow = arrow(length = unit(0.1, "in"), type = "closed")) +
  geom_point(data = nodes, aes(x, y, fill = fill), shape = 21, size = 21,
             colour = bb512$grid, stroke = 1) +
  geom_text(data = nodes, aes(x, y, label = lab, colour = tcol), parse = TRUE,
            size = 6.2, family = fam) +
  geom_text(data = levels_df, aes(x = 0.2, y = y, label = lab), hjust = 0,
            size = 5.4, colour = bb512$grey, family = fam) +
  scale_fill_identity() + scale_colour_identity() +
  coord_cartesian(xlim = c(0.1, 7.0), ylim = c(0.35, 5.65), expand = FALSE, clip = "off") +
  theme_void() +
  theme(plot.background = element_rect(fill = bb512$bg, colour = NA),
        plot.margin = margin(6, 6, 6, 6))

save_bb512(p, "02b_genotype_phenotype", layout = "half")
