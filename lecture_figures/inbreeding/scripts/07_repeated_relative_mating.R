# Repeated mating schemes: deterministic recurrence examples, not simulations.
# Founders are unrelated and non-inbred, with F = 0 at generation zero.
# Generation one is the first offspring generation from each named cross.
# Half-sib and cousin trajectories use the specified recurrences below;
# other repeated pedigree structures can give different trajectories.
source("R/theme_bb512.R")

n_gen <- 10L
stopifnot(n_gen >= 2L)
self <- full <- half <- cousin <- numeric(n_gen + 1L)
self[2] <- 0.5
full[2] <- 0.25
half[2] <- 0.125
cousin[2] <- 0.0625

for (t in 2:n_gen) {
  i <- t + 1L
  self[i] <- (1 + self[i - 1L]) / 2
  full[i] <- (1 + 2 * full[i - 1L] + full[i - 2L]) / 4
  half[i] <- (1 + 6 * half[i - 1L] + half[i - 2L]) / 8
  # Before generation zero, founders have no inbreeding relative to the reference.
  f3 <- if (i >= 4L) cousin[i - 3L] else 0
  cousin[i] <- (1 + 12 * cousin[i - 1L] + 2 * cousin[i - 2L] + f3) / 16
}

mating_order <- c("Self-fertilisation", "Full-sib mating", "Half-sib mating",
                  "First-cousin mating", "Unrelated mating")
trajectories <- cbind(self, full, half, cousin, unrelated = rep(0, n_gen + 1L))
stopifnot(all(trajectories >= 0), all(trajectories <= 1),
          all(apply(trajectories, 2, function(x) all(diff(x) >= 0))),
          isTRUE(all.equal(self, 1 - 0.5^(0:n_gen))))

df <- data.frame(
  generation = rep(0:n_gen, times = length(mating_order)),
  mating = factor(rep(mating_order, each = n_gen + 1L), levels = mating_order),
  F = as.vector(trajectories)
)
annotations <- df[df$generation == 1 & df$mating != "Unrelated mating", ]
annotations$label <- c("0.5", "0.25", "0.125", "0.0625")
cols <- stats::setNames(c(bb512$blue, bb512$clay, bb512$forest,
                          bb512$gold, bb512$grey), mating_order)
linetypes <- stats::setNames(c(rep("solid", 4), "dashed"), mating_order)

p <- ggplot2::ggplot(df, ggplot2::aes(generation, F, colour = mating)) +
  ggplot2::geom_line(ggplot2::aes(linetype = mating), linewidth = 1.2) +
  ggplot2::geom_point(size = 2.5) +
  ggplot2::geom_text(data = annotations, ggplot2::aes(label = label),
                     nudge_x = -0.15, nudge_y = 0.025, hjust = 1,
                     size = 4.2, family = "Avenir Next", show.legend = FALSE) +
  ggplot2::scale_colour_manual(values = cols, name = NULL) +
  ggplot2::scale_linetype_manual(values = linetypes, name = NULL) +
  ggplot2::scale_x_continuous(breaks = 0:n_gen,
                              expand = ggplot2::expansion(mult = c(0.015, 0.02))) +
  ggplot2::scale_y_continuous(breaks = seq(0, 1, 0.2), limits = c(0, 1.05),
                              expand = ggplot2::expansion(mult = c(0.015, 0))) +
  ggplot2::labs(x = "Generation of repeated mating", y = "Inbreeding\ncoefficient (F)") +
  theme_bb512() +
  ggplot2::guides(colour = ggplot2::guide_legend(nrow = 2, byrow = TRUE),
                   linetype = ggplot2::guide_legend(nrow = 2, byrow = TRUE))

save_bb512(p, "07_repeated_relative_mating", layout = "fullbox")
