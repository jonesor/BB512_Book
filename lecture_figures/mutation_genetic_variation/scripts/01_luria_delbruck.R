# Slides 15-16: Luria & Delbrück fluctuation test.
# Figure A (slide 15): SIMULATED prediction for 20 independent cultures under
#   each hypothesis, with matched means. Not historical data.
# Figure B (slide 16): the published 1943 counts (E. coli B, phage T1):
#   10 samples from one bulk culture vs 20 independent cultures.
#   Source: Luria & Delbrück (1943) Genetics 28:491-511, as tabulated at
#   https://www.mun.ca/biology/scarr/smcLuria-Delbruck_results.html
# Both figures share one layout so prediction and data can be compared.
source("R/theme_bb512.R")
source("R/simulations.R")

# ---- Shared plotting function -------------------------------------------
plot_fluctuation <- function(df, colours, ylim, label_fun) {
  stats_df <- do.call(rbind, lapply(split(df, df$group), function(d) {
    data.frame(group = d$group[1], mean = mean(d$resistant),
               variance = stats::var(d$resistant))
  }))
  stats_df$label <- label_fun(stats_df)
  stats_df$x <- as.numeric(stats_df$group)

  ggplot2::ggplot(df, ggplot2::aes(group, resistant, colour = group)) +
    ggplot2::geom_point(position = ggplot2::position_jitter(width = 0.16, height = 0,
                                                            seed = 1),
                        size = 3.2, alpha = 0.85) +
    ggplot2::geom_segment(data = stats_df,
                          ggplot2::aes(x = x - 0.28, xend = x + 0.28,
                                       y = mean, yend = mean),
                          inherit.aes = FALSE, colour = bb512$ink, linewidth = 0.9) +
    ggplot2::geom_text(data = stats_df,
                       ggplot2::aes(x = x, y = ylim[2], label = label),
                       inherit.aes = FALSE, vjust = 1, size = 4.6,
                       colour = bb512$ink, lineheight = 0.95) +
    ggplot2::scale_colour_manual(values = colours, guide = "none") +
    ggplot2::scale_y_continuous(limits = ylim, expand = ggplot2::expansion(mult = c(0.02, 0))) +
    ggplot2::labs(x = NULL, y = "Resistant colonies per culture") +
    theme_bb512() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(size = 16, colour = bb512$ink))
}

# ---- Figure A: simulated prediction ---------------------------------------
set.seed(51205)  # chosen so both groups have similar means (about 11)
cultures <- 20L
sim <- simulate_fluctuation(cultures = cultures, doublings = 16L, mu = 2.1e-5)
induced <- stats::rpois(cultures, lambda = sim$expectation)

pred <- data.frame(
  group = factor(rep(c("If induced at exposure", "If arose during growth"),
                     each = cultures),
                 levels = c("If induced at exposure", "If arose during growth")),
  resistant = c(induced, sim$before_exposure)
)
p_pred <- plot_fluctuation(
  pred,
  colours = c("If induced at exposure" = bb512$blue,
              "If arose during growth" = bb512$clay),
  ylim = c(0, 125),
  label_fun = function(s) sprintf("variance / mean = %.1f", s$variance / s$mean)
)
save_bb512(p_pred, "01a_luria_delbruck_prediction", layout = "takeaway")

# ---- Figure B: Luria & Delbrück (1943) data -------------------------------
bulk <- c(14, 15, 13, 21, 15, 14, 26, 16, 20, 13)
independent <- c(1, 0, 3, 0, 0, 5, 0, 5, 0, 6, 107, 0, 0, 0, 1, 0, 0, 64, 0, 35)
obs <- data.frame(
  group = factor(c(rep("Samples from one culture", length(bulk)),
                   rep("Independent cultures", length(independent))),
                 levels = c("Samples from one culture", "Independent cultures")),
  resistant = c(bulk, independent)
)
p_obs <- plot_fluctuation(
  obs,
  colours = c("Samples from one culture" = bb512$blue,
              "Independent cultures" = bb512$clay),
  ylim = c(0, 125),
  # Labels use the values PUBLISHED by Luria & Delbrück (1943). Recomputing
  # from the counts with var() gives 18.2 and 752 (n - 1 denominator); the
  # conclusion (variance close to mean vs far above it) is unchanged.
  label_fun = function(s) c("mean 16.7, variance 15", "mean 11.3, variance 694")
)
save_bb512(p_obs, "01b_luria_delbruck_data", layout = "takeaway")

cat(sprintf("Prediction: induced mean %.1f (var/mean %.1f); growth mean %.1f (var/mean %.1f)\n",
            mean(induced), var(induced) / mean(induced),
            mean(sim$before_exposure), var(sim$before_exposure) / mean(sim$before_exposure)))
cat(sprintf("Data: bulk mean %.1f var %.1f; independent mean %.2f var %.1f\n",
            mean(bulk), var(bulk), mean(independent), var(independent)))
