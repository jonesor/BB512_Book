# Inbreeding accumulates in a finite, randomly mating population.
# Analytical result for an idealised Wright-Fisher population:
#   F_t = 1 - (1 - 1/(2 Ne))^t,  and  H_t = H_0 (1 - F_t).
# Assumes F_0 = 0, constant Ne, no mutation, migration or selection.
# Not simulated: these are the expected values.
source("R/theme_bb512.R")

Ne_values   <- c(10, 50, 500)
generations <- 0:100

df <- expand.grid(t = generations, Ne = Ne_values)
df$F <- 1 - (1 - 1 / (2 * df$Ne))^df$t
df$Ne_lab <- factor(paste0("N[e] == ", df$Ne), levels = paste0("N[e] == ", Ne_values))

cols <- c(bb512$clay, bb512$forest, bb512$blue)
names(cols) <- levels(df$Ne_lab)

ends <- df[df$t == max(generations), ]
ends$y <- ends$F + c(-0.06, 0, 0.05)

p <- ggplot2::ggplot(df, ggplot2::aes(t, F, colour = Ne_lab)) +
  ggplot2::geom_line(linewidth = 1.4) +
  ggplot2::geom_text(data = ends, ggplot2::aes(x = t + 2, y = y, label = Ne_lab),
                     parse = TRUE, hjust = 0, size = 5.4, family = "Avenir Next") +
  ggplot2::scale_colour_manual(values = cols, guide = "none") +
  ggplot2::scale_x_continuous(breaks = seq(0, 100, 25), expand = ggplot2::expansion(c(0, 0.02))) +
  ggplot2::scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
  ggplot2::coord_cartesian(clip = "off") +
  ggplot2::labs(x = "Generations (t)", y = "Inbreeding coefficient (F)") +
  theme_bb512() +
  ggplot2::theme(plot.margin = ggplot2::margin(14, 80, 12, 16, "pt"))

save_bb512(p, "02_F_over_time", layout = "takeaway")
