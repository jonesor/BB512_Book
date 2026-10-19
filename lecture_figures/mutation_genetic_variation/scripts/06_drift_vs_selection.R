# Slide 32: Multiple finite-population trajectories under drift alone
# versus additive directional selection with the SAME N and initial p.
source("R/theme_bb512.R")
source("R/simulations.R")
set.seed(51206)

N <- 120L
generations <- 140L
n_rep <- 14L
p0 <- 0.2

neutral <- simulate_wf(N, generations, n_rep, p0, s = 0)
selected <- simulate_wf(N, generations, n_rep, p0, s = 0.12)
neutral$process <- "Drift alone"
selected$process <- "With selection"
df <- rbind(neutral, selected)
df$process <- factor(df$process, levels = c("Drift alone", "With selection"))

p <- ggplot2::ggplot(df, ggplot2::aes(generation, frequency,
                                     group = replicate, colour = process)) +
  ggplot2::geom_line(alpha = 0.68, linewidth = 0.8) +
  ggplot2::facet_wrap(~ process, nrow = 1) +
  ggplot2::scale_colour_manual(values = c("Drift alone" = bb512$blue,
                                           "With selection" = bb512$forest),
                                guide = "none") +
  ggplot2::scale_y_continuous(limits = c(0, 1), breaks = c(0, 0.25, 0.5, 0.75, 1)) +
  ggplot2::labs(x = "Generations", y = "Frequency of allele A") +
  theme_bb512() +
  ggplot2::theme(panel.spacing = grid::unit(20, "pt"))

save_bb512(p, "06_drift_vs_selection", layout = "half")
cat(sprintf("Each panel: N=%d diploids, p0=%.2f; selection panel s=0.12\n", N, p0))
