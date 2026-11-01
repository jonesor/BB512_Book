# 05_copes_rule_passive.R  (slide "Cope's rule: escalation in body size?", layout = "takeaway")
# SIMULATED, illustrative. 300 lineages evolve log body size by a random walk
# for 200 time steps, all starting just above a lower size limit (0).
#   Driven: each step has a small upward bias (mean +0.03, sd 0.25).
#   Passive: no bias (mean 0, sd 0.25), but size cannot go below the limit
#            (reflecting boundary), as in Stanley (1973) and McShea (1994).
# Point: the mean rises in both, so a rising average alone cannot show that
# selection (for example escalation) favoured large size.
source("R/theme_bb512.R")
library(ggplot2)
FAM <- getOption("bb512.family", "Avenir Next")
set.seed(16)
n_lin <- 300; n_t <- 200; sd_step <- 0.25
walk <- function(bias) {
  x <- matrix(0, n_t, n_lin); x[1, ] <- 0.2
  for (t in 2:n_t) x[t, ] <- abs(x[t - 1, ] + rnorm(n_lin, bias, sd_step))  # reflect at 0
  x
}
summ <- function(x, label) data.frame(time = seq_len(n_t) - 1, mean = rowMeans(x),
  lo = apply(x, 1, quantile, 0.1), hi = apply(x, 1, quantile, 0.9), model = label)
d <- rbind(summ(walk(0.03), "Selection for large size"),
           summ(walk(0), "No selection, size floor"))
d$model <- factor(d$model, levels = c("Selection for large size", "No selection, size floor"))
cat("final mean size, driven:", round(tail(d$mean[d$model == unique(d$model)[1]], 1), 2),
    " passive:", round(tail(d$mean[d$model == unique(d$model)[2]], 1), 2), "\n")
g <- ggplot(d, aes(time)) +
  geom_ribbon(aes(ymin = lo, ymax = hi), fill = bb512$sage, alpha = 0.45) +
  geom_line(aes(y = mean), colour = bb512$forest, linewidth = 1.4) +
  geom_hline(yintercept = 0, colour = bb512$clay, linewidth = 0.8, linetype = "dashed") +
  facet_wrap(~model, ncol = 2) +
  geom_text(data = data.frame(time = 199, y = 0.12, model = factor("No selection, size floor", levels = levels(d$model))),
            aes(y = y, label = "size floor"), hjust = 1, vjust = 0, size = 5, family = FAM, colour = bb512$clay) +
  labs(x = "Time", y = "Body size (log scale)") +
  theme_bb512() + theme(axis.text = element_blank(), panel.spacing = unit(1.5, "lines"))
save_bb512(g, "05_copes_rule_passive", layout = "takeaway")
