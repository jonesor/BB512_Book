# Slide "Guppies: the result": life-history evolution after guppies were moved from a
# high-predation site to a low-predation site above a waterfall (Aripo River, Trinidad).
# EMPIRICAL. Values hard-coded from Reznick, Shaw, Rodd & Shaw (1997) Science 275:1934-1937,
# Table 1, Aripo River (11 years, about 18 generations): control (high-predation source
# population) versus introduced (low-predation) population, fish reared in a common laboratory
# environment, so differences are genetic. All four differences significant (P < 0.05).
# Note: the paper's reported responses (female age 7.8 d, female size 26.8 mg) differ from the
# differences of the rounded means below by 0.1 because of rounding.
source("R/theme_bb512.R")
fam <- "Avenir Next"
df <- data.frame(
  measure = rep(c("Age at maturity (days)", "Mass at maturity (mg)"), each = 4),
  sex     = rep(c("Males", "Males", "Females", "Females"), 2),
  pop     = rep(c("High predation (source)", "Low predation (11 years later)"), 4),
  value   = c(48.6, 58.2, 85.6, 93.5, 67.5, 76.1, 162.3, 189.2))
df$sex <- factor(df$sex, levels = c("Males", "Females"))
df$pop <- factor(df$pop, levels = c("High predation (source)", "Low predation (11 years later)"))
seg <- reshape(df, idvar = c("measure", "sex"), timevar = "pop", direction = "wide")
names(seg) <- c("measure", "sex", "high", "low")
# Shorten arrows so they start and end clear of the points
seg$y0 <- seg$high + 0.2 * (seg$low - seg$high); seg$y1 <- seg$low - 0.25 * (seg$low - seg$high)
p <- ggplot2::ggplot(df, ggplot2::aes(sex, value)) +
  ggplot2::geom_segment(data = seg, ggplot2::aes(x = sex, xend = sex, y = y0, yend = y1),
                        colour = bb512$sage, linewidth = 1.6,
                        arrow = ggplot2::arrow(length = ggplot2::unit(0.12, "in"), type = "closed")) +
  ggplot2::geom_point(ggplot2::aes(colour = pop), size = 4) +
  ggplot2::facet_wrap(~measure, scales = "free_y") +
  ggplot2::scale_colour_manual(values = c(bb512$clay, bb512$forest), name = NULL) +
  ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0.25, 0.15))) +
  ggplot2::labs(x = NULL, y = NULL) +
  theme_bb512() +
  ggplot2::guides(colour = ggplot2::guide_legend(nrow = 2)) +
  ggplot2::theme(axis.text.x = ggplot2::element_text(size = 16, colour = bb512$ink),
                 panel.spacing = ggplot2::unit(2, "lines"),
                 legend.text = ggplot2::element_text(size = 15),
                 legend.margin = ggplot2::margin(0, 0, 0, 0))
save_bb512(p, "04_guppy_life_history", layout = "takeaway")
