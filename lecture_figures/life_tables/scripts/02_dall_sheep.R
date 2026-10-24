# 02_dall_sheep.R
# Slide "Real data: Dall sheep".
# Empirical. Dall sheep (Ovis dalli), Denali (then Mount McKinley) National
# Park, Alaska. Olaus Murie (1944) aged 608 skulls from horn growth; Deevey
# (1947) built a static life table from these ages at death (Dx). Values as in
# Neal's Dall sheep life table. Assumes the population was stationary and that
# skulls of all ages were equally likely to be found (Neal discusses both).
# Left: survivorship lx on a log scale (slope = mortality). Right: qx.
source("R/theme_bb512.R")
library(ggplot2)
library(patchwork)

Dx <- c(121, 7, 8, 7, 18, 28, 29, 42, 80, 114, 95, 55, 2, 2)  # deaths, ages 0-13
x  <- seq_along(Dx) - 1
Sx <- rev(cumsum(rev(Dx)))           # 608, 487, ...: alive at start of age x
lx <- Sx / Sx[1]
qx <- Dx / Sx
d  <- data.frame(x, lx, qx)

p1 <- ggplot(d, aes(x, lx)) +
  geom_line(colour = bb512$forest, linewidth = 1.4) +
  geom_point(colour = bb512$forest, size = 2.6) +
  scale_y_log10(breaks = c(0.001, 0.01, 0.1, 1), labels = c("0.001", "0.01", "0.1", "1")) +
  scale_x_continuous(breaks = seq(0, 14, 2)) +
  labs(x = "Age (years)", y = expression("Survivorship, " * italic(l)[x] * " (log scale)")) +
  theme_bb512()

# Ages 12 and 13 rest on only 4 and 2 sheep: shown in sage as unreliable
p2 <- ggplot(d, aes(x, qx)) +
  geom_line(data = subset(d, x >= 11), colour = bb512$sage, linewidth = 1.4) +
  geom_point(data = subset(d, x >= 12), colour = bb512$sage, size = 2.6) +
  geom_line(data = subset(d, x <= 11), colour = bb512$clay, linewidth = 1.4) +
  geom_point(data = subset(d, x <= 11), colour = bb512$clay, size = 2.6) +
  annotate("text", x = 13.3, y = 0.36, label = "few\nsheep", hjust = 1, size = 5.2,
           lineheight = 0.9, family = "Avenir Next", colour = bb512$sage) +
  annotate("text", x = 0.6, y = 0.29, label = "Lambs", hjust = 0, size = 5.2,
           family = "Avenir Next", colour = bb512$grey) +
  annotate("text", x = 3.6, y = 0.16, label = "Prime adults", hjust = 0.5, size = 5.2,
           family = "Avenir Next", colour = bb512$grey) +
  annotate("text", x = 9.6, y = 0.86, label = "Old age", hjust = 1, size = 5.2,
           family = "Avenir Next", colour = bb512$grey) +
  scale_x_continuous(breaks = seq(0, 14, 2)) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
  labs(x = "Age (years)", y = expression("Probability of dying, " * italic(q)[x])) +
  theme_bb512()

save_bb512(p1 + p2 + plot_layout(widths = c(1, 1)) +
             plot_annotation(theme = theme(plot.background = element_rect(fill = bb512$bg, colour = NA))), "02_dall_sheep", layout = "full")
