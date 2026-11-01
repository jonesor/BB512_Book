# 08_myxoma_lethality.R  (slide "Rabbits and myxoma: what happened", layout = "takeaway")
# EMPIRICAL SUMMARY, from Kerr et al. (2012) PLoS Pathogens 8: e1002950, citing
# Fenner & Ratcliffe (1965), Fenner et al. (1956), Fenner & Marshall (1957) and
# Fenner (1983). Case fatality rates in laboratory rabbits:
#   released strain (SLS, 1950): 99.8%
#   first attenuated field strains (early 1950s): 90-99%
#   most field strains for the next ~30 years: 70-95%
# Ranges are drawn as published; the timing of each stage is approximate.
source("R/theme_bb512.R")
library(ggplot2)
FAM <- getOption("bb512.family", "Avenir Next")
d <- data.frame(stage = factor(c("Released strain\n(1950)", "First field strains\n(early 1950s)",
                                 "Most field strains\n(next ~30 years)"),
                               levels = c("Released strain\n(1950)", "First field strains\n(early 1950s)",
                                          "Most field strains\n(next ~30 years)")),
                lo = c(99.8, 90, 70), hi = c(99.8, 99, 95),
                lab = c("99.8%", "90–99%", "70–95%"))
g <- ggplot(d, aes(stage)) +
  geom_linerange(aes(ymin = lo, ymax = hi), colour = bb512$clay, linewidth = 9) +
  geom_point(data = d[1, ], aes(y = lo), colour = bb512$clay, size = 6) +
  geom_text(aes(y = lo - 2.5, label = lab), vjust = 1, size = 5.4, family = FAM, colour = bb512$ink) +
  scale_y_continuous(limits = c(60, 101), breaks = seq(60, 100, 10)) +
  labs(x = NULL, y = "Infected rabbits killed (%)") +
  theme_bb512() + theme(axis.text.x = element_text(size = 15, colour = bb512$ink, lineheight = 0.9))
save_bb512(g, "08_myxoma_lethality", layout = "takeaway")
