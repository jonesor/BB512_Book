# Slide 10: Continent–island model, analytical (Neal Eqn 9.2), no drift or selection.
# Neal Example 9.2: sweet clover. Island q0 = 0 (white-flowered), mainland qm = 1
# (yellow-flowered allele), m = 0.05 highlighted; 0.01 and 0.2 for comparison.
source("R/theme_bb512.R"); source("R/models.R")
library(ggplot2)
fam <- bb512_font()
G <- 60
ms <- c(0.01, 0.05, 0.2)
d <- do.call(rbind, lapply(ms, function(m) cbind(continent_island(0, 1, m, G), m = m)))
d$focal <- d$m == 0.05
t_half <- generations_to(0, 1, 0.05, 0.5)  # 13.5
lab <- data.frame(x = c(60, 14, 34), y = c(0.32, 0.86, 0.70),
                  label = c("m = 0.01", "m = 0.2", "m = 0.05"),
                  col = c(bb512$grey, bb512$grey, bb512$forest))
p <- ggplot(d, aes(generation, q, group = m)) +
  geom_hline(yintercept = 0.5, linetype = "dashed", colour = bb512$grey, linewidth = 0.6) +
  geom_line(data = d[!d$focal, ], colour = bb512$sage, linewidth = 1.2) +
  geom_line(data = d[d$focal, ], colour = bb512$forest, linewidth = 1.5) +
  annotate("point", x = t_half, y = 0.5, colour = bb512$clay, size = 3.6) +
  annotate("text", x = t_half + 1.5, y = 0.42, label = "q = 0.5 after 13.5 generations",
           hjust = 0, colour = bb512$clay, size = 5.2, family = fam) +
  geom_text(data = lab, aes(x, y, label = label, colour = I(col)), inherit.aes = FALSE,
            hjust = c(1, 0, 0), size = 5.2, family = fam) +
  scale_x_continuous(breaks = seq(0, 60, 10), expand = expansion(mult = c(0.01, 0.02))) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
  labs(x = "Generations of immigration", y = expression("Allele frequency on island, "*q[t])) +
  theme_bb512()
save_bb512(p, "10_continent_island_curve", layout = "takeaway")
