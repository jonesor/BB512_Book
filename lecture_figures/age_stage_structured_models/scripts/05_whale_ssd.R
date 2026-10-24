# Stable stage distribution of the killer whale model (dominant right eigenvector).
# Analytical, from the empirical matrix of Brault & Caswell (1993).
source("R/theme_bb512.R"); source("R/mpm_models.R")
library(ggplot2)
w <- mpm_ssd(A_whale)
d <- data.frame(stage = factor(names(w), levels = whale_stages), p = as.numeric(w))
p <- ggplot(d, aes(stage, p)) +
  geom_col(fill = bb512$forest, width = 0.65) +
  geom_text(aes(label = scales::percent(p, accuracy = 1)), vjust = -0.4, size = 6,
            family = "Avenir Next", fontface = "bold", colour = bb512$ink) +
  scale_y_continuous(labels = scales::percent, limits = c(0, 0.4), breaks = seq(0, 0.4, 0.1)) +
  scale_x_discrete(labels = c("Yearling", "Juvenile", "Mature", "Post-\nreproductive")) +
  labs(x = NULL, y = "Share of females") +
  theme_bb512()
save_bb512(p, "05_whale_ssd", layout = "takeaway")
