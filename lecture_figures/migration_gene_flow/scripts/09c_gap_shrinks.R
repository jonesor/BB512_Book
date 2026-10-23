# Model 1: the gap between island and mainland, q_m - q_t, shrinks by a factor (1 - m)
# every generation (Neal Eqn 9.2). Analytical; Neal Example 9.2 values (q0 = 0, qm = 1,
# m = 0.05).
source("R/theme_bb512.R")
library(ggplot2)
fam <- bb512_font()
m <- 0.05
t <- 0:10
d <- data.frame(t = t, gap = (1 - m)^t * (1 - 0))
lab <- d[d$t %in% 0:3, ]
p <- ggplot(d, aes(t, gap)) +
  geom_col(fill = bb512$forest, width = 0.75) +
  geom_col(data = d[d$t <= 3, ], fill = bb512$clay, width = 0.75) +
  geom_text(data = lab, aes(label = formatC(gap, format = "f", digits = 2)), vjust = -0.5,
            colour = bb512$clay, size = 4.4, family = fam) +
  annotate("text", x = 10.3, y = 1.04, hjust = 1, colour = bb512$ink, size = 5, family = fam,
           label = "× 0.95 each generation") +
  scale_x_continuous(breaks = seq(0, 10, 2), expand = expansion(add = 0.6)) +
  scale_y_continuous(limits = c(0, 1.08), breaks = seq(0, 1, 0.25)) +
  labs(x = "Generation", y = expression("Gap to mainland, "*q[m] - q[t])) +
  theme_bb512()
save_bb512(p, "09c_gap_shrinks", layout = "half")
