# Slide "With G×E, heritability depends on the environment": crossing reaction norms.
# Schematic (redrawn from the previous version of the lecture, slide 29). Two genotypes at equal
# frequency; within each environment the genetic variance is the variance of the two genotype means,
# V_G = (difference / 2)^2. Environmental variance (scatter around each line) is not drawn and is assumed
# the same everywhere, so h² is highest where the lines are furthest apart and zero where they cross.
source("R/theme_bb512.R")
fam <- "Avenir Next"

g1 <- function(e) 0.20 + 0.70 * e
g2 <- function(e) 0.55 - 0.15 * e
envs <- data.frame(name = c("A", "B", "C"), e = c(0.05, 0.35 / 0.85, 0.95))
envs$y1 <- g1(envs$e); envs$y2 <- g2(envs$e)
envs$vg <- ((envs$y1 - envs$y2) / 2)^2
envs$lab <- c("V[G]~moderate", "V[G] == 0", "V[G]~high")
ln <- data.frame(e = rep(c(0, 1), 2), y = c(g1(c(0, 1)), g2(c(0, 1))), g = rep(c("Genotype 1", "Genotype 2"), each = 2))

p <- ggplot2::ggplot() +
  ggplot2::geom_segment(data = envs, ggplot2::aes(x = e, xend = e, y = pmin(y1, y2) - 0.06, yend = pmax(y1, y2) + 0.06),
                        colour = bb512$gold, linewidth = 6, alpha = 0.35, lineend = "round") +
  ggplot2::geom_line(data = ln, ggplot2::aes(e, y, colour = g), linewidth = 1.5) +
  ggplot2::geom_point(data = envs, ggplot2::aes(e, y1), colour = bb512$forest, size = 3.5) +
  ggplot2::geom_point(data = envs, ggplot2::aes(e, y2), colour = bb512$clay, size = 3.5) +
  ggplot2::geom_text(data = envs, ggplot2::aes(e, 0.02, label = lab), parse = TRUE, family = fam, size = 5.2,
                     colour = bb512$ink) +
  ggplot2::annotate("text", x = 0.68, y = g1(0.68) + 0.04, label = "Genotype 1", hjust = 1, family = fam, size = 5, colour = bb512$forest) +
  ggplot2::annotate("text", x = 0.52, y = g2(0.52) - 0.05, label = "Genotype 2", hjust = 0, family = fam, size = 5, colour = bb512$clay) +
  ggplot2::scale_colour_manual(values = c("Genotype 1" = bb512$forest, "Genotype 2" = bb512$clay), guide = "none") +
  ggplot2::scale_x_continuous(breaks = envs$e, labels = paste("Environment", envs$name), limits = c(-0.08, 1.08)) +
  ggplot2::scale_y_continuous(limits = c(-0.02, 1), breaks = NULL) +
  ggplot2::labs(x = NULL, y = "Trait value") +
  theme_bb512() +
  ggplot2::theme(panel.grid.major.y = ggplot2::element_blank(),
                 axis.text.x = ggplot2::element_text(size = 16, colour = bb512$ink))
save_bb512(p, "08_gxe_heritability", layout = "takeaway")
