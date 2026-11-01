# Divergent selection on sensitivity to alarm substance in zebrafish (Danio rerio).
# EMPIRICAL: line means digitised from Neal (2004) Fig. 19.2 (data from Gandolfi 1972), to about
# +/- 0.05 log units; error bars omitted. ED50 = dose that makes half the fish flee.
# Lower ED50 = more sensitive fish. Log base taken as 10 (consistent with Neal's ">1000-fold").
source("R/theme_bb512.R")
library(ggplot2)
fam <- "Avenir Next"
d <- data.frame(
  gen  = rep(0:4, 2),
  line = rep(c("low", "high"), each = 5),
  ed50 = c(-4.46, -3.23, -2.54, -2.76, -2.58,
           -4.46, -4.88, -5.43, -5.86, -5.86)
)
cols <- c(low = bb512$blue, high = bb512$clay)
p <- ggplot(d, aes(gen, ed50, colour = line)) +
  geom_hline(yintercept = -4.46, linetype = "dashed", colour = bb512$grey, linewidth = 0.6) +
  geom_line(linewidth = 1.4) +
  geom_point(size = 3.6) +
  annotate("text", x = 4.12, y = -2.58, label = "Selected for\nlow sensitivity", hjust = 0,
           family = fam, size = 5, colour = bb512$blue, lineheight = 0.9) +
  annotate("text", x = 4.12, y = -5.86, label = "Selected for\nhigh sensitivity", hjust = 0,
           family = fam, size = 5, colour = bb512$clay, lineheight = 0.9) +
  annotate("segment", x = 3.75, xend = 3.75, y = -2.68, yend = -5.76, colour = bb512$ink,
           linewidth = 0.6, arrow = arrow(ends = "both", length = unit(0.09, "in"))) +
  annotate("text", x = 3.68, y = -4.22, label = ">1,000-fold", hjust = 1, family = fam, size = 5,
           colour = bb512$ink, fontface = "bold") +
  annotate("text", x = 4.12, y = -4.3, label = "Starting level", hjust = 0, family = fam, size = 5,
           colour = bb512$grey) +
  scale_colour_manual(values = cols, guide = "none") +
  scale_x_continuous(breaks = 0:4, limits = c(0, 5.25)) +
  scale_y_continuous(limits = c(-6.4, -2), breaks = -6:-2) +
  labs(x = "Generation of selection", y = expression("Escape threshold, log"[10]*" ED"[50])) +
  theme_bb512()
save_bb512(p, "02_zebrafish_selection", layout = "takeaway")
