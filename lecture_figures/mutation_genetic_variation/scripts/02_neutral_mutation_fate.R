# Fate of new neutral mutations in a finite population.
# One new copy in each of 2N = 40 replicate populations (N = 20).
# Expected number that fix = 2N * 1/(2N) = 1; the seed is chosen so that
# exactly one does, making the 1/(2N) rule visible directly.
source("R/theme_bb512.R")
source("R/simulations.R")

N <- 20L
n_rep <- 2L * N
generations <- 160L
p0 <- 1 / (2 * N)

seed <- 1L
repeat {
  set.seed(seed)
  df <- simulate_wf(N = N, generations = generations, replicates = n_rep,
                    p0 = p0, s = 0)
  end <- df[df$generation == generations, ]
  if (sum(end$frequency == 1) == 1 && all(end$frequency %in% c(0, 1))) break
  seed <- seed + 1L
}
fixed_id <- as.character(end$replicate[end$frequency == 1])
df$outcome <- ifelse(as.character(df$replicate) == fixed_id, "fixed", "lost")
n_lost <- sum(end$frequency == 0)

p <- ggplot2::ggplot(df, ggplot2::aes(generation, frequency, group = replicate)) +
  ggplot2::geom_line(data = df[df$outcome == "lost", ],
                     colour = bb512$blue, alpha = 0.45, linewidth = 0.6) +
  ggplot2::geom_line(data = df[df$outcome == "fixed", ],
                     colour = bb512$clay, linewidth = 1.5) +
  ggplot2::annotate("text", x = generations, y = 0.93, hjust = 1,
                    label = "1 fixed", colour = bb512$clay, size = 5.6,
                    fontface = "bold") +
  ggplot2::annotate("text", x = generations, y = 0.08, hjust = 1,
                    label = sprintf("%d lost", n_lost), colour = bb512$blue,
                    size = 5.6, fontface = "bold") +
  ggplot2::scale_y_continuous(limits = c(0, 1), breaks = c(0, 0.25, 0.5, 0.75, 1)) +
  ggplot2::labs(x = "Generations", y = "New allele frequency") +
  theme_bb512()

save_bb512(p, "02_neutral_mutation_fate", layout = "takeaway")
cat(sprintf("seed %d: N = %d, %d new mutations, 1 fixed, %d lost\n",
            seed, N, n_rep, n_lost))
