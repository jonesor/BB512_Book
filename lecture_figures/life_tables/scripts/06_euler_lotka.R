# 06_euler_lotka.R
# Self-study slide "Finding r exactly: the Euler-Lotka equation".
# Analytical. For the lecture's hypothetical cohort (lx = 1, 0.8, 0.4, 0.1;
# mx = 0, 2, 3, 1), plot the Euler-Lotka sum, sum(exp(-r x) lx mx), against
# trial values of r. The exact r is where the sum equals 1 (r = 0.776 per
# year). The approximation r = ln(R0)/T = 0.718 gives a sum of 1.08.
# At r = 0 the sum is R0 = 2.9.
source("R/theme_bb512.R")
library(ggplot2)

x <- 0:3; lx <- c(1, 0.8, 0.4, 0.1); mx <- c(0, 2, 3, 1)
el <- function(r) sapply(r, function(ri) sum(exp(-ri * x) * lx * mx))
R0 <- sum(lx * mx); T <- sum(x * lx * mx) / R0
r_c <- log(R0) / T
r_m <- uniroot(function(r) el(r) - 1, c(0, 3))$root

d <- data.frame(r = seq(0, 1.6, length.out = 400)); d$s <- el(d$r)
marks <- data.frame(r = c(0, r_c, r_m), s = el(c(0, r_c, r_m)),
                    lab = c(sprintf("italic(r) == 0*':'~~sum~'='~italic(R)[0] == %.1f", R0),
                            sprintf("italic(r) %%~~%% ln(italic(R)[0])/italic(T) == %.3f", r_c),
                            sprintf("exact~italic(r) == %.3f", r_m)),
                    col = c("g", "a", "e"))

p <- ggplot(d, aes(r, s)) +
  geom_hline(yintercept = 1, linetype = "dashed", colour = bb512$grey, linewidth = 0.7) +
  geom_line(colour = bb512$forest, linewidth = 1.5) +
  geom_point(data = marks, aes(colour = col), size = 3.4) +
  geom_text(data = marks, aes(label = lab, colour = col), parse = TRUE,
            hjust = c(-0.1, -0.1, 1.08), vjust = c(0.5, -0.6, 1.8), size = 5.2, family = "Avenir Next") +
  scale_colour_manual(values = c(g = bb512$grey, a = bb512$gold, e = bb512$clay), guide = "none") +
  scale_y_continuous(breaks = 0:3, limits = c(0, 3.05)) +
  labs(x = expression("Trial value of " * italic(r) * " (per year)"),
       y = expression(Sigma * " " * e^{-italic(rx)} * italic(l)[x] * italic(m)[x])) +
  theme_bb512()

save_bb512(p, "06_euler_lotka", layout = "takeaway")
