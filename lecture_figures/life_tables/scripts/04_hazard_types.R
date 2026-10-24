# 04_hazard_types.R
# Slide "The shape of mortality sets the survivorship curve".
# Analytical, illustrative parameters (redraws the figure of the previous
# version of the lecture in the BB512 theme). Three hazard (force of
# mortality) trajectories and the survivorship each one produces,
# lx = exp(-cumulative hazard), on a log scale:
#   Type I   mortality increases with age  (Gompertz: 0.0005 exp(0.1 x))
#   Type II  constant mortality            (0.07 per year)
#   Type III mortality decreases with age  (0.3 exp(-0.06 x) + 0.005)
# Ages 0-80 for all three, so the shapes can be compared directly.
source("R/theme_bb512.R")
library(ggplot2)
library(patchwork)

age <- seq(0, 80, by = 0.25)
types <- c("Type I", "Type II", "Type III")
haz <- list(
  `Type I`   = function(x) 0.0005 * exp(0.1 * x),
  `Type II`  = function(x) rep(0.07, length(x)),
  `Type III` = function(x) 0.3 * exp(-0.06 * x) + 0.005)
d <- do.call(rbind, lapply(types, function(t) {
  mu <- haz[[t]](age)
  H  <- c(0, cumsum((head(mu, -1) + tail(mu, -1)) / 2 * diff(age)))  # trapezoid
  data.frame(type = factor(t, levels = types), age, mu, lx = exp(-H))
}))
d$lx[d$lx < 1e-3] <- NA                        # plot down to lx = 0.001

top <- ggplot(d, aes(age, mu)) +
  geom_line(colour = bb512$clay, linewidth = 1.4) +
  facet_wrap(~type, scales = "free_y") +
  scale_x_continuous(breaks = c(0, 40, 80)) +
  scale_y_continuous(limits = c(0, NA)) +
  labs(x = NULL, y = expression("Mortality, " * mu)) +
  theme_bb512() +
  theme(axis.text = element_blank(), panel.spacing.x = unit(28, "pt"),
        panel.grid.major.y = element_blank())  # shape only: scales differ by type

bottom <- ggplot(d, aes(age, lx)) +
  geom_line(colour = bb512$forest, linewidth = 1.4, na.rm = TRUE) +
  facet_wrap(~type) +
  scale_x_continuous(breaks = c(0, 40, 80)) +
  scale_y_log10(limits = c(1e-3, 1), breaks = c(0.001, 0.01, 0.1, 1),
                labels = c("0.001", "0.01", "0.1", "1")) +
  labs(x = "Age", y = expression(italic(l)[x] * " (log)")) +
  theme_bb512() +
  theme(strip.text = element_blank(), panel.spacing.x = unit(28, "pt"))

save_bb512(top / bottom + plot_annotation(
  theme = theme(plot.background = element_rect(fill = bb512$bg, colour = NA))),
  "04_hazard_types", layout = "tall")
