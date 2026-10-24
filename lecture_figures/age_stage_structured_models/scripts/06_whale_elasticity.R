# Elasticities of lambda to each element of the killer whale matrix, laid out as the matrix.
# Analytical, from the empirical matrix of Brault & Caswell (1993).
source("R/theme_bb512.R"); source("R/mpm_models.R")
library(ggplot2)
E <- mpm_elas(A_whale)
short <- c("Yearl.", "Juv.", "Mature", "Post-r.")
d <- expand.grid(to = seq_along(short), from = seq_along(short))
d$e <- E[cbind(d$to, d$from)]; d$a <- A_whale[cbind(d$to, d$from)]
d <- d[d$a > 0, ]
d$lab <- ifelse(d$e == 0, "0", ifelse(d$e < 0.01, "<0.01", formatC(d$e, format = "f", digits = 2)))
p <- ggplot(d, aes(from, to)) +
  geom_tile(aes(fill = e), width = 0.94, height = 0.94) +
  geom_text(aes(label = lab, colour = e > 0.2), size = 6, family = "Avenir Next", fontface = "bold") +
  scale_fill_gradient(low = bb512$pale, high = bb512$forest, guide = "none") +
  scale_colour_manual(values = c(`TRUE` = "white", `FALSE` = bb512$ink), guide = "none") +
  scale_x_continuous(breaks = 1:4, labels = short, position = "top", expand = c(0, 0)) +
  scale_y_reverse(breaks = 1:4, labels = short, expand = c(0, 0)) +
  coord_fixed() +
  labs(x = "From (stage this year)", y = "To (stage next year)") +
  theme_bb512() +
  theme(panel.grid.major.y = element_blank(), axis.line = element_blank())
save_bb512(p, "06_whale_elasticity", layout = "takeaway")
