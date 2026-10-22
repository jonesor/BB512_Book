# Slide "The decline of carbonaria": West Kirby (near Liverpool), after the Clean Air Acts.
# Empirical: carbonaria 93% (1959), 84% (1976), 33% (1990), from Neal (2004) section 11.2.1.
# Model: Case D (selection against the dominant carbonaria allele), deterministic iteration,
# one generation per year, s fitted exactly to the 1959 and 1990 points (s ~ 0.15).
# Neal's approximate Eqn 10.14 gives 0.16 for 1959-1990.
source("R/theme_bb512.R"); source("R/models.R")
fam <- "Avenir Next"
obs <- data.frame(year = c(1959, 1976, 1990), carb = c(93, 84, 33))
q <- 1 - sqrt(1 - obs$carb / 100)   # q = carbonaria allele; typica (cc) = p^2
G <- 1990 - 1959
s <- uniroot(function(s) iterate(q[1], G, zygotic_step, 1, 1 - s, 1 - s)[G + 1] - q[3], c(0.001, 0.9))$root
qq <- iterate(q[1], G, zygotic_step, 1, 1 - s, 1 - s)
mod <- data.frame(year = 1959:1990, carb = 100 * (1 - (1 - qq)^2))
p <- ggplot2::ggplot() +
  ggplot2::geom_line(data = mod, ggplot2::aes(year, carb), linewidth = 1.4, colour = bb512$grey) +
  ggplot2::geom_point(data = obs, ggplot2::aes(year, carb), size = 5, colour = bb512$clay) +
  ggplot2::annotate("text", x = 1962, y = 45, hjust = 0, family = fam, size = 5.2, colour = bb512$grey,
                    label = sprintf("Model: selection against\ncarbonaria, s = %.2f", s), lineheight = 0.9) +
  ggplot2::annotate("text", x = obs$year + c(0, 0, -1), y = obs$carb + c(6, 6, -8), family = fam, size = 5,
                    colour = bb512$clay, label = paste0(obs$carb, "%")) +
  ggplot2::scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 25)) +
  ggplot2::scale_x_continuous(breaks = seq(1960, 1990, 10)) +
  ggplot2::labs(x = "Year", y = expression(italic(carbonaria) ~ "moths (%)")) +
  theme_bb512()
save_bb512(p, "12_west_kirby", layout = "takeaway")
cat(sprintf("fitted s = %.4f; model 1976 = %.1f%%\n", s, mod$carb[mod$year == 1976]))
