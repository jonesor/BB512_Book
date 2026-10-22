# Slide "Selecting against a recessive allele is slow": incidence of a recessive condition
# when affected individuals do not reproduce (s = 1, Neal Case C; Eqn 10.12: q_t = q0 / (1 + t q0)).
# Starting incidence 1 in 10,000 (q0 = 0.01), roughly that of phenylketonuria (PKU) in Europe.
# Analytical; random mating, no new mutation (mutation would slow the decline further).
source("R/theme_bb512.R")
fam <- "Avenir Next"
q0 <- 0.01; t <- 0:100
df <- data.frame(t = t, inc = 1e5 * (q0 / (1 + t * q0))^2)
half <- 1 / sqrt(0.5e-4) - 1 / q0
p <- ggplot2::ggplot(df, ggplot2::aes(t, inc)) +
  ggplot2::geom_line(linewidth = 1.4, colour = bb512$forest) +
  ggplot2::annotate("segment", x = half, xend = half, y = 0, yend = 5, linetype = "dashed",
                    linewidth = 0.7, colour = bb512$grey) +
  ggplot2::annotate("point", x = half, y = 5, size = 4.5, colour = bb512$clay) +
  ggplot2::annotate("text", x = half + 3, y = 6.2, hjust = 0, family = fam, size = 5.2, colour = bb512$clay,
                    label = sprintf("Halved after %.0f generations\n(about 1,000 years)", half), lineheight = 0.9) +
  ggplot2::scale_y_continuous(limits = c(0, 10.5), breaks = seq(0, 10, 2.5)) +
  ggplot2::scale_x_continuous(sec.axis = ggplot2::sec_axis(~ . * 25, name = "Years (25 years per generation)",
                                                           breaks = seq(0, 2500, 500))) +
  ggplot2::labs(x = "Generations of selection (s = 1)", y = "Affected per 100,000 births") +
  theme_bb512() + ggplot2::theme(axis.line.x.top = ggplot2::element_line(colour = bb512$grey, linewidth = 0.5))
save_bb512(p, "14_eugenics", layout = "takeaway")
