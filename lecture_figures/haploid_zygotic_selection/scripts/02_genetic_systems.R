# Slide "Four genetic systems": schematic 2 x 2 grid (ploidy x reproduction) with example organisms.
# Schematic only. Examples follow Neal (2004) section 10.2 and standard life-cycle descriptions.
source("R/theme_bb512.R")
fam <- "Avenir Next"
cells <- data.frame(
  x = c(1, 2, 1, 2), y = c(2, 2, 1, 1),
  head = c("Haploid, asexual", "Diploid, asexual", "Haploid, sexual", "Diploid, sexual"),
  ex = c("",
         "",
         "Most fungi, many algae,\nmosses (haploid phase dominant)",
         "Most animals, flowering plants,\nconifers, ferns"),
  fill = c(bb512$pale, bb512$pale, bb512$pale, bb512$pale))
model <- data.frame(x = c(1, 2, 1, 2), y = c(2, 2, 1, 1) - 0.30,
  txt = c("Haploid selection model", "Haploid (clonal) model", "Haploid model in the haploid phase",
          "Zygotic selection model"),
  col = c(bb512$forest, bb512$forest, bb512$forest, bb512$clay))
p <- ggplot2::ggplot() +
  ggplot2::geom_tile(data = cells, ggplot2::aes(x, y), width = 0.96, height = 0.92,
                     fill = bb512$pale, colour = NA) +
  ggplot2::geom_text(data = cells, ggplot2::aes(x, y + 0.28, label = head), family = fam,
                     fontface = "bold", size = 6.2, colour = bb512$ink) +
  ggplot2::geom_text(data = cells, ggplot2::aes(x, y + 0.02, label = ex), family = fam,
                     size = 5.2, colour = bb512$ink, lineheight = 0.95) +
  ggplot2::annotate("text", x = 1, y = 2.02, label = "'Bacteria, e.g.'~italic('Mycobacterium tuberculosis')",
                    parse = TRUE, family = fam, size = 5.2, colour = bb512$ink) +
  ggplot2::annotate("text", x = 2, y = 2.02, parse = TRUE, family = fam, size = 5.2, colour = bb512$ink,
                    label = "'Aphids and water fleas ('*italic('Daphnia')*') in their'") +
  ggplot2::annotate("text", x = 2, y = 1.90, family = fam, size = 5.2, colour = bb512$ink,
                    label = "asexual phases") +
  ggplot2::geom_text(data = model, ggplot2::aes(x, y, label = txt, colour = col), family = fam,
                     size = 5, fontface = "bold") +
  ggplot2::scale_colour_identity() +
  ggplot2::annotate("text", x = 0.4, y = 2, label = "Asexual", angle = 90, family = fam,
                    size = 5.6, fontface = "bold", colour = bb512$grey) +
  ggplot2::annotate("text", x = 0.4, y = 1, label = "Sexual", angle = 90, family = fam,
                    size = 5.6, fontface = "bold", colour = bb512$grey) +
  ggplot2::coord_cartesian(xlim = c(0.3, 2.5), ylim = c(0.52, 2.48), expand = FALSE) +
  ggplot2::theme_void() +
  ggplot2::theme(plot.background = ggplot2::element_rect(fill = bb512$bg, colour = NA))
save_bb512(p, "02_genetic_systems", layout = "full")
