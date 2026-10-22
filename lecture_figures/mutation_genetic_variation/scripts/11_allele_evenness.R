# Two populations, two alleles each, very different evenness and H_e.
source("R/theme_bb512.R")
pops <- data.frame(pop = c("Population A","Population A","Population B","Population B"),
                   allele = c("A","a","A","a"), f = c(0.5, 0.5, 0.97, 0.03))
pops$pop <- factor(pops$pop, c("Population B", "Population A"))
pops$allele <- factor(pops$allele, c("a","A"))
lab <- data.frame(pop = factor(c("Population A","Population B"), levels(pops$pop)),
                  txt = c("A: 0.50   a: 0.50", "A: 0.97   a: 0.03"),
                  he = c("H[e] == '0.50'", "H[e] == 0.058"))
p <- ggplot2::ggplot(pops, ggplot2::aes(f, pop, fill = allele)) +
  ggplot2::geom_col(width = 0.42, colour = bb512$bg, linewidth = 0.6) +
  ggplot2::geom_text(data = lab, ggplot2::aes(0, pop, label = txt), inherit.aes = FALSE,
                     nudge_y = -0.38, hjust = 0, size = 5, colour = bb512$ink, family = "Avenir Next") +
  ggplot2::geom_text(data = lab, ggplot2::aes(1.04, pop, label = he), inherit.aes = FALSE,
                     parse = TRUE, hjust = 0, size = 6, colour = bb512$forest, family = "Avenir Next") +
  ggplot2::scale_fill_manual(values = c(A = bb512$forest, a = bb512$clay), guide = "none") +
  ggplot2::scale_x_continuous(limits = c(0, 1.32), expand = c(0, 0)) +
  ggplot2::labs(x = NULL, y = NULL, caption = NULL) +
  ggplot2::annotate("text", x = 0.66, y = 0.5, label = "Both populations have exactly two alleles",
                    size = 4.6, colour = bb512$grey, family = "Avenir Next") +
  theme_bb512() +
  ggplot2::theme(axis.text.x = ggplot2::element_blank(), axis.line = ggplot2::element_blank(),
                 panel.grid.major.y = ggplot2::element_blank(),
                 axis.text.y = ggplot2::element_text(size = 18, face = "bold", colour = bb512$forest))
save_bb512(p, "11_allele_evenness", layout = "fullbox")
