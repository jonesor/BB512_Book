# Slide 15: Luria–Delbrück fluctuation experiment — competing predictions.
# Outputs are simulated, NOT the historical data from Luria and Delbrück.
source("R/theme_bb512.R")
source("R/simulations.R")
set.seed(51201)

cultures <- 250L
sim <- simulate_fluctuation(cultures = cultures, doublings = 16L, mu = 2e-5)
# Under the simplified 'mutations only at exposure' null, independent
# resistant counts follow a Poisson approximation with matched expectation.
at_exposure <- stats::rpois(cultures, lambda = sim$expectation)

comparison <- data.frame(
  mechanism = factor(rep(c("At exposure", "Before exposure"), each = cultures),
                     levels = c("At exposure", "Before exposure")),
  resistant = c(at_exposure, sim$before_exposure)
)

p <- ggplot2::ggplot(comparison,
                     ggplot2::aes(x = mechanism, y = resistant, colour = mechanism)) +
  ggplot2::geom_boxplot(width = 0.32, outlier.shape = NA, linewidth = 0.7,
                        alpha = 0.0) +
  ggplot2::geom_jitter(width = 0.17, height = 0, alpha = 0.50, size = 1.6) +
  ggplot2::scale_colour_manual(values = c("At exposure" = bb512$blue,
                                           "Before exposure" = bb512$clay), guide = "none") +
  ggplot2::scale_y_continuous(trans = scales::pseudo_log_trans(sigma = 1),
                              breaks = c(0, 1, 3, 10, 30, 100, 300, 1000)) +
  ggplot2::labs(x = NULL, y = "Resistant cells per culture") +
  theme_bb512() +
  ggplot2::theme(axis.text.x = ggplot2::element_text(size = 17))

save_bb512(p, "01_luria_delbruck_fluctuation", layout = "takeaway")

cat(sprintf("Matched predicted mean: %.2f resistant cells/culture\n", sim$expectation))
cat(sprintf("Variance/mean: at exposure = %.1f; before exposure = %.1f\n",
            stats::var(at_exposure) / mean(at_exposure),
            stats::var(sim$before_exposure) / mean(sim$before_exposure)))
