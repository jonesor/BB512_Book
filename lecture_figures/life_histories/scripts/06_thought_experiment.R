# Slides "A thought experiment" (two builds): why selection cares less about late life.
# ANALYTICAL, fictional organism kept from the previous version of the lecture (and used, with 25 ages,
# in the practical "Trade-offs and the declining force of selection"):
#   first breeds at age 1, annual survival 0.8, 10 offspring per year, at most 25 breeding ages
#   (the same 25 ages as the practical and its spreadsheet).
# Bars: expected offspring at each age, l_x m_x. Their sum is R0 (fitness).
# 06a: the normal life history (R0 = 49.81, as in the practical).
# 06b: a mutant with one extra offspring at age 1 that dies before breeding at age 25 (R0 = 50.76,
#      the practical's first task).
source("R/theme_bb512.R")
fam <- "Avenir Next"

s <- 0.8; m <- 10; ages <- 1:25; last <- max(ages)
lx <- s^(ages - 1)
d <- data.frame(age = ages, y = lx * m)
R0 <- sum(d$y)
R0m <- R0 + 1 * lx[1] - lx[last] * m

base_plot <- function(dd) {
  ggplot2::ggplot(dd, ggplot2::aes(age, y)) +
    ggplot2::geom_col(fill = bb512$forest, width = 0.75) +
    ggplot2::scale_x_continuous("Age (years)", breaks = c(1, 5, 10, 15, 20, 25), expand = c(0.01, 0)) +
    ggplot2::scale_y_continuous("Expected offspring\nat this age", limits = c(0, 12.2),
                                breaks = seq(0, 12, 4), expand = c(0, 0)) +
    theme_bb512(base_family = fam)
}
total_label <- function(txt) {
  ggplot2::annotate("text", x = last + 0.3, y = 10.6, label = txt, parse = TRUE, hjust = 1,
                    family = fam, size = 6.2, colour = bb512$ink)
}

pa <- base_plot(d) +
  total_label(sprintf("paste('Lifetime total:  ', R[0], ' = %.2f')", R0)) +
  ggplot2::annotate("text", x = 4.6, y = 6.2,
                    label = "Most offspring come early:\nfew individuals are still alive at 15+",
                    hjust = 0, family = fam, size = 5, colour = bb512$grey, lineheight = 0.95)

dm <- d[d$age < last, ]
pb <- base_plot(dm) +
  ggplot2::annotate("rect", xmin = 0.625, xmax = 1.375, ymin = 10, ymax = 11, fill = bb512$gold) +
  ggplot2::annotate("rect", xmin = last - 0.375, xmax = last + 0.375, ymin = 0, ymax = lx[last] * m, fill = NA,
                    colour = bb512$clay, linewidth = 0.8, linetype = "dashed") +
  total_label(sprintf("paste('Mutant:  ', R[0], ' = %.2f')", R0m)) +
  ggplot2::annotate("text", x = 2.0, y = 11.55, label = "+1 offspring at age 1 (gain 1.00)", hjust = 0,
                    family = fam, size = 5, colour = bb512$gold, fontface = "bold") +
  ggplot2::annotate("text", x = last - 0.5, y = 3.4, label = sprintf("Dies before age %d\n(loses %.2f)", last, lx[last] * m),
                    hjust = 1, family = fam, size = 5, colour = bb512$clay, fontface = "bold", lineheight = 0.95) +
  ggplot2::annotate("segment", x = last - 0.45, xend = last - 0.05, y = 2.6, yend = 0.4, colour = bb512$clay,
                    linewidth = 0.6)

save_bb512(pa, "06a_thought_experiment_normal", layout = "full")
save_bb512(pb, "06b_thought_experiment_mutant", layout = "full")
