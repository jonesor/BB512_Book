# Slide "Where does selection act?": schematic life cycles.
# Three panels: asexual (clonal copying), sexual with a dominant haploid phase
# (meiosis in the zygote), sexual with a dominant diploid phase (meiosis in the gonads).
# Schematic only; stage sizes and timing are not to scale.
# Panel titles are kept short ("Sexual: mostly haploid/diploid") so they fit the
# panel width in Avenir Next; the longer "...phase dominant" wording clipped.
source("R/theme_bb512.R")
fam <- "Avenir Next"

node <- function(panel, x, y, label, ploidy) data.frame(panel, x, y, label, ploidy)
nodes <- rbind(
  node("Asexual", 0.5, 0.80, "Parent", "n or 2n"),
  node("Asexual", 0.5, 0.20, "Offspring\n(copies)", "n or 2n"),
  node("Sexual: mostly haploid", 0.50, 0.82, "Adults (n)", "n"),
  node("Sexual: mostly haploid", 0.86, 0.20, "Zygote (2n)", "2n"),
  node("Sexual: mostly haploid", 0.14, 0.20, "Gametes (n)", "n"),
  node("Sexual: mostly diploid", 0.50, 0.82, "Adults (2n)", "2n"),
  node("Sexual: mostly diploid", 0.86, 0.20, "Gametes (n)", "n"),
  node("Sexual: mostly diploid", 0.14, 0.20, "Zygote (2n)", "2n"))
nodes$panel <- factor(nodes$panel, levels = unique(nodes$panel))

arrow <- function(panel, x, y, xend, yend, label, lx, ly, curv = -0.25)
  data.frame(panel, x, y, xend, yend, label, lx, ly, curv)
arrows <- rbind(
  arrow("Asexual", 0.62, 0.66, 0.62, 0.34, "Mitosis", 0.80, 0.50, -0.3),
  arrow("Asexual", 0.38, 0.34, 0.38, 0.66, "Growth", 0.20, 0.50, -0.3),
  arrow("Sexual: mostly haploid", 0.66, 0.78, 0.92, 0.32, "", 0, 0),
  arrow("Sexual: mostly haploid", 0.70, 0.12, 0.30, 0.12, "Fertilisation", 0.50, 0.03),
  arrow("Sexual: mostly haploid", 0.08, 0.32, 0.34, 0.78, "", 0, 0),
  arrow("Sexual: mostly diploid", 0.66, 0.78, 0.92, 0.32, "Meiosis", 1.04, 0.62),
  arrow("Sexual: mostly diploid", 0.70, 0.12, 0.30, 0.12, "Fertilisation", 0.50, 0.03),
  arrow("Sexual: mostly diploid", 0.08, 0.32, 0.34, 0.78, "Growth", -0.02, 0.62))
arrows$panel <- factor(arrows$panel, levels = levels(nodes$panel))
# Haploid-dominant cycle: zygote undergoes meiosis immediately to give haploid adults;
# adults produce gametes by mitosis. Draw zygote -> adults (meiosis) as a separate arrow.
fix <- arrows$panel == "Sexual: mostly haploid"
arrows[fix, ][1, ] <- arrow("Sexual: mostly haploid", 0.92, 0.32, 0.66, 0.78, "Meiosis", 1.04, 0.62, 0.25)
arrows[fix, ][3, ] <- arrow("Sexual: mostly haploid", 0.34, 0.78, 0.08, 0.32, "Gamete\nproduction", -0.07, 0.62, 0.25)
arrows[fix, ][2, ] <- arrow("Sexual: mostly haploid", 0.30, 0.12, 0.70, 0.12, "Fertilisation", 0.50, 0.03, 0.25)

sel <- data.frame(panel = factor(c("Asexual", "Sexual: mostly haploid", "Sexual: mostly diploid"),
                                 levels = levels(nodes$panel)),
                  x = 0.5, y = c(1.02, 1.02, 1.02),
                  label = c("Selection on clones", "Selection on haploid adults", "Zygotic selection: zygote to adult"))

cols <- c("n" = bb512$blue, "2n" = bb512$forest, "n or 2n" = bb512$grey)
p <- ggplot2::ggplot() +
  ggplot2::geom_curve(data = arrows[arrows$curv < 0, ], ggplot2::aes(x, y, xend = xend, yend = yend),
                      curvature = -0.25, linewidth = 0.9, colour = bb512$grey,
                      arrow = grid::arrow(length = grid::unit(0.12, "in"), type = "closed")) +
  ggplot2::geom_curve(data = arrows[arrows$curv > 0, ], ggplot2::aes(x, y, xend = xend, yend = yend),
                      curvature = 0.25, linewidth = 0.9, colour = bb512$grey,
                      arrow = grid::arrow(length = grid::unit(0.12, "in"), type = "closed")) +
  ggplot2::geom_text(data = arrows[arrows$label != "", ], ggplot2::aes(lx, ly, label = label),
                     family = fam, size = 4.9, colour = bb512$grey, lineheight = 0.9) +
  ggplot2::geom_label(data = nodes, ggplot2::aes(x, y, label = label, fill = ploidy),
                      family = fam, size = 5.2, colour = "white", fontface = "bold",
                      linewidth = 0, label.r = grid::unit(0.15, "lines"),
                      label.padding = grid::unit(0.45, "lines"), lineheight = 0.9) +
  ggplot2::geom_text(data = sel, ggplot2::aes(x, y, label = label), family = fam,
                     size = 5, fontface = "bold", colour = bb512$clay) +
  ggplot2::scale_fill_manual(values = cols, guide = "none") +
  ggplot2::facet_wrap(~panel, nrow = 1) +
  ggplot2::coord_cartesian(xlim = c(-0.12, 1.14), ylim = c(-0.02, 1.08), clip = "off") +
  ggplot2::theme_void(base_family = fam) +
  ggplot2::theme(plot.background = ggplot2::element_rect(fill = bb512$bg, colour = NA),
                 strip.clip = "off",
                 strip.text = ggplot2::element_text(size = 17, face = "bold", colour = bb512$forest,
                                                    margin = ggplot2::margin(b = 8)),
                 panel.spacing = grid::unit(0.5, "in"),
                 plot.margin = ggplot2::margin(10, 20, 10, 20))
save_bb512(p, "03_life_cycles", layout = "full")
