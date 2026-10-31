# Five progressive schematic comparisons of migration, drift and selection.
# Nem = 1 is a rule of thumb, not a sharp transition; m = s is illustrative.
# Neutral FST uses the diploid island-model approximation 1 / (1 + 4Nem).
# This does not predict FST at a selected locus or prove local adaptation.
# Deterministic curves: no random seed needed.
source("R/theme_bb512.R")

s <- 0.01
ne <- 10^seq(2, 5, length.out = 500)
dat <- data.frame(Ne = ne, drift = 1 / ne, selection = s)
# Shade only where the drift benchmark lies below the selection benchmark.
zone <- dat[dat$drift <= dat$selection, ]
example_ne <- 10000
example_m <- 0.001
example_nm <- example_ne * example_m
example_fst <- 1 / (1 + 4 * example_nm)
stopifnot(example_nm == 10, abs(example_fst - 1 / 41) < 1e-12,
          example_m > 1 / example_ne, example_m < s)

base_plot <- function(compact = FALSE) {
  ggplot2::ggplot(dat, ggplot2::aes(x = Ne)) +
    ggplot2::scale_x_log10(limits = c(100, 100000),
      breaks = c(100, 1000, 10000, 100000), labels = scales::label_comma(),
      expand = ggplot2::expansion(mult = c(0.015, 0.025))) +
    ggplot2::scale_y_log10(limits = c(1e-6, 1),
      breaks = c(1e-6, 1e-4, 1e-2, 1),
      labels = if (compact) expression(10^-6, 10^-4, 10^-2, 1) else
        c("0.000001", "0.0001", "0.01", "1"),
      expand = ggplot2::expansion(mult = c(0.02, 0.03))) +
    ggplot2::labs(x = if (compact) expression(atop("Effective population size,", N[e])) else
                   expression("Effective population size, " * N[e]),
                   y = "Migration rate, m\n(proportion)") +
    theme_bb512() +
    ggplot2::theme(axis.title = ggplot2::element_text(size = if (compact) 15 else 18),
                   axis.text = ggplot2::element_text(size = if (compact) 12 else 15))
}

drift_line <- function() {
  ggplot2::geom_line(ggplot2::aes(y = drift), colour = bb512$forest, linewidth = 1.6)
}
selection_line <- function() {
  ggplot2::geom_hline(yintercept = s, colour = bb512$clay, linewidth = 1.6)
}
zone_ribbon <- function() {
  ggplot2::geom_ribbon(data = zone, ggplot2::aes(ymin = drift, ymax = selection),
                        fill = bb512$forest, alpha = 0.13)
}

# First reveal: migration weak relative to drift below the green benchmark.
p1 <- base_plot() + drift_line() +
  ggplot2::annotate("text", x = 900, y = 0.0035, label = "N[e]*m == 1",
    parse = TRUE, colour = bb512$forest, size = 6, hjust = 0, family = "Avenir Next") +
  ggplot2::annotate("text", x = 3300, y = 1.5e-5,
    label = "Below: migration weak relative to drift",
    colour = bb512$ink, size = 5.2, family = "Avenir Next")

# Second reveal: migration compared with an illustrative selection strength.
p2 <- base_plot() + selection_line() +
  ggplot2::annotate("text", x = 1800, y = 0.028,
    label = sprintf("m = s = %.2f", s), colour = bb512$clay, size = 6,
    hjust = 0, family = "Avenir Next") +
  ggplot2::annotate("text", x = 3000, y = 0.15,
    label = "Above: gene flow may swamp local selection",
    colour = bb512$ink, size = 5.2, family = "Avenir Next")

# Third reveal: both benchmarks on exactly the same axes.
p3 <- base_plot() + drift_line() + selection_line() +
  ggplot2::annotate("text", x = 1000, y = 0.0027, label = "N[e]*m == 1",
    parse = TRUE, colour = bb512$forest, size = 5.5, family = "Avenir Next") +
  ggplot2::annotate("text", x = 19000, y = 0.028, label = "m = s",
    colour = bb512$clay, size = 5.5, family = "Avenir Next")

# Fourth reveal: low neutral differentiation can coexist with local adaptation.
p4 <- base_plot() + zone_ribbon() + drift_line() + selection_line() +
  ggplot2::annotate("text", x = 6000, y = 0.0028,
    label = "Neutral differentiation reduced;\nlocal adaptation may persist",
    colour = bb512$ink, size = 5, lineheight = 1.1, family = "Avenir Next")

