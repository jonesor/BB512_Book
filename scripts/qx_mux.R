life_table_plot <- rbind(
  life_table,
  data.frame(age = 10, qx = tail(life_table$qx, 1))
)

p2 <- ggplot(life_table_plot, aes(age, qx)) +
  geom_step(
    direction = "hv",
    linewidth = 1.3,
    colour = "#0072B2"
  ) +
  labs(
    x = "Age",
    y = expression("Probability of death, " * q[x]),
    title = "Probability of death"
  ) +
  scale_x_continuous(
    breaks = 0:10,
    limits = c(0, 10),
    expand = c(0, 0)
  ) +
  scale_y_continuous(
    limits = c(0, 1),
    breaks = seq(0, 1, 0.2),
    expand = c(0, 0)
  ) +
  theme_classic(base_size = 16)

p2 / p1
