# Slide "Natural selection is a logical argument" (layout "full").
# Schematic of Darwin's argument as five facts and three inferences, following Neal (2004) section 2.1.2
# (after Mayr 1982). No data.
source("R/theme_bb512.R")
fam <- Sys.getenv("BB512_FONT", "Avenir Next")

bw <- 3.75; bh <- 0.52
facts <- data.frame(x = 0, y = c(4.25, 3.6, 2.95, 1.95, 0.8),
                    lab = c("3  Overproduction of offspring", "4  Resources are limited",
                            "5  Population sizes stay fairly stable",
                            "1  Individuals vary", "2  Much variation is heritable"))
inf <- data.frame(x = c(5.6, 8.65, 8.65), y = c(3.6, 1.95, 0.8),
                  w = c(2.6, 3.0, 3.0), h = c(0.95, 0.8, 0.8),
                  lab = c("Struggle for\nexistence", "Natural selection:\nsurvival is not random",
                          "Evolution: favoured\nvariants accumulate"),
                  fill = c(bb512$forest, bb512$forest, bb512$clay))
fa <- data.frame(x = bw, y = c(4.25, 3.6, 2.95, 1.95, 0.8),
                 xend = c(5.6 - 1.3, 5.6 - 1.3, 5.6 - 1.3, 8.65 - 1.5, 8.65 - 1.5),
                 yend = c(3.85, 3.6, 3.35, 1.95, 0.8))
ia <- data.frame(x = c(5.6 + 1.3, 8.65), y = c(3.6, 1.55), xend = c(8.65, 8.65), yend = c(2.35, 1.2))

arr <- grid::arrow(length = grid::unit(0.11, "in"), type = "closed")
p <- ggplot2::ggplot() +
  ggplot2::geom_segment(data = fa, ggplot2::aes(x, y, xend = xend, yend = yend),
                        colour = bb512$grey, linewidth = 0.7, arrow = arr) +
  ggplot2::geom_segment(data = ia[1, ], ggplot2::aes(x, y, xend = xend, yend = yend),
                        colour = bb512$ink, linewidth = 0.9, arrow = arr) +
  ggplot2::geom_segment(data = ia[2, ], ggplot2::aes(x, y, xend = xend, yend = yend),
                        colour = bb512$ink, linewidth = 0.9, arrow = arr) +
  ggplot2::geom_rect(data = facts, ggplot2::aes(xmin = x, xmax = x + bw, ymin = y - bh / 2, ymax = y + bh / 2),
                     fill = bb512$pale, colour = NA) +
  ggplot2::geom_text(data = facts, ggplot2::aes(x + 0.15, y, label = lab), hjust = 0, family = fam,
                     size = 5, colour = bb512$ink) +
  ggplot2::geom_rect(data = inf, ggplot2::aes(xmin = x - w / 2, xmax = x + w / 2, ymin = y - h / 2, ymax = y + h / 2,
                                              fill = fill), colour = NA) +
  ggplot2::scale_fill_identity() +
  ggplot2::geom_text(data = inf, ggplot2::aes(x, y, label = lab), family = fam, size = 5.1,
                     colour = "white", fontface = "bold", lineheight = 0.88) +
  ggplot2::annotate("text", x = 0, y = 4.85, label = "FACTS (observed)", hjust = 0, family = fam,
                    size = 4.9, colour = bb512$clay, fontface = "bold") +
  ggplot2::annotate("text", x = 4.3, y = 4.85, label = "INFERENCES (deduced)", hjust = 0, family = fam,
                    size = 4.9, colour = bb512$clay, fontface = "bold") +
  ggplot2::coord_cartesian(xlim = c(0, 10.25), ylim = c(0.35, 5.05), expand = FALSE) +
  theme_bb512(base_family = fam) +
  ggplot2::theme(axis.text = ggplot2::element_blank(), axis.title = ggplot2::element_blank(),
                 axis.line = ggplot2::element_blank(), panel.grid.major.y = ggplot2::element_blank(),
                 plot.margin = ggplot2::margin(4, 4, 4, 4))
save_bb512(p, "03_facts_inferences", layout = "full")
