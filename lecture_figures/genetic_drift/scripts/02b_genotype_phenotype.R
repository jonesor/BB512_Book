# Slide 7: "Different genotypes can give the same phenotype" (Figure & Bullets, "half")
# Schematic, not data. One locus with complete dominance: AA and Aa both give the dark
# phenotype, aa gives the pale one. Fitness depends on phenotype, so selection cannot
# tell AA from Aa: changes in their relative frequencies are left to drift.
# Fitness values (1 and 0.8) are illustrative.
# R version of the diagram previously pasted into the deck.
source("R/theme_bb512.R"); library(ggplot2)
fam <- .bb512_font

box <- function(x, y, lab, fill, tcol, w = 1.3, h = 0.72) {
  data.frame(x = x, y = y, lab = lab, fill = fill, tcol = tcol,
             xmin = x - w / 2, xmax = x + w / 2, ymin = y - h / 2, ymax = y + h / 2)
}
y_g <- 1; y_p <- 3; y_w <- 5
boxes <- rbind(
  box(c(3.1, 5.0, 6.9), y_g, c("AA", "Aa", "aa"), bb512$pale, bb512$ink),
  box(c(4.05, 6.9), y_p, c("Dark", "Pale"), c(bb512$forest, bb512$sage),
      c(bb512$bg, bb512$ink), w = 1.7),
  box(c(4.05, 6.9), y_w, c("W == 1", "W == 0.8"), bb512$bg, bb512$ink, w = 1.7)
)
boxes$parse <- grepl("==", boxes$lab)

h2 <- 0.36 + 0.08
arrows <- rbind(
  data.frame(x = c(3.1, 5.0, 6.9), y = y_g + h2, xend = c(3.75, 4.35, 6.9), yend = y_p - h2),
  data.frame(x = c(4.05, 6.9), y = y_p + h2, xend = c(4.05, 6.9), yend = y_w - h2)
)
levels_df <- data.frame(y = c(y_g, y_p, y_w), lab = c("Genotype", "Phenotype", "Fitness"))

p <- ggplot() +
  geom_segment(data = arrows, aes(x = x, y = y, xend = xend, yend = yend),
               colour = bb512$grey, linewidth = 0.9,
               arrow = arrow(length = unit(0.1, "in"), type = "closed")) +
  geom_rect(data = boxes, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = fill),
            colour = bb512$grid, linewidth = 0.8) +
  geom_text(data = subset(boxes, !parse), aes(x, y, label = lab, colour = tcol),
            size = 6, fontface = "bold", family = fam) +
  geom_text(data = subset(boxes, parse), aes(x, y, label = lab, colour = tcol),
            size = 6, family = fam, parse = TRUE) +
  geom_text(data = levels_df, aes(x = 0.2, y = y, label = lab), hjust = 0,
            size = 5.4, colour = bb512$grey, family = fam) +
  scale_fill_identity() + scale_colour_identity() +
  coord_cartesian(xlim = c(0.1, 7.85), ylim = c(0.4, 5.6), expand = FALSE, clip = "off") +
  theme_void() +
  theme(plot.background = element_rect(fill = bb512$bg, colour = NA),
        plot.margin = margin(6, 6, 6, 6))

save_bb512(p, "02b_genotype_phenotype", layout = "half")
