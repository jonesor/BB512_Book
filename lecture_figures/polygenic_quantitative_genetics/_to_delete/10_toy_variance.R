# Slide "Worked example: partitioning the variance": toy data, small enough to calculate by hand.
# ILLUSTRATIVE values (not East's data), chosen so the arithmetic is simple:
#   P1, P2 and F1 are genetically uniform, so their variances estimate V_E;
#   V_E = (2.5 + 4.0 + 5.5) / 3 = 4.0. The F2 variance is V_P = 40.0, so V_G = 36.0 (90%).
# Sample variances (n - 1 denominator), as returned by var() in R.
source("R/theme_bb512.R")
fam <- "Avenir Next"

d <- rbind(
  data.frame(group = "P1",  x = c(38, 39, 40, 41, 42)),
  data.frame(group = "P2",  x = c(91, 91, 93, 95, 95)),
  data.frame(group = "F1",  x = c(62, 62, 63, 66, 67)),
  data.frame(group = "F2",  x = c(57, 58, 61, 63, 65, 67, 69, 71, 74, 75))
)
rows <- c("P1", "P2", "F1", "F2")
d$row <- match(d$group, rev(rows))
# stack tied values so every plant is visible
d$k <- ave(d$x, d$group, d$x, FUN = seq_along) - 1
d$y <- d$row + 0.2 * d$k
d$uniform <- d$group != "F2"

v <- aggregate(x ~ group, d, var)
v$row <- match(v$group, rev(rows))
v$lab <- ifelse(v$group == "F2",
                sprintf('s^2 == "%.1f" ~ "" %%->%% "" ~ V[P]', v$x),
                sprintf('s^2 == "%.1f"', v$x))
v$lab[v$group == "F1"] <- sprintf('s^2 == "%.1f"', v$x[v$group == "F1"])
stopifnot(isTRUE(all.equal(mean(v$x[v$group != "F2"]), 4)), isTRUE(all.equal(v$x[v$group == "F2"], 40)))

p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) +
  ggplot2::geom_point(ggplot2::aes(fill = uniform), shape = 21, size = 3.6, stroke = 0.9, colour = bb512$bg) +
  ggplot2::scale_fill_manual(values = c(`TRUE` = bb512$sage, `FALSE` = bb512$forest), guide = "none") +
  ggplot2::geom_text(data = v, ggplot2::aes(x = 101, y = row, label = lab), parse = TRUE,
                     hjust = 0, family = fam, size = 5.4, colour = bb512$ink) +
  ggplot2::annotate("text", x = 101, y = 4.55, label = "Variance", hjust = 0, family = fam,
                    size = 5, fontface = "bold", colour = bb512$grey) +
  ggplot2::scale_y_continuous(breaks = 1:4, labels = rev(rows), limits = c(0.7, 4.7)) +
  ggplot2::scale_x_continuous(limits = c(35, 125), breaks = seq(40, 100, 10)) +
  ggplot2::coord_cartesian(clip = "off") +
  ggplot2::labs(x = "Corolla length (mm)", y = NULL) +
  theme_bb512() +
  ggplot2::theme(panel.grid.major.y = ggplot2::element_line(colour = bb512$grid, linewidth = 0.5),
                 axis.line = ggplot2::element_blank(),
                 axis.text.y = ggplot2::element_text(size = 17, face = "bold", colour = bb512$ink))
save_bb512(p, "10_toy_variance", layout = "takeaway")
