# Slide "Haldane's estimate": spread of carbonaria in Manchester, 1848-1898.
# Empirical anchor points: Haldane's (1924) figures as given by Neal (2004, section 11.2.1):
# carbonaria ~1% of moths in 1848 and ~99% in 1898 (one generation per year).
# Model: Case C (carbonaria dominant, selection against typica cc), deterministic iteration.
# The selection coefficient is solved exactly by iteration (s ~ 0.30); Neal's approximate
# Eqn 10.11 gives 0.33. Shown: exact-s trajectory (forest) and approximate-s trajectory (grey dashed).
source("R/theme_bb512.R"); source("R/models.R")
fam <- "Avenir Next"
q0 <- sqrt(0.99); qt <- sqrt(0.01); G <- 50
s_exact <- uniroot(function(s) iterate(q0, G, zygotic_step, 1, 1, 1 - s)[G + 1] - qt, c(0.01, 0.99))$root
s_appr <- ((q0 - qt)/(q0*qt) + log(q0*(1-qt)/(qt*(1-q0)))) / G
traj <- function(s, lab) { q <- iterate(q0, G, zygotic_step, 1, 1, 1 - s)
  data.frame(year = 1848:1898, carb = 100 * (1 - q^2), m = lab) }
df <- rbind(traj(s_exact, "exact"), traj(s_appr, "approx"))
pts <- data.frame(year = c(1848, 1898), carb = c(1, 99))
p <- ggplot2::ggplot(df, ggplot2::aes(year, carb)) +
  ggplot2::geom_line(data = df[df$m == "approx", ], linewidth = 1, linetype = "dashed", colour = bb512$grey) +
  ggplot2::geom_line(data = df[df$m == "exact", ], linewidth = 1.4, colour = bb512$forest) +
  ggplot2::geom_point(data = pts, size = 4.5, colour = bb512$clay) +
  ggplot2::annotate("text", x = 1872, y = 45, hjust = 0, family = fam, size = 5.2, colour = bb512$forest,
                    label = sprintf("Model, s = %.2f", s_exact)) +
  ggplot2::annotate("text", x = 1872, y = 66, hjust = 0, family = fam, size = 5, colour = bb512$grey,
                    label = sprintf("Dashed: s = %.2f\n(Neal's approximation)", s_appr), lineheight = 0.9) +
  ggplot2::annotate("text", x = c(1862, 1896), y = c(4, 90), hjust = c(0, 1), family = fam, size = 5,
                    colour = bb512$clay, label = c("1848: ~1%", "1898: ~99%")) +
  ggplot2::scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 25)) +
  ggplot2::scale_x_continuous(breaks = seq(1850, 1900, 10)) +
  ggplot2::labs(x = "Year (one generation per year)", y = expression(italic(carbonaria) ~ "moths (%)")) +
  theme_bb512()
save_bb512(p, "10_haldane_carbonaria", layout = "takeaway")
cat(sprintf("s exact = %.4f; s approx = %.4f\n", s_exact, s_appr))
