# 05_generation_time.R
# Slide "Same R0, different generation time".
# Analytical, illustrative. Two populations, both with R0 = 2 (each female
# replaces herself twice over per generation) but generation times of 1 and
# 2 years. N(t) = N0 R0^(t / T), N0 = 100, so r = ln(R0) / T:
# 0.69 per year (lambda = 2) and 0.35 per year (lambda = 1.41).
# Points mark the end of each generation.
source("R/theme_bb512.R")
library(ggplot2)

R0 <- 2; N0 <- 100; t_max <- 6
pops <- data.frame(T = c(1, 2), lab = c("T = 1 year", "T = 2 years"),
                   col = c(bb512$forest, bb512$clay))
lines <- do.call(rbind, lapply(seq_len(nrow(pops)), function(i) {
  t <- seq(0, t_max, length.out = 300)
  data.frame(t, N = N0 * R0^(t / pops$T[i]), lab = pops$lab[i])
}))
gens <- do.call(rbind, lapply(seq_len(nrow(pops)), function(i) {
  t <- seq(0, t_max, by = pops$T[i])
  data.frame(t, N = N0 * R0^(t / pops$T[i]), lab = pops$lab[i])
}))
cols <- setNames(pops$col, pops$lab)
ends <- aggregate(N ~ lab, data = lines, FUN = max)

p <- ggplot(lines, aes(t, N, colour = lab)) +
  geom_line(linewidth = 1.5) +
  geom_point(data = gens, size = 3) +
  geom_text(data = ends, aes(x = t_max + 0.12, y = N, label = lab), hjust = 0,
            size = 5.6, fontface = "bold", family = "Avenir Next") +
  scale_colour_manual(values = cols, guide = "none") +
  scale_x_continuous(breaks = 0:t_max, expand = expansion(mult = c(0.02, 0))) +
  scale_y_continuous(labels = scales::comma, limits = c(0, NA)) +
  coord_cartesian(xlim = c(0, t_max), clip = "off") +
  labs(x = "Time (years)", y = "Population size") +
  theme_bb512() +
  theme(plot.margin = margin(14, 150, 12, 16, "pt"))

save_bb512(p, "05_generation_time", layout = "takeaway")
