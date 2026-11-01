# Hawk-Dove game with B = 50, C = 100, D = 10 (Neal 2004 Example 19.2).
# Left: ANALYTICAL expected payoff to Hawk and to Dove against p, the frequency of Hawks.
#   W_H = -25p + 50(1 - p);  W_D = 15(1 - p).  They are equal at p* = 35/60 = 7/12.
# Right: DETERMINISTIC discrete-generation replicator dynamics, p' = p (w0 + W_H) / mean, with
#   baseline fitness w0 = 50 so that all fitnesses are positive (the choice of w0 changes the
#   speed, not the equilibrium). Infinite population, asexual inheritance of strategy, random encounters.
source("R/theme_bb512.R")
library(ggplot2)
fam <- "Avenir Next"
B <- 50; C <- 100; D <- 10; w0 <- 50
a <- (B - C) / 2; b <- B; c <- 0; d <- B / 2 - D
pstar <- (b - d) / ((b - d) + (c - a))

pp <- seq(0, 1, by = 0.01)
pay <- rbind(data.frame(p = pp, W = a * pp + b * (1 - pp), s = "Hawk"),
             data.frame(p = pp, W = c * pp + d * (1 - pp), s = "Dove"))
cols <- c(Hawk = bb512$clay, Dove = bb512$blue)
left <- ggplot(pay, aes(p, W, colour = s)) +
  geom_hline(yintercept = 0, colour = bb512$grey, linewidth = 0.5) +
  geom_vline(xintercept = pstar, linetype = "dashed", colour = bb512$grey, linewidth = 0.6) +
  geom_line(linewidth = 1.4) +
  annotate("text", x = 0.16, y = 46, label = "Hawk", hjust = 0, family = fam, size = 5.6, colour = bb512$clay, fontface = "bold") +
  annotate("text", x = 0.04, y = 20.5, label = "Dove", hjust = 0, family = fam, size = 5.6, colour = bb512$blue, fontface = "bold") +
  annotate("text", x = pstar + 0.02, y = 49, label = "p* = 7/12", hjust = 0, family = fam, size = 5.2, colour = bb512$ink) +
  annotate("segment", x = 0.2, xend = 0.45, y = -16, yend = -16, colour = bb512$ink, linewidth = 0.8,
           arrow = arrow(length = unit(0.1, "in"), type = "closed")) +
  annotate("segment", x = 0.97, xend = 0.72, y = 24, yend = 24, colour = bb512$ink, linewidth = 0.8,
           arrow = arrow(length = unit(0.1, "in"), type = "closed")) +
  annotate("text", x = 0.02, y = -16, label = "Hawks\nspread", hjust = 0, family = fam, size = 4.95, colour = bb512$ink, lineheight = 0.85) +
  annotate("text", x = 0.98, y = 32, label = "Doves spread", hjust = 1, family = fam, size = 4.95, colour = bb512$ink, lineheight = 0.85) +
  scale_colour_manual(values = cols, guide = "none") +
  scale_x_continuous(breaks = seq(0, 1, 0.25), labels = c("0", "0.25", "0.5", "0.75", "1")) +
  scale_y_continuous(limits = c(-27, 52), breaks = seq(-25, 50, 25)) +
  labs(x = "Frequency of Hawks (p)", y = "Average payoff") +
  theme_bb512()

gens <- 0:40
traj <- do.call(rbind, lapply(c(0.02, 0.25, 0.9, 0.99), function(p0) {
  p <- numeric(length(gens)); p[1] <- p0
  for (t in 2:length(gens)) {
    q <- p[t - 1]
    WH <- w0 + a * q + b * (1 - q); WD <- w0 + c * q + d * (1 - q)
    p[t] <- q * WH / (q * WH + (1 - q) * WD)
  }
  data.frame(gen = gens, p = p, start = p0)
}))
right <- ggplot(traj, aes(gen, p, group = start)) +
  geom_hline(yintercept = pstar, linetype = "dashed", colour = bb512$grey, linewidth = 0.6) +
  geom_line(colour = bb512$forest, linewidth = 1.3) +
  annotate("text", x = 40, y = pstar + 0.06, label = "ESS: 58% Hawks", hjust = 1, family = fam, size = 5.2, colour = bb512$ink) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25), labels = c("0", "0.25", "0.5", "0.75", "1")) +
  labs(x = "Generation", y = "Frequency of Hawks") +
  theme_bb512()

p <- patchwork::wrap_plots(left, right, nrow = 1, widths = c(1, 1)) &
  theme(plot.background = element_rect(fill = bb512$bg, colour = NA))
save_bb512(p, "07_hawk_dove_dynamics", layout = "full")
