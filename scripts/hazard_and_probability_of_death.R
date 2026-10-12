library(ggplot2)

# Probability of death
q <- seq(0, 0.999, length.out = 500)

# Corresponding hazard (force of mortality)
mu <- -log(1 - q)

dat <- data.frame(q, mu)

ggplot(dat, aes(x = q, y = mu)) +
  
  # Hazard corresponding to each probability
  geom_line(
    linewidth = 1.4,
    colour = "#E76F51"
  ) +
  
  # 1:1 reference line
  geom_abline(
    slope = 1, intercept = 0,
    linetype = "dashed",
    linewidth = 0.8,
    colour = "grey45"
  ) +
  
  annotate(
    "text",
    x = 0.28, y = 0.16,
    label = "At low mortality:\nqₓ ≈ μₓ",
    hjust = 0,
    size = 5
  ) +
  
  annotate(
    "text",
    x = 0.67, y = 4.8,
    label = "Probability is bounded at 1,\nbut hazard can keep increasing",
    hjust = 0,
    size = 5
  ) +
  
  scale_x_continuous(
    limits = c(0, 1),
    breaks = seq(0, 1, 0.2),
    expand = c(0, 0)
  ) +
  
  coord_cartesian(ylim = c(0, 7)) +
  
  labs(
    x = expression("Probability of death, " * q[x]),
    y = expression("Force of mortality, " * mu[x])
  ) +
  
  theme_classic(base_size = 17) +
  
  theme(
    axis.title = element_text(size = 18),
    axis.text = element_text(size = 14)
  )