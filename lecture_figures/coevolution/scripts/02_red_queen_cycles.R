# 02_red_queen_cycles.R  (slide "Rare hosts escape, parasites follow", layout = "takeaway")
# SIMULATED: matching-alleles model (R/models.R), sh = 0.3, sp = 0.6, mu = 0.005,
# starting at host allele frequency 0.7, parasite 0.5. Deterministic.
# Host peaks are followed by parasite peaks about 7 generations later (period ~30).
source("R/theme_bb512.R"); source("R/models.R")
library(ggplot2)
FAM <- getOption("bb512.family", "Avenir Next")

rq <- sim_matching_alleles(gens = 120)
peaks <- function(x) which(diff(sign(diff(x))) == -2) + 1
hp <- peaks(rq$host); pp <- peaks(rq$parasite)
h1 <- hp[hp > 20][1]; p1 <- pp[pp > h1][1]       # a host peak and the following parasite peak
cat("host peak at gen", rq$generation[h1], "; parasite peak at gen", rq$generation[p1], "\n")

g <- ggplot(rq, aes(generation)) +
  geom_hline(yintercept = 0.5, colour = bb512$grey, linetype = "dashed", linewidth = 0.6) +
  geom_line(aes(y = parasite), colour = bb512$clay, linewidth = 1.4) +
  geom_line(aes(y = host), colour = bb512$forest, linewidth = 1.4) +
  annotate("segment", x = rq$generation[h1], xend = rq$generation[p1],
           y = 1.0, yend = 1.0, colour = bb512$gold, linewidth = 1,
           arrow = grid::arrow(length = grid::unit(0.12, "in"))) +
  annotate("text", x = rq$generation[p1] + 2, y = 1.0, label = "time lag",
           hjust = 0, colour = bb512$gold, size = 5.2, family = FAM) +
  annotate("text", x = 0, y = 1.17, label = "Host allele", hjust = 0,
           colour = bb512$forest, size = 5.5, family = FAM) +
  annotate("text", x = 40, y = 1.17, label = "Matching parasite allele", hjust = 0,
           colour = bb512$clay, size = 5.5, family = FAM) +
  scale_y_continuous(limits = c(0, 1.22), breaks = c(0, 0.5, 1)) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.01))) +
  labs(x = "Generation", y = "Allele frequency") +
  theme_bb512()
save_bb512(g, "02_red_queen_cycles", layout = "takeaway")
