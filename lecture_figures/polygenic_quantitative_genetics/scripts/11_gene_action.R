# Slide "Genetic variance has parts": Neal's (2004) hypothetical two-locus series, drawn as wheat kernels.
# Analytical/illustrative (Neal, section "Partitioning the components of genetic variation").
# Same idea as Nilsson-Ehle's wheat, cut to two loci: capital letters are red alleles.
#   Additive:               each red allele adds 1                       -> 0 1 2 3 4
#   Dominance:              red is dominant at EACH locus (A over a, B over b): one red allele = two -> 0 2 2 4 4
#   Epistasis only:         score = (number of A) x (number of B); heterozygotes exactly intermediate
#                           at each locus (no dominance), but the effect of A depends on B  -> 0 0 0 2 4
#                           (added for BB512; not in Neal; additive-by-additive epistasis)
#   Dominance + epistasis:  as dominance, and A only has an effect if a B is present      -> 0 0 0 4 4
# A key (capitals = red, lower case = white) sits top left, above the row labels.
# Kernel colours use the same white-to-dark-red ramp as the wheat figure (01_wheat_f2.R), on a 0-4 scale.
source("R/theme_bb512.R")
fam <- "Avenir Next"

geno  <- c("aabb", "Aabb", "AAbb", "AABb", "AABB")
nred  <- 0:4
rules <- data.frame(
  row   = 4:1,
  name  = c("Additive", "Dominance", "Epistasis only", "Dominance + epistasis"),
  rule  = c("each red allele adds 1", "one red allele per gene\ndoes as much as two",
            "effect of A depends on how\nmany B; no dominance", "dominance, and A only\nworks if a B is present"),
  stringsAsFactors = FALSE)
score <- list(c(0, 1, 2, 3, 4), c(0, 2, 2, 4, 4), c(0, 0, 0, 2, 4), c(0, 0, 0, 4, 4))

# check the rules reproduce Neal's scores
nA <- c(0, 1, 2, 2, 2); nB <- c(0, 0, 0, 1, 2)
stopifnot(identical(nA + nB, score[[1]]),
          identical(2 * (nA > 0) + 2 * (nB > 0), score[[2]]),
          identical(nA * nB, score[[3]]),
          identical(ifelse(nB > 0, 2 * (nA > 0) + 2 * (nB > 0), 0), score[[4]]))

ramp <- grDevices::colorRampPalette(c(bb512$pale, "#D9B79B", bb512$clay, "#5E2A1F"))(5)
k <- do.call(rbind, lapply(1:4, function(i)
  data.frame(row = rules$row[i], col = 1:5, score = score[[i]])))
k$fill <- ramp[k$score + 1]
k$txt  <- ifelse(k$score >= 3, "white", bb512$ink)

hdr <- data.frame(col = 1:5, geno = geno, nred = paste(nred, "red"))
# key, top left: students found the caption-only key easy to miss
key <- data.frame(y = c(4.78, 4.5),
                  lab = c("A, B = red alleles", "a, b = white alleles"),
                  col = c(bb512$clay, bb512$grey), face = c("bold", "plain"))

p <- ggplot2::ggplot(k) +
  ggplot2::geom_point(ggplot2::aes(col, row, fill = I(fill)), shape = 21, size = 17,
                      colour = bb512$grey, stroke = 0.5) +
  ggplot2::geom_text(ggplot2::aes(col, row, label = score, colour = I(txt)), family = fam,
                     size = 6.5, fontface = "bold") +
  ggplot2::geom_text(data = hdr, ggplot2::aes(col, 4.78, label = geno), family = fam, size = 6.5,
                     fontface = "bold", colour = bb512$forest) +
  ggplot2::geom_text(data = hdr, ggplot2::aes(col, 4.5, label = nred), family = fam, size = 4.8,
                     colour = bb512$grey) +
  ggplot2::geom_text(data = key, ggplot2::aes(-1.6, y, label = lab, colour = I(col), fontface = face),
                     family = fam, size = 5.2, hjust = 0) +
  ggplot2::geom_text(data = rules, ggplot2::aes(-1.6, row + 0.13, label = name), family = fam, size = 6,
                     fontface = "bold", colour = bb512$ink, hjust = 0) +
  ggplot2::geom_text(data = rules, ggplot2::aes(-1.6, row - 0.08, label = rule), family = fam, size = 4.6,
                     colour = bb512$grey, hjust = 0, vjust = 1, lineheight = 0.9) +
  ggplot2::scale_x_continuous(limits = c(-1.7, 5.5), expand = c(0, 0)) +
  ggplot2::scale_y_continuous(limits = c(0.55, 4.95), expand = c(0, 0)) +
  ggplot2::coord_cartesian(clip = "off") +
  theme_bb512() +
  ggplot2::theme(axis.text = ggplot2::element_blank(), axis.title = ggplot2::element_blank(),
                 axis.line = ggplot2::element_blank(), panel.grid.major.y = ggplot2::element_blank(),
                 plot.margin = ggplot2::margin(6, 10, 6, 10))
dir.create("figures", showWarnings = FALSE)
ggplot2::ggsave("figures/11_gene_action.png", p, device = ragg::agg_png, width = 9.6, height = 4.1,
                units = "in", dpi = 300, bg = bb512$bg)
