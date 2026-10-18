# Slide 35: Heterozygote advantage (overdominance).
# Illustrative relative fitnesses, NOT measured human malaria coefficients.
source("R/theme_bb512.R")
source("R/simulations.R")

wAA <- 0.88  # HbA/HbA: malaria disadvantage in this stylised environment
wAS <- 1.00  # HbA/HbS: heterozygote advantage
wSS <- 0.15  # HbS/HbS: severe sickle-cell disease disadvantage
q_equilibrium <- (wAS - wAA) / (2*wAS - wAA - wSS)

fitness <- data.frame(
  genotype = factor(c("HbA/HbA", "HbA/HbS", "HbS/HbS"),
                    levels = c("HbA/HbA", "HbA/HbS", "HbS/HbS")),
  relative_fitness = c(wAA, wAS, wSS)
)
p_fitness <- ggplot2::ggplot(fitness, ggplot2::aes(genotype, relative_fitness)) +
  ggplot2::geom_col(fill = c(bb512$blue, bb512$forest, bb512$clay), width = 0.63) +
  ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", relative_fitness)),
                     vjust = -0.5, size = 5.5, colour = bb512$ink) +
  ggplot2::scale_y_continuous(limits = c(0, 1.12), breaks = seq(0, 1, 0.25)) +
  ggplot2::labs(x = "Genotype", y = "Relative fitness (illustrative)") +
  theme_bb512() +
  ggplot2::theme(panel.grid.major.x = ggplot2::element_blank())
save_bb512(p_fitness, "07a_heterozygote_advantage_fitness", layout = "half")

# Under deterministic viability selection, all initial polymorphic
# populations approach an internal equilibrium when the heterozygote is fittest.
starting_q <- c(0.02, 0.07, 0.30, 0.70)
generations <- 70L
curves <- do.call(rbind, lapply(starting_q, function(q0) {
  q <- numeric(generations + 1L)
  q[1] <- q0
  for (t in seq_len(generations)) {
    q[t + 1] <- viability_step(q[t], wAA, wAS, wSS)
  }
  data.frame(generation = 0:generations, q_S = q,
             initial_q = factor(sprintf("%.2f", q0),
                                levels = sprintf("%.2f", starting_q)))
}))
p_eq <- ggplot2::ggplot(curves,
                        ggplot2::aes(generation, q_S, colour = initial_q)) +
  ggplot2::geom_hline(yintercept = q_equilibrium, linetype = "dashed",
                      linewidth = 0.75, colour = bb512$grey) +
  ggplot2::geom_line(linewidth = 1.2) +
  ggplot2::scale_colour_manual(
    values = stats::setNames(c(bb512$blue, bb512$forest, bb512$gold, bb512$clay),
                             levels(curves$initial_q)),
    name = "Starting HbS frequency") +
  ggplot2::scale_y_continuous(limits = c(0, 0.75), breaks = seq(0, 0.75, 0.15)) +
  ggplot2::labs(x = "Generations", y = "Frequency of HbS (q)") +
  theme_bb512()
save_bb512(p_eq, "07b_heterozygote_advantage_equilibrium", layout = "full")
cat(sprintf("Illustrative stable HbS frequency = %.4f\n", q_equilibrium))
