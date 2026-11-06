# Slide "Ploidy and sex decide the model": schematic 2 x 2 grid
# (columns: ploidy; rows: reproduction) with example organisms and the model that applies.
# The axis subtitles carry the logic: ploidy makes dominance possible, sex makes it matter.
# Three boxes share one colour (haploid model); only the diploid sexual box (zygotic model) differs.
# Schematic only. Examples follow Neal (2004) section 10.2 and standard life-cycle descriptions.
# Diploid asexual examples restricted to aphids and Daphnia (diploid parthenogenetic phases);
# apomictic dandelions and many parthenogenetic lizards are triploid, and bdelloid ploidy is disputed.
source("R/theme_bb512.R")
fam <- "Avenir Next"

cells <- data.frame(x = c(1, 2, 1, 2), y = c(2, 2, 1, 1),
                    fill = c(bb512$pale, bb512$pale, bb512$pale, bb512$clay))
ex_y  <- 0.10    # vertical offset of the example text within each box
mod_y <- -0.22   # vertical offset of the model label within each box
model <- data.frame(x = c(1, 2, 1, 2), y = c(2, 2, 1, 1) + mod_y,
                    txt = c("Haploid model", "Haploid model", "Haploid model", "Zygotic model"),
                    col = c(bb512$forest, bb512$forest, bb512$forest, "white"))

head_lab <- function(x, y, txt) ggplot2::annotate("text", x = x, y = y, label = txt, family = fam,
                                                  size = 6.4, fontface = "bold", colour = bb512$ink)
sub_lab  <- function(x, y, txt, hjust = 0.5) ggplot2::annotate("text", x = x, y = y, label = txt,
                                                  family = fam, size = 4.8, fontface = "italic",
                                                  colour = bb512$grey, hjust = hjust, lineheight = 0.95)
ex_lab   <- function(x, y, txt, col = bb512$ink, parse = FALSE) ggplot2::annotate("text", x = x, y = y,
                                                  label = txt, parse = parse, family = fam, size = 5.4,
                                                  colour = col, lineheight = 0.95)

p <- ggplot2::ggplot() +
  ggplot2::geom_tile(data = cells, ggplot2::aes(x, y, fill = fill), width = 0.96, height = 0.86,
                     colour = NA) +
  ggplot2::scale_fill_identity() +
  # Examples (plotmath where a name needs italics)
  ex_lab(1, 2 + ex_y, "'Bacteria, e.g.'~italic('Mycobacterium tuberculosis')", parse = TRUE) +
  ex_lab(2, 2 + ex_y + 0.07, "'Aphids, water fleas ('*italic('Daphnia')*')'", parse = TRUE) +
  ex_lab(2, 2 + ex_y - 0.07, "in their asexual phases") +
  ex_lab(1, 1 + ex_y, "Most fungi, many algae,\nmosses") +
  ex_lab(2, 1 + ex_y, "Most animals and plants", col = "white") +
  ggplot2::geom_text(data = model, ggplot2::aes(x, y, label = txt, colour = col), family = fam,
                     size = 5.8, fontface = "bold") +
  ggplot2::scale_colour_identity() +
  # Column headers: ploidy
  head_lab(1, 2.66, "Haploid") + sub_lab(1, 2.53, "no dominance possible") +
  head_lab(2, 2.66, "Diploid") + sub_lab(2, 2.53, "dominance possible") +
  # Row headers: reproduction (left-aligned, horizontal for readability)
  ggplot2::annotate("text", x = 0.02, y = 2.08, label = "Asexual", hjust = 0, family = fam,
                    size = 6.4, fontface = "bold", colour = bb512$ink) +
  sub_lab(0.02, 1.92, "genotype passed\non intact", hjust = 0) +
  ggplot2::annotate("text", x = 0.02, y = 1.08, label = "Sexual", hjust = 0, family = fam,
                    size = 6.4, fontface = "bold", colour = bb512$ink) +
  sub_lab(0.02, 0.92, "genotypes rebuilt\neach generation", hjust = 0) +
  ggplot2::coord_cartesian(xlim = c(0, 2.5), ylim = c(0.54, 2.76), expand = FALSE) +
  ggplot2::theme_void() +
  ggplot2::theme(plot.background = ggplot2::element_rect(fill = bb512$bg, colour = NA))
save_bb512(p, "02_genetic_systems", layout = "full")
