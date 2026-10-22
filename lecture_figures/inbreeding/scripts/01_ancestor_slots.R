# Ancestor "slots" in a pedigree: 2^t ancestors t generations back.
# Analytical (exact arithmetic), not simulated.
# Point: in a small population the number of slots soon exceeds the number of
# individuals available, so the same individuals must fill several slots
# (pedigree collapse) and everyone is related.
source("R/theme_bb512.R")

generations <- 0:20
pop_sizes   <- c(50, 1000)

df <- data.frame(t = generations, slots = 2^generations)
cross <- data.frame(N = pop_sizes,
                    t = ceiling(log2(pop_sizes)))  # first t with 2^t > N
cross$slots <- 2^cross$t

p <- ggplot2::ggplot(df, ggplot2::aes(t, slots)) +
  ggplot2::geom_hline(yintercept = pop_sizes, colour = bb512$grey,
                      linetype = "dashed", linewidth = 0.7) +
  ggplot2::geom_line(colour = bb512$forest, linewidth = 1.4) +
  ggplot2::geom_point(data = cross, colour = bb512$clay, size = 3.6) +
  ggplot2::annotate("text", x = 20, y = pop_sizes * 2.4,
                    label = c("N = 50", "N = 1,000"), hjust = 1,
                    colour = bb512$grey, size = 5.2, family = "Avenir Next") +
  ggplot2::annotate("text", x = cross$t + 0.4, y = cross$slots / 1.9,
                    label = paste0(cross$t, " generations"), hjust = 0,
                    colour = bb512$clay, size = 5.2, family = "Avenir Next") +
  ggplot2::scale_y_log10(breaks = 10^(0:6),
                         labels = c("1", "10", "100", "1,000", "10,000",
                                    "100,000", "1,000,000")) +
  ggplot2::scale_x_continuous(breaks = seq(0, 20, 5)) +
  ggplot2::labs(x = "Generations back (t)", y = expression("Ancestor slots, " * 2^t)) +
  theme_bb512()

save_bb512(p, "01_ancestor_slots", layout = "half")
