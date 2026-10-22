# Inbreeding coefficient of offspring from matings between relatives.
# Analytical values from path counting, assuming non-inbred, unrelated founders.
# Empirical comparison: Charles II of Spain, F = 0.254 (Alvarez et al. 2009,
# PLoS ONE 4: e5174), estimated from a pedigree of about 3,000 individuals.
source("R/theme_bb512.R")

df <- data.frame(
  mating = c("Self-fertilisation", "Full siblings", "Parent \u00d7 offspring",
             "Half siblings", "First cousins", "Second cousins",
             "Charles II of Spain"),
  F      = c(1/2, 1/4, 1/4, 1/8, 1/16, 1/64, 0.254),
  lab    = c("1/2 = 0.5", "1/4 = 0.25", "1/4 = 0.25", "1/8 = 0.125",
             "1/16 = 0.0625", "1/64 = 0.0156", "0.254 (pedigree estimate)"),
  type   = c(rep("theory", 6), "empirical")
)
df$mating <- factor(df$mating, levels = rev(df$mating))
cols <- c(theory = bb512$forest, empirical = bb512$gold)

p <- ggplot2::ggplot(df, ggplot2::aes(F, mating, colour = type)) +
  ggplot2::geom_segment(ggplot2::aes(x = 0, xend = F, yend = mating),
                        colour = bb512$sage, linewidth = 1.2) +
  ggplot2::geom_point(size = 4.2) +
  ggplot2::geom_text(ggplot2::aes(label = lab), nudge_x = 0.02, hjust = 0, size = 5,
                     family = "Avenir Next") +
  ggplot2::scale_colour_manual(values = cols, guide = "none") +
  ggplot2::scale_x_continuous(limits = c(0, 0.75), breaks = seq(0, 0.5, 0.25),
                              expand = ggplot2::expansion(c(0, 0))) +
  ggplot2::labs(x = "Inbreeding coefficient of offspring (F)", y = NULL) +
  theme_bb512() +
  ggplot2::theme(panel.grid.major.y = ggplot2::element_blank(),
                 axis.text.y = ggplot2::element_text(size = 15, colour = bb512$ink))

save_bb512(p, "06_F_by_relationship", layout = "takeaway")
