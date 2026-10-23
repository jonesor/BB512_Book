# Slide "Four patterns of reaction norms": schematic reaction norms for two genotypes.
# Schematic (redrawn from the previous version of the lecture, slides 25-27). Straight lines for
# simplicity; real reaction norms are often curved and have limits.
source("R/theme_bb512.R")
fam <- "Avenir Next"

panels <- c("Plastic,\nno genetic variation", "Genetic variation,\nnot plastic",
            "Both, no G×E\n(parallel lines)", "G×E\n(different slopes)")
e <- c(0, 1)
spec <- list(c(0.2, 0.6, 0.2, 0.6),  # intercept, slope for genotype 1 then genotype 2
             c(0.75, 0, 0.35, 0),
             c(0.5, 0.4, 0.15, 0.4),
             c(0.15, 0.75, 0.45, 0.05))
d <- do.call(rbind, lapply(seq_along(panels), function(i) {
  s <- spec[[i]]
  rbind(data.frame(panel = panels[i], g = "Genotype 1", e = e, y = s[1] + s[2] * e),
        data.frame(panel = panels[i], g = "Genotype 2", e = e, y = s[3] + s[4] * e))
}))
d$panel <- factor(d$panel, panels)
# In panel 1 the genotypes are identical: offset genotype 2 slightly so both lines are visible
d$y[d$panel == panels[1] & d$g == "Genotype 2"] <- d$y[d$panel == panels[1] & d$g == "Genotype 2"] - 0.025
labs <- subset(d, e == 1 & panel == panels[3])

p <- ggplot2::ggplot(d, ggplot2::aes(e, y, colour = g)) +
  ggplot2::geom_line(linewidth = 1.5) +
  ggplot2::geom_text(data = labs, ggplot2::aes(label = g), hjust = 1, vjust = -0.8, family = fam, size = 4.9) +
  ggplot2::facet_wrap(~panel, nrow = 1) +
  ggplot2::scale_colour_manual(values = c("Genotype 1" = bb512$forest, "Genotype 2" = bb512$clay), guide = "none") +
  ggplot2::scale_x_continuous(limits = c(-0.05, 1.05), breaks = NULL) +
  ggplot2::scale_y_continuous(limits = c(0, 1.05), breaks = NULL) +
  ggplot2::labs(x = "Environment (e.g. temperature)", y = "Trait value") +
  theme_bb512() +
  ggplot2::theme(panel.grid.major.y = ggplot2::element_blank(), panel.spacing = grid::unit(0.35, "in"),
                 strip.text = ggplot2::element_text(lineheight = 0.9, vjust = 0, size = 16))
save_bb512(p, "07_reaction_norms", layout = "full")
