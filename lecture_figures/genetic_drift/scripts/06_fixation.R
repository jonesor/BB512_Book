# Slide: "Result 1: a neutral allele fixes with probability equal to its frequency"
# (Title, Bullets & Photo, "takeaway"). Simulated Wright-Fisher drift of a NEW neutral
# mutation: N = 10, so it starts at 1/(2N) = 1/20. We run 2N = 20 replicates and
# search for a seed in which exactly one fixes, matching the expectation 1/(2N).
# This is an illustrative choice of seed, disclosed in the speaker notes.
source("R/theme_bb512.R"); source("R/drift_helpers.R"); library(ggplot2)
N <- 10; n_rep <- 2 * N; n_gen <- 80
seed <- NA
for (s in 1:5000) {                        # guarded search
  set.seed(s); d <- wf_drift(N, 1 / (2 * N), n_gen, n_rep)
  fin <- d$p[d$generation == n_gen]
  if (sum(fin == 1) == 1 && all(fin %in% c(0, 1))) { seed <- s; break }
}
if (is.na(seed)) stop("No seed found")
message("Seed used: ", seed)
writeLines(as.character(seed), "figures/06_fixation_seed.txt")
fixed_rep <- d$rep[d$generation == n_gen & d$p == 1]
d$fate <- ifelse(d$rep == fixed_rep, "fixed", "lost")

fig <- ggplot(d, aes(generation, p, group = rep, colour = fate, linewidth = fate)) +
  geom_line(data = d[d$fate == "lost", ], alpha = 0.6) +
  geom_line(data = d[d$fate == "fixed", ]) +
  scale_colour_manual(values = c(fixed = bb512$clay, lost = bb512$blue), guide = "none") +
  scale_linewidth_manual(values = c(fixed = 1.5, lost = 0.7), guide = "none") +
  bb_text(x = n_gen * 0.62, y = 0.88, label = "Fixed in 1 of 20 populations", colour = bb512$clay,
          size = 6, fontface = "bold") +
  bb_text(x = n_gen * 0.75, y = 0.14, label = "Lost in 19 of 20", colour = bb512$blue, size = 6) +
  scale_y_continuous(breaks = c(0, 0.5, 1)) +
  labs(x = "Generation", y = "Frequency of new allele") +
  theme_bb512()
save_bb512(fig, "06_fixation", layout = "takeaway")
