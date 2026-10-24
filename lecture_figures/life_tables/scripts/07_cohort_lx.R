# 07_cohort_lx.R
# Slide "From counts to survivorship".
# Analytical. Survivorship of the lecture's hypothetical cohort
# (S = 500, 400, 200, 50, 0 at ages 0-4; l = S / 500), on a linear scale,
# so students see the table as a curve before any arithmetic.
source("R/theme_bb512.R")
library(ggplot2)

d <- data.frame(x = 0:4, S = c(500, 400, 200, 50, 0))
d$l <- d$S / d$S[1]

p <- ggplot(d, aes(x, l)) +
  geom_line(colour = bb512$forest, linewidth = 1.5) +
  geom_point(colour = bb512$forest, size = 3.4) +
  geom_text(aes(label = format(l, nsmall = 1)), nudge_x = 0.12, nudge_y = 0.06, hjust = 0,
            size = 5.4, family = "Avenir Next", colour = bb512$forest) +
  scale_y_continuous(limits = c(0, 1.08), breaks = seq(0, 1, 0.25)) +
  scale_x_continuous(breaks = 0:4, expand = expansion(mult = c(0.04, 0.1))) +
  labs(x = expression("Age, " * italic(x) * " (years)"),
       y = expression("Survivorship, " * italic(l)[x])) +
  theme_bb512()

save_bb512(p, "07_cohort_lx", layout = "half")
