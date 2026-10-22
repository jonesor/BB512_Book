# Two-way mutation A <-> a approaches q_hat = mu/(mu+nu), but very slowly.
# mu = 1e-5 (A -> a), nu = 1e-6 (a -> A): q_hat = 0.909.
source("R/theme_bb512.R")

mu <- 1e-5; nu <- 1e-6
q_hat <- mu / (mu + nu)
t <- seq(0, 6e5, by = 1000)
traj <- function(q0) q_hat + (q0 - q_hat) * (1 - mu - nu)^t
df <- rbind(data.frame(t = t, q = traj(0), start = "Start: all A"),
            data.frame(t = t, q = traj(1), start = "Start: all a"))

p <- ggplot2::ggplot(df, ggplot2::aes(t / 1000, q, colour = start)) +
  ggplot2::geom_hline(yintercept = q_hat, linetype = "dashed",
                      colour = bb512$grey, linewidth = 0.7) +
  ggplot2::geom_line(linewidth = 1.5) +
  ggplot2::annotate("text", x = 600, y = q_hat - 0.07, hjust = 1,
                    label = "hat(q) == 0.91", parse = TRUE,
                    colour = bb512$grey, size = 5.4) +
  ggplot2::scale_colour_manual(values = c(bb512$forest, bb512$clay), name = NULL) +
  ggplot2::scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
  ggplot2::labs(x = "Generations (thousands)", y = "Frequency of allele a") +
  theme_bb512()

save_bb512(p, "03b_reversible_equilibrium", layout = "takeaway")
cat(sprintf("q_hat = %.3f; half-way time = %.0f generations\n",
            q_hat, log(0.5) / log(1 - mu - nu)))