# Fifth reveal: one illustrative point between the two benchmarks.
p5 <- base_plot() + zone_ribbon() + drift_line() + selection_line() +
  ggplot2::annotate("point", x = example_ne, y = example_m,
                     colour = bb512$gold, size = 4.7) +
  ggplot2::annotate("text", x = 14000, y = 0.003,
    label = sprintf("%g effective migrants\nper generation", example_nm),
    colour = bb512$gold, size = 5.2, hjust = 0, family = "Avenir Next") +
  ggplot2::annotate("text", x = 14000, y = 0.00025,
    label = sprintf("'Neutral'~F[ST] %%~~%% %.3f", example_fst), parse = TRUE,
    colour = bb512$gold, size = 5.2, hjust = 0, family = "Avenir Next") +
  ggplot2::annotate("text", x = 3500, y = 1.3e-5,
    label = sprintf("m/s = %g: local adaptation may persist", example_m / s),
    colour = bb512$ink, size = 4.7, family = "Avenir Next")

plots <- list(p1, p2, p3, p4, p5)
for (i in seq_along(plots)) {
  save_bb512(plots[[i]], sprintf("02_migration_build_%02d", i), layout = "fullbox")
  save_bb512(plots[[i]], sprintf("02_migration_build_%02d_1_78", i), layout = "widescreen")
}

# Taller Figure & Bullets versions, retaining identical axes across all five.
# Reposition annotations rather than shrinking the wide version as an image.
half1 <- base_plot(compact = TRUE) + drift_line() +
  ggplot2::annotate("text", x = 900, y = 0.0035, label = "N[e]*m == 1",
    parse = TRUE, colour = bb512$forest, size = 4.8, hjust = 0, family = "Avenir Next") +
  ggplot2::annotate("text", x = 3300, y = 1.5e-5,
    label = "Below: migration weak\nrelative to drift",
    colour = bb512$ink, size = 4.3, family = "Avenir Next")

half2 <- base_plot(compact = TRUE) + selection_line() +
  ggplot2::annotate("text", x = 3000, y = 0.028,
    label = sprintf("m = s = %.2f", s), colour = bb512$clay,
    size = 4.8, family = "Avenir Next") +
  ggplot2::annotate("text", x = 3000, y = 0.22,
    label = "Above: gene flow may\nswamp local selection",
    colour = bb512$ink, size = 4.3, family = "Avenir Next")

half3 <- base_plot(compact = TRUE) + drift_line() + selection_line() +
  ggplot2::annotate("text", x = 1000, y = 0.0027, label = "N[e]*m == 1",
    parse = TRUE, colour = bb512$forest, size = 4.8, family = "Avenir Next") +
  ggplot2::annotate("text", x = 19000, y = 0.028, label = "m = s",
    colour = bb512$clay, size = 4.8, family = "Avenir Next")

half4 <- base_plot(compact = TRUE) + zone_ribbon() + drift_line() + selection_line() +
  ggplot2::annotate("text", x = 6000, y = 0.002,
    label = "Neutral differentiation\nreduced; local adaptation\nmay persist",
    colour = bb512$ink, size = 4.1, lineheight = 1.05, family = "Avenir Next")

half5 <- base_plot(compact = TRUE) + zone_ribbon() + drift_line() + selection_line() +
  ggplot2::annotate("point", x = example_ne, y = example_m,
                     colour = bb512$gold, size = 4.7) +
  ggplot2::annotate("text", x = 3200, y = 0.22,
    label = sprintf("%g effective migrants\nper generation", example_nm),
    colour = bb512$gold, size = 4.6, family = "Avenir Next") +
  ggplot2::annotate("text", x = 3200, y = 0.035,
    label = sprintf("'Neutral'~F[ST] %%~~%% %.3f", example_fst), parse = TRUE,
    colour = bb512$gold, size = 4.6, family = "Avenir Next") +
  ggplot2::annotate("text", x = 3500, y = 1.3e-5,
    label = sprintf("m/s = %g: local\nadaptation may persist", example_m / s),
    colour = bb512$ink, size = 4.2, family = "Avenir Next")

half_plots <- list(half1, half2, half3, half4, half5)
for (i in seq_along(half_plots)) {
  save_bb512(half_plots[[i]], sprintf("02_migration_build_%02d_half", i), layout = "half")
}
