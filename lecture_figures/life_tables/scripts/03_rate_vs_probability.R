# 03_rate_vs_probability.R
# Slides "Mortality: probability or rate?" and "Probability is bounded; rate is not".
# Analytical, illustrative parameters.
# 03a: one mortality schedule described two ways. The force of mortality
#      (hazard) rises exponentially with age (Gompertz: mu(x) = a exp(b x),
#      a = 0.02, b = 0.6). The probability of dying in each one-year interval is
#      q_x = 1 - exp(-integral of mu over the interval). q_x is a step per
#      interval and can never exceed 1; mu(x) is continuous and unbounded.
# 03b: for a constant hazard over one interval, q = 1 - exp(-mu).
#      At low mortality q is close to mu; at high mortality q approaches 1.
source("R/theme_bb512.R")
library(ggplot2)
library(patchwork)

a <- 0.02; b <- 0.6; max_age <- 10
H  <- function(x) a / b * (exp(b * x) - 1)               # cumulative hazard
qx <- data.frame(x = 0:(max_age - 1))
qx$q <- 1 - exp(-(H(qx$x + 1) - H(qx$x)))
steps <- data.frame(x = c(rbind(qx$x, qx$x + 1)), q = rep(qx$q, each = 2))
mu <- data.frame(x = seq(0, max_age, length.out = 400))
mu$mu <- a * exp(b * mu$x)

bg_theme <- plot_annotation(theme = theme(plot.background = element_rect(fill = bb512$bg, colour = NA)))

p1 <- ggplot(steps, aes(x, q)) +
  geom_hline(yintercept = 1, linetype = "dashed", colour = bb512$grey, linewidth = 0.7) +
  geom_line(colour = bb512$forest, linewidth = 1.4) +
  scale_x_continuous(breaks = seq(0, 10, 2)) +
  scale_y_continuous(limits = c(0, 1.05), breaks = seq(0, 1, 0.25)) +
  labs(x = "Age (years)", y = expression("Probability of dying, " * italic(q)[x])) +
  theme_bb512()

p2 <- ggplot(mu, aes(x, mu)) +
  geom_hline(yintercept = 1, linetype = "dashed", colour = bb512$grey, linewidth = 0.7) +
  geom_line(colour = bb512$clay, linewidth = 1.4) +
  scale_x_continuous(breaks = seq(0, 10, 2)) +
  scale_y_continuous(breaks = seq(0, 8, 2)) +
  labs(x = "Age (years)", y = expression("Force of mortality, " * mu(italic(x)))) +
  theme_bb512()

save_bb512(p1 + p2 + bg_theme, "03a_same_mortality_two_ways", layout = "full")

# ---- 03b: q against mu --------------------------------------------------
curve <- data.frame(mu = seq(0, 6, length.out = 400))
curve$q <- 1 - exp(-curve$mu)
pts <- data.frame(mu = c(0.1, 1, 2, 5))
pts$q <- 1 - exp(-pts$mu)
pts$lab <- sprintf("μ = %g, q = %.2f", pts$mu, pts$q)
pts$lab[pts$mu == 5] <- "μ = 5, q = 0.993"
pts$lab[pts$mu == 0.1] <- "μ = 0.1, q = 0.095"

p3 <- ggplot(curve, aes(mu, q)) +
  annotate("segment", x = 0, y = 0, xend = 1.15, yend = 1.15, linetype = "dashed",
           colour = bb512$grey, linewidth = 0.7) +
  geom_hline(yintercept = 1, linetype = "dotted", colour = bb512$grey, linewidth = 0.7) +
  geom_line(colour = bb512$forest, linewidth = 1.5) +
  geom_point(data = pts, colour = bb512$clay, size = 3.2) +
  geom_text(data = pts, aes(label = lab, hjust = ifelse(mu == 5, 0.75, -0.08),
                            vjust = ifelse(mu == 5, 2.0, 1.4)), size = 5.2,
            family = "Avenir Next", colour = bb512$clay) +
  annotate("text", x = 1.25, y = 1.13, label = "q = μ", hjust = 0, size = 5.2,
           family = "Avenir Next", colour = bb512$grey) +
  coord_cartesian(xlim = c(0, 6), ylim = c(0, 1.2), clip = "off") +
  scale_x_continuous(breaks = 0:6) +
  scale_y_continuous(breaks = seq(0, 1, 0.25)) +
  labs(x = expression("Force of mortality, " * mu * " (per year)"),
       y = expression("Probability of dying, " * italic(q))) +
  theme_bb512()

save_bb512(p3, "03b_q_vs_mu", layout = "takeaway")
