# Slide "Count over the whole life, not one season": why birds may lay fewer eggs than the number that
# fledges most young this season (Neal 2004, "Number of offspring", optimal brood size figure).
# SCHEMATIC, illustrative functions:
#   chick survival      s_c(n) = 0.9 / (1 + exp(1.2 (n - 8)))   (falls as broods get larger)
#   young per season    Y(n)   = n s_c(n)
#   adult annual survival S(n) = 0.85 - 0.08 n                    (cost of reproduction to parents)
#   expected breeding seasons  = 1 / (1 - S(n))
#   lifetime young      L(n)   = Y(n) / (1 - S(n))
# Peaks: 6 eggs for one season, 5 eggs over the lifetime.
# Both curves are scaled to a maximum of 1 so that their peaks can be compared.
source("R/theme_bb512.R")
fam <- "Avenir Next"

n <- 1:10
sc <- 0.9 / (1 + exp(1.2 * (n - 8)))
Y <- n * sc
S <- 0.85 - 0.08 * n
L <- Y / (1 - S)
d <- rbind(data.frame(n = n, y = Y / max(Y), what = "This season only"),
           data.frame(n = n, y = L / max(L), what = "Whole lifetime"))
pk <- data.frame(what = c("This season only", "Whole lifetime"),
                 n = c(n[which.max(Y)], n[which.max(L)]))
cols <- c("This season only" = bb512$sage, "Whole lifetime" = bb512$forest)
message("Peaks: season ", pk$n[1], ", lifetime ", pk$n[2])

p <- ggplot2::ggplot(d, ggplot2::aes(n, y, colour = what)) +
  ggplot2::geom_vline(data = pk, ggplot2::aes(xintercept = n, colour = what), linetype = "dashed",
                      linewidth = 0.8) +
  ggplot2::geom_line(linewidth = 1.4) +
  ggplot2::geom_point(size = 3.2) +
  ggplot2::annotate("text", x = pk$n[1] + 0.25, y = 1.08, label = "Lack's optimum", hjust = 0,
                    family = fam, size = 5, colour = bb512$grey, fontface = "bold") +
  ggplot2::annotate("text", x = pk$n[2] - 0.25, y = 1.08, label = "Lifetime optimum", hjust = 1,
                    family = fam, size = 5, colour = bb512$forest, fontface = "bold") +
  ggplot2::annotate("text", x = 8.2, y = 0.88, label = "Young raised\nthis season", family = fam,
                    size = 5, colour = bb512$grey, lineheight = 0.95, hjust = 0) +
  ggplot2::annotate("text", x = 2.0, y = 0.12, label = "Young raised over\nthe whole lifetime",
                    family = fam, size = 5, colour = bb512$forest, lineheight = 0.95, hjust = 0) +
  ggplot2::scale_colour_manual(values = cols, guide = "none") +
  ggplot2::scale_x_continuous("Clutch size (eggs)", breaks = 1:10) +
  ggplot2::scale_y_continuous("Young raised (scaled)", limits = c(0, 1.14),
                              breaks = seq(0, 1, 0.25)) +
  theme_bb512(base_family = fam)

save_bb512(p, "05_lifetime_clutch", layout = "takeaway")
