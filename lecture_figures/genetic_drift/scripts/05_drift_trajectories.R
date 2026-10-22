# Slide: "Small populations drift faster" (Title & Photo, "full")
# Simulated Wright-Fisher drift, p0 = 0.5, 20 replicates, 60 generations,
# N = 10 vs N = 100. Lines coloured by outcome at generation 60.
source("R/theme_bb512.R"); source("R/drift_helpers.R"); library(ggplot2)
n_gen <- 60; n_rep <- 20
labs2 <- c("N = 10", "N = 100")
# Illustrative seed: search (guarded) for a run that shows the typical contrast,
# i.e. no N = 100 replicate fixed or lost by generation 60 (expected absorption time
# from p = 0.5 is about 4N ln 2 = 2.8N, i.e. ~280 generations; P(all 20 still
# variable) = 0.55), AND 2-4 of the N = 10 replicates still variable (typical is
# about 1, so this panel is chosen to show all three outcomes). Seed recorded in
# figures/05_drift_trajectories_seed.txt and in the speaker notes.
for (seed in 2026:7026) {
  set.seed(seed)
  d <- rbind(cbind(wf_drift(10, 0.5, n_gen, n_rep), pop = labs2[1]),
             cbind(wf_drift(100, 0.5, n_gen, n_rep), pop = labs2[2]))
  e10 <- d$p[d$pop == labs2[1] & d$generation == n_gen]
  e100 <- d$p[d$pop == labs2[2] & d$generation == n_gen]
  if (all(e100 > 0 & e100 < 1) && sum(e10 > 0 & e10 < 1) %in% 2:4) break
}
message("Seed used: ", seed)
dir.create("figures", showWarnings = FALSE)
writeLines(as.character(seed), "figures/05_drift_trajectories_seed.txt")
d$pop <- factor(d$pop, levels = labs2)
end <- d[d$generation == n_gen, ]
end$outcome <- ifelse(end$p == 1, "Fixed", ifelse(end$p == 0, "Lost", "Still variable"))
d <- merge(d, end[, c("pop", "rep", "outcome")])
cnt <- aggregate(rep ~ pop + outcome, end, length)
lab <- do.call(rbind, lapply(split(cnt, cnt$pop), function(z) {
  get <- function(o) if (o %in% z$outcome) z$rep[z$outcome == o] else 0
  data.frame(pop = z$pop[1], label = sprintf("Fixed %d  ·  Lost %d  ·  Variable %d",
             get("Fixed"), get("Lost"), get("Still variable")))
}))
print(lab)
cols <- c(Fixed = bb512$clay, Lost = bb512$blue, "Still variable" = bb512$sage)

fig <- ggplot(d, aes(generation, p, group = interaction(pop, rep), colour = outcome)) +
  geom_line(linewidth = 0.9, alpha = 0.85) +
  geom_text(data = lab, aes(x = n_gen / 2, y = 1.13, label = label), inherit.aes = FALSE,
            size = 5, colour = bb512$ink, family = .bb512_font) +
  facet_wrap(~pop) +
  scale_colour_manual(values = cols, guide = "none") +
  scale_y_continuous(breaks = c(0, 0.5, 1), limits = c(0, 1.18)) +
  labs(x = "Generation", y = expression("Frequency of " * italic(A))) +
  theme_bb512() + theme(panel.spacing = unit(2, "lines"))
save_bb512(fig, "05_drift_trajectories", layout = "full")
