# Slide 18: Fate of a newly arisen neutral allele in finite populations.
# N = 20 deliberately makes rare fixation events visible in a teaching plot.
source("R/theme_bb512.R")
source("R/simulations.R")
set.seed(51202)

N <- 20L
n_rep <- 600L
generations <- 220L
p0 <- 1 / (2 * N)
df <- simulate_wf(N = N, generations = generations, replicates = n_rep,
                  p0 = p0, s = 0)

end_state <- df[df$generation == generations, c("replicate", "frequency")]
fixed <- as.character(end_state$replicate[end_state$frequency == 1])
lost  <- as.character(end_state$replicate[end_state$frequency == 0])
if (length(fixed) == 0) stop("No fixation in simulation. Increase n_rep.")

# The background paths are ALL replicates. Two overlaid paths illustrate
# outcomes, but must not be read as equally likely.
fixed_id <- fixed[1L]
lost_id <- lost[1L]
exemplars <- df[as.character(df$replicate) %in% c(fixed_id, lost_id), ]
exemplars$outcome <- ifelse(as.character(exemplars$replicate) == fixed_id,
                            "Rare fixation", "Loss")

p <- ggplot2::ggplot(df,
                     ggplot2::aes(generation, frequency, group = replicate)) +
  ggplot2::geom_line(colour = bb512$sage, alpha = 0.14, linewidth = 0.35) +
  ggplot2::geom_line(data = exemplars,
                     ggplot2::aes(colour = outcome), linewidth = 1.4) +
  ggplot2::scale_colour_manual(values = c("Rare fixation" = bb512$clay,
                                           "Loss" = bb512$blue),
                                name = NULL) +
  ggplot2::scale_y_continuous(limits = c(0, 1), breaks = c(0, 0.25, 0.5, 0.75, 1)) +
  ggplot2::labs(x = "Generations", y = "New allele frequency") +
  theme_bb512()

save_bb512(p, "02_neutral_mutation_fate", layout = "takeaway")
cat(sprintf("N = %d, initial p = 1/(2N) = %.3f; theoretical fixation probability = %.3f\n",
            N, p0, p0))
cat(sprintf("Observed fixed: %d of %d (simulation will vary with seed)\n",
            length(fixed), n_rep))
