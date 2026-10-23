# Slide "Predicting the response: sheep body weight": breeder's equation R = h² S, worked example.
# Analytical, illustrative values (kept from the previous version of the lecture):
# parental mean 100 kg, mean of the selected parents 125 kg, h² = 0.5, so S = 25 kg, R = 12.5 kg.
# Assumptions for the drawing: weight ~ Normal(100, sd 15) in the parents; truncation selection, with the
# truncation point solved so that the mean of the selected tail is exactly 125 kg; offspring drawn with the
# same SD (in reality selection changes the variance a little).
source("R/theme_bb512.R")
fam <- "Avenir Next"

mu <- 100; sdv <- 15; ys <- 125; h2 <- 0.5
S <- ys - mu; R <- h2 * S
tail_mean <- function(z) mu + sdv * dnorm(z) / (1 - pnorm(z))
z <- uniroot(function(z) tail_mean(z) - ys, c(0, 4))$root
cut <- mu + z * sdv
x <- seq(45, 175, by = 0.25)
gens <- c("Parents", "Offspring")
d <- rbind(data.frame(gen = gens[1], x = x, y = dnorm(x, mu, sdv)),
           data.frame(gen = gens[2], x = x, y = dnorm(x, mu + R, sdv)))
d$gen <- factor(d$gen, gens)
sel <- subset(d, gen == gens[1] & x >= cut)
top <- max(d$y)
vl <- data.frame(gen = factor(c(gens[1], gens[1], gens[2], gens[2]), gens),
                 x = c(mu, ys, mu, mu + R), col = c(bb512$grey, bb512$clay, bb512$grey, bb512$forest),
                 lab = c("100", "125", "100", "112.5"), hj = c(0.5, 0.5, 1.1, -0.1))
arr <- data.frame(gen = factor(gens, gens), x0 = c(mu, mu), x1 = c(ys, mu + R), y = top * 1.12,
                  lab = c("S = 25 kg", "R = h² × S = 12.5 kg"), col = c(bb512$clay, bb512$forest))

p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) +
  ggplot2::geom_area(data = sel, fill = bb512$clay, alpha = 0.35) +
  ggplot2::geom_line(colour = bb512$forest, linewidth = 1.2) +
  ggplot2::geom_segment(data = vl, ggplot2::aes(x = x, xend = x, y = 0, yend = top * 1.03, colour = I(col)),
                        linewidth = 0.8, linetype = "dashed") +
  ggplot2::geom_text(data = vl, ggplot2::aes(x = x, y = -top * 0.02, label = lab, colour = I(col), hjust = hj),
                     family = fam, size = 4.9, vjust = 1) +
  ggplot2::geom_segment(data = arr, ggplot2::aes(x = x0, xend = x1, y = y, yend = y, colour = I(col)),
                        linewidth = 1, arrow = grid::arrow(length = grid::unit(0.1, "in"), type = "closed")) +
  ggplot2::geom_text(data = arr, ggplot2::aes(x = x1 + 3, y = y, label = lab, colour = I(col)),
                     family = fam, size = 5.4, hjust = 0, fontface = "bold") +
  ggplot2::geom_text(data = data.frame(gen = factor(gens[1], gens), x = 160, y = top * 0.45),
                     ggplot2::aes(x, y), label = "selected\nto breed", family = fam,
                     size = 4.9, colour = bb512$clay, lineheight = 0.9) +
  ggplot2::facet_wrap(~gen, ncol = 1, strip.position = "left") +
  ggplot2::scale_y_continuous(limits = c(-top * 0.16, top * 1.25), expand = c(0, 0)) +
  ggplot2::scale_x_continuous(limits = c(45, 185), breaks = NULL) +
  ggplot2::labs(x = "Body weight (kg)", y = NULL) +
  theme_bb512() +
  ggplot2::theme(axis.text.y = ggplot2::element_blank(), panel.grid.major.y = ggplot2::element_blank(),
                 axis.line.y = ggplot2::element_blank(), strip.placement = "outside",
                 strip.text.y.left = ggplot2::element_text(angle = 0, hjust = 1, size = 16),
                 panel.spacing = grid::unit(0.15, "in"))
save_bb512(p, "05_breeders_equation", layout = "takeaway")
message(sprintf("Truncation point = %.1f kg (z = %.3f); %.1f%% of parents selected", cut, z, 100 * (1 - pnorm(z))))
